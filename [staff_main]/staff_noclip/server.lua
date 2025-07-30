-- staff_noclip/server.lua
local function isAllowed(source)
    return exports['staff_commands']:IsStaff(source)
end

RegisterNetEvent('staff_noclip:tryToggleNoclip', function()
    local src = source
    if isAllowed(src) then
        TriggerClientEvent('staff_noclip:toggleNoclip', src)
    else
        print(("^1[staff_noclip]^0 Unauthorized access attempt by %s"):format(src))
    end
end)