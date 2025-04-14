--// Happy skidding \\--

-- Define the global config
getgenv().Config = {
    Triggerbot = {
        Settings = {
            Enabled = false,
            Delay = 0.1,
            Keybind = Enum.KeyCode.T,
            Mode = "Toggle", -- Options: "Toggle" or "Hold"
        }
    }
}

local GameReference = cloneref(Game)

if not GameReference:IsLoaded() then GameReference.Loaded:Wait() end

--// Services \\--
local Workspace = GameReference:GetService("Workspace")
local RunService = GameReference:GetService("RunService")
local Players = GameReference:GetService("Players")
local UserInputService = GameReference:GetService("UserInputService")

--// LocalPlayer \\--
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LocalHumanoid = LocalCharacter:FindFirstChildOfClass("Humanoid") or LocalCharacter:FindFirstChildWhichIsA("Humanoid") or LocalCharacter:WaitForChild("Humanoid")
local LocalRootPart = LocalHumanoid.RootPart or LocalCharacter:WaitForChild("HumanoidRootPart")
local LocalGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera") or Workspace:WaitForChild("Camera")

--// Variables \\--
local LastActivationTime = tick()
local IsKeyHeld = false

--// Triggerbot Settings \\--
local Triggerbot = getgenv().Config.Triggerbot  -- Accessing the global config

--// Circle \\--
local Circle = Drawing.new("Circle")
Circle.Visible = true
Circle.Transparency = 1
Circle.Color = Color3.fromRGB(255, 255, 255)
Circle.Filled = false
Circle.Radius = 150
Circle.NumSides = Circle.Radius * 100
Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

--// Functions \\--

--// LocalPlayer | CharacterAdded \\--
LocalPlayer.CharacterAdded:Connect(function(Character)
    LocalCharacter = Character
    LocalHumanoid = LocalCharacter:FindFirstChildOfClass("Humanoid") or LocalCharacter:FindFirstChildWhichIsA("Humanoid") or LocalCharacter:WaitForChild("Humanoid")
    LocalRootPart = LocalHumanoid.RootPart or LocalCharacter:WaitForChild("HumanoidRootPart")
end)

--// Checks If A Player Is Behind A Wall \\--
local function WallCheck(Part)
    local CameraPosition = Camera.CFrame.Position
    local PartPosition = Part.CFrame.Position
    local Direction = (PartPosition - CameraPosition).Unit
    local Distance = (PartPosition - CameraPosition).Magnitude

    local RayParams = RaycastParams.new()
    RayParams.FilterDescendantsInstances = {LocalCharacter, Camera}
    RayParams.FilterType = Enum.RaycastFilterType.Blacklist
    RayParams.IgnoreWater = true

    local Result = Workspace:Raycast(CameraPosition, Direction * Distance, RayParams)

    if Result then
        local HitPart = Result.Instance
        local HitModel = HitPart and HitPart:FindFirstAncestorOfClass("Model")
        local HitPlayer = HitModel and Players:GetPlayerFromCharacter(HitModel)

        if HitPlayer then
            return false
        elseif not HitPart or not HitModel or not HitPlayer then
            return true
        end
    end

    return false
end

--// Gets Aim Cursor Frame \\--
local function GetAimCursor()
    if LocalGui then
        local MainGui = LocalGui:FindFirstChild("MainScreenGui") or LocalGui:FindFirstChild("Main Screen") or LocalGui:FindFirstChild("MainScreen") or LocalGui:FindFirstChild("MainGui") or LocalGui:FindFirstChild("gui") or LocalGui:FindFirstChild("ScreenGui")
        if MainGui then
            local AimCursor = MainGui:FindFirstChild("Aim") or MainGui:FindFirstChild("AimUI")
            if AimCursor then
                return AimCursor
            end
        end
    end
    return nil
end

--// Get Player In Circle \\--
local function GetPlayerInCircle()
    local Distance = math.huge
    local PlayerInCircle = nil

    for Index, Player in ipairs(Players:GetPlayers()) do
        if Player.UserId ~= LocalPlayer.UserId and Player.Character then
            for IIndex, Child in ipairs(Player.Character:GetChildren()) do
                if (Child:IsA("BasePart") or Child:IsA("MeshPart") or Child:IsA("Part")) and Child.Transparency < 1 then
                    local ScreenPosition, OnScreen = Camera:WorldToScreenPoint(Child.Position)
                    local DistanceToCircleCenter = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - Circle.Position).Magnitude

                    if OnScreen and not WallCheck(Child) then
                        if Circle.Radius >= DistanceToCircleCenter then
                            if Distance >= DistanceToCircleCenter then
                                PlayerInCircle = DistanceToCircleCenter
                                Distance = DistanceToCircleCenter
                            end
                        end
                    end
                end
            end
        end
    end
    return PlayerInCircle
end

--// Keybind Handling \\--
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end

    if Input.KeyCode == Triggerbot.Settings.Keybind then
        if Triggerbot.Settings.Mode == "Toggle" then
            Triggerbot.Settings.Enabled = not Triggerbot.Settings.Enabled
        elseif Triggerbot.Settings.Mode == "Hold" then
            IsKeyHeld = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(Input, GameProcessed)
    if GameProcessed then return end

    if Input.KeyCode == Triggerbot.Settings.Keybind and Triggerbot.Settings.Mode == "Hold" then
        IsKeyHeld = false
    end
end)

--// Activates Tool When A Player In Circle \\--
RunService.Heartbeat:Connect(function()
    local ShouldRun = false

    if Triggerbot.Settings.Mode == "Toggle" and Triggerbot.Settings.Enabled then
        ShouldRun = true
    elseif Triggerbot.Settings.Mode == "Hold" and IsKeyHeld then
        ShouldRun = true
    end

    if ShouldRun then
        local TargetPlayer = GetPlayerInCircle()
        local AimCursor = GetAimCursor()

        if AimCursor then
            Circle.Position = AimCursor.AbsolutePosition
            Circle.Radius = ((AimCursor.AbsoluteSize.X + AimCursor.AbsoluteSize.Y) / 2) * 2.5
        end

        if TargetPlayer and (tick() - LastActivationTime) >= Triggerbot.Settings.Delay then
            if LocalCharacter and LocalHumanoid and LocalRootPart then
                local Tool = LocalCharacter:FindFirstChildOfClass("Tool")
                if Tool and Tool:FindFirstChild("Handle") then
                    Tool:Activate()
                    task.wait(0.1)
                    Tool:Deactivate()
                end
            end
            LastActivationTime = tick()
        end
    end
end)
