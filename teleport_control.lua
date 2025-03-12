-- ui.lua

local function createFrame(screenGui)
    local frame = Instance.new("Frame")
    frame.Parent = screenGui
    frame.Size = UDim2.new(0, 350, 0, 350)
    frame.Position = UDim2.new(0.5, -175, 0.5, -175)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    
    local UICorner = Instance.new("UICorner")
    UICorner.Parent = frame
    UICorner.CornerRadius = UDim.new(0, 12)
    
    local titleBar = Instance.new("Frame")
    titleBar.Parent = frame
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    titleBar.BorderSizePixel = 0
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = titleBar
    titleCorner.CornerRadius = UDim.new(0, 12)
    
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
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Parent = frame
    buttonContainer.Size = UDim2.new(1, -20, 1, -60)
    buttonContainer.Position = UDim2.new(0, 10, 0, 50)
    buttonContainer.BackgroundTransparency = 1
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = buttonContainer
    listLayout.Padding = UDim.new(0, 10)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    
    local function createStyledButton(text, color)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 45)
        button.BackgroundColor3 = color
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.GothamSemibold
        button.TextSize = 16
        button.Text = text
        button.AutoButtonColor = true
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.Parent = button
        buttonCorner.CornerRadius = UDim.new(0, 8)
        
        local shadow = Instance.new("Frame")
        shadow.Parent = button
        shadow.Size = UDim2.new(1, 2, 1, 2)
        shadow.Position = UDim2.new(0, -1, 0, -1)
        shadow.BackgroundColor3 = Color3.new(0, 0, 0)
        shadow.BackgroundTransparency = 0.7
        shadow.ZIndex = button.ZIndex - 1
        shadow.BorderSizePixel = 0
        
        local shadowCorner = Instance.new("UICorner")
        shadowCorner.Parent = shadow
        shadowCorner.CornerRadius = UDim.new(0, 8)
        
        return button
    end
    
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
    
    local setLocationButton, teleportButton = createButtonPair(
        "Set Location", 
        Color3.fromRGB(41, 98, 174), 
        "Teleport", 
        Color3.fromRGB(46, 148, 94)
    
    local markButton, teleportToolButton = createButtonPair(
        "Mark", 
        Color3.fromRGB(174, 41, 41), 
        "Teleport Tool", 
        Color3.fromRGB(90, 74, 164))
    
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
    healthInput.Text = "50"
    healthInput.ClipsDescendants = true
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.Parent = healthInput
    inputCorner.CornerRadius = UDim.new(0, 8)
    
    local statusContainer = Instance.new("Frame")
    statusContainer.Parent = buttonContainer
    statusContainer.Size = UDim2.new(1, 0, 0, 45)
    statusContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    statusContainer.BorderSizePixel = 0
    
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
    
    local exitButton = Instance.new("TextButton")
    exitButton.Parent = titleBar
    exitButton.Text = "×"
    exitButton.Size = UDim2.new(0, 30, 0, 30)
    exitButton.Position = UDim2.new(1, -35, 0.5, -15)
    exitButton.BackgroundColor3 = Color3.fromRGB(174, 41, 41)
    exitButton.TextColor3 = Color3.new(1, 1, 1)
    exitButton.Font = Enum.Font.GothamBold
    exitButton.TextSize = 24
    
    local exitCorner = Instance.new("UICorner")
    exitCorner.Parent = exitButton
    exitCorner.CornerRadius = UDim.new(0, 15)
    
    return frame, setLocationButton, teleportButton, markButton, teleportToolButton, healthInput, statusLabel, exitButton
end

return createFrame
