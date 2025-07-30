Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/sc', 'Send a message to staff', {
        { name = 'message', help = 'Message text' }
    })
end)
