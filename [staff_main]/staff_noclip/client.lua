local QBCore = exports['qb-core']:GetCoreObject()

local noclip = false
local useFreecam = true
local speedLevel = 3 -- Normal
local speeds = { 0.05, 0.1, 0.25, 0.5, 1.0, 2.0, 3.5, 8.0 }
local speedLabels = { "Slowest", "Very Slow", "Slow", "Normal", "Fast", "Faster", "Very Fast", "Fastest" }
local visible = true
local target = nil

local staticAnimDict = "amb@world_human_stand_impatient@male@no_sign@base"
local staticAnimName = "base"

local speedNotiExpire = 0
local visibilityNotiExpire = 0
local speedNotiText = ""
local visibilityNotiText = ""

local function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

local function ApplyStaticAnim(ped)
    LoadAnimDict(staticAnimDict)
    FreezeEntityPosition(ped, true)
    TaskPlayAnim(ped, staticAnimDict, staticAnimName, 8.0, -8.0, -1, 32, 0.0, false, false, false)
end

local function RotationToDirection(rot)
    local radX = math.rad(rot.x)
    local radZ = math.rad(rot.z)
    local cosX = math.cos(radX)
    return vector3(
        -math.sin(radZ) * math.abs(cosX),
         math.cos(radZ) * math.abs(cosX),
         math.sin(radX)
    )
end

local function ShowSpeedNotification(label)
    speedNotiText = "Speed: ~g~" .. label
    speedNotiExpire = GetGameTimer() + 1500
end

local function ShowVisibilityNotification()
    visibilityNotiText = "Invisibility: " .. (visible and "~r~Disabled~s~" or "~g~Enabled~s~")
    visibilityNotiExpire = GetGameTimer() + 1500
end

local function ToggleVisibility()
    local ped = PlayerPedId()
    visible = not visible

    if target ~= nil and IsEntityAVehicle(target) then
        SetEntityVisible(target, visible, false)
        SetEntityAlpha(target, visible and 255 or 0, false)
        SetEntityVisible(ped, visible, false)
        SetEntityAlpha(ped, visible and 255 or 0, false)
    else
        SetEntityVisible(ped, visible, false)
        SetEntityAlpha(ped, visible and 255 or 0, false)
    end

    ShowVisibilityNotification()
end

local function ToggleNoclip()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    target = veh ~= 0 and veh or ped
    noclip = not noclip

    -- Play sound effect when toggling noclip
    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

    if noclip then
        if veh ~= 0 then
            local heading = GetEntityHeading(veh)
            SetEntityRotation(veh, 0.0, 0.0, heading, 2, true)
            SetVehicleOnGroundProperly(veh)
        end

        SetEntityCollision(target, false, false)
        SetEntityInvincible(target, true)
        SetEntityHasGravity(target, false)
        FreezeEntityPosition(target, false)

        if target == ped then
            SetEntityVisible(ped, visible, false)
            SetEntityAlpha(ped, visible and 255 or 0, false)
            ApplyStaticAnim(ped)
        end

        speedNotiExpire = 0
        visibilityNotiExpire = 0
    else
        if target ~= nil then
            if IsEntityAVehicle(target) then
                SetEntityVisible(target, true, false)
                SetEntityAlpha(target, 255, false)
            end
            if target == ped then
                ClearPedTasksImmediately(ped)
                SetEntityVisible(ped, true, false)
                SetEntityAlpha(ped, 255, false)
            end
        end

        SetEntityHasGravity(target, true)
        SetEntityVelocity(target, 0.0, 0.0, 0.0)

        SetEntityCollision(target, true, true)
        SetEntityInvincible(target, false)
        FreezeEntityPosition(target, false)

        target = nil
        visible = true
    end
end


local function ToggleMode()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    useFreecam = not useFreecam

    -- Update target depending on mode
    if noclip then
        if useFreecam then
            -- Freecam mode uses ped as target
            if target ~= ped then
                -- Reset previous target first
                if target and DoesEntityExist(target) then
                    SetEntityCollision(target, true, true)
                    SetEntityInvincible(target, false)
                    SetEntityHasGravity(target, true)
                    FreezeEntityPosition(target, false)
                    SetEntityVisible(target, true, false)
                    SetEntityAlpha(target, 255, false)
                end

                target = ped
                SetEntityCollision(target, false, false)
                SetEntityInvincible(target, true)
                SetEntityHasGravity(target, false)
                FreezeEntityPosition(target, false)
                SetEntityVisible(ped, visible, false)
                SetEntityAlpha(ped, visible and 255 or 0, false)
                ApplyStaticAnim(ped)
            end
        else
            -- PedBased mode uses vehicle as target, if inside vehicle
            if veh ~= 0 then
                if target ~= veh then
                    -- Reset previous target first
                    if target and DoesEntityExist(target) then
                        SetEntityCollision(target, true, true)
                        SetEntityInvincible(target, false)
                        SetEntityHasGravity(target, true)
                        FreezeEntityPosition(target, false)
                        SetEntityVisible(target, true, false)
                        SetEntityAlpha(target, 255, false)
                    end

                    target = veh
                    SetEntityCollision(target, false, false)
                    SetEntityInvincible(target, true)
                    SetEntityHasGravity(target, false)
                    FreezeEntityPosition(target, false)
                    SetEntityVisible(target, true, false)
                    SetEntityAlpha(target, 255, false)

                    ClearPedTasksImmediately(ped)
                    SetEntityVisible(ped, true, false)
                    SetEntityAlpha(ped, 255, false)
                end
            else
                -- If no vehicle, fallback to ped target in pedBased mode
                target = ped
            end
        end
    end

    speedNotiText = "Mode: " .. (useFreecam and "~b~Freecam" or "~y~PedBased")
    speedNotiExpire = GetGameTimer() + 1500
end

-- Handle keybinds manually without commands or key mapping
CreateThread(function()
    while true do
        Wait(0)

        -- F10 - Toggle noclip (server validated)
        if IsControlJustReleased(0, 57) then -- F10
            TriggerServerEvent("staff_noclip:tryToggleNoclip")
        end

        -- H - Toggle noclip mode, only if noclip active
        if noclip and IsControlJustReleased(0, 56) then -- H
            ToggleMode()
        end

        -- Q - Toggle visibility
        if noclip and IsControlJustReleased(0, 44) then -- Q
            ToggleVisibility()
        end
    end
end)





-- Triggered by the server only if user is allowed
RegisterNetEvent("staff_noclip:toggleNoclip", function()
    ToggleNoclip()
end)

-- Main Noclip Thread
CreateThread(function()
    while true do
        Wait(0)
        if noclip and target then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(target)
            local moveVec = vector3(0, 0, 0)
            local speed = speeds[speedLevel]
            DisableControlAction(0, 86, true)
            DisableControlAction(0, 74, true)

            if useFreecam then
                local camRot = GetGameplayCamRot(2)
                local camDir = RotationToDirection(camRot)
                local camRight = vector3(-camDir.y, camDir.x, 0.0)

                if IsControlPressed(0, 32) then moveVec = moveVec + camDir end -- W
                if IsControlPressed(0, 33) then moveVec = moveVec - camDir end -- S
                if IsControlPressed(0, 34) then moveVec = moveVec + camRight end -- D
                if IsControlPressed(0, 35) then moveVec = moveVec - camRight end -- A
            else
                local heading = math.rad(GetEntityHeading(target))
                local forward = vector3(-math.sin(heading), math.cos(heading), 0.0)

                if IsControlPressed(0, 32) then moveVec = moveVec + forward end -- W
                if IsControlPressed(0, 33) then moveVec = moveVec - forward end -- S
                if IsControlPressed(0, 34) then SetEntityHeading(target, GetEntityHeading(target) + 2.5) end -- D
                if IsControlPressed(0, 35) then SetEntityHeading(target, GetEntityHeading(target) - 2.5) end -- A
            end

            if IsControlPressed(0, 38) then moveVec = moveVec + vector3(0, 0, 1.0) end -- E (up)
            if IsControlPressed(0, 47) then moveVec = moveVec - vector3(0, 0, 1.0) end -- G (down)

            if IsControlJustPressed(0, 21) then
                speedLevel = speedLevel + 1
                if speedLevel > #speeds then speedLevel = 1 end
                ShowSpeedNotification(speedLabels[speedLevel])
            end

            local newPos = pos + (moveVec * speed)
            SetEntityCoordsNoOffset(target, newPos.x, newPos.y, newPos.z, true, true, true)
            SetEntityVelocity(target, 0.0, 0.0, 0.0)
            SetEntityCollision(target, false, false)
            SetEntityHasGravity(target, false)

            if target == ped then
                SetEntityVisible(ped, visible, false)
                SetEntityAlpha(ped, visible and 255 or 0, false)
                SetEntityHasGravity(target, true)
            end
        else
            Wait(0)
        end
    end
end)

-- Keep animation applied if ped in noclip
CreateThread(function()
    while true do
        Wait(0)
        if noclip and target == PlayerPedId() then
            local ped = PlayerPedId()
            if not IsEntityPlayingAnim(ped, staticAnimDict, staticAnimName, 3) then
                ApplyStaticAnim(ped)
            end
        end
    end
end)

-- Draw UI and notifications
local function DrawTextUI(x, y, text, scale)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(scale or 0.35, scale or 0.35)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow()
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

CreateThread(function()
    while true do
        Wait(0)
        if noclip then
            local modeText = useFreecam and "~b~Freecam" or "~y~PedBased"
            local invisText = visible and "~r~Disabled" or "~g~Enabled"
            local speedText = speedLabels[speedLevel]

            -- Adjusted rectangle: further right and higher
            DrawRect(0.90, 0.15, 0.18, 0.17, 0, 0, 0, 130)

            -- Adjusted text: further right and higher
            DrawTextUI(0.83, 0.07, "~w~[F10] Noclip ~g~[ENABLED]", 0.40)
            DrawTextUI(0.83, 0.10, "~w~Speed: " .. "~g~" .. speedText)
            DrawTextUI(0.83, 0.12, "~w~Invisibility: " .. invisText)
            DrawTextUI(0.83, 0.14, "~w~Mode: " .. modeText)

            DrawTextUI(0.83, 0.16, "~w~[LSHIFT] Cycle Speed")
            DrawTextUI(0.83, 0.18, "~w~[Q] Toggle Invisibility")
            DrawTextUI(0.83, 0.20, "~w~[F9] Camera Controls")

            -- Notifications stay centered
            if GetGameTimer() < speedNotiExpire then
                DrawTextUI(0.5, 0.8, speedNotiText)
            end
            if GetGameTimer() < visibilityNotiExpire then
                DrawTextUI(0.5, 0.83, visibilityNotiText)
            end
        else
            Wait(500)
        end
    end
end)
