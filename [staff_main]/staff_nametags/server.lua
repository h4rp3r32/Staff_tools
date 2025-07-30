local QBCore = exports['qb-core']:GetCoreObject()

local redNameList = {}

RegisterNetEvent('staff_nametags:requestToggle', function()
    local src = source
    if exports['staff_commands']:IsStaff(src) then
        TriggerClientEvent('staff_nametags:toggleAllowed', src)
    else
        TriggerClientEvent('staff_nametags:toggleDenied', src)
    end
end)

RegisterNetEvent('staff_nametags:setRedStatus', function(isEnabled)
    local src = source

    -- Staff check using the export
    if not exports['staff_commands']:IsStaff(src) then
        return
    end

    redNameList[src] = isEnabled or nil

    -- Notify all clients of updated red list
    TriggerClientEvent('staff_nametags:updateRedList', -1, redNameList)
end)

RegisterNetEvent('staff_nametags:requestPlayerName', function(targetId)
    local src = source
    local name = GetPlayerName(targetId) or "Unknown"

    local rank = 0
    if exports['staff_commands'] then
        rank = exports['staff_commands']:IsStaff(targetId) and exports['staff_commands']:GetPlayerRank(targetId) or 0
    end

    TriggerClientEvent('staff_nametags:updatePlayerName', src, targetId, name, rank)
end)

-- New event for IC name requests
RegisterNetEvent('staff_nametags:requestPlayerICName', function(targetId)
    local src = source

    -- Only allow staff to request this info
    if not exports['staff_commands']:IsStaff(src) then
        return
    end

    local icName = "Unknown"
    local rank = 0

    if exports['staff_commands']:IsStaff(targetId) then
        rank = exports['staff_commands']:GetPlayerRank(targetId) or 0
    end

    local player = QBCore.Functions.GetPlayer(targetId)
    if player and player.PlayerData and player.PlayerData.charinfo then
        local charinfo = player.PlayerData.charinfo
        icName = charinfo.firstname .. " " .. charinfo.lastname
    end

    TriggerClientEvent('staff_nametags:updatePlayerName', src, targetId, icName, rank)
end)

AddEventHandler('playerDropped', function()
    local src = source
    redNameList[src] = nil
    TriggerClientEvent('staff_nametags:updateRedList', -1, redNameList)
end)
