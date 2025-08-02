local showNames = false
local useICNames = false
local tags = {}
local playerNames = {}
local redNamePlayers = {} -- serverId => true

local playerRanks = {} -- serverId => rank number

RegisterNetEvent('staff_nametags:updatePlayerName', function(serverId, playerName, rank)
    playerNames[serverId] = playerName
    playerRanks[serverId] = rank or 0
end)

RegisterNetEvent('staff_nametags:updateRedList', function(redList)
    redNamePlayers = redList
end)

local function CreateTagForPlayer(serverId, playerPed)
    Wait(0)
    if tags[playerPed] then return end

    local playerName = playerNames[serverId] or "Loading..."
    local rank = playerRanks[serverId] or 0

    if playerName == "Loading..." then
        if useICNames then
            TriggerServerEvent('staff_nametags:requestPlayerICName', serverId)
        else
            TriggerServerEvent('staff_nametags:requestPlayerName', serverId)
        end
        return
    end

    if DoesEntityExist(playerPed) then
        local spacing = "\n"
        local tagText = ("%d - %s%s"):format(serverId, playerName, spacing)

        local tagId = CreateFakeMpGamerTag(playerPed, tagText, false, true, '', 0)

        SetMpGamerTagAlpha(tagId, 0, 255)
        SetMpGamerTagAlpha(tagId, 2, 255)

        if redNamePlayers[serverId] then
            SetMpGamerTagColour(tagId, 0, 6)
        else
            SetMpGamerTagColour(tagId, 0, 0)
        end

        SetMpGamerTagHealthBarColour(tagId, 25)

        -- Hide headset icon initially
        SetMpGamerTagVisibility(tagId, 9, false)

        -- Wanted stars based on rank (capped at 5)
        local wantedLevel = math.min(rank, 5)
        SetMpGamerTagVisibility(tagId, 7, wantedLevel > 0)
        SetMpGamerTagWantedLevel(tagId, wantedLevel)

        tags[playerPed] = tagId
    end
end


local function RemoveTagForPed(ped)
    if tags[ped] then
        RemoveMpGamerTag(tags[ped])
        tags[ped] = nil
    end
end

local function ClearAllTags()
    for ped, tagId in pairs(tags) do
        RemoveMpGamerTag(tagId)
    end
    tags = {}
end

local function ToggleNameTags()
    showNames = not showNames

    TriggerServerEvent('staff_nametags:setRedStatus', showNames)

    if not showNames then
        ClearAllTags()
    end
end

RegisterCommand('playertags', function()
    TriggerServerEvent('staff_nametags:requestToggle')
end)

RegisterKeyMapping('playertags', 'Toggle Staff Name Tags', 'keyboard', '0')

RegisterNetEvent('staff_nametags:toggleAllowed', function()
    ToggleNameTags()
end)

RegisterNetEvent('staff_nametags:toggleDenied', function()
end)

-- Updated toggleicnames command with cache clearing & immediate refresh
RegisterCommand('toggleicnames', function()
    useICNames = not useICNames

    local msg = useICNames and "~g~Using IC names in nametags." or "~r~Using CFX names in nametags."
    TriggerEvent('chat:addMessage', {
        args = {"SYSTEM", msg},
        color = useICNames and {0, 255, 0} or {255, 0, 0}
    })

    -- Clear tags and cached names/ranks to force refresh
    ClearAllTags()
    playerNames = {}
    playerRanks = {}

    -- If nametags are active, recreate all tags immediately
    if showNames then
        local players = GetActivePlayers()
        local localPed = PlayerPedId()
        local localServerId = GetPlayerServerId(PlayerId())

        CreateTagForPlayer(localServerId, localPed)

        for _, playerIndex in ipairs(players) do
            local playerPed = GetPlayerPed(playerIndex)
            local serverId = GetPlayerServerId(playerIndex)

            if playerPed ~= 0 and DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
                CreateTagForPlayer(serverId, playerPed)
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)

        if showNames then
            local players = GetActivePlayers()
            local localPed = PlayerPedId()
            local localServerId = GetPlayerServerId(PlayerId())

            if not tags[localPed] then
                CreateTagForPlayer(localServerId, localPed)
            end

            for _, playerIndex in ipairs(players) do
                local playerPed = GetPlayerPed(playerIndex)
                local serverId = GetPlayerServerId(playerIndex)

                if playerPed ~= 0 and DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
                    if not tags[playerPed] then
                        CreateTagForPlayer(serverId, playerPed)
                    else
                        local tagId = tags[playerPed]

                        SetMpGamerTagVisibility(tagId, 0, true)
                        SetMpGamerTagVisibility(tagId, 2, true)

                        -- HEADSET icon (component 9)
                        if NetworkIsPlayerTalking(playerIndex) then
                            SetMpGamerTagVisibility(tagId, 9, true)
                        else
                            SetMpGamerTagVisibility(tagId, 9, false)
                        end

                        if redNamePlayers[serverId] then
                            SetMpGamerTagColour(tagId, 0, 6)
                        else
                            SetMpGamerTagColour(tagId, 0, 0)
                        end

                        -- Update wanted stars
                        local rank = playerRanks[serverId] or 0
                        local wantedLevel = math.min(rank, 5)
                        SetMpGamerTagVisibility(tagId, 7, wantedLevel > 0)
                        SetMpGamerTagWantedLevel(tagId, wantedLevel)
                    end
                else
                    RemoveTagForPed(playerPed)
                end
            end
        else
            ClearAllTags()
            Wait(1000)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        ClearAllTags()
    end
end)
