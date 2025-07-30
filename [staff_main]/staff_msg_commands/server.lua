RegisterCommand('smsg', function(source, args)
    -- Check if the sender is staff using the export
    if not exports['staff_commands']:IsStaff(source) then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {"INSUFFICIANT PERMISSIONS:", "You do not have permission to use this command."}
        })
        return
    end

    local targetId = tonumber(args[1])
    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {"ERROR:", "Specified player does not exist!"}
        })
        return
    end

    table.remove(args, 1)
    local senderName = GetPlayerName(source)
    local msg = table.concat(args, " ")

    -- Send private message to target
    TriggerClientEvent('chat:addMessage', targetId, {
        color = {255, 192, 215},
        args = {
            "STAFF DM",
            senderName .. " (ID: " .. source .. "): " .. msg .. " - To respond type /report (message)"
        }
    })

    -- Confirm to sender
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 0},
        args = {"^2Message sent to", GetPlayerName(targetId) .. " (ID: " .. targetId .. ")"}
    })
end, false)
