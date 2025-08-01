-- staff_noclip/server.lua

local function isAllowed(source)
    local rank = exports['staff_commands']:GetPlayerRank(source)
    return rank and rank >= 3 -- Only rank 3 (Admin) and above can use noclip
end

RegisterNetEvent('staff_noclip:tryToggleNoclip', function()
    local src = source
    if isAllowed(src) then
        TriggerClientEvent('staff_noclip:toggleNoclip', src)
    end
end)
