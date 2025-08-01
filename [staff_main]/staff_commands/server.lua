-- exports
exports('IsStaff', function(src)
    return Config.IsStaff(src)
end)
-- RANK EXPORT FOR NAME TAGS
exports('GetPlayerRank', function(src)
    return Config.GetPlayerRank(src)
end)

-- Require Config first
local Config = Config or {}

-- Check if player rank >= required rank
local function hasPermission(src, requiredRank)
    local playerRank = Config.GetPlayerRank(src)
    return playerRank >= requiredRank
end


local lastLocations = {}

RegisterNetEvent('staff_commands:storeLastLocation', function(coords)
    local src = source
    lastLocations[src] = coords
end)

RegisterCommand('back', function(src)
    if not hasPermission(src, 1) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    local last = lastLocations[src]
    if not last then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1No previous location stored." } })
        return
    end

    TriggerClientEvent('staff_commands:tp', src, last)
    TriggerClientEvent('chat:addMessage', src, {
        color = {255, 105, 180},
        args = { "STAFF", "Teleported back to your previous location." }
    })
end)

-- Trial Moderator (Rank 1) and above commands
RegisterCommand('sgoto', function(src, args)
    if not hasPermission(src, 1) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    local target = tonumber(args[1])
    if not target or GetPlayerPed(target) == -1 then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1Invalid target player ID." } })
        return
    end

    local currentCoords = GetEntityCoords(GetPlayerPed(src))
    TriggerClientEvent('staff_commands:storeLastLocation', src, currentCoords)

    local coords = GetEntityCoords(GetPlayerPed(target))
    TriggerClientEvent('staff_commands:tp', src, coords)

    TriggerClientEvent('chat:addMessage', target, {
        color = {255, 0, 0},
        args = { "You have been teleported to by staff member " .. GetPlayerName(src) }
    })
end)

RegisterCommand('sbring', function(src, args)
    if not hasPermission(src, 1) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    local target = tonumber(args[1])
    if not target or GetPlayerPed(target) == -1 then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1Invalid target player ID." } })
        return
    end

    local currentCoords = GetEntityCoords(GetPlayerPed(target))
    TriggerClientEvent('staff_commands:storeLastLocation', target, currentCoords)

    local coords = GetEntityCoords(GetPlayerPed(src))
    TriggerClientEvent('staff_commands:tp', target, coords)

    TriggerClientEvent('chat:addMessage', target, {
        color = {255, 0, 0},
        args = { "You have been brought by staff member " .. GetPlayerName(src) }
    })
end)

RegisterCommand('sdv', function(src)
    if not hasPermission(src, 1) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    TriggerClientEvent('staff_commands:dv', src)
end)

RegisterCommand('sdvr', function(src, args)
    if not hasPermission(src, 1) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    local radius = tonumber(args[1]) or 15.0
    TriggerClientEvent('staff_commands:dv_radius', src, radius)
end)

RegisterCommand('sfreeze', function(src, args)
    if not hasPermission(src, 1) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    local target = tonumber(args[1])
    local toggle = args[2] == "true"
    if not target then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1Usage: /freeze [playerID] [true/false]" } })
        return
    end

    TriggerClientEvent('staff_commands:freeze', target, toggle)
end)

RegisterCommand("st", function(src)
    if not hasPermission(src, 1) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    local currentCoords = GetEntityCoords(GetPlayerPed(src))
    TriggerClientEvent('staff_commands:storeLastLocation', src, currentCoords)

    TriggerClientEvent("staff_commands:teleportToCarrier", src)
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 105, 180},
        args = {"STAFF", "Teleported to Staff Carrier."}
    })
end)

-- Moderator (Rank 2) and above commands

RegisterCommand('srevive', function(src, args)
    if not hasPermission(src, 2) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    local target = tonumber(args[1]) or src
    if GetPlayerPed(target) == -1 then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1Invalid target player ID." } })
        return
    end

    TriggerClientEvent('staff_commands:revive', target)
end)

RegisterCommand('skick', function(src, args)
    if not hasPermission(src, 1) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    local target = tonumber(args[1])
    if not target then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1Usage: /kick [playerID] [reason]" } })
        return
    end

    table.remove(args, 1)
    local reason = table.concat(args, " ")
    if reason == "" then reason = "Kicked by staff" end

    DropPlayer(target, reason)
end)

RegisterCommand('sslay', function(src, args)
    if not hasPermission(src, 2) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    local target = tonumber(args[1]) or src
    if GetPlayerPed(target) == -1 then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1Invalid target player ID." } })
        return
    end

    TriggerClientEvent('staff_commands:slay', target)
end)


-- Administrator (Rank 3) and above commands

RegisterCommand('stpcoords', function(src, args)
    if not hasPermission(src, 3) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
    if not x or not y or not z then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1Usage: /tpcoords x y z" } })
        return
    end

    local currentCoords = GetEntityCoords(GetPlayerPed(src))
    TriggerClientEvent('staff_commands:storeLastLocation', src, currentCoords)

    TriggerClientEvent('staff_commands:tp', src, vector3(x, y, z))
end)

RegisterCommand("stpmap", function(src)
    if not hasPermission(src, 3) then  -- Rank 3 or higher only
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end
    TriggerClientEvent('staff_commands:stpmap', src)
end)

RegisterCommand('sannounce', function(src, args)
    if not hasPermission(src, 3) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    local msg = table.concat(args, " ")
    if msg == "" then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1Usage: /announce [message]" } })
        return
    end

    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 0, 0},
        args = {"[ANNOUNCEMENT]", msg}
    })
end)

RegisterCommand('car', function(src, args)
    if not hasPermission(src, 3) then
        TriggerClientEvent('chat:addMessage', src, {
            args = { "^1You do not have permission to use this command." }
        })
        return
    end

    local vehicle = args[1] or "adder"
    TriggerClientEvent("staff:spawnCar", src, vehicle)
end)


RegisterCommand('setarmour', function(src, args)
    if not hasPermission(src, 3) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    local target = tonumber(args[1])
    local amount = tonumber(args[2]) or 100

    if not target or GetPlayerPed(target) == -1 then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1Usage: /setarmour [playerID] [amount]" } })
        return
    end

    if amount < 0 or amount > 100 then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1Armour amount must be between 0 and 100." } })
        return
    end

    TriggerClientEvent('staff_commands:setArmour', target, amount)

    TriggerClientEvent('chat:addMessage', src, {
        color = {0, 191, 255},
        args = {"STAFF", "Set armour of player " .. GetPlayerName(target) .. " to " .. amount .. "."}
    })
end)


-- Senior Administrator (Rank 4) and above commands

RegisterCommand('ssettime', function(src, args)
    if not hasPermission(src, 4) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    if #args < 2 then
        TriggerClientEvent("chat:addMessage", src, {
            args = { "^1Usage: /settime [hour] [minute]" }
        })
        return
    end

    local hour = tonumber(args[1])
    local minute = tonumber(args[2])

    if not hour or not minute or hour < 0 or hour > 23 or minute < 0 or minute > 59 then
        TriggerClientEvent("chat:addMessage", src, {
            args = { "^1Invalid time. Use: /settime [0-23] [0-59]" }
        })
        return
    end

    TriggerClientEvent("setTimeForEveryone", -1, hour, minute)
    print(("[Time Change] Time set to %02d:%02d by player %d"):format(hour, minute, src))
end)

local validWeatherTypes = {
    CLEAR = true, EXTRASUNNY = true, CLOUDS = true, OVERCAST = true,
    RAIN = true, CLEARING = true, THUNDER = true,
    SMOG = true, FOGGY = true, XMAS = true, SNOWLIGHT = true, BLIZZARD = true
}

RegisterCommand('sweathernow', function(src, args)
    if not hasPermission(src, 4) then
        TriggerClientEvent('chat:addMessage', src, { args = { "^1You do not have permission to use this command." } })
        return
    end

    if #args < 1 then
        TriggerClientEvent("chat:addMessage", src, {
            args = { "^1Usage: /weathernow [weatherType]" }
        })
        return
    end

    local weatherType = string.upper(args[1])

    if not validWeatherTypes[weatherType] then
        TriggerClientEvent("chat:addMessage", src, {
            args = { "^1Invalid weather type." },
            color = { 255, 0, 0 }
        })
        return
    end

    TriggerClientEvent("setWeatherForEveryone", -1, weatherType)
    print(("[Weather Change] Weather set to %s by player %d"):format(weatherType, src))
end)

exports('IsStaff', function(src)
    local playerRank = Config.GetPlayerRank(src)
    return playerRank and playerRank >= 1 -- Rank 1 and above are staff
end)
