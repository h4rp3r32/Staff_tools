RegisterServerEvent("staff_menu_ui:checkPermission")
AddEventHandler("staff_menu_ui:checkPermission", function()
    local src = source
    if not exports["staff_commands"]:IsStaff(src) then return end

    local rank = exports["staff_commands"]:GetPlayerRank(src)

    local players = {}
    for _, id in ipairs(GetPlayers()) do
        table.insert(players, {
            id = tonumber(id),
            name = GetPlayerName(id) or "Unknown"
        })
    end

    TriggerClientEvent("staff_menu_ui:openMenu", src, rank, players)
end)
