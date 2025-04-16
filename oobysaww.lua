--// Took Around 2 days

getgenv().Depart = {
    ['Intro'] = {
        ['Activated'] = false,
        ['Mode'] = "1"
    },
    ['Binding'] = {
        ['Aiming'] = 'C',
        ['Resolver'] = 'G',
        ['Macro'] = 'X',
        ['Trigger'] = 'T'
    },
    ['Macro'] = {
        ['Keybind'] = "X",
        ['Activated'] = true,
        ['Mode'] = "FirstPerson",
        ['Speed'] = 0.01,
        ['Enabled'] = false, 
    },
    ['Fighting'] = {
        ['Silent'] = {
            ['Activated'] = true,
            ['NearestPoint'] = true,
            ['Tune'] = 0.1,
            ['Prediction'] = 0.1243,
            ['MultipleParts'] = {"HumanoidRootPart", "Head", "Torso"},
            ['Anti_Groundshots'] = true,
            ['Anti_Curve'] = true,
            ['KOcheck'] = true,
            ['MaxAngle'] = 60,
            ['fovSettings'] = {
                ['FovRadius'] = 500,
                ['Activated'] = true,
                ['Visible'] = true,
                ['Color'] = Color3.fromRGB(255, 255, 255),
                ['Thickness'] = 0.2,
                ['Filled'] = false
            }
        },
        ['Aiming'] = {
            ['ClosestBodyPart'] = true,
            ['Activate'] = true,
            ['Key'] = "C",
            ['TargetParts'] = 'HumanoidRootPart',
            ['Prediction'] = 0.014556,
            ['CameraSmoothness'] = 0.067889
        },
        ['AimingAirSection'] = {
            ['ActivateAirBornePrediction'] = true,
            ['AirBorneParts'] = 'Head',
            ['AirBorneSmoothness'] = 0.078856,
            ['AirShotPrediction'] = 0.1255
        },
        ['AimPointMultipleHitParts'] = {
            ['Activated'] = true,
            ['Multi'] = {'Head', 'HumanoidRootPart', 'UpperTorso', 'LowerTorso'}
        },
        ['AimPoint'] = {
            ['Activated'] = false,
            ['Prediction'] = 0.12445,
            ['Parts'] = 'HumanoidRootPart',
            ['AirBorneParts'] = 'Head'
        },
        ['Offsets'] = {
            ['Jump'] = {0.12},
            ['Fall'] = {-0.12}
        }
    },
    ['Triggerbot'] = {
        ['Mode'] = 2,
        ['Activated'] = true,
        ['Prediction'] = 0.1355,
        ['Radius'] = 25,
        ['UseDelay'] = true,
        ['Delay'] = 0.05,
        ['WhitelistedGuns'] = {
            '[Revolver]',
            '[DoubleBarrel]',
            '[TacticalShotgun]'
        },
        ['HitParts'] = {
            "Head", "UpperTorso", "HumanoidRootPart", "LowerTorso",
            "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm",
            "LeftUpperArm", "RightUpperArm", "LeftFoot", "LeftLowerLeg",
            "LeftUpperLeg", "RightLowerLeg", "RightFoot", "RightUpperLeg"
        }
    },
    ['Miscellaneous'] = {
        ['Resolver'] = {
            ['Activated'] = true,
            ['Notification'] = true
        },
        ['PredictionAdjuster'] = {
            ['EnableAdjuster'] = true,
            ['VelocityThreshold'] = 100
        },
        ['Checks'] = {
            ['WallCheck'] = false
        }
    }
}

--[[

local Arguments = loadstring(game:HttpGet("https://raw.githubusercontent.com/hojixv/Argument.lua/refs/heads/main/Arguments.lua"))()

--]]

--[[
(Use only if needed)

    local hojixv = getrawmetatable(game)
    local char = hojixv.__namecall
    setreadonly(hojixv, false)
    hojixv.__namecall = newcclosure(function(...)
        local args = {...}
        if TargetKeybind and getnamecallmethod() == "FireServer" and args[2] == then

            if Depart.Hook then
                args[3] = hojixvChosenPlayer.Character[Depart.Hook].Position + (hojixvChosenPlayer.Character.Humanoid.MoveDirection * Depart.Hook.Tune)
            else
                args[3] = hojixvChosenPlayer.Character[Depart.Hook].Position +
                (hojixvChosenPlayer.Character[Depart.Hook].Velocity * Depart.Hook.Resolver)
            end
            return char(unpack(args))
        end
        return char(...)
    end)

--]]

if not LPH_OBFUSCATED then
    LPH_JIT_MAX = function(...)
        return (...)
    end
    LPH_NO_VIRTUALIZE = function(...)
        return (...)
    end
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- V
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local playersService = game:GetService("Players")
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera
local localPlayer = playersService.LocalPlayer
local mouse = localPlayer:GetMouse()

local Whiteowls = Drawing.new("Circle")
local fovSettings = getgenv().Depart.Fighting.Silent.fovSettings

Whiteowls.Thickness = fovSettings.Thickness
Whiteowls.Color = fovSettings.Color
Whiteowls.Filled = fovSettings.Filled

local Smokedope2016 = false
local RR = nil

local function updateCircles()
    local guiInsetY = game:GetService("GuiService"):GetGuiInset().Y
    local mousePosition = Vector2.new(mouse.X, mouse.Y + guiInsetY)

    if fovSettings.Visible then
        Whiteowls.Visible = true
        Whiteowls.Radius = fovSettings.FovRadius
        Whiteowls.Position = mousePosition
    else
        Whiteowls.Visible = false
    end
end

runService.RenderStepped:Connect(updateCircles)

local function isDead(player)
    if player.Character and player.Character:FindFirstChild("BodyEffects") then
        local bodyEffects = player.Character.BodyEffects
        local ko = bodyEffects:FindFirstChild("K.O") or bodyEffects:FindFirstChild("KO")
        return ko and ko.Value or false
    end
    return false
end

local function findClosestPlayer()
    local closestPlayer, shortestDistance = nil, math.huge
    local mousePosition = Vector2.new(mouse.X, mouse.Y)

    for _, player in ipairs(playersService:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPosition, onScreen = camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude
                if fovSettings.FovRadius > distance and distance < shortestDistance then
                    closestPlayer, shortestDistance = player, distance
                end
            end
        end
    end
    return closestPlayer
end

local function toggleCamlock(input, processed)
    if processed then return end

    local camlockKey = Enum.KeyCode[getgenv().Depart.Binding.Aiming]
    if input.KeyCode == camlockKey then
        Smokedope2016 = not Smokedope2016

        if Smokedope2016 and getgenv().Depart.Fighting.Aiming.Activate then
            RR = findClosestPlayer()
        else
            RR = nil
        end
    end
end

userInputService.InputBegan:Connect(toggleCamlock)

local function getArgument()
    local currentPlaceId = game.PlaceId
    local eventName, args

    if currentPlaceId == 2788229376 or currentPlaceId == 7213786345 or currentPlaceId == 16033173781 then
        eventName = "MainEvent"
        args = { "UpdateMousePosI2", Vector3.new(-621.6868286132812, 18.75, -117.6417465209961) }
    elseif currentPlaceId == 9825515356 then
        eventName = "MainEvent"
        args = { "MousePosUpdate", Vector3.new(9367.11328125, 547.904541015625, -3346.381103515625) }
    elseif currentPlaceId == 15186202290 or currentPlaceId == 17836920497 or currentPlaceId == 17403265390 then
        eventName = "MAINEVENT"
        args = { "MOUSE", Vector3.new(-105.59376525878906, 11.003229141235352, 127.97737884521484) }
    else
        eventName = "UpdateMousePosI2"
        args = { "MousePosUpdate", Vector3.new(-134.94320678710938, 21.908273696899414, -769.0164794921875) }
    end

    return eventName, args
end

print 'Detection #1'

local function getVelocity(player, partName)
    local part = player.Character and player.Character:FindFirstChild(partName)
    return part and part.Velocity or Vector3.new()
end

local function handleCamlock()
    if Smokedope2016 and RR and RR.Character and not isDead(RR) then
        local settings = getgenv().Depart.Fighting.Aiming
        local hitPartName = settings.TargetParts
        local targetPart = RR.Character:FindFirstChild(hitPartName)

        if targetPart then
            local targetVelocity = getVelocity(RR, hitPartName)
            local predictedPosition = targetPart.Position + targetVelocity * settings.Prediction
            local targetCFrame = CFrame.new(camera.CFrame.Position, predictedPosition)

            camera.CFrame = camera.CFrame:Lerp(targetCFrame, settings.CameraSmoothness)
        end
    else
        RR = nil
    end
end

runService.RenderStepped:Connect(handleCamlock)

local function onToolEquipped(tool)
    
end

local function connectToolEvents()
    for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            onToolEquipped(tool)
        end
    end

    localPlayer.Backpack.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            onToolEquipped(child)
        end
    end)
end

connectToolEvents()

local function onCharacterAdded(character)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            onToolEquipped(child)
        end
    end)

    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            onToolEquipped(tool)
        end
    end

    RR = nil 
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)
if localPlayer.Character then
    onCharacterAdded(localPlayer.Character)
end

if getgenv().Depart['Intro'].Activated then
    local soundId = "rbxassetid://6580172940"  
    local imageId = "rbxassetid://18928845290" 
    
    local sound = Instance.new("Sound", game.Workspace)
    sound.SoundId = soundId
    sound:Play()

    local introGui = Instance.new("ScreenGui", localPlayer.PlayerGui)
    local introFrame = Instance.new("Frame", introGui)
    introFrame.Size = UDim2.new(1, 0, 1, 0)
    introFrame.BackgroundColor3 = Color3.new(0, 0, 0)

    local introImage = Instance.new("ImageLabel", introFrame)
    introImage.Size = UDim2.new(1, 0, 1, 0)
    introImage.Image = imageId
    introImage.BackgroundTransparency = 1

    for i = 0, 1, 0.01 do
        introFrame.BackgroundTransparency = i
        wait(0.01)
    end

    wait(2)

    for i = 1, 0, -0.01 do
        introFrame.BackgroundTransparency = i
        wait(0.01)
    end

    introGui:Destroy()
end

local VirtualInputManager = game:GetService("VirtualInputManager")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local function handleMacroSpeedGlitch()
    local settings = getgenv().Depart.Macro
    local interval = settings.Speed

    if settings.Activated then 
        local function onMacroInput(input, processed)
            if processed then return end

            if input.KeyCode == Enum.KeyCode[settings.Keybind] then
                settings.Enabled = not settings.Enabled 
                --
                if settings.Enabled then 
                    if settings.Mode == "FirstPerson" then
                        local nextActionTime = tick() + interval

                        repeat
                            if tick() >= nextActionTime then
                                VirtualInputManager:SendMouseWheelEvent(0, 0, true, game)
                                runService.Heartbeat:Wait()
                                VirtualInputManager:SendMouseWheelEvent(0, 0, false, game)
                                nextActionTime = tick() + interval
                            end
                            runService.Heartbeat:Wait()
                        until not settings.Enabled -- Changed Activate to Enabled

                    elseif settings.Mode == "ThirdPerson" then
                        local actionInterval = interval / 4
                        local nextActionTime = tick() + actionInterval

                        repeat
                            if tick() >= nextActionTime then
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.I, false, game)
                                nextActionTime = tick() + actionInterval
                            end
                            runService.Heartbeat:Wait()

                            if tick() >= nextActionTime then
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.O, false, game)
                                nextActionTime = tick() + actionInterval
                            end
                            runService.Heartbeat:Wait()

                            if tick() >= nextActionTime then
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.I, false, game)
                                nextActionTime = tick() + actionInterval
                            end
                            runService.Heartbeat:Wait()

                            if tick() >= nextActionTime then
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.O, false, game)
                                nextActionTime = tick() + actionInterval
                            end
                            runService.Heartbeat:Wait()

                        until not settings.Enabled 
                    end
                end
            end
        end
        userInputService.InputBegan:Connect(onMacroInput)
    end
end

handleMacroSpeedGlitch()

local Inset = game:GetService("GuiService"):GetGuiInset().Y
local Mouse = game.Players.LocalPlayer:GetMouse()
local Client = game.Players.LocalPlayer
local Cam = workspace.CurrentCamera
local RunService = game:GetService("RunService")

--// FOV Circle Drawing
local FOV = Drawing.new("Circle")
local fovSettings = Depart.Fighting.Silent.fovSettings

-- Apply FOV settings
FOV.Thickness = fovSettings.Thickness
FOV.Color = fovSettings.Color
FOV.Filled = fovSettings.Filled

local function UpdateFOV()
    if fovSettings.Visible then
        FOV.Position = Vector2.new(Mouse.X, Mouse.Y + Inset)
        FOV.Radius = fovSettings.FovRadius
        FOV.Visible = true
    else
        FOV.Visible = false
    end
end

local function WallCheck(destination, ignore)
    if not Depart.Miscellaneous.Checks.WallCheck then
        return true
    end
    local origin = Cam.CFrame.p
    local direction = (destination - origin).unit * 100  
    local ray = Ray.new(origin, direction)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, ignore)
    return hit == nil
end

local function Death(Plr)
    if Plr.Character and Plr.Character:FindFirstChild("BodyEffects") then
        local bodyEffects = Plr.Character.BodyEffects
        local ko = bodyEffects:FindFirstChild("K.O") or bodyEffects:FindFirstChild("KO")
        return ko and ko.Value
    end
    return false
end

function DetectionFunction(detection)
    if detection then
        print('Arguments Detected')
    end
end

DetectionFunction(true) -- global )_<

print (game.PlaceId)

local function getEventName()
    local placeIds = {
        [2788229376] = "UpdateMousePosI2",
        [7213786345] = "UpdateMousePosI2",
        [16033173781] = "UpdateMousePosI2",
        [9825515356] = "MousePosUpdate",
        [17897702920] = "UpdateMousePos",
        [15644861772] = "UpdateMousePos",
        [125825216602676] = "MOUSE",
        [122094140167766] = "MOUSE",
        [138831788033519] = "MOUSE", 
        [15186202290] = "MOUSE",
    }
    return placeIds[game.PlaceId] or "UpdateMousePosI2"
end

print 'Detection #2'

local Argument = 138831788033519
local Argument = 15186202290
local Argument = 122094140167766
local Argument = 125825216602676

if game.PlaceId == Argument then
    print("Detected target place ID: " .. Argument)
else
    print("Argument Detected")
end

local function MainEvents()
    local eventNames = {
        "MainEvent",
        "MAINEVENT",
        "Bullets",
        ".gg/untitledhood",
    }
    for _, child in pairs(game.ReplicatedStorage:GetChildren()) do
        for _, eventName in pairs(eventNames) do
            if child.Name == eventName then
                return child
            end
        end
    end
end

local function getClosestChar()
    local target, closestDist = nil, math.huge
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)

    for _, v in pairs(game.Players:GetPlayers()) do
        if v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart") then
            if Depart.Fighting.Silent.KOcheck and Death(v) then
                continue
            end

            local closestPart, closestPartDistance = nil, math.huge
            local partsToCheck = Depart.Fighting.Silent.MultipleParts

            for _, partName in pairs(partsToCheck) do
                local part = v.Character:FindFirstChild(partName)
                if part then
                    local partPos = Cam:WorldToScreenPoint(part.Position)
                    local distance = (Vector2.new(partPos.X, partPos.Y) - mousePos).Magnitude
                    if distance < closestPartDistance and distance < Depart.Fighting.Silent.fovSettings.FovRadius and WallCheck(part.Position, {Client, v.Character}) then
                        closestPartDistance = distance
                        closestPart = part
                    end
                end
            end

            if closestPart and closestPartDistance < closestDist then
                closestDist = closestPartDistance
                target = {Player = v, Part = closestPart}
            end
        end
    end
    return target
end

local function connectToolActivation(tool)
    if tool:IsA("Tool") then
        local debounce = false
        tool.Activated:Connect(function()
            if not debounce then
                debounce = true
                if Depart.Fighting.Silent.Activated then
                    local target = getClosestChar()
                    if target then
                        local endPoint = target.Part.Position + (target.Part.Velocity * Depart.Fighting.Silent.Prediction)
                        MainEvents():FireServer(getEventName(), endPoint)
                    end
                end
                task.wait(0.1)
                debounce = false
            end
        end)
    end
end

local function setupToolConnections()
    for _, tool in pairs(Client.Backpack:GetChildren()) do
        connectToolActivation(tool)
    end

    Client.Backpack.ChildAdded:Connect(function(tool)
        connectToolActivation(tool)
    end)
end

local function handleRespawn()
    task.wait(1)

    Cam = workspace.CurrentCamera
    Mouse = Client:GetMouse()

    setupToolConnections()

    FOV.Thickness = fovSettings.Thickness
    FOV.Color = fovSettings.Color
    FOV.Filled = fovSettings.Filled

    RunService.RenderStepped:Connect(function()
        UpdateFOV()
    end)
end

local function setupRespawnHandling()
    Client.CharacterAdded:Connect(function()
        handleRespawn()
    end)
end

handleRespawn()
setupRespawnHandling()

print 'Fuck Nigga Loaded!'
