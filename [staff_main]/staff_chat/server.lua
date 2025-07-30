RegisterCommand('sc', function(source, args)
    if #args == 0 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {'StaffChat', 'Usage: /sc <message>'}
        })
        return
    end

    -- Check if player is staff using export from staff_commands
    if not exports.staff_commands:IsStaff(source) then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {'INSUFFICIANT PERMISSIONS', 'You do not have permission to use this command.'}
        })
        return
    end

    local msg = table.concat(args, ' ')

    -- Send message only to staff members
    for _, playerId in ipairs(GetPlayers()) do
        local pid = tonumber(playerId)
        if pid and exports.staff_commands:IsStaff(pid) then
            TriggerClientEvent('chat:addMessage', pid, {
                color = {0, 255, 0},
                args = {'STAFF CHAT', GetPlayerName(source) .. ': ' .. msg}
            })
        end
    end
end)
