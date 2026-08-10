-- ============================================================
-- SolsticeUI v7.0 - Premium Modern UI Overhaul
-- Inspired by Vape V4 aesthetics, kept original API simplicity
-- Glassmorphism, spring physics, micro-interactions
-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ==================== FONT LOADER ====================
local FontLoader = {}
local fontTable = {
    SFDisplay = "https://github.com/Storm99999/Moon/raw/main/src/fonts/SFPRODISPLAYBOLD.OTF",
    Minecraft = "https://github.com/MoeriiLua/fontNIGTHING/raw/main/Minecraft%20Regular.otf",
    GreyCliff = "https://github.com/Storm99999/Moon/raw/main/src/fonts/GreyCliff.otf"
}

local request = request or http_request or (syn and syn.request) or function() end
local getAsset = (syn and getsynasset) or getcustomasset

if not isfolder("SolsticeFonts") then makefolder("SolsticeFonts") end
for name, url in next, fontTable do
    if not isfile("SolsticeFonts/" .. name .. ".otf") then
        pcall(function()
            writefile("SolsticeFonts/" .. name .. ".otf", request({Url = url, Method = "GET"}).Body)
        end)
    end
end

function FontLoader.setFont(fontName, textLabel)
    if fontTable[fontName] == nil then return end
    local jsonPath = "SolsticeFonts/" .. fontName .. "Face.json"
    if not isfile(jsonPath) then
        writefile(jsonPath, HttpService:JSONEncode({
            name = fontName,
            faces = {{name = "Regular", weight = 300, style = "normal", assetId = getAsset("SolsticeFonts/" .. fontName .. ".otf")}}
        }))
    end
    textLabel.FontFace = Font.new(getAsset(jsonPath))
end

-- ==================== LIBRARY ====================
local SolsticeUI = {}
SolsticeUI.__index = SolsticeUI

-- ==================== PREMIUM PALETTE ====================
local PALETTE = {
    PanelBg = Color3.fromRGB(15, 15, 19),
    PanelBgTransparency = 0.02,
    PanelBorder = Color3.fromRGB(55, 55, 65),
    PanelBorderHover = Color3.fromRGB(75, 75, 90),

    HeaderBg = Color3.fromRGB(22, 22, 28),
    HeaderBgHover = Color3.fromRGB(28, 28, 36),
    HeaderText = Color3.fromRGB(220, 220, 225),
    HeaderIcon = Color3.fromRGB(140, 140, 155),

    ItemBg = Color3.fromRGB(20, 20, 26),
    ItemBgTransparency = 0.15,
    ItemText = Color3.fromRGB(200, 200, 210),
    ItemHoverBg = Color3.fromRGB(32, 32, 42),
    ItemHoverBorder = Color3.fromRGB(45, 45, 58),

    ActiveBg = Color3.fromRGB(255, 140, 190),
    ActiveText = Color3.fromRGB(10, 10, 14),
    ActiveGradientStart = Color3.fromRGB(255, 130, 185),
    ActiveGradientEnd = Color3.fromRGB(200, 140, 255),
    ActiveGlow = Color3.fromRGB(255, 120, 180),

    PressBg = Color3.fromRGB(255, 110, 165),
    PressGlow = Color3.fromRGB(255, 90, 150),

    SettingBg = Color3.fromRGB(12, 12, 16),
    SettingBgTransparency = 0.06,
    SettingText = Color3.fromRGB(160, 160, 175),
    SettingValue = Color3.fromRGB(235, 235, 240),
    SettingHover = Color3.fromRGB(18, 18, 24),
    SettingBorder = Color3.fromRGB(35, 35, 45),

    SliderTrack = Color3.fromRGB(40, 40, 50),
    SliderTrackHover = Color3.fromRGB(50, 50, 62),
    SliderFill = Color3.fromRGB(200, 200, 215),
    SliderFillActive = Color3.fromRGB(255, 150, 200),
    SliderThumb = Color3.fromRGB(255, 255, 255),
    SliderThumbGlow = Color3.fromRGB(255, 180, 220),

    ToggleOff = Color3.fromRGB(45, 45, 55),
    ToggleOffHover = Color3.fromRGB(55, 55, 68),
    ToggleOn = Color3.fromRGB(255, 140, 190),
    ToggleOnHover = Color3.fromRGB(255, 160, 205),
    ToggleKnob = Color3.fromRGB(255, 255, 255),
    ToggleKnobShadow = Color3.fromRGB(0, 0, 0),

    SearchBg = Color3.fromRGB(22, 22, 28),
    SearchBorder = Color3.fromRGB(45, 45, 58),
    SearchBorderFocus = Color3.fromRGB(255, 140, 190),
    SearchPlaceholder = Color3.fromRGB(100, 100, 115),

    ArrayListBg = Color3.fromRGB(12, 12, 16),
    ArrayListBgTransparency = 0.08,
    ArrayListBorder = Color3.fromRGB(35, 35, 45),

    NotifBg = Color3.fromRGB(18, 18, 24),
    NotifBorder = Color3.fromRGB(255, 140, 190),
    NotifBorderTransparency = 0.5,

    Muted = Color3.fromRGB(100, 100, 115),
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(10, 10, 14),
    Shadow = Color3.fromRGB(0, 0, 0),

    AccentCyan = Color3.fromRGB(100, 220, 255),
    AccentGreen = Color3.fromRGB(130, 255, 170),
    AccentYellow = Color3.fromRGB(255, 220, 100),
}

-- ==================== ADVANCED ANIMATION PRESETS ====================
local ANIM = {
    Micro = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Quick = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Standard = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    SpringSoft = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    SpringIn = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
    Expand = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
    Collapse = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
    Hover = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    HoverOut = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    PanelLoad = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    PanelSlide = TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
    NotifyIn = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    NotifyOut = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
    ToggleSwitch = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    ToggleColor = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    SliderMove = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    SliderRelease = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    ArrayIn = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    ArrayOut = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
    ArrayReorder = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
}

local DEFAULT_CONFIG = {
    PanelWidth = 155,
    PanelHeaderHeight = 24,
    ItemHeight = 20,
    SettingHeight = 32,
    SliderHeight = 44,

    CornerRadius = UDim.new(0, 4),
    PanelCornerRadius = UDim.new(0, 6),
    ButtonCornerRadius = UDim.new(0, 3),

    Font = Enum.Font.SourceSansSemibold,
    FontItalic = Enum.Font.SourceSansItalic,
    TextSize = 13,
    HeaderTextSize = 13,

    PanelSpacing = 170,
    StartX = 24,
    StartY = 50,

    ArrayListFont = Enum.Font.SourceSansBold,
    ArrayListTextSize = 15,
    ArrayListItemHeight = 18,
    ArrayListRainbowSpeed = 0.3,
    ArrayListAnimSpeed = 0.35,

    UseCustomFont = true,
    CustomFontName = "SFDisplay",

    Parent = nil,
    ShowSearchBar = true,
    ShowArrayList = true,
    ShowNotifications = true,
    ShowWatermark = true,

    SaveConfig = true,
    ConfigPath = "SolsticeUI/config.json",

    LoadAnimDelay = 0.08,
    LoadAnimDuration = 0.45,
    ClickScale = 0.94,
    ClickScaleDuration = 0.08,
    ClickRestoreDuration = 0.18,

    UseGlassEffect = true,
    GlassTransparency = 0.15,

    UseShadows = true,
    ShadowTransparency = 0.7,
    ShadowOffset = 4,
}

-- ==================== UTILITY FUNCTIONS ====================
local function HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p, q, t = v*(1-s), v*(1-f*s), v*(1-(1-f)*s)
    i = i % 6
    if i == 0 then r,g,b = v,t,p
    elseif i == 1 then r,g,b = q,v,p
    elseif i == 2 then r,g,b = p,v,t
    elseif i == 3 then r,g,b = p,q,v
    elseif i == 4 then r,g,b = t,p,v
    elseif i == 5 then r,g,b = v,p,q end
    return Color3.new(r, g, b)
end

local function Corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or DEFAULT_CONFIG.CornerRadius
    c.Parent = parent
    return c
end

local function GetTextWidth(text, font, size)
    font = font or DEFAULT_CONFIG.Font
    size = size or DEFAULT_CONFIG.TextSize
    return TextService:GetTextSize(text, size, font, Vector2.new(9999, 9999)).X
end

local function Tween(obj, info, props)
    return TweenService:Create(obj, info, props)
end

-- ==================== SHADOW SYSTEM ====================
local function AddShadow(parent, config)
    config = config or {}
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = PALETTE.Shadow
    shadow.ImageTransparency = config.transparency or DEFAULT_CONFIG.ShadowTransparency
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, config.offsetX or 8, 1, config.offsetY or 8)
    shadow.Position = UDim2.new(0, -(config.offsetX or 8)/2, 0, -(config.offsetY or 8)/2)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

-- ==================== DRAGGING ====================
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local drag, dragStart, startPos, dragTouch

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dragTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not drag then return end
        if dragTouch and input.UserInputType == Enum.UserInputType.Touch then
            if input ~= dragTouch then return end
        elseif not dragTouch and input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if dragTouch and input == dragTouch then drag = false; dragTouch = nil
            elseif not dragTouch then drag = false end
        end
    end)
end

-- ==================== CONSTRUCTOR ====================
function SolsticeUI.new(userConfig)
    local self = setmetatable({}, SolsticeUI)

    self.Config = {}
    for k, v in pairs(DEFAULT_CONFIG) do self.Config[k] = v end
    if userConfig then
        for k, v in pairs(userConfig) do self.Config[k] = v end
    end

    self.SavedConfig = {}
    if self.Config.SaveConfig and isfile(self.Config.ConfigPath) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(self.Config.ConfigPath))
        end)
        if success then self.SavedConfig = decoded end
    end

    local TargetParent = self.Config.Parent
    if not TargetParent then
        TargetParent = LocalPlayer:WaitForChild("PlayerGui")
        pcall(function()
            if gethui then TargetParent = gethui()
            elseif CoreGui then TargetParent = CoreGui end
        end)
    end

    self.ClickGui = Instance.new("ScreenGui")
    self.ClickGui.Name = "SolsticeClickGUI"
    self.ClickGui.ResetOnSpawn = false
    self.ClickGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ClickGui.Parent = TargetParent

    self.HudGui = Instance.new("ScreenGui")
    self.HudGui.Name = "SolsticeHUD"
    self.HudGui.ResetOnSpawn = false
    self.HudGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.HudGui.Parent = TargetParent

    self.GUI_ENABLED = true
    self.ARRAYLIST_ENABLED = self.Config.ShowArrayList
    self.EnabledModules = {}
    self.AllModules = {}
    self.Panels = {}
    self.ArrayListItems = {}
    self.RainbowOffset = 0
    self.NextPanelX = self.Config.StartX
    self.NextPanelY = self.Config.StartY
    self.PanelLoadQueue = {}
    self.NotifQueue = {}

    self:_InitWatermark()
    self:_InitSearchBar()
    self:_InitArrayList()
    self:_InitNotifications()
    self:_StartRenderLoop()
    self:_BindToggleKey()
    self:_StartConfigSaver()

    return self
end

-- ==================== CONFIG SAVER ====================
function SolsticeUI:_StartConfigSaver()
    if not self.Config.SaveConfig then return end
    if not isfolder("SolsticeUI") then makefolder("SolsticeUI") end

    task.spawn(function()
        repeat
            task.wait(5)
            if self.Config.SaveConfig then
                local success, encoded = pcall(function()
                    return HttpService:JSONEncode(self.SavedConfig)
                end)
                if success then
                    pcall(function() writefile(self.Config.ConfigPath, encoded) end)
                end
            end
        until not self.ClickGui or not self.ClickGui.Parent
    end)
end

function SolsticeUI:_SaveModuleState(name, state, value)
    if not self.SavedConfig.modules then self.SavedConfig.modules = {} end
    self.SavedConfig.modules[name] = {state = state, value = value}
end

-- ==================== LOADING ANIMATION ====================
function SolsticeUI:_PlayPanelLoadAnimation(panel, index)
    panel.BackgroundTransparency = 1
    panel.Position = UDim2.new(
        panel.Position.X.Scale, 
        panel.Position.X.Offset, 
        panel.Position.Y.Scale, 
        panel.Position.Y.Offset + 35
    )

    local stroke = panel:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Transparency = 1 end

    local delay = index * self.Config.LoadAnimDelay
    task.delay(delay, function()
        Tween(panel, ANIM.PanelLoad, {
            BackgroundTransparency = PALETTE.PanelBgTransparency,
            Position = UDim2.new(
                panel.Position.X.Scale,
                panel.Position.X.Offset,
                panel.Position.Y.Scale,
                panel.Position.Y.Offset - 35
            )
        }):Play()

        if stroke then
            Tween(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Transparency = 0.35
            }):Play()
        end

        local content = panel:FindFirstChild("Content")
        if content then
            content.Position = UDim2.new(0, 0, 0, self.Config.PanelHeaderHeight + 5)
            Tween(content, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, self.Config.PanelHeaderHeight)
            }):Play()
        end
    end)
end

-- ==================== WATERMARK ====================
function SolsticeUI:_InitWatermark()
    if not self.Config.ShowWatermark then return end

    local wm = Instance.new("Frame")
    wm.Name = "Watermark"
    wm.Size = UDim2.new(0, 220, 0, 70)
    wm.Position = UDim2.new(0, 16, 0, 12)
    wm.BackgroundTransparency = 1
    wm.Parent = self.HudGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = PALETTE.PanelBg
    bg.BackgroundTransparency = 0.7
    bg.BorderSizePixel = 0
    bg.Parent = wm
    Corner(bg, UDim.new(0, 6))

    local stroke = Instance.new("UIStroke")
    stroke.Color = PALETTE.PanelBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = bg

    local moixel = Instance.new("TextLabel")
    moixel.Size = UDim2.new(1, -16, 0, 26)
    moixel.Position = UDim2.new(0, 8, 0, 6)
    moixel.BackgroundTransparency = 1
    moixel.Text = "Moixel"
    moixel.TextColor3 = Color3.fromRGB(210, 210, 215)
    moixel.Font = Enum.Font.SourceSansBold
    moixel.TextSize = 22
    moixel.TextXAlignment = Enum.TextXAlignment.Left
    moixel.Parent = bg
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, moixel) end

    local underline = Instance.new("Frame")
    underline.Size = UDim2.new(0, 50, 0, 2)
    underline.Position = UDim2.new(0, 8, 0, 32)
    underline.BackgroundColor3 = PALETTE.ActiveGradientStart
    underline.BorderSizePixel = 0
    underline.Parent = bg

    local ugrad = Instance.new("UIGradient")
    ugrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, PALETTE.ActiveGradientStart),
        ColorSequenceKeypoint.new(1, PALETTE.ActiveGradientEnd)
    })
    ugrad.Parent = underline

    local bilibili = Instance.new("TextLabel")
    bilibili.Size = UDim2.new(1, -16, 0, 18)
    bilibili.Position = UDim2.new(0, 8, 0, 36)
    bilibili.BackgroundTransparency = 1
    bilibili.Text = "bilibili"
    bilibili.TextColor3 = Color3.fromRGB(170, 170, 178)
    bilibili.Font = Enum.Font.SourceSansItalic
    bilibili.TextSize = 15
    bilibili.TextXAlignment = Enum.TextXAlignment.Left
    bilibili.Parent = bg
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, bilibili) end

    local solstice = Instance.new("TextLabel")
    solstice.Size = UDim2.new(1, -16, 0, 18)
    solstice.Position = UDim2.new(0, 8, 0, 52)
    solstice.BackgroundTransparency = 1
    solstice.Text = "Solstice"
    solstice.TextColor3 = Color3.fromRGB(150, 150, 162)
    solstice.Font = Enum.Font.SourceSansItalic
    solstice.TextSize = 14
    solstice.TextXAlignment = Enum.TextXAlignment.Left
    solstice.Parent = bg
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, solstice) end

    bg.BackgroundTransparency = 1
    stroke.Transparency = 1
    Tween(bg, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.7
    }):Play()
    Tween(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.6
    }):Play()
end

-- ==================== SEARCH BAR ====================
function SolsticeUI:_InitSearchBar()
    if not self.Config.ShowSearchBar then return end

    local frame = Instance.new("Frame")
    frame.Name = "SearchBar"
    frame.Size = UDim2.new(0, 220, 0, 28)
    frame.Position = UDim2.new(0.5, -110, 0, 10)
    frame.BackgroundColor3 = PALETTE.SearchBg
    frame.BackgroundTransparency = 0.04
    frame.BorderSizePixel = 0
    frame.Parent = self.ClickGui
    Corner(frame, UDim.new(0, 6))

    AddShadow(frame, {offsetX = 6, offsetY = 6, transparency = 0.75})

    local stroke = Instance.new("UIStroke")
    stroke.Color = PALETTE.SearchBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = frame

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 26, 1, 0)
    icon.Position = UDim2.new(0, 8, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "\ud83d\udd0d"
    icon.TextColor3 = PALETTE.Muted
    icon.Font = self.Config.Font
    icon.TextSize = 11
    icon.Parent = frame

    local box = Instance.new("TextBox")
    box.Name = "SearchBox"
    box.Size = UDim2.new(1, -38, 1, 0)
    box.Position = UDim2.new(0, 30, 0, 0)
    box.BackgroundTransparency = 1
    box.Text = ""
    box.PlaceholderText = "Search modules..."
    box.PlaceholderColor3 = PALETTE.SearchPlaceholder
    box.TextColor3 = PALETTE.ItemText
    box.Font = self.Config.Font
    box.TextSize = 13
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false
    box.Parent = frame
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, box) end

    box.Focused:Connect(function()
        Tween(stroke, TweenInfo.new(0.2), {Color = PALETTE.SearchBorderFocus, Transparency = 0.2}):Play()
        Tween(frame, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    box.FocusLost:Connect(function()
        Tween(stroke, TweenInfo.new(0.2), {Color = PALETTE.SearchBorder, Transparency = 0.4}):Play()
        Tween(frame, TweenInfo.new(0.2), {BackgroundTransparency = 0.04}):Play()
    end)

    self.SearchBox = box
    box:GetPropertyChangedSignal("Text"):Connect(function()
        self:_FilterModules(box.Text)
    end)

    frame.Position = UDim2.new(0.5, -110, 0, -40)
    Tween(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -110, 0, 10)
    }):Play()
end

function SolsticeUI:_FilterModules(query)
    query = string.lower(query or "")
    for _, panelData in ipairs(self.Panels) do
        local content = panelData.Instance:FindFirstChild("Content")
        if content then
            for _, child in ipairs(content:GetChildren()) do
                if child:IsA("Frame") and child.Name ~= "UIListLayout" then
                    local btn = child:FindFirstChildOfClass("TextButton")
                    if btn then
                        local shouldShow = query == "" or string.find(string.lower(btn.Text), query, 1, true) ~= nil
                        if shouldShow ~= child.Visible then
                            child.Visible = shouldShow
                            if shouldShow then
                                child.Size = UDim2.new(1, 0, 0, 0)
                                Tween(child, ANIM.Expand, {Size = UDim2.new(1, 0, 0, self.Config.ItemHeight)}):Play()
                            end
                        end
                    end
                end
            end
            panelData:UpdateHeight()
        end
    end
end

-- ==================== ARRAY LIST ====================
function SolsticeUI:_InitArrayList()
    self.ArrayListMaster = Instance.new("Frame")
    self.ArrayListMaster.Name = "ArrayListMaster"
    self.ArrayListMaster.AnchorPoint = Vector2.new(1, 0)
    self.ArrayListMaster.Position = UDim2.new(1, -10, 0, 8)
    self.ArrayListMaster.BackgroundTransparency = 1
    self.ArrayListMaster.Parent = self.HudGui

    self.ArrayListContent = Instance.new("Frame")
    self.ArrayListContent.Size = UDim2.new(1, 0, 1, 0)
    self.ArrayListContent.BackgroundTransparency = 1
    self.ArrayListContent.Parent = self.ArrayListMaster

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.Padding = UDim.new(0, 2)
    layout.Parent = self.ArrayListContent
end

function SolsticeUI:_UpdateArrayList()
    if not self.ARRAYLIST_ENABLED then
        self.ArrayListMaster.Visible = false
        return
    end

    local enabled = {}
    for name, data in pairs(self.EnabledModules) do
        if data.state then
            local display = name
            if data.value and tostring(data.value) ~= "" then
                display = name .. " " .. tostring(data.value)
            end
            table.insert(enabled, {name = name, display = display})
        end
    end

    if #enabled == 0 then
        self.ArrayListMaster.Visible = false
        return
    end

    self.ArrayListMaster.Visible = true

    table.sort(enabled, function(a, b)
        return GetTextWidth(a.display, self.Config.ArrayListFont, self.Config.ArrayListTextSize) >
               GetTextWidth(b.display, self.Config.ArrayListFont, self.Config.ArrayListTextSize)
    end)

    local activeNames = {}
    for _, data in ipairs(enabled) do
        activeNames[data.name] = true
    end

    for name, itemFrame in pairs(self.ArrayListItems) do
        if not activeNames[name] and itemFrame.Visible then
            itemFrame.Visible = false
            local bg = itemFrame:FindFirstChild("BgBar")
            local txt = itemFrame:FindFirstChild("TextLabel")
            local border = itemFrame:FindFirstChild("BorderLine")
            local tw = GetTextWidth(txt.Text, self.Config.ArrayListFont, self.Config.ArrayListTextSize) + 12

            if bg and txt then
                Tween(bg, ANIM.ArrayOut, {
                    Position = UDim2.new(0, tw + 60, 0, 0),
                    BackgroundTransparency = 1
                }):Play()
                Tween(txt, TweenInfo.new(self.Config.ArrayListAnimSpeed * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(0, tw + 40, 0, 0),
                    TextTransparency = 1
                }):Play()
                if border then
                    Tween(border, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                end
            end
            task.delay(self.Config.ArrayListAnimSpeed + 0.15, function()
                if itemFrame and itemFrame.Parent then
                    itemFrame.Visible = false
                end
            end)
        end
    end

    local maxW = 0
    for i, data in ipairs(enabled) do
        local itemFrame = self.ArrayListItems[data.name]
        local isNew = false

        if not itemFrame then
            isNew = true
            itemFrame = Instance.new("Frame")
            itemFrame.Name = data.name .. "_AL"
            itemFrame.BackgroundTransparency = 1
            itemFrame.ClipsDescendants = false
            itemFrame.Parent = self.ArrayListContent

            local bgBar = Instance.new("Frame")
            bgBar.Name = "BgBar"
            bgBar.Size = UDim2.new(0, 0, 1, 0)
            bgBar.Position = UDim2.new(0, 0, 0, 0)
            bgBar.BackgroundColor3 = PALETTE.ArrayListBg
            bgBar.BackgroundTransparency = 1
            bgBar.BorderSizePixel = 0
            bgBar.ZIndex = 1
            bgBar.Parent = itemFrame
            Corner(bgBar, UDim.new(0, 3))

            local borderLine = Instance.new("Frame")
            borderLine.Name = "BorderLine"
            borderLine.Size = UDim2.new(0, 2, 1, -4)
            borderLine.Position = UDim2.new(0, 0, 0, 2)
            borderLine.BackgroundColor3 = PALETTE.ActiveGradientStart
            borderLine.BackgroundTransparency = 1
            borderLine.BorderSizePixel = 0
            borderLine.ZIndex = 2
            borderLine.Parent = bgBar

            local gradOverlay = Instance.new("UIGradient")
            gradOverlay.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.new(0.95, 0.95, 0.97))
            })
            gradOverlay.Transparency = NumberSequence.new(0.92)
            gradOverlay.Parent = bgBar

            local txt = Instance.new("TextLabel")
            txt.Name = "TextLabel"
            txt.Size = UDim2.new(0, 0, 1, 0)
            txt.Position = UDim2.new(0, 0, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Font = self.Config.ArrayListFont
            txt.TextSize = self.Config.ArrayListTextSize
            txt.TextXAlignment = Enum.TextXAlignment.Right
            txt.TextTransparency = 1
            txt.ZIndex = 3
            txt.Parent = itemFrame
            if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, txt) end

            self.ArrayListItems[data.name] = itemFrame
        end

        itemFrame.Visible = true
        itemFrame.LayoutOrder = i

        local txt = itemFrame:FindFirstChild("TextLabel")
        local bgBar = itemFrame:FindFirstChild("BgBar")
        local borderLine = bgBar and bgBar:FindFirstChild("BorderLine")

        if txt then
            txt.Text = data.display
        end

        local tw = GetTextWidth(data.display, self.Config.ArrayListFont, self.Config.ArrayListTextSize) + 14
        if tw > maxW then maxW = tw end

        itemFrame.Size = UDim2.new(0, tw, 0, self.Config.ArrayListItemHeight)

        if txt then
            txt.Size = UDim2.new(0, tw - 8, 1, 0)
            txt.Position = UDim2.new(0, -6, 0, 0)
        end
        if bgBar then
            bgBar.Size = UDim2.new(0, tw, 1, 0)
        end

        if isNew then
            if bgBar then
                bgBar.Position = UDim2.new(0, tw + 60, 0, 0)
                Tween(bgBar, ANIM.ArrayIn, {
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = PALETTE.ArrayListBgTransparency
                }):Play()
            end
            if borderLine then
                Tween(borderLine, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0.3
                }):Play()
            end
            if txt then
                txt.Position = UDim2.new(0, tw + 40, 0, 0)
                Tween(txt, TweenInfo.new(self.Config.ArrayListAnimSpeed * 0.85, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, -6, 0, 0),
                    TextTransparency = 0
                }):Play()
            end
        else
            if bgBar then
                bgBar.Position = UDim2.new(0, 0, 0, 0)
                bgBar.BackgroundTransparency = PALETTE.ArrayListBgTransparency
            end
            if borderLine then
                borderLine.BackgroundTransparency = 0.3
            end
            if txt then
                txt.Position = UDim2.new(0, -6, 0, 0)
                txt.TextTransparency = 0
            end
        end
    end

    self.ArrayListMaster.Size = UDim2.new(0, maxW, 0, #enabled * (self.Config.ArrayListItemHeight + 2))
end

function SolsticeUI:_SetModuleState(name, state, value)
    if not self.EnabledModules[name] then
        self.EnabledModules[name] = {state = false, value = ""}
    end
    self.EnabledModules[name].state = state
    if value ~= nil then
        self.EnabledModules[name].value = value
    end
    self:_SaveModuleState(name, state, value)
    self:_UpdateArrayList()
end

-- ==================== NOTIFICATIONS ====================
function SolsticeUI:_InitNotifications()
    if not self.Config.ShowNotifications then return end
    self.NotifContainer = Instance.new("Frame")
    self.NotifContainer.Size = UDim2.new(0, 300, 0.5, 0)
    self.NotifContainer.Position = UDim2.new(1, -14, 0.92, 0)
    self.NotifContainer.AnchorPoint = Vector2.new(1, 1)
    self.NotifContainer.BackgroundTransparency = 1
    self.NotifContainer.Parent = self.HudGui

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Padding = UDim.new(0, 6)
    layout.Parent = self.NotifContainer
end

function SolsticeUI:Notify(text, dur)
    if not self.Config.ShowNotifications then return end
    dur = dur or 2.5
    local tw = math.min(GetTextWidth(text, self.Config.Font, 13) + 36, 300)

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, tw, 0, 32)
    holder.BackgroundTransparency = 1
    holder.Parent = self.NotifContainer

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 1, 0)
    card.Position = UDim2.new(0, tw + 50, 0, 0)
    card.BackgroundColor3 = PALETTE.NotifBg
    card.BackgroundTransparency = 0.03
    card.BorderSizePixel = 0
    card.Parent = holder
    Corner(card, UDim.new(0, 4))

    AddShadow(card, {offsetX = 4, offsetY = 4, transparency = 0.8})

    local gradLine = Instance.new("Frame")
    gradLine.Size = UDim2.new(1, 0, 0, 2)
    gradLine.BackgroundColor3 = PALETTE.ActiveGradientStart
    gradLine.BorderSizePixel = 0
    gradLine.Parent = card

    local lineGrad = Instance.new("UIGradient")
    lineGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, PALETTE.ActiveGradientStart),
        ColorSequenceKeypoint.new(1, PALETTE.ActiveGradientEnd)
    })
    lineGrad.Parent = gradLine

    local stroke = Instance.new("UIStroke")
    stroke.Color = PALETTE.NotifBorder
    stroke.Thickness = 1
    stroke.Transparency = PALETTE.NotifBorderTransparency
    stroke.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -14, 1, -2)
    lbl.Position = UDim2.new(0, 7, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = PALETTE.ItemText
    lbl.Font = self.Config.Font
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Parent = card
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, lbl) end

    Tween(card, ANIM.NotifyIn, {Position = UDim2.new(0, 0, 0, 0)}):Play()

    Tween(gradLine, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), {
        BackgroundTransparency = 0.3
    }):Play()

    task.delay(dur, function()
        if card and card.Parent then
            local fadeOut = Tween(card, ANIM.NotifyOut, {
                Position = UDim2.new(0, tw + 50, 0, 0),
                BackgroundTransparency = 1
            })
            fadeOut:Play()
            Tween(stroke, TweenInfo.new(0.25), {Transparency = 1}):Play()
            Tween(lbl, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            Tween(gradLine, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            fadeOut.Completed:Connect(function()
                holder:Destroy()
            end)
        end
    end)
end

-- ==================== RENDER LOOP ====================
function SolsticeUI:_StartRenderLoop()
    RunService.RenderStepped:Connect(function(dt)
        if self.ARRAYLIST_ENABLED then
            self.RainbowOffset = (self.RainbowOffset + dt * self.Config.ArrayListRainbowSpeed) % 1
            for name, itemFrame in pairs(self.ArrayListItems) do
                if itemFrame.Visible then
                    local txt = itemFrame:FindFirstChild("TextLabel")
                    local borderLine = itemFrame:FindFirstChild("BgBar") and itemFrame.BgBar:FindFirstChild("BorderLine")
                    if txt then
                        local hue = (self.RainbowOffset + (itemFrame.LayoutOrder - 1) * 0.05) % 1
                        local color = HSVtoRGB(hue, 0.75, 1)
                        txt.TextColor3 = color
                        if borderLine then
                            borderLine.BackgroundColor3 = color
                        end
                    end
                end
            end
        end
    end)
end

-- ==================== TOGGLE KEY ====================
function SolsticeUI:_BindToggleKey()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            self.GUI_ENABLED = not self.GUI_ENABLED
            self.ClickGui.Enabled = self.GUI_ENABLED

            for i, panelData in ipairs(self.Panels) do
                local panel = panelData.Instance
                if self.GUI_ENABLED then
                    panel.BackgroundTransparency = 1
                    local stroke = panel:FindFirstChildOfClass("UIStroke")
                    if stroke then stroke.Transparency = 1 end
                    Tween(panel, ANIM.PanelLoad, {BackgroundTransparency = PALETTE.PanelBgTransparency}):Play()
                    if stroke then
                        Tween(stroke, TweenInfo.new(0.5), {Transparency = 0.35}):Play()
                    end
                end
            end
        end
    end)
end

-- ==================== CREATE CATEGORY ====================
function SolsticeUI:CreateCategory(name, iconChar, position, features)
    position = position or UDim2.new(0, self.NextPanelX, 0, self.NextPanelY)
    self.NextPanelX = self.NextPanelX + self.Config.PanelSpacing

    local ui = self
    local panelData = {
        Name = name,
        Collapsed = false,
        Features = features or {},
        CurrentExpandedHeight = self.Config.PanelHeaderHeight,
    }

    local panel = Instance.new("Frame")
    panel.Name = name .. "Panel"
    panel.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.PanelHeaderHeight)
    panel.Position = position
    panel.BackgroundColor3 = PALETTE.PanelBg
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel = 0
    panel.ZIndex = 10
    panel.Parent = self.ClickGui
    Corner(panel, self.Config.PanelCornerRadius)

    AddShadow(panel, {offsetX = 8, offsetY = 8, transparency = 0.65})

    local stroke = Instance.new("UIStroke")
    stroke.Color = PALETTE.PanelBorder
    stroke.Thickness = 1
    stroke.Transparency = 1
    stroke.Parent = panel

    local topAccent = Instance.new("Frame")
    topAccent.Name = "TopAccent"
    topAccent.Size = UDim2.new(1, 0, 0, 2)
    topAccent.Position = UDim2.new(0, 0, 0, 0)
    topAccent.BackgroundColor3 = PALETTE.ActiveGradientStart
    topAccent.BorderSizePixel = 0
    topAccent.ZIndex = 11
    topAccent.Parent = panel

    local topGrad = Instance.new("UIGradient")
    topGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, PALETTE.ActiveGradientStart),
        ColorSequenceKeypoint.new(0.5, PALETTE.ActiveGradientEnd),
        ColorSequenceKeypoint.new(1, PALETTE.ActiveGradientStart)
    })
    topGrad.Parent = topAccent

    panelData.Instance = panel

    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, self.Config.PanelHeaderHeight)
    header.BackgroundColor3 = PALETTE.HeaderBg
    header.BackgroundTransparency = 0.1
    header.BorderSizePixel = 0
    header.Text = ""
    header.AutoButtonColor = false
    header.ZIndex = 11
    header.Parent = panel
    Corner(header, UDim.new(0, 4))

    header.MouseEnter:Connect(function()
        Tween(header, ANIM.Hover, {BackgroundColor3 = PALETTE.HeaderBgHover}):Play()
    end)
    header.MouseLeave:Connect(function()
        Tween(header, ANIM.HoverOut, {BackgroundColor3 = PALETTE.HeaderBg}):Play()
    end)

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 20, 1, 0)
    iconLbl.Position = UDim2.new(0, 8, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = iconChar or "\u2022"
    iconLbl.TextColor3 = PALETTE.HeaderIcon
    iconLbl.Font = self.Config.FontItalic
    iconLbl.TextSize = 11
    iconLbl.TextXAlignment = Enum.TextXAlignment.Center
    iconLbl.ZIndex = 12
    iconLbl.Parent = header
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, iconLbl) end

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -28, 1, 0)
    title.Position = UDim2.new(0, 22, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = PALETTE.HeaderText
    title.Font = self.Config.Font
    title.TextSize = self.Config.HeaderTextSize
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 12
    title.Parent = header
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, title) end

    local expandIcon = Instance.new("TextLabel")
    expandIcon.Size = UDim2.new(0, 16, 0, 16)
    expandIcon.Position = UDim2.new(1, -20, 0.5, -8)
    expandIcon.BackgroundTransparency = 1
    expandIcon.Text = "\u25bc"
    expandIcon.TextColor3 = PALETTE.Muted
    expandIcon.Font = Enum.Font.SourceSans
    expandIcon.TextSize = 10
    expandIcon.ZIndex = 12
    expandIcon.Parent = header

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -self.Config.PanelHeaderHeight)
    content.Position = UDim2.new(0, 0, 0, self.Config.PanelHeaderHeight)
    content.BackgroundTransparency = 1
    content.Parent = panel
    content.ClipsDescendants = true
    content.ZIndex = 10

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 1)
    list.Parent = content

    function panelData:UpdateHeight()
        local target = self.Collapsed and ui.Config.PanelHeaderHeight or self.CurrentExpandedHeight
        Tween(panel, ANIM.Expand, {
            Size = UDim2.new(0, ui.Config.PanelWidth, 0, target)
        }):Play()

        Tween(expandIcon, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Rotation = self.Collapsed and -90 or 0
        }):Play()
    end

    function panelData:ToggleCollapse()
        self.Collapsed = not self.Collapsed
        self:UpdateHeight()
    end

    header.MouseButton1Click:Connect(function() panelData:ToggleCollapse() end)
    MakeDraggable(panel, header)

    for i, feat in ipairs(features or {}) do
        ui:_CreateFeature(content, panelData, feat)
    end

    task.delay(0.05, function()
        panelData:UpdateHeight()
    end)

    table.insert(self.Panels, panelData)

    local panelIndex = #self.Panels
    self:_PlayPanelLoadAnimation(panel, panelIndex)

    return panelData
end

-- ==================== CREATE FEATURE ====================
function SolsticeUI:_CreateFeature(content, panelData, feat)
    local ui = self
    local modContainer = Instance.new("Frame")
    modContainer.Name = feat.name .. "Container"
    modContainer.Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight)
    modContainer.BackgroundTransparency = 1
    modContainer.ClipsDescendants = true
    modContainer.Parent = content

    local modLayout = Instance.new("UIListLayout")
    modLayout.SortOrder = Enum.SortOrder.LayoutOrder
    modLayout.Padding = UDim.new(0, 0)
    modLayout.Parent = modContainer

    local btn = Instance.new("TextButton")
    btn.Name = feat.name
    btn.Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight)
    btn.BackgroundColor3 = PALETTE.ItemBg
    btn.BackgroundTransparency = PALETTE.ItemBgTransparency
    btn.BorderSizePixel = 0
    btn.Text = feat.name
    btn.TextColor3 = PALETTE.ItemText
    btn.Font = ui.Config.Font
    btn.TextSize = ui.Config.TextSize
    btn.AutoButtonColor = false
    btn.ZIndex = 11
    btn.Parent = modContainer
    Corner(btn, ui.Config.ButtonCornerRadius)

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = PALETTE.ItemHoverBorder
    btnStroke.Thickness = 1
    btnStroke.Transparency = 1
    btnStroke.Parent = btn

    local activeGrad = Instance.new("UIGradient")
    activeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, PALETTE.ActiveGradientStart),
        ColorSequenceKeypoint.new(1, PALETTE.ActiveGradientEnd)
    })
    activeGrad.Rotation = 90
    activeGrad.Enabled = false
    activeGrad.Parent = btn

    local glowFrame = Instance.new("Frame")
    glowFrame.Name = "Glow"
    glowFrame.Size = UDim2.new(1, 0, 1, 0)
    glowFrame.BackgroundColor3 = PALETTE.PressGlow
    glowFrame.BackgroundTransparency = 1
    glowFrame.BorderSizePixel = 0
    glowFrame.ZIndex = 0
    glowFrame.Parent = btn
    Corner(glowFrame, ui.Config.ButtonCornerRadius)

    local activeDot = Instance.new("Frame")
    activeDot.Name = "ActiveDot"
    activeDot.Size = UDim2.new(0, 4, 0, 4)
    activeDot.Position = UDim2.new(0, 6, 0.5, -2)
    activeDot.BackgroundColor3 = PALETTE.ActiveGradientStart
    activeDot.BorderSizePixel = 0
    activeDot.ZIndex = 12
    activeDot.Visible = false
    activeDot.Parent = btn
    Corner(activeDot, UDim.new(0.5, 0))

    local dotGlow = Instance.new("Frame")
    dotGlow.Size = UDim2.new(1, 4, 1, 4)
    dotGlow.Position = UDim2.new(0, -2, 0, -2)
    dotGlow.BackgroundColor3 = PALETTE.ActiveGlow
    dotGlow.BackgroundTransparency = 0.6
    dotGlow.BorderSizePixel = 0
    dotGlow.ZIndex = 11
    dotGlow.Parent = activeDot
    Corner(dotGlow, UDim.new(0.5, 0))

    local hasSettings = feat.settings and #feat.settings > 0
    local indicator = nil
    if hasSettings then
        indicator = Instance.new("TextButton")
        indicator.Name = "Indicator"
        indicator.Size = UDim2.new(0, 18, 1, 0)
        indicator.Position = UDim2.new(1, -22, 0, 0)
        indicator.BackgroundTransparency = 1
        indicator.Text = "+"
        indicator.TextColor3 = PALETTE.Muted
        indicator.Font = ui.Config.Font
        indicator.TextSize = 12
        indicator.AutoButtonColor = false
        indicator.ZIndex = 12
        indicator.Parent = btn
    end

    local enabled = false
    local featType = feat.type or "toggle"
    local settingsExpanded = false
    local settingsContainer = nil
    local setHeight = 0

    if ui.SavedConfig.modules and ui.SavedConfig.modules[feat.name] then
        enabled = ui.SavedConfig.modules[feat.name].state or false
        if enabled and featType ~= "button" then
            btn.BackgroundColor3 = PALETTE.ActiveBg
            btn.BackgroundTransparency = 0
            btn.TextColor3 = PALETTE.ActiveText
            activeGrad.Enabled = true
            activeDot.Visible = true
            ui:_SetModuleState(feat.name, true, ui.SavedConfig.modules[feat.name].value)
            if feat.callback then pcall(feat.callback, true) end
        end
    end

    btn.MouseEnter:Connect(function()
        if not enabled then
            Tween(btn, ANIM.Hover, {
                BackgroundColor3 = PALETTE.ItemHoverBg,
                BackgroundTransparency = 0.1
            }):Play()
            Tween(btnStroke, TweenInfo.new(0.15), {Transparency = 0.5}):Play()
        else
            Tween(btn, ANIM.Hover, {
                BackgroundTransparency = 0.05
            }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not enabled then
            Tween(btn, ANIM.HoverOut, {
                BackgroundColor3 = PALETTE.ItemBg,
                BackgroundTransparency = PALETTE.ItemBgTransparency
            }):Play()
            Tween(btnStroke, TweenInfo.new(0.12), {Transparency = 1}):Play()
        else
            Tween(btn, ANIM.HoverOut, {
                BackgroundTransparency = 0
            }):Play()
        end
    end)

    local function doToggle()
        if featType == "button" then return end
        enabled = not enabled
        ui:_SetModuleState(feat.name, enabled)
        if enabled then
            Tween(btn, ANIM.Standard, {
                BackgroundColor3 = PALETTE.ActiveBg,
                BackgroundTransparency = 0,
                TextColor3 = PALETTE.ActiveText
            }):Play()
            activeGrad.Enabled = true
            activeDot.Visible = true

            Tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight + 2)
            }):Play()
            task.delay(0.12, function()
                if enabled then
                    Tween(btn, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight)
                    }):Play()
                end
            end)

            Tween(activeDot, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 6, 0, 6),
                Position = UDim2.new(0, 5, 0.5, -3)
            }):Play()
            task.delay(0.3, function()
                Tween(activeDot, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, 4, 0, 4),
                    Position = UDim2.new(0, 6, 0.5, -2)
                }):Play()
            end)
        else
            Tween(btn, ANIM.Standard, {
                BackgroundColor3 = PALETTE.ItemBg,
                BackgroundTransparency = PALETTE.ItemBgTransparency,
                TextColor3 = PALETTE.ItemText
            }):Play()
            activeDot.Visible = false
            task.delay(0.2, function()
                if not enabled then activeGrad.Enabled = false end
            end)
        end
        if feat.callback then pcall(feat.callback, enabled) end
    end

    local function toggleSettings()
        if not settingsContainer then return end
        settingsExpanded = not settingsExpanded
        local targetH = settingsExpanded and (ui.Config.ItemHeight + setHeight) or ui.Config.ItemHeight

        Tween(modContainer, ANIM.SpringSoft, {
            Size = UDim2.new(1, 0, 0, targetH)
        }):Play()

        if settingsExpanded then
            settingsContainer.BackgroundTransparency = 1
            Tween(settingsContainer, TweenInfo.new(0.25), {
                BackgroundTransparency = PALETTE.SettingBgTransparency
            }):Play()
            for _, child in ipairs(settingsContainer:GetChildren()) do
                if child:IsA("Frame") then
                    child.BackgroundTransparency = 1
                    Tween(child, TweenInfo.new(0.2), {
                        BackgroundTransparency = PALETTE.SettingBgTransparency
                    }):Play()
                end
            end
        end

        panelData.CurrentExpandedHeight = panelData.CurrentExpandedHeight + (settingsExpanded and setHeight or -setHeight)
        panelData:UpdateHeight()
        if indicator then
            local targetRotation = settingsExpanded and 45 or 0
            Tween(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Rotation = targetRotation
            }):Play()
        end
    end

    if featType == "button" then
        btn.MouseButton1Down:Connect(function()
            Tween(btn, TweenInfo.new(ui.Config.ClickScaleDuration), {
                Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight * ui.Config.ClickScale),
                BackgroundColor3 = PALETTE.PressBg,
                BackgroundTransparency = 0
            }):Play()
            Tween(glowFrame, TweenInfo.new(0.08), {
                BackgroundTransparency = 0.35
            }):Play()
        end)

        btn.MouseButton1Up:Connect(function()
            Tween(btn, TweenInfo.new(ui.Config.ClickRestoreDuration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight),
                BackgroundColor3 = PALETTE.ItemBg,
                BackgroundTransparency = PALETTE.ItemBgTransparency
            }):Play()
            Tween(glowFrame, TweenInfo.new(0.15), {
                BackgroundTransparency = 1
            }):Play()
        end)

        btn.MouseLeave:Connect(function()
            Tween(btn, ANIM.Hover, {
                Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight),
                BackgroundColor3 = PALETTE.ItemBg,
                BackgroundTransparency = PALETTE.ItemBgTransparency
            }):Play()
            Tween(glowFrame, TweenInfo.new(0.1), {
                BackgroundTransparency = 1
            }):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            if feat.callback then pcall(feat.callback) end
            ui:Notify(feat.name .. " executed", 1.2)
        end)
    else
        btn.MouseButton1Down:Connect(function()
            if not enabled then
                Tween(btn, TweenInfo.new(ui.Config.ClickScaleDuration), {
                    Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight * ui.Config.ClickScale)
                }):Play()
                Tween(glowFrame, TweenInfo.new(0.08), {
                    BackgroundTransparency = 0.4
                }):Play()
            end
        end)

        btn.MouseButton1Up:Connect(function()
            if not enabled then
                Tween(btn, TweenInfo.new(ui.Config.ClickRestoreDuration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight)
                }):Play()
            end
            Tween(glowFrame, TweenInfo.new(0.15), {
                BackgroundTransparency = 1
            }):Play()
        end)

        btn.MouseLeave:Connect(function()
            if not enabled then
                Tween(btn, ANIM.Hover, {
                    Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight)
                }):Play()
            end
            Tween(glowFrame, TweenInfo.new(0.1), {
                BackgroundTransparency = 1
            }):Play()
        end)

        btn.MouseButton1Click:Connect(doToggle)
    end

    if indicator then
        indicator.MouseButton1Click:Connect(function()
            toggleSettings()
        end)
    end

    modContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            toggleSettings()
        end
    end)

    panelData.CurrentExpandedHeight = panelData.CurrentExpandedHeight + ui.Config.ItemHeight

    ui.AllModules[feat.name] = {
        Button = btn,
        Enabled = function() return enabled end,
        Toggle = doToggle,
    }

    if hasSettings then
        settingsContainer, setHeight = ui:_CreateSettings(modContainer, panelData, feat.settings, feat.name)
    end
end

-- ==================== CREATE SETTINGS ====================
function SolsticeUI:_CreateSettings(modContainer, panelData, settings, moduleName)
    local ui = self
    local setHeight = 0
    local container = Instance.new("Frame")
    container.Name = "Settings"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundColor3 = PALETTE.SettingBg
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ZIndex = 11
    container.Parent = modContainer

    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = PALETTE.SettingBorder
    containerStroke.Thickness = 1
    containerStroke.Transparency = 0.5
    containerStroke.Parent = container

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 1)
    list.Parent = container

    for _, s in ipairs(settings) do
        local height = ui.Config.SettingHeight
        if s.type == "slider" then height = ui.Config.SliderHeight
        elseif s.type == "color" then height = 26
        elseif s.type == "dropdown" then height = 26
        end

        setHeight = setHeight + height + 1

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, height)
        frame.BackgroundColor3 = PALETTE.SettingBg
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.ZIndex = 11
        frame.Parent = container

        local frameStroke = Instance.new("UIStroke")
        frameStroke.Color = PALETTE.SettingBorder
        frameStroke.Thickness = 1
        frameStroke.Transparency = 0.3
        frameStroke.Parent = frame

        if s.type == "toggle" then
            ui:_CreateToggleSetting(frame, s, moduleName)
        elseif s.type == "slider" then
            ui:_CreateSliderSetting(frame, s, moduleName)
        elseif s.type == "button" then
            ui:_CreateButtonSetting(frame, s)
        elseif s.type == "keybind" then
            ui:_CreateKeybindSetting(frame, s)
        elseif s.type == "color" then
            ui:_CreateColorSetting(frame, s)
        elseif s.type == "dropdown" then
            ui:_CreateDropdownSetting(frame, s)
        end
    end

    setHeight = math.max(0, setHeight - 1)
    container.Size = UDim2.new(1, 0, 0, setHeight)
    return container, setHeight
end

-- ==================== TOGGLE SETTING (iOS Style) ====================
function SolsticeUI:_CreateToggleSetting(frame, s, moduleName)
    local ui = self
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 12
    btn.Parent = frame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -56, 1, 0)
    nameLbl.Position = UDim2.new(0, 10, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = s.name
    nameLbl.TextColor3 = s.default and PALETTE.SettingValue or PALETTE.SettingText
    nameLbl.Font = ui.Config.Font
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 12
    nameLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, nameLbl) end

    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 30, 0, 16)
    switchBg.Position = UDim2.new(1, -40, 0.5, -8)
    switchBg.BackgroundColor3 = s.default and PALETTE.ToggleOn or PALETTE.ToggleOff
    switchBg.BorderSizePixel = 0
    switchBg.ZIndex = 12
    switchBg.Parent = frame
    Corner(switchBg, UDim.new(0.5, 0))

    local switchStroke = Instance.new("UIStroke")
    switchStroke.Color = s.default and PALETTE.ToggleOn or PALETTE.ToggleOff
    switchStroke.Thickness = 1
    switchStroke.Transparency = 0.3
    switchStroke.Parent = switchBg

    local switchKnob = Instance.new("Frame")
    switchKnob.Size = UDim2.new(0, 13, 0, 13)
    switchKnob.Position = s.default and UDim2.new(1, -14, 0.5, -6.5) or UDim2.new(0, 1.5, 0.5, -6.5)
    switchKnob.BackgroundColor3 = PALETTE.ToggleKnob
    switchKnob.BorderSizePixel = 0
    switchKnob.ZIndex = 13
    switchKnob.Parent = switchBg
    Corner(switchKnob, UDim.new(0.5, 0))

    local knobShadow = Instance.new("Frame")
    knobShadow.Size = UDim2.new(1, 4, 1, 4)
    knobShadow.Position = UDim2.new(0, -2, 0, -2)
    knobShadow.BackgroundColor3 = PALETTE.ToggleKnobShadow
    knobShadow.BackgroundTransparency = 0.65
    knobShadow.BorderSizePixel = 0
    knobShadow.ZIndex = 12
    knobShadow.Parent = switchKnob
    Corner(knobShadow, UDim.new(0.5, 0))

    local val = s.default
    btn.MouseButton1Click:Connect(function()
        val = not val
        nameLbl.TextColor3 = val and PALETTE.SettingValue or PALETTE.SettingText

        Tween(switchBg, ANIM.ToggleColor, {
            BackgroundColor3 = val and PALETTE.ToggleOn or PALETTE.ToggleOff
        }):Play()
        Tween(switchStroke, ANIM.ToggleColor, {
            Color = val and PALETTE.ToggleOn or PALETTE.ToggleOff
        }):Play()

        Tween(switchKnob, ANIM.ToggleSwitch, {
            Position = val and UDim2.new(1, -14, 0.5, -6.5) or UDim2.new(0, 1.5, 0.5, -6.5)
        }):Play()

        Tween(switchKnob, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 15, 0, 15)
        }):Play()
        task.delay(0.1, function()
            Tween(switchKnob, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 13, 0, 13)
            }):Play()
        end)

        if s.callback then pcall(s.callback, val) end
    end)

    btn.MouseEnter:Connect(function()
        if not val then
            Tween(switchBg, TweenInfo.new(0.15), {BackgroundColor3 = PALETTE.ToggleOffHover}):Play()
        else
            Tween(switchBg, TweenInfo.new(0.15), {BackgroundColor3 = PALETTE.ToggleOnHover}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        Tween(switchBg, TweenInfo.new(0.15), {BackgroundColor3 = val and PALETTE.ToggleOn or PALETTE.ToggleOff}):Play()
    end)
end

-- ==================== SLIDER SETTING (Premium) ====================
function SolsticeUI:_CreateSliderSetting(frame, s, moduleName)
    local ui = self

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0.5, 0, 0, 16)
    nameLbl.Position = UDim2.new(0, 10, 0, 3)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = s.name
    nameLbl.TextColor3 = PALETTE.SettingText
    nameLbl.Font = ui.Config.Font
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 12
    nameLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, nameLbl) end

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.4, 0, 0, 16)
    valLbl.Position = UDim2.new(0.55, 0, 0, 3)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = string.format("%.2f", s.default)
    valLbl.TextColor3 = PALETTE.SettingValue
    valLbl.Font = ui.Config.Font
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 12
    valLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, valLbl) end

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -20, 0, 5)
    barBg.Position = UDim2.new(0, 10, 0, 24)
    barBg.BackgroundColor3 = PALETTE.SliderTrack
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 12
    barBg.Parent = frame
    Corner(barBg, UDim.new(0.5, 0))

    local pct = (s.default - s.min) / (s.max - s.min)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = PALETTE.SliderFill
    fill.BorderSizePixel = 0
    fill.ZIndex = 13
    fill.Parent = barBg
    Corner(fill, UDim.new(0.5, 0))

    local hitArea = Instance.new("TextButton")
    hitArea.Size = UDim2.new(1, 0, 1, 20)
    hitArea.Position = UDim2.new(0, 0, 0, -10)
    hitArea.BackgroundTransparency = 1
    hitArea.Text = ""
    hitArea.ZIndex = 15
    hitArea.Parent = barBg

    local thumbSize = 14
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, thumbSize, 0, thumbSize)
    thumb.Position = UDim2.new(pct, -thumbSize/2, 0.5, -thumbSize/2)
    thumb.BackgroundColor3 = PALETTE.SliderThumb
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 14
    thumb.Parent = barBg
    Corner(thumb, UDim.new(0.5, 0))

    local glowRing = Instance.new("Frame")
    glowRing.Size = UDim2.new(1, 10, 1, 10)
    glowRing.Position = UDim2.new(0, -5, 0, -5)
    glowRing.BackgroundColor3 = PALETTE.SliderThumbGlow
    glowRing.BackgroundTransparency = 0.75
    glowRing.BorderSizePixel = 0
    glowRing.ZIndex = 13
    glowRing.Parent = thumb
    Corner(glowRing, UDim.new(0.5, 0))

    local highlight = Instance.new("Frame")
    highlight.Size = UDim2.new(0.5, 0, 0.5, 0)
    highlight.Position = UDim2.new(0.25, 0, 0.15, 0)
    highlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    highlight.BackgroundTransparency = 0.3
    highlight.BorderSizePixel = 0
    highlight.ZIndex = 15
    highlight.Parent = thumb
    Corner(highlight, UDim.new(0.5, 0))

    local dragging = false
    local dragTouch = nil

    local function updateSlider(inputPos)
        local relX = inputPos.X - barBg.AbsolutePosition.X
        local sliderX = math.clamp(relX, 0, barBg.AbsoluteSize.X)
        local newPct = sliderX / math.max(barBg.AbsoluteSize.X, 1)

        Tween(fill, ANIM.SliderMove, {
            Size = UDim2.new(newPct, 0, 1, 0)
        }):Play()

        Tween(thumb, ANIM.SliderMove, {
            Position = UDim2.new(newPct, -thumbSize/2, 0.5, -thumbSize/2)
        }):Play()

        local val = s.min + (s.max - s.min) * newPct
        val = math.floor(val * 100) / 100
        valLbl.Text = string.format("%.2f", val)
        if s.callback then pcall(s.callback, val) end
        if ui.EnabledModules[moduleName] then
            ui:_SetModuleState(moduleName, true, val)
        end
    end

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil

            Tween(thumb, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, thumbSize + 4, 0, thumbSize + 4)
            }):Play()
            Tween(glowRing, TweenInfo.new(0.12), {
                BackgroundTransparency = 0.3,
                Size = UDim2.new(1, 16, 1, 16),
                Position = UDim2.new(0, -8, 0, -8)
            }):Play()
            Tween(fill, TweenInfo.new(0.1), {BackgroundColor3 = PALETTE.SliderFillActive}):Play()

            updateSlider(input.Position)
        end
    end

    hitArea.InputBegan:Connect(onInputBegan)
    thumb.InputBegan:Connect(onInputBegan)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if dragTouch and input.UserInputType == Enum.UserInputType.Touch then
            if input ~= dragTouch then return end
            updateSlider(input.Position)
        elseif not dragTouch and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if dragTouch and input == dragTouch then
                dragging = false; dragTouch = nil
            elseif not dragTouch then
                dragging = false
            end
            Tween(thumb, ANIM.SliderRelease, {
                Size = UDim2.new(0, thumbSize, 0, thumbSize)
            }):Play()
            Tween(glowRing, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.75,
                Size = UDim2.new(1, 10, 1, 10),
                Position = UDim2.new(0, -5, 0, -5)
            }):Play()
            Tween(fill, TweenInfo.new(0.2), {BackgroundColor3 = PALETTE.SliderFill}):Play()
        end
    end)

    frame.MouseEnter:Connect(function()
        Tween(barBg, TweenInfo.new(0.15), {BackgroundColor3 = PALETTE.SliderTrackHover}):Play()
    end)
    frame.MouseLeave:Connect(function()
        Tween(barBg, TweenInfo.new(0.15), {BackgroundColor3 = PALETTE.SliderTrack}):Play()
    end)
end

-- ==================== BUTTON SETTING ====================
function SolsticeUI:_CreateButtonSetting(frame, s)
    local ui = self
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(48, 48, 58)
    btn.BackgroundTransparency = 0.25
    btn.BorderSizePixel = 0
    btn.Text = s.name
    btn.TextColor3 = PALETTE.SettingValue
    btn.Font = ui.Config.Font
    btn.TextSize = 11
    btn.ZIndex = 12
    btn.Parent = frame
    Corner(btn, UDim.new(0, 3))
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, btn) end

    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 0, 1, 0)
    glow.BackgroundColor3 = PALETTE.PressGlow
    glow.BackgroundTransparency = 1
    glow.BorderSizePixel = 0
    glow.ZIndex = 11
    glow.Parent = btn
    Corner(glow, UDim.new(0, 3))

    btn.MouseEnter:Connect(function()
        Tween(btn, ANIM.Hover, {BackgroundTransparency = 0.08}):Play()
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, ANIM.Hover, {BackgroundTransparency = 0.25}):Play()
        Tween(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        Tween(glow, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
    end)

    btn.MouseButton1Down:Connect(function()
        Tween(btn, TweenInfo.new(0.06), {
            Size = UDim2.new(0.97, 0, 0.92, 0),
            BackgroundTransparency = 0.02
        }):Play()
        Tween(glow, TweenInfo.new(0.06), {BackgroundTransparency = 0.3}):Play()
    end)

    btn.MouseButton1Up:Connect(function()
        Tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 0.08
        }):Play()
        Tween(glow, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        if s.callback then pcall(s.callback) end
    end)
end

-- ==================== KEYBIND SETTING ====================
function SolsticeUI:_CreateKeybindSetting(frame, s)
    local ui = self
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 12
    btn.Parent = frame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0.5, 0, 1, 0)
    nameLbl.Position = UDim2.new(0, 10, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = s.name
    nameLbl.TextColor3 = PALETTE.SettingText
    nameLbl.Font = ui.Config.Font
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 12
    nameLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, nameLbl) end

    local keyBg = Instance.new("Frame")
    keyBg.Size = UDim2.new(0, 54, 0, 20)
    keyBg.Position = UDim2.new(1, -62, 0.5, -10)
    keyBg.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
    keyBg.BackgroundTransparency = 0.15
    keyBg.BorderSizePixel = 0
    keyBg.ZIndex = 12
    keyBg.Parent = frame
    Corner(keyBg, UDim.new(0, 4))

    local keyStroke = Instance.new("UIStroke")
    keyStroke.Color = PALETTE.SettingBorder
    keyStroke.Thickness = 1
    keyStroke.Transparency = 0.4
    keyStroke.Parent = keyBg

    local keyLbl = Instance.new("TextLabel")
    keyLbl.Size = UDim2.new(1, 0, 1, 0)
    keyLbl.BackgroundTransparency = 1
    keyLbl.Text = s.default and s.default.Name or "None"
    keyLbl.TextColor3 = PALETTE.SettingValue
    keyLbl.Font = ui.Config.Font
    keyLbl.TextSize = 11
    keyLbl.TextXAlignment = Enum.TextXAlignment.Center
    keyLbl.ZIndex = 13
    keyLbl.Parent = keyBg
    if ui.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, keyLbl) end

    local listening = false
    local listenConn = nil

    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyLbl.Text = "..."
        keyLbl.TextColor3 = Color3.fromRGB(255, 200, 100)

        local pulseTween = Tween(keyBg, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true), {
            BackgroundColor3 = Color3.fromRGB(58, 58, 75)
        })
        pulseTween:Play()

        listenConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if listenConn then listenConn:Disconnect() end
                pulseTween:Cancel()
                listening = false
                local newKey = input.KeyCode
                keyLbl.Text = newKey.Name
                keyLbl.TextColor3 = PALETTE.SettingValue
                Tween(keyBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(38, 38, 48)}):Play()
                if s.callback then pcall(s.callback, newKey) end
            end
        end)
    end)
end

-- ==================== COLOR SETTING ====================
function SolsticeUI:_CreateColorSetting(frame, s)
    local ui = self
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0.4, 0, 1, 0)
    nameLbl.Position = UDim2.new(0, 10, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = s.name
    nameLbl.TextColor3 = PALETTE.SettingText
    nameLbl.Font = ui.Config.Font
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 12
    nameLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, nameLbl) end

    local colors = s.colors or {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 128, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 128, 255),
        Color3.fromRGB(128, 0, 255),
    }

    local boxSize = 12
    local spacing = 3
    local startX = ui.Config.PanelWidth - (#colors * (boxSize + spacing)) - 8

    for i, color in ipairs(colors) do
        local box = Instance.new("TextButton")
        box.Size = UDim2.new(0, boxSize, 0, boxSize)
        box.Position = UDim2.new(0, startX + (i-1) * (boxSize + spacing), 0.5, -boxSize/2)
        box.BackgroundColor3 = color
        box.BorderSizePixel = 0
        box.Text = ""
        box.ZIndex = 12
        box.Parent = frame
        Corner(box, UDim.new(0, 3))

        local boxStroke = Instance.new("UIStroke")
        boxStroke.Color = PALETTE.SettingBorder
        boxStroke.Thickness = 1
        boxStroke.Transparency = 0.5
        boxStroke.Parent = box

        box.MouseEnter:Connect(function()
            Tween(box, TweenInfo.new(0.1), {
                Size = UDim2.new(0, boxSize+3, 0, boxSize+3),
                Position = UDim2.new(0, startX + (i-1) * (boxSize + spacing) - 1.5, 0.5, -boxSize/2 - 1.5)
            }):Play()
            Tween(boxStroke, TweenInfo.new(0.1), {Transparency = 0}):Play()
        end)
        box.MouseLeave:Connect(function()
            Tween(box, TweenInfo.new(0.1), {
                Size = UDim2.new(0, boxSize, 0, boxSize),
                Position = UDim2.new(0, startX + (i-1) * (boxSize + spacing), 0.5, -boxSize/2)
            }):Play()
            Tween(boxStroke, TweenInfo.new(0.1), {Transparency = 0.5}):Play()
        end)

        box.MouseButton1Click:Connect(function()
            if s.callback then pcall(s.callback, color) end
        end)
    end
end

-- ==================== DROPDOWN SETTING ====================
function SolsticeUI:_CreateDropdownSetting(frame, s)
    local ui = self
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 12
    btn.Parent = frame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0.4, 0, 1, 0)
    nameLbl.Position = UDim2.new(0, 10, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = s.name
    nameLbl.TextColor3 = PALETTE.SettingText
    nameLbl.Font = ui.Config.Font
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 12
    nameLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, nameLbl) end

    local valBg = Instance.new("Frame")
    valBg.Size = UDim2.new(0, 80, 0, 20)
    valBg.Position = UDim2.new(1, -90, 0.5, -10)
    valBg.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
    valBg.BackgroundTransparency = 0.15
    valBg.BorderSizePixel = 0
    valBg.ZIndex = 12
    valBg.Parent = frame
    Corner(valBg, UDim.new(0, 3))

    local valStroke = Instance.new("UIStroke")
    valStroke.Color = PALETTE.SettingBorder
    valStroke.Thickness = 1
    valStroke.Transparency = 0.4
    valStroke.Parent = valBg

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(1, -8, 1, 0)
    valLbl.Position = UDim2.new(0, 4, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = s.default or "Select..."
    valLbl.TextColor3 = PALETTE.SettingValue
    valLbl.Font = ui.Config.Font
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 13
    valLbl.Parent = valBg
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, valLbl) end

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 12, 0, 12)
    arrow.Position = UDim2.new(0, 4, 0.5, -6)
    arrow.BackgroundTransparency = 1
    arrow.Text = "\u25bc"
    arrow.TextColor3 = PALETTE.Muted
    arrow.Font = Enum.Font.SourceSans
    arrow.TextSize = 8
    arrow.ZIndex = 13
    arrow.Parent = valBg

    btn.MouseButton1Click:Connect(function()
        if s.options then
            local current = valLbl.Text
            local idx = 1
            for i, opt in ipairs(s.options) do
                if opt == current then idx = i; break end
            end
            idx = idx % #s.options + 1
            valLbl.Text = s.options[idx]

            -- Pop animation
            Tween(valBg, TweenInfo.new(0.08), {Size = UDim2.new(0, 84, 0, 22), Position = UDim2.new(1, -92, 0.5, -11)}):Play()
            task.delay(0.08, function()
                Tween(valBg, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 80, 0, 20), Position = UDim2.new(1, -90, 0.5, -10)
                }):Play()
            end)

            if s.callback then pcall(s.callback, s.options[idx]) end
        end
    end)

    btn.MouseEnter:Connect(function()
        Tween(valBg, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        Tween(valStroke, TweenInfo.new(0.15), {Transparency = 0.2}):Play()
    end)
    btn.MouseLeave:Connect(function()
        Tween(valBg, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
        Tween(valStroke, TweenInfo.new(0.15), {Transparency = 0.4}):Play()
    end)
end

-- ==================== PUBLIC API ====================
function SolsticeUI:IsEnabled(name)
    return self.EnabledModules[name] and self.EnabledModules[name].state or false
end

function SolsticeUI:ToggleModule(name)
    local mod = self.AllModules[name]
    if mod and mod.Toggle then mod.Toggle() end
end

function SolsticeUI:SetValue(name, value)
    self:_SetModuleState(name, self:IsEnabled(name), value)
end

function SolsticeUI:Destroy()
    if self.ClickGui then self.ClickGui:Destroy() end
    if self.HudGui then self.HudGui:Destroy() end
    self.EnabledModules = {}
    self.AllModules = {}
    self.Panels = {}
    self.ArrayListItems = {}
end

return SolsticeUI
