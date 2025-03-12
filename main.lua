-- main.lua

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local createFrame = require(script.Parent.ui)
local createTeleportTool = require(script.Parent.tools)

local player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local teleportLocation = nil
local markEnabled = false
local healthThreshold = 50

local frame, setLocationButton, teleportButton, markButton, teleportToolButton, healthInput, statusLabel, exitButton = createFrame(screenGui)

local function updateStatus(text)
    statusLabel.Text = "Status: " .. text
end

setLocationButton.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        teleportLocation = player.Character.HumanoidRootPart.CFrame
        updateStatus("Location set!")
        print("Teleport location set!")
    else
        updateStatus("Error: Character not found")
        warn("Player character or HumanoidRootPart not found!")
    end
end)

teleportButton.MouseButton1Click:Connect(function()
    if teleportLocation and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = teleportLocation
        updateStatus("Teleported!")
        print("Teleported!")
    else
        updateStatus("Error: No location set")
        warn("Teleport location not set or player character not found!")
    end
end)

markButton.MouseButton1Click:Connect(function()
    markEnabled = not markEnabled
    if markEnabled then
        markButton.BackgroundColor3 = Color3.fromRGB(46, 148, 94)
        updateStatus("Auto-Teleport enabled")
        print("Mark enabled: Auto-Teleport on low health!")
    else
        markButton.BackgroundColor3 = Color3.fromRGB(174, 41, 41)
        updateStatus("Auto-Teleport disabled")
        print("Mark disabled!")
    end
end)

healthInput.FocusLost:Connect(function()
    local input = tonumber(healthInput.Text)
    if input and input >= 0 and input <= 100 then
        healthThreshold = input
        updateStatus("Threshold set to " .. healthThreshold .. "%")
        print("Health threshold set to " .. healthThreshold .. "%")
    else
        warn("Invalid health percentage! Please enter a number between 0 and 100.")
        healthInput.Text = tostring(healthThreshold)
        updateStatus("Invalid threshold value")
    end
end)

local function monitorHealth()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if markEnabled and humanoid.Health < (humanoid.MaxHealth * (healthThreshold / 100)) then
                if teleportLocation then
                    player.Character.HumanoidRootPart.CFrame = teleportLocation
                    updateStatus("Auto-Teleported: Low health")
                    print("Auto-Teleported due to low health!")
                else
                    updateStatus("Error: No location set")
                    warn("Teleport location not set!")
                end
            end
        end)
    else
        warn("Player character or Humanoid not found!")
    end
end

monitorHealth()

exitButton.MouseButton1Click:Connect(function()
    frame:Destroy()
end)

teleportToolButton.MouseButton1Click:Connect(function()
    createTeleportTool(player)
    updateStatus("Teleport Tool added to backpack")
    print("Teleport Tool added to backpack!")
end)

local reopenIcon = Instance.new("ImageButton")
reopenIcon.Parent = screenGui
reopenIcon.Image = "rbxassetid://7592612672"
reopenIcon.Size = UDim2.new(0, 50, 0, 50)
reopenIcon.Position = UDim2.new(0, 15, 0, 15)
reopenIcon.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
reopenIcon.BackgroundTransparency = 0.2

local iconCorner = Instance.new("UICorner")
iconCorner.Parent = reopenIcon
iconCorner.CornerRadius = UDim.new(0, 25)

local iconGlow = Instance.new("UIStroke")
iconGlow.Parent = reopenIcon
iconGlow.Color = Color3.fromRGB(100, 100, 255)
iconGlow.Thickness = 2
iconGlow.Transparency = 0.5

local dragging = false
local dragInput, startPos

reopenIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        startPos = input.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

reopenIcon.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - startPos
        reopenIcon.Position = UDim2.new(
            reopenIcon.Position.X.Scale,
            reopenIcon.Position.X.Offset + delta.X,
            reopenIcon.Position.Y.Scale,
            reopenIcon.Position.Y.Offset + delta.Y
        )
        startPos = input.Position
    end
end)

reopenIcon.MouseEnter:Connect(function()
    TweenService:Create(reopenIcon, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(iconGlow, TweenInfo.new(0.3), {Transparency = 0}):Play()
end)

reopenIcon.MouseLeave:Connect(function()
    TweenService:Create(reopenIcon, TweenInfo.new(0.3), {BackgroundTransparency = 0.2}):Play()
    TweenService:Create(iconGlow, TweenInfo.new(0.3), {Transparency = 0.5}):Play()
end)

reopenIcon.MouseButton1Click:Connect(function()
    if frame and frame.Parent then
        frame:Destroy()
    else
        frame = createFrame(screenGui)
    end
end)