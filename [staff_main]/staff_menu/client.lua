-- client.lua

local menuOpen = false

RegisterCommand("staffmenu", function()
    TriggerServerEvent("staff_menu_ui:checkPermission")
end)

RegisterKeyMapping("staffmenu", "Open Staff Menu", "keyboard", "DELETE")

RegisterNetEvent("staff_menu_ui:openMenu", function(rank, players)
    SetNuiFocus(true, true)
    menuOpen = true
    SendNUIMessage({
        action = "open",
        rank = rank,
        players = players
    })
end)

RegisterNUICallback("closeMenu", function(_, cb)
    SetNuiFocus(false, false)
    menuOpen = false
    cb({})
end)

RegisterNUICallback("performAction", function(data, cb)
    local action = data.action
    local target = data.target
    local args = data.args or {}

    if action == "bring" then
        ExecuteCommand("sbring " .. target)
    elseif action == "goto" then
        ExecuteCommand("sgoto " .. target)
    elseif action == "revive" then
        ExecuteCommand("srevive " .. target)
    elseif action == "slay" then
        ExecuteCommand("sslay " .. target)
    elseif action == "drop" then
    local reason = args.reason or "Dropped by staff"
    ExecuteCommand("skick " .. target .. " " .. reason)
    elseif action == "announce" then
        ExecuteCommand("sannounce " .. args.message)
    elseif action == "setTime" then
        ExecuteCommand("ssettime " .. args.hour .. " " .. args.minute)
    elseif action == "setWeather" then
        ExecuteCommand("sweathernow " .. args.weatherType)
    elseif action == "spectate" then
        local targetPed = GetPlayerPed(GetPlayerFromServerId(tonumber(target)))
        local myPed = PlayerPedId()
        SetEntityVisible(myPed, false)
        SetEntityInvincible(myPed, true)
        AttachEntityToEntity(myPed, targetPed, 0, 0.0, 1.5, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    end

    cb({})
end)
