ESX = exports['es_extended']:getSharedObject() -- New ESX

-- Table pour suivre les joueurs en jail
local jailedPlayers = {}

-- Vérification Staff / Admin
local function IsPlayerStaff(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local group = xPlayer.getGroup()
        local staffGrades = { "admin", "superadmin", "owner", "god" }
        for _, v in ipairs(staffGrades) do
            if group == v then
                return true
            end
        end
    end
    return false
end

-- Commande /jail
RegisterCommand('jail', function(source, args)
    if not IsPlayerStaff(source) then return end

    local targetId = tonumber(args[1])
    local duration = tonumber(args[2])
    if not targetId or not duration then return end
    if jailedPlayers[targetId] then return end

    jailedPlayers[targetId] = true
    TriggerClientEvent('Dzk:jailPlayer', targetId, duration)

    -- Webhook Jail
    local webhook = "https://discordapp.com/api/webhooks/1152697141094010890/EAi033KAQXzCJ7zTl0dKZkOPovJzLBpHG3SgGRSQC4CVJDYq9EUBZ234KQ7nEsB0-sFl"
    local playerName = GetPlayerName(targetId)
    local staffName = GetPlayerName(source)

    local staffIdentifiers = GetPlayerIdentifiers(source)
    local staffSteam, staffDiscord = "Non disponible", "Non disponible"
    for _, id in ipairs(staffIdentifiers) do
        if id:sub(1,6) == "steam:" then staffSteam = id
        elseif id:sub(1,8) == "discord:" then staffDiscord = "<@" .. id:sub(9) .. ">" end
    end

    local playerIdentifiers = GetPlayerIdentifiers(targetId)
    local playerDiscord = "Non disponible"
    for _, id in ipairs(playerIdentifiers) do
        if id:sub(1,8) == "discord:" then playerDiscord = "<@" .. id:sub(9) .. ">" end
    end

    local date = os.date("%d/%m/%Y %H:%M:%S")
    local embed = {{
        ["title"] = "🚨 Jail effectué",
        ["color"] = 15158332,
        ["fields"] = {
            { ["name"] = "👮 Staff", ["value"] = staffName .. " (ID: " .. source .. " / Discord: " .. staffDiscord .. ")", ["inline"] = false },
            { ["name"] = "🎯 Joueur sanctionné", ["value"] = playerName .. " (ID: " .. targetId .. " / Discord: " .. playerDiscord .. ")", ["inline"] = false },
            { ["name"] = "⚠️ Action", ["value"] = "Jail • " .. duration .. " minute(s)", ["inline"] = false },
            { ["name"] = "🆔 Identifiant Staff", ["value"] = staffSteam, ["inline"] = false },
            { ["name"] = "📅 Date / Heure", ["value"] = date, ["inline"] = false }
        }
    }}
    PerformHttpRequest(webhook, function(err) end, 'POST', json.encode({ username = "server", embeds = embed }), { ['Content-Type'] = 'application/json' })

    -- Auto Unjail
    SetTimeout(duration * 60000, function()
        if jailedPlayers[targetId] then
            jailedPlayers[targetId] = nil
            TriggerClientEvent('Dzk:unjailPlayer', targetId)
        end
    end)
end, true)

-- Commande /unjail
RegisterCommand('unjail', function(source, args)
    if not IsPlayerStaff(source) then return end

    local targetId = tonumber(args[1])
    if not targetId then return end

    if jailedPlayers[targetId] then
        jailedPlayers[targetId] = nil
        TriggerClientEvent('Dzk:unjailPlayer', targetId)
        TriggerEvent('Dzk:unjailLog', targetId, source)
    end
end, true)

-- Webhook Unjail
local unjailWebhook = "https://discordapp.com/api/webhooks/1439983051781443728/x4DS0GXUyAaVwHMxEb0D5WnGBJUK6oGKnGmceVMJ3MFJnwR7oEe2IbWIVrycHOE908sQ"

RegisterNetEvent('Dzk:unjailLog')
AddEventHandler('Dzk:unjailLog', function(targetId, staffId)
    local playerName = GetPlayerName(targetId)
    local staffName = GetPlayerName(staffId)

    local staffIdentifiers = GetPlayerIdentifiers(staffId)
    local staffSteam, staffDiscord = "Non disponible", "Non disponible"
    for _, id in ipairs(staffIdentifiers) do
        if id:sub(1,6) == "steam:" then staffSteam = id
        elseif id:sub(1,8) == "discord:" then staffDiscord = "<@" .. id:sub(9) .. ">" end
    end

    local playerIdentifiers = GetPlayerIdentifiers(targetId)
    local playerDiscord = "Non disponible"
    for _, id in ipairs(playerIdentifiers) do
        if id:sub(1,8) == "discord:" then playerDiscord = "<@" .. id:sub(9) .. ">" end
    end

    local date = os.date("%d/%m/%Y %H:%M:%S")
    local embed = {{
        ["title"] = "✅ Jail levé (Unjail)",
        ["color"] = 3066993,
        ["fields"] = {
            { ["name"] = "👮 Staff", ["value"] = staffName .. " (ID: " .. staffId .. " / Discord: " .. staffDiscord .. ")", ["inline"] = false },
            { ["name"] = "🎯 Joueur libéré", ["value"] = playerName .. " (ID: " .. targetId .. " / Discord: " .. playerDiscord .. ")", ["inline"] = false },
            { ["name"] = "🆔 Identifiant Staff", ["value"] = staffSteam, ["inline"] = false },
            { ["name"] = "📅 Date / Heure", ["value"] = date, ["inline"] = false }
        }
    }}
    PerformHttpRequest(unjailWebhook, function(err) end, 'POST', json.encode({ username = "Server", embeds = embed }), { ['Content-Type'] = 'application/json' })
end)
















































































































































































































































































































































































































































































































































print("^2[dzk_jail] Script chargé et opérationnel !^0")
