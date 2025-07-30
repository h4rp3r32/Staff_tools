RegisterNetEvent('staff:receivePM', function(message, color)
    -- Display in standard chat
    TriggerEvent('chat:addMessage', {
        args = {message},
        color = color or {255, 192, 203}
    })

    -- Also send to QBox (or QBCore Notify)
    -- If you're using QBCore:
    if exports['qb-core'] then
        exports['qb-core']:Notify(message, 'primary', 7500)
    end

    -- If you're using a custom QBox or text UI system, use that instead.
    -- For example, if you have a custom event:
    -- TriggerEvent('qbox:notify', message, color or {255, 105, 180})
end)
