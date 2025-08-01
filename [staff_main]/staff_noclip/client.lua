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

    -- Only toggle player visibility, not vehicle
    SetEntityVisible(ped, visible, false)
    SetEntityAlpha(ped, visible and 255 or 0, false)

    ShowVisibilityNotification()
end

local function ToggleNoclip()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    target = veh ~= 0 and veh or ped
    noclip = not noclip

    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

    if noclip then
        if veh ~= 0 then
            local heading = GetEntityHeading(veh)
            SetEntityRotation(veh, 0.0, 0.0, heading, 2, true)
            SetVehicleOnGroundProperly(veh)
        end

        SetEntityCollision(target, false, false)
        SetEntityInvincible(target, true)
        SetEntityHasGravity(target, true)
        FreezeEntityPosition(target, false)

        if target == ped then
            SetEntityVisible(ped, visible, false)
            SetEntityAlpha(ped, visible and 255 or 0, false)
            ApplyStaticAnim(ped)
        end

        speedNotiExpire = 0
        visibilityNotiExpire = 0
    else
        if target == ped then
            ClearPedTasksImmediately(ped)
            SetEntityVisible(ped, true, false)
            SetEntityAlpha(ped, 255, false)
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

    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

    if noclip then
        if useFreecam then
            if veh ~= 0 then
                target = veh
            else
                if target and DoesEntityExist(target) then
                    SetEntityCollision(target, true, true)
                    SetEntityInvincible(target, false)
                    SetEntityHasGravity(target, true)
                    FreezeEntityPosition(target, false)
                end

                target = ped
                SetEntityCollision(ped, false, false)
                SetEntityInvincible(ped, true)
                SetEntityHasGravity(ped, false)
                FreezeEntityPosition(ped, false)
                SetEntityVisible(ped, visible, false)
                SetEntityAlpha(ped, visible and 255 or 0, false)

                ApplyStaticAnim(ped)
            end
        else
            if veh ~= 0 then
                target = veh
            else
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

        if IsControlJustReleased(0, 57) then -- F10
            TriggerServerEvent("staff_noclip:tryToggleNoclip")
        end

        if noclip and IsControlJustReleased(0, 56) then -- H
            ToggleMode()
        end

        if noclip and IsControlJustReleased(0, 44) then -- Q
            ToggleVisibility()
        end
    end
end)

RegisterNetEvent("staff_noclip:toggleNoclip", function()
    ToggleNoclip()
end)

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

                if IsControlPressed(0, 32) then moveVec = moveVec + camDir end
                if IsControlPressed(0, 33) then moveVec = moveVec - camDir end
                if IsControlPressed(0, 34) then moveVec = moveVec + camRight end
                if IsControlPressed(0, 35) then moveVec = moveVec - camRight end
            else
                local heading = math.rad(GetEntityHeading(target))
                local forward = vector3(-math.sin(heading), math.cos(heading), 0.0)

                if IsControlPressed(0, 32) then moveVec = moveVec + forward end
                if IsControlPressed(0, 33) then moveVec = moveVec - forward end
                if IsControlPressed(0, 34) then SetEntityHeading(target, GetEntityHeading(target) + 2.5) end
                if IsControlPressed(0, 35) then SetEntityHeading(target, GetEntityHeading(target) - 2.5) end
            end

            if IsControlPressed(0, 38) then moveVec = moveVec + vector3(0, 0, 1.0) end
            if IsControlPressed(0, 47) then moveVec = moveVec - vector3(0, 0, 1.0) end

            if IsControlJustPressed(0, 21) then
                speedLevel = speedLevel + 1
                if speedLevel > #speeds then speedLevel = 1 end
                ShowSpeedNotification(speedLabels[speedLevel])
            end

            local newPos = pos + (moveVec * speed)
            SetEntityCoordsNoOffset(target, newPos.x, newPos.y, newPos.z, true, true, true)
            SetEntityVelocity(target, 0.0, 0.0, 0.0)
            SetEntityCollision(target, false, false)
            SetEntityHasGravity(target, true)

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

            DrawRect(0.90, 0.15, 0.18, 0.17, 0, 0, 0, 130)
            DrawTextUI(0.83, 0.07, "~w~[F10] Noclip ~g~[ENABLED]", 0.40)
            DrawTextUI(0.83, 0.10, "~w~Speed: " .. "~g~" .. speedText)
            DrawTextUI(0.83, 0.12, "~w~Invisibility: " .. invisText)
            DrawTextUI(0.83, 0.14, "~w~Mode: " .. modeText)
            DrawTextUI(0.83, 0.16, "~w~[LSHIFT] Cycle Speed")
            DrawTextUI(0.83, 0.18, "~w~[Q] Toggle Invisibility")
            DrawTextUI(0.83, 0.20, "~w~[F9] Camera Controls")

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
