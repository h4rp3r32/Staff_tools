RegisterNetEvent('staff_commands:revive')
AddEventHandler('staff_commands:revive', function()
    local ped = PlayerPedId()
    if IsEntityDead(ped) then
        local coords = GetEntityCoords(ped)
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
        ClearPedTasksImmediately(ped)
        SetEntityHealth(ped, 200)
        TriggerEvent('chat:addMessage', { 
            color = { 0, 255, 0 },
            args = { "^2SYSTEM", "You have been revived." } })
    end
end)

RegisterNetEvent('staff_commands:slay')
AddEventHandler('staff_commands:slay', function()
    SetEntityHealth(PlayerPedId(), 0)
    TriggerEvent('chat:addMessage', { 
        color = { 255, 0, 0 },
        args = { "SYSTEM", "You have been destroyed." }
    })
end)


RegisterNetEvent('staff_commands:tp')
AddEventHandler('staff_commands:tp', function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
end)


-- TP map command
RegisterNetEvent('staff_commands:stpmap')
AddEventHandler('staff_commands:stpmap', function()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    local waypoint = GetFirstBlipInfoId(8)
    if waypoint == 0 then
        TriggerEvent('chat:addMessage', { args = { "^1No waypoint set on the map!" } })
        return
    end

    local coords = GetBlipInfoIdCoord(waypoint)
    local x, y = coords.x, coords.y
    local groundZ = 850.0
    local Z_START = 950.0
    local found = false

    -- Check if player is in a vehicle
    local vehicle = GetVehiclePedIsIn(ped, false)
    local entity = ped

    if vehicle ~= 0 then
        entity = vehicle -- teleport the vehicle instead
    end

    -- Fade out for smooth teleport
    DoScreenFadeOut(650)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    FreezeEntityPosition(entity, true)

    for i = Z_START, 0, -25.0 do
        local z = i
        if (i % 2) ~= 0 then
            z = Z_START - i
        end

        NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)
        local timer = GetGameTimer()
        while IsNetworkLoadingScene() do
            if GetGameTimer() - timer > 1000 then break end
            Wait(0)
        end
        NewLoadSceneStop()
        SetEntityCoordsNoOffset(entity, x, y, z, false, false, false)

        RequestCollisionAtCoord(x, y, z)
        local innerTimer = GetGameTimer()
        while not HasCollisionLoadedAroundEntity(entity) do
            if GetGameTimer() - innerTimer > 1000 then break end
            Wait(0)
        end

        found, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
        if found then
            SetEntityCoordsNoOffset(entity, x, y, groundZ + 1.0, false, false, false)
            break
        end
        Wait(0)
    end

    FreezeEntityPosition(entity, false)
    DoScreenFadeIn(650)

    if not found then
        SetEntityCoords(entity, x, y, 50.0, false, false, false, true)
        TriggerEvent('chat:addMessage', { args = { "^1Could not find ground. Teleported 50m above waypoint." } })
    else
        TriggerEvent('chat:addMessage', { args = { "^2Teleported to waypoint!" } })
    end
end)


-- Freeze player command
RegisterNetEvent('staff_commands:freeze')
AddEventHandler('staff_commands:freeze', function(toggle)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, toggle)
end)

RegisterNetEvent('staff_commands:dv')
AddEventHandler('staff_commands:dv', function()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local vehicles = GetGamePool("CVehicle")
    local closestVeh = nil
    local closestDist = 15.0 -- max distance

    for _, veh in ipairs(vehicles) do
        local vehCoords = GetEntityCoords(veh)
        local dist = #(pedCoords - vehCoords)
        if dist < closestDist then
            closestDist = dist
            closestVeh = veh
        end
    end

    if closestVeh and DoesEntityExist(closestVeh) then
        DeleteEntity(closestVeh)
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            args = { "SYSTEM", "Vehicle deleted." }
        })
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            args = { "SYSTEM", "No nearby vehicle found." }
        })
    end
    TriggerEvent('chat:addSuggestion', '/dv', 'Delete vehicle', {
        { name = 'nearest', help = 'Closest (default: 15.0)' }
    })
end)

RegisterCommand("sdvr", function(source, args)
    local radius = tonumber(args[1]) or 15.0
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local vehicles = GetGamePool("CVehicle")
    local deletedCount = 0

    for _, veh in ipairs(vehicles) do
        local vehCoords = GetEntityCoords(veh)
        local dist = #(pedCoords - vehCoords)
        if dist <= radius and DoesEntityExist(veh) then
            DeleteEntity(veh)
            deletedCount = deletedCount + 1
        end
    end

    if deletedCount > 0 then
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            args = { "SYSTEM", "Deleted " .. deletedCount .. " vehicles within " .. radius .. " meters." }
        })
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            args = { "SYSTEM", "No vehicles found within " .. radius .. " meters." }
        })
    end
    TriggerEvent('chat:addSuggestion', '/dvr', 'Delete all vehicles in radius', {
        { name = 'radius', help = 'Radius in meters (default: 15.0)' }
    })
end)


RegisterNetEvent("staff_commands:teleportToCarrier")
AddEventHandler("staff_commands:teleportToCarrier", function()
    local ped = PlayerPedId()
    SetEntityCoords(ped, vec4(3110.56, -4761.55, 15.26, 125.42))
end)

RegisterNetEvent("setTimeForEveryone", function(hour, minute)
    NetworkOverrideClockTime(hour, minute, 0)
    TriggerEvent('chat:addSuggestion', '/settime', 'Set the in-game time (24h format)', {
    { name = 'hour', help = 'Hour of day (0-23)' },
    { name = 'minute', help = 'Minute of hour (0-59)' }
})
end)

RegisterNetEvent("setWeatherForEveryone", function(weatherType)
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypeOvertimePersist(weatherType, 15.0)
    SetWeatherTypeNow(weatherType)
    SetWeatherTypeNowPersist(weatherType)
    SetWeatherTypePersist(weatherType)
    TriggerEvent('chat:addSuggestion', '/weathernow', 'Set the in-game weather', {
        { name = 'weatherType', help = 'Type of weather (CLEAR, CLOUDS, EXTRASUNNY, OVERCAST, RAIN, CLEARING, THUNDER, SMOG, FOGGY, XMAS, SNOWLIGHT, BLIZZARD)' }
    })
end)

-- Car spawn command
RegisterNetEvent("staff:spawnCar", function(vehicleName)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local model = GetHashKey(vehicleName)

    RequestModel(model)
    local timeout = 5000
    while not HasModelLoaded(model) and timeout > 0 do
        Wait(10)
        timeout = timeout - 10
    end

    if not HasModelLoaded(model) then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {"SYSTEM", "Could not load model: " .. vehicleName}
        })
        return
    end

    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleNumberPlateText(vehicle, "ADMINCAR")
    SetVehicleModKit(vehicle, 0)

    SetVehicleMod(vehicle, 11, 3, false) -- Engine
    SetVehicleMod(vehicle, 12, 2, false) -- Brakes
    SetVehicleMod(vehicle, 13, 2, false) -- Transmission
    SetVehicleMod(vehicle, 15, 3, false) -- Suspension
    SetVehicleMod(vehicle, 16, 4, false) -- Armor
    SetVehicleWindowTint(vehicle, 1)

    TaskWarpPedIntoVehicle(ped, vehicle, -1)



    SetModelAsNoLongerNeeded(model)
    TriggerServerEvent('qbx_vehiclekeys:server:hotwiredVehicle', VehToNet(vehicle))
end)


RegisterNetEvent('staff_commands:storeLastLocation')
AddEventHandler('staff_commands:storeLastLocation', function(coords)
    TriggerServerEvent('staff_commands:storeLastLocation', coords)
end)

RegisterNetEvent('staff_commands:setArmour')
AddEventHandler('staff_commands:setArmour', function(amount)
    local ped = PlayerPedId()
    SetPedArmour(ped, amount)
    TriggerEvent('chat:addMessage', {
        color = {0, 191, 255},
        args = {"SYSTEM", "Your armour has been set to " .. amount .. "."}
    })
end)

TriggerEvent('chat:addSuggestion', '/setarmour', 'Set armour for a player', {
    { name = 'playerID', help = 'Target player ID' },
    { name = 'amount', help = 'Armour amount (0-100)' }
})
