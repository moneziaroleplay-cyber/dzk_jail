local ESX = exports['es_extended']:getSharedObject()
local jailedPlayers = {}
local recentUnjails = {} 
local jailHistory = {} -- Garde tout jusqu'au reboot

local GithubRepo = "moneziaroleplay-cyber/dzk_jail"

Citizen.CreateThread(function()
    Citizen.Wait(5000)
    local resourceName = GetCurrentResourceName()
    local localVersion = GetResourceMetadata(resourceName, 'version', 0) or "1.0.0"
    
    -- Le lien utilise 'main' car ta branche est 'Principaux'
    local updateUrl = "https://raw.githubusercontent.com/"..GithubRepo.."/main/version.txt"

    PerformHttpRequest(updateUrl, function(errorCode, resultData, resultHeaders)
        if errorCode == 200 and resultData then
            local latestVersion = resultData:gsub("%s+", "")
            if latestVersion ~= localVersion then
                print("^0[^4"..resourceName.."^0] ^1MISE À JOUR DISPONIBLE (v"..latestVersion..")^7")
                print("^0[^1txAdmin^0] ^3Version locale: ^7" .. localVersion .. " ^1-> ^2Nouvelle version: ^7" .. latestVersion)
            else
                print("^0[^4"..resourceName.."^0] ^2Le script est à jour (v" .. localVersion .. ")^7")
            end
        end
    end, "GET", "", "")
end)

-- Fonction centrale pour l'historique
function LogToHistory(type, staffName, targetName, targetId, duration, reason)
    table.insert(jailHistory, {
        type = type, -- "JAIL", "UNJAIL" ou "FINI"
        staffName = staffName,
        targetName = targetName,
        targetId = targetId,
        reason = reason or "Aucune",
        duration = duration or 0,
        date = os.date("%d/%m/%Y à %H:%M:%S")
    })
end

-- Vérification Staff
local function IsPlayerStaff(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local group = string.lower(xPlayer.getGroup())
        local staffGrades = { "admin", "superadmin", "owner", "mod" }
        for _, v in ipairs(staffGrades) do
            if group == v then return true end
        end
    end
    return false
end

-- Refresh List
local function RefreshJailList(source)
    local listForNui = {}
    local currentTime = os.time()
    for k, v in pairs(jailedPlayers) do
        v.status = "active"
        table.insert(listForNui, v)
    end
    for k, v in pairs(recentUnjails) do
        local diff = currentTime - v.releaseTime
        if diff < 300 then 
            v.status = "released"
            v.secondsSince = diff
            table.insert(listForNui, v)
        else
            recentUnjails[k] = nil 
        end
    end
    TriggerClientEvent('Dzk:openJailMenu', source, listForNui)
end

RegisterCommand('jail', function(source, args)
    if not IsPlayerStaff(source) then return end
    RefreshJailList(source)
end, false)

-- ACTION : JAIL
RegisterServerEvent('Dzk:processJail')
AddEventHandler('Dzk:processJail', function(targetId, duration, reason)
    local _source = source
    targetId = tonumber(targetId)
    duration = tonumber(duration)
    if not targetId or not duration or not reason then return end
    
    local xTarget = ESX.GetPlayerFromId(targetId)
    if xTarget then
        local targetName = GetPlayerName(targetId)
        local staffName = GetPlayerName(_source)

        jailedPlayers[targetId] = {
            id = targetId,
            name = targetName,
            time = duration,
            reason = reason,
            staffName = staffName
        }

        -- LOG : JAIL EFFECTUÉ
        LogToHistory("JAIL", staffName, targetName, targetId, duration, reason)

        TriggerClientEvent('Dzk:jailPlayer', targetId, duration, reason)

        -- Fin auto du jail
        SetTimeout(duration * 60000, function()
            if jailedPlayers[targetId] then
                -- LOG : FIN DE TEMPS
                LogToHistory("FINI", "Système", targetName, targetId, duration, "Temps écoulé")
                
                recentUnjails[targetId] = jailedPlayers[targetId]
                recentUnjails[targetId].releaseTime = os.time()
                jailedPlayers[targetId] = nil
                TriggerClientEvent('Dzk:unjailPlayer', targetId)
            end
        end)
    end
end)

-- ACTION : LIBÉRER (Bouton Staff)
RegisterServerEvent('Dzk:requestUnjail')
AddEventHandler('Dzk:requestUnjail', function(data)
    local _source = source
    if not IsPlayerStaff(_source) then return end
    local targetId = tonumber(data.id)
    
    if targetId and jailedPlayers[targetId] then
        local targetName = jailedPlayers[targetId].name
        local staffName = GetPlayerName(_source)

        -- LOG : LIBÉRATION PAR STAFF
        LogToHistory("UNJAIL", staffName, targetName, targetId, 0, "Libéré manuellement")

        recentUnjails[targetId] = jailedPlayers[targetId]
        recentUnjails[targetId].releaseTime = os.time()
        jailedPlayers[targetId] = nil
        TriggerClientEvent('Dzk:unjailPlayer', targetId)
        RefreshJailList(_source)
    end
end)

-- Envoi Historique
RegisterServerEvent('Dzk:requestHistory')
AddEventHandler('Dzk:requestHistory', function()
    local _source = source
    TriggerClientEvent('Dzk:sendHistory', _source, jailHistory)
end)