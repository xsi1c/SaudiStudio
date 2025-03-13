-- إنشاء واجهة المستخدم الرئيسية
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- متغيرات لتخزين البيانات
local teleportLocation = nil
local markEnabled = false
local healthThreshold = 50 -- القيمة الافتراضية 50%
local currentLanguage = "Arabic" -- اللغة الافتراضية
local resetOnDie = false -- تعطيل إعادة التعيين عند الموت

-- قاموس الترجمة
local translations = {
    Arabic = {
        title = "أداة التحكم بالانتقال",
        mainTab = "الرئيسية",
        teleportTab = "الانتقال",
        settingsTab = "الإعدادات",
        setLocation = "تعيين الموقع",
        teleport = "الانتقال",
        autoTeleport = "تفعيل الانتقال التلقائي",
        healthPercentage = "نسبة الصحة للانتقال التلقائي (%)",
        status = "الحالة: ",
        ready = "جاهز",
        locationSet = "تم تعيين الموقع!",
        teleported = "تم الانتقال!",
        autoTeleportEnabled = "تم تفعيل الانتقال التلقائي",
        autoTeleportDisabled = "تم تعطيل الانتقال التلقائي",
        thresholdSet = "تم تعيين العتبة إلى ",
        invalidThreshold = "قيمة عتبة غير صالحة",
        autoTeleported = "تم الانتقال تلقائيًا: صحة منخفضة",
        noLocationSet = "خطأ: لم يتم تعيين موقع",
        characterNotFound = "خطأ: لم يتم العثور على الشخصية",
        settingsTitle = "إعدادات البرنامج",
        transparency = "شفافية الواجهة",
        buttonColor = "لون الأزرار",
        saveSettings = "حفظ الإعدادات",
        resetSettings = "إعادة تعيين الإعدادات",
        language = "اللغة",
        settingsSaved = "تم حفظ الإعدادات",
        settingsReset = "تم إعادة تعيين الإعدادات",
        killScript = "إنهاء البرنامج"
    },
    English = {
        title = "Teleport Control Tool",
        mainTab = "Main",
        teleportTab = "Teleport", 
        settingsTab = "Settings",
        setLocation = "Set Location",
        teleport = "Teleport",
        autoTeleport = "Enable Auto-Teleport",
        healthPercentage = "Health Percentage for Auto-Teleport (%)",
        status = "Status: ",
        ready = "Ready",
        locationSet = "Location set!",
        teleported = "Teleported!",
        autoTeleportEnabled = "Auto-Teleport enabled",
        autoTeleportDisabled = "Auto-Teleport disabled", 
        thresholdSet = "Threshold set to ",
        invalidThreshold = "Invalid threshold value",
        autoTeleported = "Auto-Teleported: Low health",
        noLocationSet = "Error: No location set",
        characterNotFound = "Error: Character not found",
        settingsTitle = "Program Settings",
        transparency = "Interface Transparency",
        buttonColor = "Button Color",
        saveSettings = "Save Settings",
        resetSettings = "Reset Settings",
        language = "Language",
        settingsSaved = "Settings saved",
        settingsReset = "Settings reset",
        killScript = "Kill Script"
    }
}

-- دالة للحصول على النص المترجم
local function getText(key)
    return translations[currentLanguage][key] or key
end

-- دالة لإنشاء الإطار الرئيسي
local function createFrame()
    local frame = Instance.new("Frame")
    frame.Parent = screenGui
    frame.Size = UDim2.new(0, 400, 0, 400)
    frame.Position = UDim2.new(0.5, -200, 0.5, -200) -- توسيط الإطار
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    
    -- جعل الإطار قابل للسحب
    local dragging = false
    local dragInput, startPos
    
    frame.InputBegan:Connect(function(input)
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
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - startPos
            frame.Position = UDim2.new(
                frame.Position.X.Scale,
                frame.Position.X.Offset + delta.X,
                frame.Position.Y.Scale,
                frame.Position.Y.Offset + delta.Y
            )
            startPos = input.Position
        end
    end)

    -- إضافة زوايا مستديرة
    local UICorner = Instance.new("UICorner")
    UICorner.Parent = frame
    UICorner.CornerRadius = UDim.new(0, 12)
    
    -- شريط العنوان
    local titleBar = Instance.new("Frame")
    titleBar.Parent = frame
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    titleBar.BorderSizePixel = 0
    
    -- زوايا مستديرة لشريط العنوان
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = titleBar
    titleCorner.CornerRadius = UDim.new(0, 12)
    
    -- نص العنوان
    local titleText = Instance.new("TextLabel")
    titleText.Parent = titleBar
    titleText.Text = getText("title")
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.new(0, 80, 0, 0) -- تحريك النص للوسط
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.new(1, 1, 1)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Center
    
    -- زر تبديل اللغة (على اليسار)
    local languageButton = Instance.new("TextButton")
    languageButton.Parent = titleBar
    languageButton.Text = currentLanguage == "Arabic" and "EN" or "عربي"
    languageButton.Size = UDim2.new(0, 30, 0, 30)
    languageButton.Position = UDim2.new(0, 5, 0.5, -15)
    languageButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    languageButton.TextColor3 = Color3.new(1, 1, 1)
    languageButton.Font = Enum.Font.GothamBold
    languageButton.TextSize = 14
    
    -- زوايا مستديرة لزر اللغة
    local langCorner = Instance.new("UICorner")
    langCorner.Parent = languageButton
    langCorner.CornerRadius = UDim.new(0, 15)
    
    -- زر الخروج (على اليسار)
    local exitButton = Instance.new("TextButton")
    exitButton.Parent = titleBar
    exitButton.Text = "×"
    exitButton.Size = UDim2.new(0, 30, 0, 30)
    exitButton.Position = UDim2.new(0, 40, 0.5, -15)
    exitButton.BackgroundColor3 = Color3.fromRGB(174, 41, 41)
    exitButton.TextColor3 = Color3.new(1, 1, 1)
    exitButton.Font = Enum.Font.GothamBold
    exitButton.TextSize = 24
    
    -- زوايا مستديرة لزر الخروج
    local exitCorner = Instance.new("UICorner")
    exitCorner.Parent = exitButton
    exitCorner.CornerRadius = UDim.new(0, 15)

    -- [باقي الكود يبقى كما هو مع تعديل المواقع حسب الحاجة]

    -- إضافة وظائف الأزرار
    exitButton.MouseButton1Click:Connect(function()
        frame:Destroy()
    end)

    languageButton.MouseButton1Click:Connect(function()
        currentLanguage = currentLanguage == "English" and "Arabic" or "English"
        -- تحديث النصوص
        titleText.Text = getText("title")
        languageButton.Text = currentLanguage == "Arabic" and "EN" or "عربي"
        -- تحديث باقي النصوص في الواجهة
    end)

    return frame
end

-- إنشاء الأيقونة القابلة للسحب
local reopenIcon = Instance.new("ImageButton")
reopenIcon.Parent = screenGui
reopenIcon.Image = "rbxassetid://7592612672"
reopenIcon.Size = UDim2.new(0, 50, 0, 50)
reopenIcon.Position = UDim2.new(0.5, -25, 0, 15) -- توسيط الأيقونة
reopenIcon.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
reopenIcon.BackgroundTransparency = 0.2

-- جعل الأيقونة قابلة للسحب
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

-- زوايا مستديرة للأيقونة
local iconCorner = Instance.new("UICorner")
iconCorner.Parent = reopenIcon
iconCorner.CornerRadius = UDim.new(0, 25)

-- تأثير توهج للأيقونة
local iconGlow = Instance.new("UIStroke")
iconGlow.Parent = reopenIcon
iconGlow.Color = Color3.fromRGB(100, 100, 255)
iconGlow.Thickness = 2
iconGlow.Transparency = 0.5

-- تأثيرات التحويم
reopenIcon.MouseEnter:Connect(function()
    game:GetService("TweenService"):Create(reopenIcon, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    game:GetService("TweenService"):Create(iconGlow, TweenInfo.new(0.3), {Transparency = 0}):Play()
end)

reopenIcon.MouseLeave:Connect(function()
    game:GetService("TweenService"):Create(reopenIcon, TweenInfo.new(0.3), {BackgroundTransparency = 0.2}):Play()
    game:GetService("TweenService"):Create(iconGlow, TweenInfo.new(0.3), {Transparency = 0.5}):Play()
end)

-- إعادة فتح الإطار
local frame = createFrame()
reopenIcon.MouseButton1Click:Connect(function()
    if frame and frame.Parent then
        frame:Destroy()
        frame = nil
    else
        frame = createFrame()
    end
end)
