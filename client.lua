local inJail = false

local jailTime = 0
local jailCoords = vector3(1644.580200, 2527.608886, 45.556762)
local jailRadius = 9.0
local unjailCoords = vector3(-262.971436, -901.200012, 32.296020) 

-- ===================================================
-- EVENT : METTRE EN JAIL
-- ===================================================
RegisterNetEvent('Dzk:jailPlayer')
AddEventHandler('Dzk:jailPlayer', function(duration)
    local playerPed = PlayerPedId()

    -- Téléportation UNIQUE au début
    SetEntityCoords(playerPed, jailCoords)
    inJail = true
    jailTime = duration * 60 -- secondes

    -- 🔊 SONS RP JAIL (seulement alarme et voice)
    SendNUIMessage({ action = "playSound", sound = "prison_alarm" })
    Citizen.Wait(2000)
    SendNUIMessage({ action = "playSound", sound = "prison_voice" })

    -- Thread pour timer
    Citizen.CreateThread(function()
        while inJail and jailTime > 0 do
            Citizen.Wait(1000)
            jailTime = jailTime - 1
        end

        if inJail then
            inJail = false
            SetEntityCoords(PlayerPedId(), unjailCoords)
        end
    end)
end)

-- ===================================================
-- EVENT : SORTIR DE JAIL
-- ===================================================
RegisterNetEvent('Dzk:unjailPlayer')
AddEventHandler('Dzk:unjailPlayer', function()
    inJail = false
    SetEntityCoords(PlayerPedId(), unjailCoords)
end)

-- ===================================================
-- OPTION 1 : ANTI-SUICIDE / ANTI-RESPAWN
-- ===================================================
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if inJail then
            local ped = PlayerPedId()
            if IsEntityDead(ped) then
                Citizen.Wait(2000)
                NetworkResurrectLocalPlayer(jailCoords.x, jailCoords.y, jailCoords.z, 0.0, true, true)
                SetEntityCoords(PlayerPedId(), jailCoords)
                ClearPedTasksImmediately(PlayerPedId())
            end
        end
    end
end)

-- ===================================================
-- OPTION 3 : BLOQUER F8 & KILL
-- ===================================================
Citizen.CreateThread(function()
    while false do
        Citizen.Wait(0)
        if inJail then
            DisableControlAction(0, 243, true) -- F8 console
            DisableControlAction(0, 47, true)  -- G
            DisableControlAction(0, 245, true) -- T
        end
    end
end)

-- ===================================================
-- VERIFICATION DE LA POSITION EN JAIL
-- ===================================================
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if inJail then
            local playerPed = PlayerPedId()
            local px, py, pz = table.unpack(GetEntityCoords(playerPed))
            local distance = #(vector3(px, py, pz) - jailCoords)
            if distance > jailRadius then
                SetEntityCoords(playerPed, jailCoords)
                ClearPedTasksImmediately(playerPed)
            end
        end
    end
end)

-- ===================================================
-- TEXTE 3D DU TEMPS RESTANT
-- ===================================================
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if inJail then
            local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))
            local minutes = math.floor(jailTime / 60)
            local seconds = jailTime % 60
            local text = string.format("~r~Vous êtes en jail ! Temps restant : %02d:%02d", minutes, seconds)
            DrawText3D(px, py, pz + 1.0, text)
        end
    end
end)

-- ===================================================
-- FONCTION : DrawText3D
-- ===================================================
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()
    local distance = #(vector3(x, y, z) - camCoords)
    local scale = (1 / distance) * 2
    if scale > 0.5 then scale = 0.5 end

    if onScreen then
        SetTextScale(0.70 * scale, 0.70 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextCentre(true)
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
