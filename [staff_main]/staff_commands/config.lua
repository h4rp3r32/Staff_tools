Config = {}

-- Map of allowed players and their ranks (1 to 4)
-- Example identifiers: fivem:14622233, steam:110000...
Config.StaffRanks = {
    ["EXAMPLE:000"] = 5, -- Harper32 ()
    -- Add more here: ["identifier"] = rank,
}

-- Get the highest rank of the player based on identifiers
function Config.GetPlayerRank(src)
    local playerRanks = {}
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        local rank = Config.StaffRanks[string.lower(id)]
        if rank then
            table.insert(playerRanks, rank)
        end
    end
    if #playerRanks == 0 then return 0 end -- Not staff
    table.sort(playerRanks, function(a, b) return a > b end)
    return playerRanks[1] -- Return highest rank found
end


