-- إنشاء واجهة المستخدم الرئيسية
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- متغيرات لتخزين البيانات
local teleportLocation = nil
local markEnabled = false
local healthThreshold = 50 -- القيمة الافتراضية 50%
local flyEnabled = false
local noclipEnabled = false
local speedMultiplier = 1 -- مضاعف السرعة الافتراضي
local currentLanguage = "Arabic" -- اللغة الافتراضية
local resetOnDie = false -- تعطيل إعادة التعيين عند الموت

-- قاموس الترجمة
local translations = {
    Arabic = {
        title = "أداة التحكم بالانتقال",
        mainTab = "الرئيسية",
        teleportTab = "الانتقال",
        itemsTab = "الأدوات",
        settingsTab = "الإعدادات",
        setLocation = "تعيين الموقع",
        teleport = "الانتقال",
        autoTeleport = "تفعيل الانتقال التلقائي",
        teleportTool = "أداة الانتقال",
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
        toolsTitle = "قائمة الأدوات",
        select = "تحديد",
        cancel = "إلغاء",
        getSelectedItems = "جلب العناصر المحددة",
        settingsTitle = "إعدادات البرنامج",
        transparency = "شفافية الواجهة",
        buttonColor = "لون الأزرار",
        saveSettings = "حفظ الإعدادات",
        resetSettings = "إعادة تعيين الإعدادات",
        language = "اللغة",
        noclipTool = "أداة اختراق الجدران",
        flyTool = "أداة الطيران",
        speedTool = "أداة السرعة",
        speedValue = "قيمة السرعة:",
        settingsSaved = "تم حفظ الإعدادات",
        settingsReset = "تم إعادة تعيين الإعدادات",
        noclipEnabled = "تم تفعيل اختراق الجدران",
        noclipDisabled = "تم تعطيل اختراق الجدران",
        flyEnabled = "تم تفعيل الطيران",
        flyDisabled = "تم تعطيل الطيران",
        speedChanged = "تم تغيير السرعة إلى: ",
        toolAdded = "تمت إضافة الأداة إلى الحقيبة",
        killScript = "إنهاء البرنامج"
    },
    English = {
        title = "Teleport Control Tool",
        mainTab = "Main",
        teleportTab = "Teleport",
        itemsTab = "Tools",
        settingsTab = "Settings",
        setLocation = "Set Location",
        teleport = "Teleport",
        autoTeleport = "Enable Auto-Teleport",
        teleportTool = "Teleport Tool",
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
        toolsTitle = "Tools List",
        select = "Select",
        cancel = "Cancel",
        getSelectedItems = "Get Selected Tools",
        settingsTitle = "Program Settings",
        transparency = "Interface Transparency",
        buttonColor = "Button Color",
        saveSettings = "Save Settings",
        resetSettings = "Reset Settings",
        language = "Language",
        noclipTool = "Noclip Tool",
        flyTool = "Fly Tool",
        speedTool = "Speed Tool",
        speedValue = "Speed Value:",
        settingsSaved = "Settings saved",
        settingsReset = "Settings reset",
        noclipEnabled = "Noclip enabled",
        noclipDisabled = "Noclip disabled",
        flyEnabled = "Fly enabled",
        flyDisabled = "Fly disabled",
        speedChanged = "Speed changed to: ",
        toolAdded = "Tool added to backpack",
        killScript = "Kill Script"
    }
}

-- دالة للحصول على النص المترجم
local function getText(key)
    return translations[currentLanguage][key] or key
end

-- دالة لحفظ الإعدادات
local function saveSettings(settings)
    local success, errorMsg = pcall(function()
        writefile("teleport_tool_settings.json", game:GetService("HttpService"):JSONEncode(settings))
    end)
    
    if not success then
        warn("Failed to save settings: " .. errorMsg)
    end
end

-- دالة لتحميل الإعدادات
local function loadSettings()
    local success, result = pcall(function()
        if isfile("teleport_tool_settings.json") then
            return game:GetService("HttpService"):JSONDecode(readfile("teleport_tool_settings.json"))
        end
        return nil
    end)
    
    if success and result then
        return result
    else
        return {
            transparency = 0.1,
            buttonColor = Color3.fromRGB(41, 98, 174),
            language = "Arabic",
            healthThreshold = 50,
            speedMultiplier = 1
        }
    end
end

-- تحميل الإعدادات المحفوظة
local savedSettings = loadSettings()
if savedSettings then
    healthThreshold = savedSettings.healthThreshold or healthThreshold
    speedMultiplier = savedSettings.speedMultiplier or speedMultiplier
    currentLanguage = savedSettings.language or currentLanguage
end

-- دالة لإنشاء الإطار الرئيسي
local function createFrame()
    local frame = Instance.new("Frame")
    frame.Parent = screenGui
    frame.Size = UDim2.new(0, 400, 0, 400) -- أكبر قليلاً
    frame.Position = UDim2.new(0.5, -200, 0.5, -200) -- في وسط الشاشة
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- خلفية سوداء
    frame.BackgroundTransparency = savedSettings.transparency or 0.1 -- شفافية من الإعدادات
    frame.BorderSizePixel = 0 -- إزالة الحدود
    
    -- إضافة زوايا مستديرة
    local UICorner = Instance.new("UICorner")
    UICorner.Parent = frame
    UICorner.CornerRadius = UDim.new(0, 12)
    
    -- شريط العنوان
    local titleBar = Instance.new("Frame")
    titleBar.Parent = frame
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 65) -- لون أفتح قليلاً من الإطار الرئيسي
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
    titleText.Position = UDim2.new(0, 20, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.new(1, 1, 1)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- زر تبديل اللغة
    local languageButton = Instance.new("TextButton")
    languageButton.Parent = titleBar
    languageButton.Text = currentLanguage == "Arabic" and "EN" or "عربي"
    languageButton.Size = UDim2.new(0, 30, 0, 30)
    languageButton.Position = UDim2.new(1, -70, 0.5, -15)
    languageButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    languageButton.TextColor3 = Color3.new(1, 1, 1)
    languageButton.Font = Enum.Font.GothamBold
    languageButton.TextSize = 14
    
    -- زوايا مستديرة لزر اللغة
    local langCorner = Instance.new("UICorner")
    langCorner.Parent = languageButton
    langCorner.CornerRadius = UDim.new(0, 15)
    
    -- إضافة زر الخروج
    local exitButton = Instance.new("TextButton")
    exitButton.Parent = titleBar
    exitButton.Text = "×"
    exitButton.Size = UDim2.new(0, 30, 0, 30)
    exitButton.Position = UDim2.new(1, -35, 0.5, -15)
    exitButton.BackgroundColor3 = Color3.fromRGB(174, 41, 41) -- أحمر
    exitButton.TextColor3 = Color3.new(1, 1, 1)
    exitButton.Font = Enum.Font.GothamBold
    exitButton.TextSize = 24
    
    -- زوايا مستديرة لزر الخروج
    local exitCorner = Instance.new("UICorner")
    exitCorner.Parent = exitButton
    exitCorner.CornerRadius = UDim.new(0, 15) -- دائري تماماً
    
    -- إنشاء نظام التبويب
    local tabContainer = Instance.new("Frame")
    tabContainer.Parent = frame
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    tabContainer.BorderSizePixel = 0
    
    -- إنشاء حاوية المحتوى
    local contentContainer = Instance.new("Frame")
    contentContainer.Parent = frame
    contentContainer.Size = UDim2.new(1, 0, 1, -80)
    contentContainer.Position = UDim2.new(0, 0, 0, 80)
    contentContainer.BackgroundTransparency = 1
    
    -- دالة لإنشاء زر تبويب
    local function createTabButton(text, position)
        local tabButton = Instance.new("TextButton")
        tabButton.Parent = tabContainer
        tabButton.Text = text
        tabButton.Size = UDim2.new(0.25, 0, 1, 0)
        tabButton.Position = UDim2.new(0.25 * position, 0, 0, 0)
        tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        tabButton.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.TextSize = 14
        tabButton.BorderSizePixel = 0
        
        return tabButton
    end
    
    -- إنشاء أزرار التبويب
    local mainTabButton = createTabButton(getText("mainTab"), 0)
    local teleportTabButton = createTabButton(getText("teleportTab"), 1)
    local itemsTabButton = createTabButton(getText("itemsTab"), 2)
    local settingsTabButton = createTabButton(getText("settingsTab"), 3)
    
    -- إنشاء صفحات المحتوى
    local mainTab = Instance.new("Frame")
    mainTab.Parent = contentContainer
    mainTab.Size = UDim2.new(1, 0, 1, 0)
    mainTab.BackgroundTransparency = 1
    mainTab.Visible = true
    
    local teleportTab = Instance.new("Frame")
    teleportTab.Parent = contentContainer
    teleportTab.Size = UDim2.new(1, 0, 1, 0)
    teleportTab.BackgroundTransparency = 1
    teleportTab.Visible = false
    
    local itemsTab = Instance.new("Frame")
    itemsTab.Parent = contentContainer
    itemsTab.Size = UDim2.new(1, 0, 1, 0)
    itemsTab.BackgroundTransparency = 1
    itemsTab.Visible = false
    
    local settingsTab = Instance.new("Frame")
    settingsTab.Parent = contentContainer
    settingsTab.Size = UDim2.new(1, 0, 1, 0)
    settingsTab.BackgroundTransparency = 1
    settingsTab.Visible = false
    
    -- دالة لتبديل التبويبات
    local function switchTab(tabFrame)
        mainTab.Visible = false
        teleportTab.Visible = false
        itemsTab.Visible = false
        settingsTab.Visible = false
        
        mainTabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        teleportTabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        itemsTabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        settingsTabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        
        tabFrame.Visible = true
        
        if tabFrame == mainTab then
            mainTabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        elseif tabFrame == teleportTab then
            teleportTabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        elseif tabFrame == itemsTab then
            itemsTabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        elseif tabFrame == settingsTab then
            settingsTabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        end
    end
    
    -- ربط أزرار التبويب بالوظائف
    mainTabButton.MouseButton1Click:Connect(function()
        switchTab(mainTab)
    end)
    
    teleportTabButton.MouseButton1Click:Connect(function()
        switchTab(teleportTab)
    end)
    
    itemsTabButton.MouseButton1Click:Connect(function()
        switchTab(itemsTab)
    end)
    
    settingsTabButton.MouseButton1Click:Connect(function()
        switchTab(settingsTab)
    end)
    
    -- دالة لإنشاء زر منسق
    local function createStyledButton(parent, text, color, size, position)
        local button = Instance.new("TextButton")
        button.Parent = parent
        button.Size = size or UDim2.new(1, 0, 0, 45)
        button.Position = position or UDim2.new(0, 0, 0, 0)
        button.BackgroundColor3 = color
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.GothamSemibold
        button.TextSize = 16
        button.Text = text
        button.AutoButtonColor = true
        
        -- إضافة زوايا مستديرة للزر
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.Parent = button
        buttonCorner.CornerRadius = UDim.new(0, 8)
        
        -- إضافة تأثير ظل خفيف
        local shadow = Instance.new("Frame")
        shadow.Parent = button
        shadow.Size = UDim2.new(1, 2, 1, 2)
        shadow.Position = UDim2.new(0, -1, 0, -1)
        shadow.BackgroundColor3 = Color3.new(0, 0, 0)
        shadow.BackgroundTransparency = 0.7
        shadow.ZIndex = button.ZIndex - 1
        shadow.BorderSizePixel = 0
        
        -- زوايا مستديرة للظل
        local shadowCorner = Instance.new("UICorner")
        shadowCorner.Parent = shadow
        shadowCorner.CornerRadius = UDim.new(0, 8)
        
        return button
    end
    
    -- دالة لإنشاء تسمية منسقة
    local function createStyledLabel(parent, text, size, position)
        local label = Instance.new("TextLabel")
        label.Parent = parent
        label.Text = text
        label.Size = size or UDim2.new(1, 0, 0, 30)
        label.Position = position or UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        return label
    end
    
    -- إنشاء محتوى التبويب الرئيسي
    local mainContent = Instance.new("Frame")
    mainContent.Parent = mainTab
    mainContent.Size = UDim2.new(1, -40, 1, -20)
    mainContent.Position = UDim2.new(0, 20, 0, 10)
    mainContent.BackgroundTransparency = 1
    
    -- إضافة شعار أو صورة
    local logoImage = Instance.new("ImageLabel")
    logoImage.Parent = mainContent
    logoImage.Size = UDim2.new(0, 100, 0, 100)
    logoImage.Position = UDim2.new(0.5, -50, 0, 20)
    logoImage.BackgroundTransparency = 1
    logoImage.Image = "rbxassetid://7592612672" -- استبدل برقم الصورة المناسب
    
    -- إضافة عنوان البرنامج
    local appTitle = createStyledLabel(mainContent, getText("title"), UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 130))
    appTitle.TextSize = 24
    appTitle.Font = Enum.Font.GothamBold
    appTitle.TextXAlignment = Enum.TextXAlignment.Center
    
    -- إضافة معلومات المطور
    local creatorInfo = createStyledLabel(mainContent, "تم التطوير بواسطة: xsi1c", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 180))
    creatorInfo.TextXAlignment = Enum.TextXAlignment.Center
    
    local discordInfo = createStyledLabel(mainContent, "ديسكورد: xsi1c", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 210))
    discordInfo.TextXAlignment = Enum.TextXAlignment.Center
    
    -- إضافة وصف مختصر
    local description = createStyledLabel(mainContent, "أداة متقدمة للانتقال والتحكم في اللعبة مع ميزات متعددة", UDim2.new(1, 0, 0, 60), UDim2.new(0, 0, 0, 250))
    description.TextWrapped = true
    description.TextXAlignment = Enum.TextXAlignment.Center
    
    -- إضافة زر إنهاء البرنامج
    local killScriptButton = createStyledButton(mainContent, getText("killScript"), Color3.fromRGB(174, 41, 41), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 320))
    
    -- إنشاء محتوى تبويب الانتقال
    local teleportContent = Instance.new("ScrollingFrame")
    teleportContent.Parent = teleportTab
    teleportContent.Size = UDim2.new(1, -40, 1, -20)
    teleportContent.Position = UDim2.new(0, 20, 0, 10)
    teleportContent.BackgroundTransparency = 1
    teleportContent.ScrollBarThickness = 6
    teleportContent.CanvasSize = UDim2.new(0, 0, 0, 400) -- يمكن تعديله حسب المحتوى
    
    -- إضافة أزرار الانتقال
    local setLocationButton = createStyledButton(teleportContent, getText("setLocation"), Color3.fromRGB(41, 98, 174), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 10))
    
    local teleportButton = createStyledButton(teleportContent, getText("teleport"), Color3.fromRGB(46, 148, 94), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 65))
    
    local markButton = createStyledButton(teleportContent, getText("autoTeleport"), Color3.fromRGB(174, 41, 41), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 120))
    
    -- إضافة مدخل نسبة الصحة
    local healthLabel = createStyledLabel(teleportContent, getText("healthPercentage"), UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 175))
    
    local healthInput = Instance.new("TextBox")
    healthInput.Parent = teleportContent
    healthInput.PlaceholderText = "50"
    healthInput.Size = UDim2.new(1, 0, 0, 45)
    healthInput.Position = UDim2.new(0, 0, 0, 205)
    healthInput.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    healthInput.TextColor3 = Color3.new(1, 1, 1)
    healthInput.Font = Enum.Font.GothamSemibold
    healthInput.TextSize = 16
    healthInput.Text = tostring(healthThreshold) -- القيمة الافتراضية
    healthInput.ClipsDescendants = true
    
    -- إضافة زوايا مستديرة للمدخل
    local inputCorner = Instance.new("UICorner")
    inputCorner.Parent = healthInput
    inputCorner.CornerRadius = UDim.new(0, 8)
    
    -- إضافة مؤشر الحالة
    local statusContainer = Instance.new("Frame")
    statusContainer.Parent = teleportContent
    statusContainer.Size = UDim2.new(1, 0, 0, 45)
    statusContainer.Position = UDim2.new(0, 0, 0, 260)
    statusContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    statusContainer.BorderSizePixel = 0
    
    -- إضافة زوايا مستديرة لحاوية الحالة
    local statusCorner = Instance.new("UICorner")
    statusCorner.Parent = statusContainer
    statusCorner.CornerRadius = UDim.new(0, 8)
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Parent = statusContainer
    statusLabel.Text = getText("status") .. getText("ready")
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.new(1, 1, 1)
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.TextSize = 14
    
    -- إنشاء محتوى تبويب الأدوات
    local itemsContent = Instance.new("ScrollingFrame")
    itemsContent.Parent = itemsTab
    itemsContent.Size = UDim2.new(1, -40, 1, -20)
    itemsContent.Position = UDim2.new(0, 20, 0, 10)
    itemsContent.BackgroundTransparency = 1
    itemsContent.ScrollBarThickness = 6
    itemsContent.CanvasSize = UDim2.new(0, 0, 0, 500) -- زيادة المساحة للأدوات الإضافية
    
    -- إضافة عنوان قائمة الأدوات
    local itemsTitle = createStyledLabel(itemsContent, getText("toolsTitle"), UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 10))
    itemsTitle.TextSize = 18
    itemsTitle.Font = Enum.Font.GothamBold
    
    -- إضافة أدوات متعددة
    local teleportToolButton = createStyledButton(itemsContent, getText("teleportTool"), Color3.fromRGB(90, 74, 164), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 50))
    
    local noclipToolButton = createStyledButton(itemsContent, getText("noclipTool"), Color3.fromRGB(174, 120, 41), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 105))
    
    local flyToolButton = createStyledButton(itemsContent, getText("flyTool"), Color3.fromRGB(41, 174, 125), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 160))
    
    -- إضافة أداة السرعة مع شريط تمرير
    local speedToolButton = createStyledButton(itemsContent, getText("speedTool"), Color3.fromRGB(174, 41, 125), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 215))
    
    local speedLabel = createStyledLabel(itemsContent, getText("speedValue") .. " " .. speedMultiplier, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 270))
    
    local speedSlider = Instance.new("Frame")
    speedSlider.Parent = itemsContent
    speedSlider.Size = UDim2.new(1, 0, 0, 30)
    speedSlider.Position = UDim2.new(0, 0, 0, 300)
    speedSlider.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    
    -- إضافة زوايا مستديرة للشريط
    local speedSliderCorner = Instance.new("UICorner")
    speedSliderCorner.Parent = speedSlider
    speedSliderCorner.CornerRadius = UDim.new(0, 8)
    
    -- إضافة مؤشر الشريط
    local speedIndicator = Instance.new("Frame")
    speedIndicator.Parent = speedSlider
    speedIndicator.Size = UDim2.new(speedMultiplier / 10, 0, 1, 0) -- القيمة الافتراضية
-- إنشاء واجهة المستخدم الرئيسية
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- متغيرات لتخزين البيانات
local teleportLocation = nil
local markEnabled = false
local healthThreshold = 50 -- القيمة الافتراضية 50%
local selectedItems = {} -- لتخزين العناصر المحددة
local flyEnabled = false
local noclipEnabled = false
local speedMultiplier = 1 -- مضاعف السرعة الافتراضي
local currentLanguage = "Arabic" -- اللغة الافتراضية
local resetOnDie = false -- تعطيل إعادة التعيين عند الموت

-- قاموس الترجمة
local translations = {
    Arabic = {
        title = "أداة التحكم بالانتقال",
        mainTab = "الرئيسية",
        teleportTab = "الانتقال",
        itemsTab = "الأدوات",
        settingsTab = "الإعدادات",
        setLocation = "تعيين الموقع",
        teleport = "الانتقال",
        autoTeleport = "تفعيل الانتقال التلقائي",
        teleportTool = "أداة الانتقال",
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
        toolsTitle = "قائمة الأدوات",
        select = "تحديد",
        cancel = "إلغاء",
        getSelectedItems = "جلب العناصر المحددة",
        settingsTitle = "إعدادات البرنامج",
        transparency = "شفافية الواجهة",
        buttonColor = "لون الأزرار",
        saveSettings = "حفظ الإعدادات",
        resetSettings = "إعادة تعيين الإعدادات",
        language = "اللغة",
        noclipTool = "أداة اختراق الجدران",
        flyTool = "أداة الطيران",
        speedTool = "أداة السرعة",
        speedValue = "قيمة السرعة:",
        settingsSaved = "تم حفظ الإعدادات",
        settingsReset = "تم إعادة تعيين الإعدادات",
        noclipEnabled = "تم تفعيل اختراق الجدران",
        noclipDisabled = "تم تعطيل اختراق الجدران",
        flyEnabled = "تم تفعيل الطيران",
        flyDisabled = "تم تعطيل الطيران",
        speedChanged = "تم تغيير السرعة إلى: ",
        toolAdded = "تمت إضافة الأداة إلى الحقيبة",
        killScript = "إنهاء البرنامج"
    },
    English = {
        title = "Teleport Control Tool",
        mainTab = "Main",
        teleportTab = "Teleport",
        itemsTab = "Tools",
        settingsTab = "Settings",
        setLocation = "Set Location",
        teleport = "Teleport",
        autoTeleport = "Enable Auto-Teleport",
        teleportTool = "Teleport Tool",
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
        toolsTitle = "Tools List",
        select = "Select",
        cancel = "Cancel",
        getSelectedItems = "Get Selected Tools",
        settingsTitle = "Program Settings",
        transparency = "Interface Transparency",
        buttonColor = "Button Color",
        saveSettings = "Save Settings",
        resetSettings = "Reset Settings",
        language = "Language",
        noclipTool = "Noclip Tool",
        flyTool = "Fly Tool",
        speedTool = "Speed Tool",
        speedValue = "Speed Value:",
        settingsSaved = "Settings saved",
        settingsReset = "Settings reset",
        noclipEnabled = "Noclip enabled",
        noclipDisabled = "Noclip disabled",
        flyEnabled = "Fly enabled",
        flyDisabled = "Fly disabled",
        speedChanged = "Speed changed to: ",
        toolAdded = "Tool added to backpack",
        killScript = "Kill Script"
    }
}

-- دالة للحصول على النص المترجم
local function getText(key)
    return translations[currentLanguage][key] or key
end

-- دالة لحفظ الإعدادات
local function saveSettings(settings)
    local success, errorMsg = pcall(function()
        writefile("teleport_tool_settings.json", game:GetService("HttpService"):JSONEncode(settings))
    end)
    
    if not success then
        warn("Failed to save settings: " .. errorMsg)
    end
end

-- دالة لتحميل الإعدادات
local function loadSettings()
    local success, result = pcall(function()
        if isfile("teleport_tool_settings.json") then
            return game:GetService("HttpService"):JSONDecode(readfile("teleport_tool_settings.json"))
        end
        return nil
    end)
    
    if success and result then
        return result
    else
        return {
            transparency = 0.1,
            buttonColor = Color3.fromRGB(41, 98, 174),
            language = "Arabic",
            healthThreshold = 50,
            speedMultiplier = 1
        }
    end
end

-- تحميل الإعدادات المحفوظة
local savedSettings = loadSettings()
if savedSettings then
    healthThreshold = savedSettings.healthThreshold or healthThreshold
    speedMultiplier = savedSettings.speedMultiplier or speedMultiplier
    currentLanguage = savedSettings.language or currentLanguage
end

-- دالة لإنشاء الإطار الرئيسي
local function createFrame()
    local frame = Instance.new("Frame")
    frame.Parent = screenGui
    frame.Size = UDim2.new(0, 400, 0, 400) -- أكبر قليلاً
    frame.Position = UDim2.new(0, 20, 0.5, -200) -- على اليسار
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- خلفية سوداء
    frame.BackgroundTransparency = savedSettings.transparency or 0.1 -- شفافية من الإعدادات
    frame.BorderSizePixel = 0 -- إزالة الحدود
    
    -- إضافة زوايا مستديرة
    local UICorner = Instance.new("UICorner")
    UICorner.Parent = frame
    UICorner.CornerRadius = UDim.new(0, 12)
    
    -- شريط العنوان
    local titleBar = Instance.new("Frame")
    titleBar.Parent = frame
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 65) -- لون أفتح قليلاً من الإطار الرئيسي
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
    titleText.Position = UDim2.new(0, 20, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.new(1, 1, 1)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- زر تبديل اللغة
    local languageButton = Instance.new("TextButton")
    languageButton.Parent = titleBar
    languageButton.Text = currentLanguage == "Arabic" and "EN" or "عربي"
    languageButton.Size = UDim2.new(0, 30, 0, 30)
    languageButton.Position = UDim2.new(1, -70, 0.5, -15)
    languageButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    languageButton.TextColor3 = Color3.new(1, 1, 1)
    languageButton.Font = Enum.Font.GothamBold
    languageButton.TextSize = 14
    
    -- زوايا مستديرة لزر اللغة
    local langCorner = Instance.new("UICorner")
    langCorner.Parent = languageButton
    langCorner.CornerRadius = UDim.new(0, 15)
    
    -- إضافة زر الخروج
    local exitButton = Instance.new("TextButton")
    exitButton.Parent = titleBar
    exitButton.Text = "×"
    exitButton.Size = UDim2.new(0, 30, 0, 30)
    exitButton.Position = UDim2.new(1, -35, 0.5, -15)
    exitButton.BackgroundColor3 = Color3.fromRGB(174, 41, 41) -- أحمر
    exitButton.TextColor3 = Color3.new(1, 1, 1)
    exitButton.Font = Enum.Font.GothamBold
    exitButton.TextSize = 24
    
    -- زوايا مستديرة لزر الخروج
    local exitCorner = Instance.new("UICorner")
    exitCorner.Parent = exitButton
    exitCorner.CornerRadius = UDim.new(0, 15) -- دائري تماماً
    
    -- إنشاء نظام التبويب
    local tabContainer = Instance.new("Frame")
    tabContainer.Parent = frame
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    tabContainer.BorderSizePixel = 0
    
    -- إنشاء حاوية المحتوى
    local contentContainer = Instance.new("Frame")
    contentContainer.Parent = frame
    contentContainer.Size = UDim2.new(1, 0, 1, -80)
    contentContainer.Position = UDim2.new(0, 0, 0, 80)
    contentContainer.BackgroundTransparency = 1
    
    -- دالة لإنشاء زر تبويب
    local function createTabButton(text, position)
        local tabButton = Instance.new("TextButton")
        tabButton.Parent = tabContainer
        tabButton.Text = text
        tabButton.Size = UDim2.new(0.25, 0, 1, 0)
        tabButton.Position = UDim2.new(0.25 * position, 0, 0, 0)
        tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        tabButton.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.TextSize = 14
        tabButton.BorderSizePixel = 0
        
        return tabButton
    end
    
    -- إنشاء أزرار التبويب
    local mainTabButton = createTabButton(getText("mainTab"), 0)
    local teleportTabButton = createTabButton(getText("teleportTab"), 1)
    local itemsTabButton = createTabButton(getText("itemsTab"), 2)
    local settingsTabButton = createTabButton(getText("settingsTab"), 3)
    
    -- إنشاء صفحات المحتوى
    local mainTab = Instance.new("Frame")
    mainTab.Parent = contentContainer
    mainTab.Size = UDim2.new(1, 0, 1, 0)
    mainTab.BackgroundTransparency = 1
    mainTab.Visible = true
    
    local teleportTab = Instance.new("Frame")
    teleportTab.Parent = contentContainer
    teleportTab.Size = UDim2.new(1, 0, 1, 0)
    teleportTab.BackgroundTransparency = 1
    teleportTab.Visible = false
    
    local itemsTab = Instance.new("Frame")
    itemsTab.Parent = contentContainer
    itemsTab.Size = UDim2.new(1, 0, 1, 0)
    itemsTab.BackgroundTransparency = 1
    itemsTab.Visible = false
    
    local settingsTab = Instance.new("Frame")
    settingsTab.Parent = contentContainer
    settingsTab.Size = UDim2.new(1, 0, 1, 0)
    settingsTab.BackgroundTransparency = 1
    settingsTab.Visible = false
    
    -- دالة لتبديل التبويبات
    local function switchTab(tabFrame)
        mainTab.Visible = false
        teleportTab.Visible = false
        itemsTab.Visible = false
        settingsTab.Visible = false
        
        mainTabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        teleportTabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        itemsTabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        settingsTabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        
        tabFrame.Visible = true
        
        if tabFrame == mainTab then
            mainTabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        elseif tabFrame == teleportTab then
            teleportTabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        elseif tabFrame == itemsTab then
            itemsTabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        elseif tabFrame == settingsTab then
            settingsTabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        end
    end
    
    -- ربط أزرار التبويب بالوظائف
    mainTabButton.MouseButton1Click:Connect(function()
        switchTab(mainTab)
    end)
    
    teleportTabButton.MouseButton1Click:Connect(function()
        switchTab(teleportTab)
    end)
    
    itemsTabButton.MouseButton1Click:Connect(function()
        switchTab(itemsTab)
    end)
    
    settingsTabButton.MouseButton1Click:Connect(function()
        switchTab(settingsTab)
    end)
    
    -- دالة لإنشاء زر منسق
    local function createStyledButton(parent, text, color, size, position)
        local button = Instance.new("TextButton")
        button.Parent = parent
        button.Size = size or UDim2.new(1, 0, 0, 45)
        button.Position = position or UDim2.new(0, 0, 0, 0)
        button.BackgroundColor3 = color
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.GothamSemibold
        button.TextSize = 16
        button.Text = text
        button.AutoButtonColor = true
        
        -- إضافة زوايا مستديرة للزر
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.Parent = button
        buttonCorner.CornerRadius = UDim.new(0, 8)
        
        -- إضافة تأثير ظل خفيف
        local shadow = Instance.new("Frame")
        shadow.Parent = button
        shadow.Size = UDim2.new(1, 2, 1, 2)
        shadow.Position = UDim2.new(0, -1, 0, -1)
        shadow.BackgroundColor3 = Color3.new(0, 0, 0)
        shadow.BackgroundTransparency = 0.7
        shadow.ZIndex = button.ZIndex - 1
        shadow.BorderSizePixel = 0
        
        -- زوايا مستديرة للظل
        local shadowCorner = Instance.new("UICorner")
        shadowCorner.Parent = shadow
        shadowCorner.CornerRadius = UDim.new(0, 8)
        
        return button
    end
    
    -- دالة لإنشاء تسمية منسقة
    local function createStyledLabel(parent, text, size, position)
        local label = Instance.new("TextLabel")
        label.Parent = parent
        label.Text = text
        label.Size = size or UDim2.new(1, 0, 0, 30)
        label.Position = position or UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        return label
    end
    
    -- إنشاء محتوى التبويب الرئيسي
    local mainContent = Instance.new("Frame")
    mainContent.Parent = mainTab
    mainContent.Size = UDim2.new(1, -40, 1, -20)
    mainContent.Position = UDim2.new(0, 20, 0, 10)
    mainContent.BackgroundTransparency = 1
    
    -- إضافة شعار أو صورة
    local logoImage = Instance.new("ImageLabel")
    logoImage.Parent = mainContent
    logoImage.Size = UDim2.new(0, 100, 0, 100)
    logoImage.Position = UDim2.new(0.5, -50, 0, 20)
    logoImage.BackgroundTransparency = 1
    logoImage.Image = "rbxassetid://7592612672" -- استبدل برقم الصورة المناسب
    
    -- إضافة عنوان البرنامج
    local appTitle = createStyledLabel(mainContent, getText("title"), UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 130))
    appTitle.TextSize = 24
    appTitle.Font = Enum.Font.GothamBold
    appTitle.TextXAlignment = Enum.TextXAlignment.Center
    
    -- إضافة معلومات المطور
    local creatorInfo = createStyledLabel(mainContent, "تم التطوير بواسطة: xsi1c", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 180))
    creatorInfo.TextXAlignment = Enum.TextXAlignment.Center
    
    local discordInfo = createStyledLabel(mainContent, "ديسكورد: xsi1c", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 210))
    discordInfo.TextXAlignment = Enum.TextXAlignment.Center
    
    -- إضافة وصف مختصر
    local description = createStyledLabel(mainContent, "أداة متقدمة للانتقال والتحكم في اللعبة مع ميزات متعددة", UDim2.new(1, 0, 0, 60), UDim2.new(0, 0, 0, 250))
    description.TextWrapped = true
    description.TextXAlignment = Enum.TextXAlignment.Center
    
    -- إضافة زر إنهاء البرنامج
    local killScriptButton = createStyledButton(mainContent, getText("killScript"), Color3.fromRGB(174, 41, 41), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 320))
    
    -- إنشاء محتوى تبويب الانتقال
    local teleportContent = Instance.new("ScrollingFrame")
    teleportContent.Parent = teleportTab
    teleportContent.Size = UDim2.new(1, -40, 1, -20)
    teleportContent.Position = UDim2.new(0, 20, 0, 10)
    teleportContent.BackgroundTransparency = 1
    teleportContent.ScrollBarThickness = 6
    teleportContent.CanvasSize = UDim2.new(0, 0, 0, 400) -- يمكن تعديله حسب المحتوى
    
    -- إضافة أزرار الانتقال
    local setLocationButton = createStyledButton(teleportContent, getText("setLocation"), Color3.fromRGB(41, 98, 174), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 10))
    
    local teleportButton = createStyledButton(teleportContent, getText("teleport"), Color3.fromRGB(46, 148, 94), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 65))
    
    local markButton = createStyledButton(teleportContent, getText("autoTeleport"), Color3.fromRGB(174, 41, 41), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 120))
    
    -- إضافة مدخل نسبة الصحة
    local healthLabel = createStyledLabel(teleportContent, getText("healthPercentage"), UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 175))
    
    local healthInput = Instance.new("TextBox")
    healthInput.Parent = teleportContent
    healthInput.PlaceholderText = "50"
    healthInput.Size = UDim2.new(1, 0, 0, 45)
    healthInput.Position = UDim2.new(0, 0, 0, 205)
    healthInput.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    healthInput.TextColor3 = Color3.new(1, 1, 1)
    healthInput.Font = Enum.Font.GothamSemibold
    healthInput.TextSize = 16
    healthInput.Text = tostring(healthThreshold) -- القيمة الافتراضية
    healthInput.ClipsDescendants = true
    
    -- إضافة زوايا مستديرة للمدخل
    local inputCorner = Instance.new("UICorner")
    inputCorner.Parent = healthInput
    inputCorner.CornerRadius = UDim.new(0, 8)
    
    -- إضافة مؤشر الحالة
    local statusContainer = Instance.new("Frame")
    statusContainer.Parent = teleportContent
    statusContainer.Size = UDim2.new(1, 0, 0, 45)
    statusContainer.Position = UDim2.new(0, 0, 0, 260)
    statusContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    statusContainer.BorderSizePixel = 0
    
    -- إضافة زوايا مستديرة لحاوية الحالة
    local statusCorner = Instance.new("UICorner")
    statusCorner.Parent = statusContainer
    statusCorner.CornerRadius = UDim.new(0, 8)
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Parent = statusContainer
    statusLabel.Text = getText("status") .. getText("ready")
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.new(1, 1, 1)
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.TextSize = 14
    
    -- إنشاء محتوى تبويب الأدوات
    local itemsContent = Instance.new("ScrollingFrame")
    itemsContent.Parent = itemsTab
    itemsContent.Size = UDim2.new(1, -40, 1, -20)
    itemsContent.Position = UDim2.new(0, 20, 0, 10)
    itemsContent.BackgroundTransparency = 1
    itemsContent.ScrollBarThickness = 6
    itemsContent.CanvasSize = UDim2.new(0, 0, 0, 500) -- زيادة المساحة للأدوات الإضافية
    
    -- إضافة عنوان قائمة الأدوات
    local itemsTitle = createStyledLabel(itemsContent, getText("toolsTitle"), UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 10))
    itemsTitle.TextSize = 18
    itemsTitle.Font = Enum.Font.GothamBold
    
    -- إضافة أدوات متعددة
    local teleportToolButton = createStyledButton(itemsContent, getText("teleportTool"), Color3.fromRGB(90, 74, 164), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 50))
    
    local noclipToolButton = createStyledButton(itemsContent, getText("noclipTool"), Color3.fromRGB(174, 120, 41), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 105))
    
    local flyToolButton = createStyledButton(itemsContent, getText("flyTool"), Color3.fromRGB(41, 174, 125), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 160))
    
    -- إضافة أداة السرعة مع شريط تمرير
    local speedToolButton = createStyledButton(itemsContent, getText("speedTool"), Color3.fromRGB(174, 41, 125), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 215))
    
    local speedLabel = createStyledLabel(itemsContent, getText("speedValue") .. " " .. speedMultiplier, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 270))
    
    local speedSlider = Instance.new("Frame")
    speedSlider.Parent = itemsContent
    speedSlider.Size = UDim2.new(1, 0, 0, 30)
    speedSlider.Position = UDim2.new(0, 0, 0, 300)
    speedSlider.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    
    -- إضافة زوايا مستديرة للشريط
    local speedSliderCorner = Instance.new("UICorner")
    speedSliderCorner.Parent = speedSlider
    speedSliderCorner.CornerRadius = UDim.new(0, 8)
    
    -- إضافة مؤشر الشريط
    local speedIndicator = Instance.new("Frame")
    speedIndicator.Parent = speedSlider
    speedIndicator.Size = UDim2.new(speedMultiplier / 10, 0, 1, 0) -- القيمة الافتراضية
    speedIndicator.BackgroundColor3 = Color3.fromRGB(174, 41, 125)
    
    -- إضافة زوايا مستديرة للمؤشر
    local speedIndicatorCorner = Instance.new("UICorner")
    speedIndicatorCorner.Parent = speedIndicator
    speedIndicatorCorner.CornerRadius = UDim.new(0, 8)
    
    -- جعل شريط السرعة قابل للتفاعل
    local isDraggingSpeed = false
    
    -- إنشاء قائمة العناصر
    local itemsList = Instance.new("Frame")
    itemsList.Parent = itemsContent
    itemsList.Size = UDim2.new(1, 0, 0, 300)
    itemsList.Position = UDim2.new(0, 0, 0, 50)
    itemsList.BackgroundTransparency = 1
    
    -- دالة لإنشاء عنصر في القائمة
    local function createItemEntry(name, index)
        local itemEntry = Instance.new("Frame")
        itemEntry.Parent = itemsList
        itemEntry.Size = UDim2.new(1, 0, 0, 40)
        itemEntry.Position = UDim2.new(0, 0, 0, (index - 1) * 45)
        itemEntry.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        
        -- إضافة زوايا مستديرة للعنصر
        local entryCorner = Instance.new("UICorner")
        entryCorner.Parent = itemEntry
        entryCorner.CornerRadius = UDim.new(0, 8)
        
        -- إضافة اسم العنصر
        local itemName = createStyledLabel(itemEntry, name, UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 10, 0, 0))
        
        -- إضافة زر التحديد
        local selectButton = createStyledButton(itemEntry, "تحديد", Color3.fromRGB(46, 148, 94), UDim2.new(0.25, 0, 0.8, 0), UDim2.new(0.72, 0, 0.1, 0))
        selectButton.TextSize = 14
        
        selectButton.MouseButton1Click:Connect(function()
            if selectedItems[name] then
                selectedItems[name] = nil
                selectButton.BackgroundColor3 = Color3.fromRGB(46, 148, 94) -- أخضر
                selectButton.Text = "تحديد"
            else
                selectedItems[name] = true
                selectButton.BackgroundColor3 = Color3.fromRGB(174, 41, 41) -- أحمر
                selectButton.Text = "إلغاء"
            end
        end)
        
        return itemEntry
    end
    
    -- إضافة بعض العناصر للتجربة
    local itemNames = {"سيف", "درع", "قوس", "سهام", "مفتاح", "جرعة شفاء", "جرعة قوة"}
    for i, name in ipairs(itemNames) do
        createItemEntry(name, i)
    end
    
    -- إضافة زر جلب العناصر المحددة
    local getItemsButton = createStyledButton(itemsContent, "جلب العناصر المحددة", Color3.fromRGB(41, 98, 174), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 350))
    
    -- إنشاء محتوى تبويب الإعدادات
    local settingsContent = Instance.new("ScrollingFrame")
    settingsContent.Parent = settingsTab
    settingsContent.Size = UDim2.new(1, -40, 1, -20)
    settingsContent.Position = UDim2.new(0, 20, 0, 10)
    settingsContent.BackgroundTransparency = 1
    settingsContent.ScrollBarThickness = 6
    settingsContent.CanvasSize = UDim2.new(0, 0, 0, 400) -- يمكن تعديله حسب المحتوى
    
    -- إضافة عنوان الإعدادات
    local settingsTitle = createStyledLabel(settingsContent, "إعدادات البرنامج", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 10))
    settingsTitle.TextSize = 18
    settingsTitle.Font = Enum.Font.GothamBold
    
    -- إضافة إعدادات الشفافية
    local transparencyLabel = createStyledLabel(settingsContent, "شفافية الواجهة", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 50))
    
    local transparencySlider = Instance.new("Frame")
    transparencySlider.Parent = settingsContent
    transparencySlider.Size = UDim2.new(1, 0, 0, 30)
    transparencySlider.Position = UDim2.new(0, 0, 0, 80)
    transparencySlider.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    
    -- إضافة زوايا مستديرة للشريط
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.Parent = transparencySlider
    sliderCorner.CornerRadius = UDim.new(0, 8)
    
    -- إضافة مؤشر الشريط
    local sliderIndicator = Instance.new("Frame")
    sliderIndicator.Parent = transparencySlider
    sliderIndicator.Size = UDim2.new(0.5, 0, 1, 0) -- 50% كقيمة افتراضية
    sliderIndicator.BackgroundColor3 = Color3.fromRGB(41, 98, 174)
    
    -- إضافة زوايا مستديرة للمؤشر
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.Parent = sliderIndicator
    indicatorCorner.CornerRadius = UDim.new(0, 8)
    
    -- إضافة إعدادات الألوان
    local colorLabel = createStyledLabel(settingsContent, "لون الأزرار", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 120))
    
    -- إضافة خيارات الألوان
    local colorOptions = Instance.new("Frame")
    colorOptions.Parent = settingsContent
    colorOptions.Size = UDim2.new(1, 0, 0, 50)
    colorOptions.Position = UDim2.new(0, 0, 0, 150)
    colorOptions.BackgroundTransparency = 1
    
    -- دالة لإنشاء خيار لون
    local function createColorOption(color, index)
        local colorButton = Instance.new("TextButton")
        colorButton.Parent = colorOptions
        colorButton.Size = UDim2.new(0.18, 0, 1, 0)
        colorButton.Position = UDim2.new(0.2 * (index - 1), 0, 0, 0)
        colorButton.BackgroundColor3 = color
        colorButton.Text = ""
        
        -- إضافة زوايا مستديرة لخيار اللون
        local colorCorner = Instance.new("UICorner")
        colorCorner.Parent = colorButton
        colorCorner.CornerRadius = UDim.new(0, 8)
        
        return colorButton
    end
    
    -- إضافة خيارات الألوان
    local colors = {
        Color3.fromRGB(41, 98, 174), -- أزرق
        Color3.fromRGB(46, 148, 94), -- أخضر
        Color3.fromRGB(174, 41, 41), -- أحمر
        Color3.fromRGB(90, 74, 164), -- بنفسجي
        Color3.fromRGB(174, 120, 41) -- برتقالي
    }
    
    for i, color in ipairs(colors) do
        createColorOption(color, i)
    end
    
    -- إضافة زر حفظ الإعدادات
    local saveSettingsButton = createStyledButton(settingsContent, "حفظ الإعدادات", Color3.fromRGB(46, 148, 94), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 210))
    
    -- إضافة زر إعادة تعيين الإعدادات
    local resetSettingsButton = createStyledButton(settingsContent, "إعادة تعيين الإعدادات", Color3.fromRGB(174, 41, 41), UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 265))
    
    -- دالة لتحديث نص الحالة
    local function updateStatus(text)
        statusLabel.Text = "الحالة: " .. text
    end
    
    -- وظائف الأزرار في تبويب الانتقال
    setLocationButton.MouseButton1Click:Connect(function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            teleportLocation = player.Character.HumanoidRootPart.CFrame
            updateStatus("تم تعيين الموقع!")
            print("تم تعيين موقع الانتقال!")
        else
            updateStatus("خطأ: لم يتم العثور على الشخصية")
            warn("لم يتم العثور على شخصية اللاعب أو HumanoidRootPart!")
        end
    end)

    teleportButton.MouseButton1Click:Connect(function()
        local player = game.Players.LocalPlayer
        if teleportLocation and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = teleportLocation
            updateStatus("تم الانتقال!")
            print("تم الانتقال!")
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
