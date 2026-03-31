local inJail = false
local jailTime = 0
local jailReason = ""
local jailCoords = vector3(1644.5802, 2527.6088, 45.5567)
local jailRadius = 9.0
local unjailCoords = vector3(-262.9714, -901.2000, 32.2960) 

-- OUVRIR LE MENU PRINCIPAL
RegisterNetEvent('Dzk:openJailMenu')
AddEventHandler('Dzk:openJailMenu', function(list)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openPanel", jailedList = list })
end)

-- RÉCEPTION DE L'HISTORIQUE DEPUIS LE SERVEUR
RegisterNetEvent('Dzk:sendHistory')
AddEventHandler('Dzk:sendHistory', function(history)
    SendNUIMessage({
        action = "updateHistory",
        history = history
    })
end)

-- ==========================================
-- CALLBACKS NUI (Lien HTML -> Script)
-- ==========================================

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- CE CALLBACK ÉTAIT MANQUANT POUR LE BOUTON LIBÉRER
RegisterNUICallback('requestUnjail', function(data, cb)
    TriggerServerEvent('Dzk:requestUnjail', data) 
    cb('ok')
end)

RegisterNUICallback('validateJail', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('Dzk:processJail', data.id, data.time, data.reason)
    cb('ok')
end)

RegisterNUICallback('getHistory', function(data, cb)
    TriggerServerEvent('Dzk:requestHistory')
    cb('ok')
end)

-- ==========================================
-- LOGIQUE DE JAIL
-- ==========================================

RegisterNetEvent('Dzk:jailPlayer')
AddEventHandler('Dzk:jailPlayer', function(duration, reason)
    local playerPed = PlayerPedId()
    
    -- On TP le joueur au centre du jail
    SetEntityCoords(playerPed, jailCoords)
    
    inJail = true
    jailTime = duration * 60
    jailReason = reason

    -- Sons d'ambiance
    SendNUIMessage({ action = "playSound", sound = "prison_alarm" })
    Citizen.Wait(2000)
    SendNUIMessage({ action = "playSound", sound = "prison_voice" })
    
    -- Boucle du chrono
    Citizen.CreateThread(function()
        while inJail and jailTime > 0 do
            Citizen.Wait(1000)
            jailTime = jailTime - 1
        end
        
        -- Si le temps arrive à zéro naturellement
        if inJail then
            inJail = false
            jailTime = 0
            SetEntityCoords(PlayerPedId(), unjailCoords)
        end
    end)
end)

-- Event forcé par le Staff (/unjail ou bouton panel)
RegisterNetEvent('Dzk:unjailPlayer')
AddEventHandler('Dzk:unjailPlayer', function()
    inJail = false
    jailTime = 0
    SetEntityCoords(PlayerPedId(), unjailCoords)
end)

-- SÉCURITÉ (Anti-évasion et Resurection)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if inJail then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            
            -- Si le joueur s'éloigne trop ou meurt
            if #(coords - jailCoords) > jailRadius or IsEntityDead(ped) then
                if IsEntityDead(ped) then 
                    NetworkResurrectLocalPlayer(jailCoords, 0.0, true, true) 
                end
                SetEntityCoords(ped, jailCoords)
            end
        end
    end
end)

-- AFFICHAGE 3D (Texte au dessus de la tête)
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        if inJail then
            sleep = 0
            local pPed = PlayerPedId()
            local pCoords = GetEntityCoords(pPed)
            
            local minutes = math.floor(jailTime / 60)
            local seconds = jailTime % 60
            
            local text = "~r~VOUS AVEZ ÉTÉ MIS EN JAIL\n~w~Raison : ~y~" .. jailReason .. "\n~w~Temps restant : ~b~" .. string.format("%02d:%02d", minutes, seconds)
            
            -- Hauteur réglée à +0.9 comme demandé
            DrawText3D(pCoords.x, pCoords.y, pCoords.z + 0.9, text)
        end
        Citizen.Wait(sleep)
    end
end)

-- FONCTION D'AFFICHAGE TEXTE 3D
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.40, 0.40)
        SetTextFont(4)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextOutline()
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end