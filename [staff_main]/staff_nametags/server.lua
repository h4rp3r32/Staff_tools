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

    -- Get the player rank from staff_commands export (or directly if available here)
    local rank = 0
    if exports['staff_commands'] then
        rank = exports['staff_commands']:IsStaff(targetId) and exports['staff_commands']:GetPlayerRank(targetId) or 0
    else
        -- fallback: if Config accessible here
        -- rank = Config.GetPlayerRank(targetId)
    end

    TriggerClientEvent('staff_nametags:updatePlayerName', src, targetId, name, rank)
end)

AddEventHandler('playerDropped', function()
    local src = source
    redNameList[src] = nil
    TriggerClientEvent('staff_nametags:updateRedList', -1, redNameList)
end)
