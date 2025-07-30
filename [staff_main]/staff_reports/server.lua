RegisterCommand("report", function(source, args, rawCommand)
    local msg = table.concat(args, " ")

    if msg == "" then
        TriggerClientEvent('chat:addMessage', source, {
            args = { "^1REPORTING:", "/report [message]" }
        })
        return
    end

    -- Notify all staff members
    for _, playerId in ipairs(GetPlayers()) do
        if Config.IsStaff(playerId) then
        TriggerClientEvent('chat:addMessage', playerId, {
                color = {0, 0, 255},
                args = {'REPORT:', GetPlayerName(source) .. ' (ID: ' .. source .. ') ' .. msg}
            })
        end
    end

    -- Optionally, confirm to the reporter
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 0},
        args = { 'Report recived. A staff member will be with you shortly.'}
    })
end
)
