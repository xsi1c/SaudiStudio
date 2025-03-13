-- Create a ScreenGui to hold the UI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Variable to store the teleport location
local teleportLocation = nil

-- Variable to track the Mark Button state
local markEnabled = false

-- Variable to store the health percentage threshold
local healthThreshold = 50 -- Default to 50%

-- Function to create the main frame
local function createFrame()
    local frame = Instance.new("Frame")
    frame.Parent = screenGui
    frame.Size = UDim2.new(0, 350, 0, 350) -- Slightly wider and shorter
    frame.Position = UDim2.new(0.5, -175, 0.5, -175) -- Center the frame
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35) -- Dark blue-gray background
    frame.BackgroundTransparency = 0.1 -- More opaque
    frame.BorderSizePixel = 0 -- Remove the border
    
    -- Add rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.Parent = frame
    UICorner.CornerRadius = UDim.new(0, 12)
    
    -- Add a title bar
    local titleBar = Instance.new("Frame")
    titleBar.Parent = frame
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 65) -- Slightly lighter than the main frame
    titleBar.BorderSizePixel = 0
    
    -- Add rounded corners to title bar
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = titleBar
    titleCorner.CornerRadius = UDim.new(0, 12)
    
    -- Add title text
    local titleText = Instance.new("TextLabel")
    titleText.Parent = titleBar
    titleText.Text = "Teleport Control"
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 20, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.new(1, 1, 1)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Container for buttons
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Parent = frame
    buttonContainer.Size = UDim2.new(1, -20, 1, -60) -- Padding on all sides
    buttonContainer.Position = UDim2.new(0, 10, 0, 50) -- Position below title bar
    buttonContainer.BackgroundTransparency = 1
    
    -- Add a UIListLayout to organize buttons
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = buttonContainer
    listLayout.Padding = UDim.new(0, 10) -- Spacing between elements
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    
    -- Create a function to style buttons consistently
    local function createStyledButton(text, color)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 45)
        button.BackgroundColor3 = color
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.GothamSemibold
        button.TextSize = 16
        button.Text = text
        button.AutoButtonColor = true
        
        -- Add rounded corners to the button
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.Parent = button
        buttonCorner.CornerRadius = UDim.new(0, 8)
        
        -- Add a subtle shadow effect
        local shadow = Instance.new("Frame")
        shadow.Parent = button
        shadow.Size = UDim2.new(1, 2, 1, 2)
        shadow.Position = UDim2.new(0, -1, 0, -1)
        shadow.BackgroundColor3 = Color3.new(0, 0, 0)
        shadow.BackgroundTransparency = 0.7
        shadow.ZIndex = button.ZIndex - 1
        shadow.BorderSizePixel = 0
        
        -- Rounded corners for shadow
        local shadowCorner = Instance.new("UICorner")
        shadowCorner.Parent = shadow
        shadowCorner.CornerRadius = UDim.new(0, 8)
        
        return button
    end
    
    -- Create a function for button pairs
    local function createButtonPair(text1, color1, text2, color2)
        local pairContainer = Instance.new("Frame")
        pairContainer.Parent = buttonContainer
        pairContainer.Size = UDim2.new(1, 0, 0, 45)
        pairContainer.BackgroundTransparency = 1
        
        local button1 = createStyledButton(text1, color1)
        button1.Parent = pairContainer
        button1.Size = UDim2.new(0.48, 0, 1, 0)
        button1.Position = UDim2.new(0, 0, 0, 0)
        
        local button2 = createStyledButton(text2, color2)
        button2.Parent = pairContainer
        button2.Size = UDim2.new(0.48, 0, 1, 0)
        button2.Position = UDim2.new(0.52, 0, 0, 0)
        
        return button1, button2
    end
    
    -- Create button pairs
    local setLocationButton, teleportButton = createButtonPair(
        "Set Location", 
        Color3.fromRGB(41, 98, 174), -- Blue
        "Teleport", 
        Color3.fromRGB(46, 148, 94) -- Green
    )
    
    local markButton, teleportToolButton = createButtonPair(
        "Mark", 
        Color3.fromRGB(174, 41, 41), -- Red (disabled by default)
        "Teleport Tool", 
        Color3.fromRGB(90, 74, 164) -- Purple
    )
    
    -- Health input with label
    local healthContainer = Instance.new("Frame")
    healthContainer.Parent = buttonContainer
    healthContainer.Size = UDim2.new(1, 0, 0, 70)
    healthContainer.BackgroundTransparency = 1
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Parent = healthContainer
    healthLabel.Text = "Health Threshold (%)"
    healthLabel.Size = UDim2.new(1, 0, 0, 20)
    healthLabel.Position = UDim2.new(0, 0, 0, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.new(1, 1, 1)
    healthLabel.Font = Enum.Font.GothamMedium
    healthLabel.TextSize = 14
    healthLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local healthInput = Instance.new("TextBox")
    healthInput.Parent = healthContainer
    healthInput.PlaceholderText = "Enter Health % (e.g., 50)"
    healthInput.Size = UDim2.new(1, 0, 0, 45)
    healthInput.Position = UDim2.new(0, 0, 0, 25)
    healthInput.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    healthInput.TextColor3 = Color3.new(1, 1, 1)
    healthInput.Font = Enum.Font.GothamSemibold
    healthInput.TextSize = 16
    healthInput.Text = tostring(healthThreshold) -- Default value
    healthInput.ClipsDescendants = true
    
    -- Add rounded corners to the input
    local inputCorner = Instance.new("UICorner")
    inputCorner.Parent = healthInput
    inputCorner.CornerRadius = UDim.new(0, 8)
    
    -- Status indicator
    local statusContainer = Instance.new("Frame")
    statusContainer.Parent = buttonContainer
    statusContainer.Size = UDim2.new(1, 0, 0, 45)
    statusContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    statusContainer.BorderSizePixel = 0
    
    -- Add rounded corners to status container
    local statusCorner = Instance.new("UICorner")
    statusCorner.Parent = statusContainer
    statusCorner.CornerRadius = UDim.new(0, 8)
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Parent = statusContainer
    statusLabel.Text = "Status: Ready"
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.new(1, 1, 1)
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.TextSize = 14
    
    -- Add an Exit Button
    local exitButton = Instance.new("TextButton")
    exitButton.Parent = titleBar
    exitButton.Text = "×"
    exitButton.Size = UDim2.new(0, 30, 0, 30)
    exitButton.Position = UDim2.new(1, -35, 0.5, -15)
    exitButton.BackgroundColor3 = Color3.fromRGB(174, 41, 41) -- Red
    exitButton.TextColor3 = Color3.new(1, 1, 1)
    exitButton.Font = Enum.Font.GothamBold
    exitButton.TextSize = 24
    
    -- Add rounded corners to exit button
    local exitCorner = Instance.new("UICorner")
    exitCorner.Parent = exitButton
    exitCorner.CornerRadius = UDim.new(0, 15) -- Fully rounded
    
    -- Function to update the status text
    local function updateStatus(text)
        statusLabel.Text = "Status: " .. text
    end
    
    -- Function to save the player's current position as the teleport location
    setLocationButton.MouseButton1Click:Connect(function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            teleportLocation = player.Character.HumanoidRootPart.CFrame
            updateStatus("Location set!")
            print("Teleport location set!")
        else
            updateStatus("Error: Character not found")
            warn("Player character or HumanoidRootPart not found!")
        end
    end)

    -- Function to teleport the player to the saved location
    teleportButton.MouseButton1Click:Connect(function()
        local player = game.Players.LocalPlayer
        if teleportLocation and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = teleportLocation
            updateStatus("Teleported!")
            print("Teleported!")
        else
            updateStatus("Error: No location set")
            warn("Teleport location not set or player character not found!")
        end
    end)

    -- Function to toggle the Mark Button state
    markButton.MouseButton1Click:Connect(function()
        markEnabled = not markEnabled -- Toggle the state
        if markEnabled then
            markButton.BackgroundColor3 = Color3.fromRGB(46, 148, 94) -- Green (enabled)
            updateStatus("Auto-Teleport enabled")
            print("Mark enabled: Auto-Teleport on low health!")
        else
            markButton.BackgroundColor3 = Color3.fromRGB(174, 41, 41) -- Red (disabled)
            updateStatus("Auto-Teleport disabled")
            print("Mark disabled!")
        end
    end)

    -- Function to update the health threshold
    healthInput.FocusLost:Connect(function()
        local input = tonumber(healthInput.Text)
        if input and input >= 0 and input <= 100 then
            healthThreshold = input
            updateStatus("Threshold set to " .. healthThreshold .. "%")
            print("Health threshold set to " .. healthThreshold .. "%")
        else
            warn("Invalid health percentage! Please enter a number between 0 and 100.")
            healthInput.Text = tostring(healthThreshold) -- Reset to previous value
            updateStatus("Invalid threshold value")
        end
    end)

    -- Function to monitor player health and auto-teleport if enabled
    local function monitorHealth()
        local player = game.Players.LocalPlayer
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

    -- Start monitoring player health
    monitorHealth()

    -- Function to delete the frame when the exit button is clicked
    exitButton.MouseButton1Click:Connect(function()
        frame:Destroy() -- Delete the frame
    end)

    -- Function to give the player a teleport tool
    teleportToolButton.MouseButton1Click:Connect(function()
        local tool = Instance.new("Tool")
        tool.Name = "TeleportTool"
        tool.Parent = game.Players.LocalPlayer.Backpack
        tool.ToolTip = "Click to teleport to a location"
        
        -- Add a handle to the tool
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Parent = tool
        handle.Size = Vector3.new(1, 1, 3)
        handle.BrickColor = BrickColor.new("Royal purple")
        handle.Material = Enum.Material.Neon
        
        tool.Activated:Connect(function()
            local player = game.Players.LocalPlayer
            local mouse = player:GetMouse()
            local target = mouse.Hit.Position
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(target)
                updateStatus("Used teleport tool")
                print("Teleported to clicked location!")
            else
                updateStatus("Error: Character not found")
                warn("Player character or HumanoidRootPart not found!")
            end
        end)

        updateStatus("Teleport Tool added to backpack")
        print("Teleport Tool added to backpack!")
    end)

    return frame
end

-- Create the initial frame
local frame = createFrame()

-- Add a small icon to reopen the frame
local reopenIcon = Instance.new("ImageButton")
reopenIcon.Parent = screenGui
reopenIcon.Image = "rbxassetid://7592612672" -- Roblox image ID
reopenIcon.Size = UDim2.new(0, 50, 0, 50) -- 50x50 pixels
reopenIcon.Position = UDim2.new(0, 15, 0, 15) -- Top-left corner
reopenIcon.BackgroundColor3 = Color3.fromRGB(45, 45, 65) -- Match title bar color
reopenIcon.BackgroundTransparency = 0.2 -- Slightly transparent

-- Add rounded corners to icon
local iconCorner = Instance.new("UICorner")
iconCorner.Parent = reopenIcon
iconCorner.CornerRadius = UDim.new(0, 25) -- Fully rounded

-- Add a subtle glow effect
local iconGlow = Instance.new("UIStroke")
iconGlow.Parent = reopenIcon
iconGlow.Color = Color3.fromRGB(100, 100, 255)
iconGlow.Thickness = 2
iconGlow.Transparency = 0.5

-- Make the reopen icon movable
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

game:GetService("UserInputService").InputChanged:Connect(function(input)
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

-- Add hover effect to the reopen icon
reopenIcon.MouseEnter:Connect(function()
    game:GetService("TweenService"):Create(reopenIcon, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    game:GetService("TweenService"):Create(iconGlow, TweenInfo.new(0.3), {Transparency = 0}):Play()
end)

reopenIcon.MouseLeave:Connect(function()
    game:GetService("TweenService"):Create(reopenIcon, TweenInfo.new(0.3), {BackgroundTransparency = 0.2}):Play()
    game:GetService("TweenService"):Create(iconGlow, TweenInfo.new(0.3), {Transparency = 0.5}):Play()
end)

-- Function to reopen the frame when the icon is clicked
reopenIcon.MouseButton1Click:Connect(function()
    if frame and frame.Parent then -- Check if the frame is open
        frame:Destroy() -- Close the frame (like the exit button)
    else
        frame = createFrame() -- Recreate the frame
    end
end)