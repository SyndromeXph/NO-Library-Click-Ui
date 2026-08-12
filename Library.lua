-- ============================================================
-- SolsticeUI v6.0 - Animation & Polish Overhaul
-- Optimized click feedback, smooth toggles, spring physics
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


-- ==================== MATH UTILS ====================

local MathUtils = {}

function MathUtils.lerp(a, b, t)
    return a + t * (b - a)
end

function MathUtils.clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

-- ==================== COLOR UTILS ====================

local ColorUtils = {}

ColorUtils.theme = {
    Color3.fromRGB(233, 168, 188),  -- #E9A8BC 浅粉
    Color3.fromRGB(110, 200, 241),  -- #6EC8F1 浅蓝
    Color3.new(1, 1, 1),            -- 白色
}

function ColorUtils.hsvToRgb(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q end

    return Color3.new(r, g, b)
end

function ColorUtils.lerpColors(seconds, index, colors)
    if #colors == 0 then return Color3.new(1, 1, 1) end
    local time = 10000 / seconds
    local angle = (tick() * 1000 + index) % time
    local segmentTime = time / #colors
    local segmentIndex = math.floor(angle / segmentTime)
    local segmentIndexFloat = angle / segmentTime - segmentIndex
    local startColor = colors[segmentIndex + 1]
    local endColor = colors[(segmentIndex + 1) % #colors + 1]

    return startColor:Lerp(endColor, segmentIndexFloat)
end

function ColorUtils.getThemedColor(index)
    return ColorUtils.lerpColors(3.0, index, ColorUtils.theme)
end

-- ==================== MODULE DATA STRUCTURE ====================

local Module = {}
Module.__index = Module

function Module.new(name, settingDisplay, enabled)
    local self = setmetatable({}, Module)
    self.name = name or ""
    self.settingDisplay = settingDisplay or ""
    self.enabled = enabled or false
    self.visibleInArrayList = true
    self.key = 0
    self.arrayListAnim = 0
    self.lastEnabledTime = enabled and tick() or 0
    return self
end

function Module:setState(state)
    if state and not self.enabled then
        self.lastEnabledTime = tick()
    end
    self.enabled = state
end

-- ==================== ARRAYLIST SYSTEM ====================

local Arraylist = {}
Arraylist.__index = Arraylist

Arraylist.Display = {
    Outline = 0,
    Bar = 1,
    Split = 2,
    None = 3,
}

function Arraylist.new()
    local self = setmetatable({}, Arraylist)
    self.mModules = {}
    self.mInitialized = false
    self.mDisplay = Arraylist.Display.Split
    self.mGlow = true
    self.mGlowStrength = 1.9
    self.mGlowDensity = 2
    self.mFontSize = 15.0
    self.mTopOffset = 10.0
    self.mRightOffset = 30.0
    self.mTextShadow = true
    self.mShadowOffset = 1.0
    return self
end

function Arraylist:initModules()
    if self.mInitialized then return end
    self.mInitialized = true
end

function Arraylist:setModuleState(name, setting, enabled)
    for _, mod in ipairs(self.mModules) do
        if mod.name == name then
            mod:setState(enabled)
            return
        end
    end
    local mod = Module.new(name, setting, enabled)
    mod.visibleInArrayList = true
    table.insert(self.mModules, mod)
end

function Arraylist:setGlow(enabled) self.mGlow = enabled end
function Arraylist:setGlowDensity(density) self.mGlowDensity = density end
function Arraylist:setGlowRadius(radius) self.mGlowStrength = radius end
function Arraylist:setRightOffset(offset) self.mRightOffset = offset end
function Arraylist:setTopOffset(offset) self.mTopOffset = offset end
function Arraylist:setDisplay(mode) self.mDisplay = mode end
function Arraylist:setTextShadow(enabled) self.mTextShadow = enabled end
function Arraylist:setShadowOffset(offset) self.mShadowOffset = offset end
function Arraylist:setFontSize(size) self.mFontSize = size end

-- ==================== ARRAYLIST RENDERER ====================
local moduleUIs = {}

local function createModuleUI(modName, parentFrame)
    local container = Instance.new("Frame")
    container.Name = modName .. "_Container"
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Parent = parentFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = container

    -- Outline（外边框）
    local outline = Instance.new("UIStroke")
    outline.Name = "Outline"
    outline.Thickness = 1
    outline.Transparency = 1
    outline.Parent = container

    -- Glow（发光效果）
    local glow = Instance.new("UIStroke")
    glow.Name = "Glow"
    glow.Thickness = 2
    glow.Transparency = 1
    glow.Parent = container

    -- 文字标签
    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Right
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = container

    -- Bar（竖条）- 在文字后面（容器最右侧）
    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.BackgroundTransparency = 0
    bar.Size = UDim2.new(0, 3, 1, -4)
    bar.Position = UDim2.new(1, -6, 0, 2)
    bar.AnchorPoint = Vector2.new(0, 0)
    bar.Parent = container
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = container

    return {
        container = container,
        bar = bar,
        outline = outline,
        glow = glow,
        label = label,
        currentAnim = 0,
        isExiting = false,
        exitAnim = 0,
    }
end

local function updateArraylist()
    
    -- 收集所有模块（包括未启用的，用于维护固定顺序）
    local allModules = {}
    for _, mod in ipairs(al.mModules) do
        if mod.visibleInArrayList then
            table.insert(allModules, mod)
        end
    end

    -- 按开启顺序排序（先开启的在上）
    table.sort(allModules, function(a, b)
        return (a.lastEnabledTime or 0) < (b.lastEnabledTime or 0)
    end)

    -- 标记哪些模块当前是启用状态
    local enabledSet = {}
    for _, mod in ipairs(allModules) do
        if mod.enabled then
            enabledSet[mod.name] = true
        end
    end

    -- 更新退场状态
    for name, ui in pairs(moduleUIs) do
        if not enabledSet[name] then
            if not ui.isExiting then
                ui.isExiting = true
                ui.exitAnim = ui.currentAnim
            end
        else
            ui.isExiting = false
            ui.exitAnim = 0
        end
    end

    -- 按开启顺序渲染所有模块（包括退场中的）
    local renderIndex = 0
    for _, mod in ipairs(allModules) do
        local ui = moduleUIs[mod.name]
        local isEnabled = mod.enabled
        local isExiting = ui and ui.isExiting

        if not ui and not isEnabled then
            continue
        end

        if not ui then
            ui = createModuleUI(mod.name, arraylistFrame)
            moduleUIs[mod.name] = ui
        end

        ui.currentAnim = mod.arrayListAnim

        local anim
        if isEnabled then
            anim = mod.arrayListAnim
        elseif isExiting then
            anim = ui.exitAnim
        else
            ui.container.Visible = false
            ui.container.Size = UDim2.new(0, 0, 0, 0)
            continue
        end

        if anim < 0.01 then
            ui.container.Visible = false
            ui.container.Size = UDim2.new(0, 0, 0, 0)
            continue
        end

        renderIndex = renderIndex + 1

        local displayText = mod.name
        if mod.settingDisplay ~= "" then
            displayText = displayText .. " " .. mod.settingDisplay
        end

        local color = ColorUtils.getThemedColor(renderIndex * 100)

        local displayColor = color
        if isExiting then
            displayColor = color:Lerp(Color3.fromRGB(100, 100, 100), 1 - anim)
        end

        local targetHeight = math.max(0, (al.mFontSize + 8) * anim)
        ui.container.Size = UDim2.new(0, 0, 0, targetHeight)
        ui.container.AutomaticSize = anim > 0.01 and Enum.AutomaticSize.X or Enum.AutomaticSize.None
        ui.container.BackgroundTransparency = 1 - (0.7 * anim)
        ui.container.Visible = true
        ui.container.LayoutOrder = mod.lastEnabledTime or 0

        ui.label.Text = displayText
        ui.label.TextSize = al.mFontSize
        ui.label.TextColor3 = displayColor

        if al.mTextShadow then
            ui.label.TextStrokeTransparency = math.clamp(0.5 - (al.mShadowOffset * 0.15), 0, 1)
            ui.label.TextStrokeColor3 = Color3.new(0, 0, 0)
        else
            ui.label.TextStrokeTransparency = 1
        end

        ui.bar.BackgroundColor3 = displayColor

        local displayMode = al.mDisplay
        if displayMode == Arraylist.Display.None then
            ui.bar.Visible = false
            ui.outline.Transparency = 1
            ui.glow.Transparency = 1
            ui.glow.Enabled = false
        elseif displayMode == Arraylist.Display.Bar then
            ui.bar.Visible = true
            ui.outline.Transparency = 1
            ui.glow.Transparency = 1
        elseif displayMode == Arraylist.Display.Outline then
            ui.bar.Visible = false
            ui.outline.Transparency = 1 - (0.6 * anim)
            ui.outline.Color = displayColor
            local glowAlpha = al.mGlow and (0.5 * anim * (al.mGlowDensity / 5)) or 0
            ui.glow.Transparency = 1 - glowAlpha
            ui.glow.Color = displayColor
            ui.glow.Thickness = al.mGlowStrength
        elseif displayMode == Arraylist.Display.Split then
            ui.bar.Visible = true
            ui.outline.Transparency = 1 - (0.4 * anim)
            ui.outline.Color = displayColor
            local glowAlpha = al.mGlow and (0.4 * anim * (al.mGlowDensity / 5)) or 0
            ui.glow.Transparency = 1 - glowAlpha
            ui.glow.Color = displayColor
            ui.glow.Thickness = al.mGlowStrength
        end
    end
end
-- ==================== LIBRARY ====================
local SolsticeUI = {}
SolsticeUI.__index = SolsticeUI

local PALETTE = {
    PanelBg = Color3.fromRGB(18, 18, 22),
    PanelBgTransparency = 0.04,
    PanelBorder = Color3.fromRGB(42, 42, 50),

    HeaderBg = Color3.fromRGB(28, 28, 34),
    HeaderText = Color3.fromRGB(195, 195, 200),
    HeaderIcon = Color3.fromRGB(125, 125, 135),

    ItemBg = Color3.fromRGB(26, 26, 32),
    ItemBgTransparency = 0.2,
    ItemText = Color3.fromRGB(210, 210, 215),
    ItemHoverBg = Color3.fromRGB(38, 38, 46),

    ActiveBg = Color3.fromRGB(255, 165, 200),
    ActiveText = Color3.fromRGB(15, 15, 20),
    ActiveGradientStart = Color3.fromRGB(255, 165, 200),
    ActiveGradientEnd = Color3.fromRGB(215, 155, 245),

    PressBg = Color3.fromRGB(255, 130, 175),
    PressGlow = Color3.fromRGB(255, 100, 160),

    SettingBg = Color3.fromRGB(14, 14, 18),
    SettingBgTransparency = 0.08,
    SettingText = Color3.fromRGB(175, 175, 185),
    SettingValue = Color3.fromRGB(230, 230, 235),
    SettingHover = Color3.fromRGB(22, 22, 28),

    SliderTrack = Color3.fromRGB(48, 48, 56),
    SliderFill = Color3.fromRGB(195, 195, 205),
    SliderThumb = Color3.fromRGB(255, 255, 255),
    SliderThumbGlow = Color3.fromRGB(255, 190, 220),

    ToggleOff = Color3.fromRGB(48, 48, 56),
    ToggleOn = Color3.fromRGB(255, 155, 195),
    ToggleKnob = Color3.fromRGB(255, 255, 255),

    SearchBg = Color3.fromRGB(24, 24, 30),
    SearchPlaceholder = Color3.fromRGB(90, 90, 100),

    ArrayListBg = Color3.fromRGB(16, 16, 20),
    ArrayListBgTransparency = 0.12,

    Muted = Color3.fromRGB(110, 110, 120),
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(15, 15, 18),
    NotifBorder = Color3.fromRGB(255, 165, 200),
}

-- ==================== ANIMATION PRESETS ====================
local ANIM = {
    Quick = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Standard = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    BounceIn = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    BounceOut = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
    Expand = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    SpringExpand = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Hover = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Slide = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    NotifyIn = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    NotifyOut = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    PanelLoad = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

local DEFAULT_CONFIG = {
    PanelWidth = 140,
    PanelHeaderHeight = 20,
    ItemHeight = 17,
    SettingHeight = 30,
    SliderHeight = 40,

    CornerRadius = UDim.new(0, 3),
    PanelCornerRadius = UDim.new(0, 4),

    Font = Enum.Font.SourceSansSemibold,
    FontItalic = Enum.Font.SourceSansItalic,
    TextSize = 12,
    HeaderTextSize = 12,

    PanelSpacing = 155,
    StartX = 20,
    StartY = 45,

    ArrayListFont = Enum.Font.SourceSansBold,
    ArrayListTextSize = 14,
    ArrayListItemHeight = 16,
    ArrayListRainbowSpeed = 0.35,
    ArrayListAnimSpeed = 0.3,

    UseCustomFont = true,
    CustomFontName = "SFDisplay",

    Parent = nil,
    ShowSearchBar = true,
    ShowArrayList = true,
    ShowNotifications = true,
    ShowWatermark = true,

    SaveConfig = true,
    ConfigPath = "SolsticeUI/config.json",

    LoadAnimDelay = 0.06,
    LoadAnimDuration = 0.4,
    ClickScale = 0.96,
    ClickScaleDuration = 0.06,
    ClickRestoreDuration = 0.12,
}

-- ==================== UTILITIES ====================
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
    self.NextPanelX = self.Config.StartX
    self.NextPanelY = self.Config.StartY
    self.PanelLoadQueue = {}

    self.arraylist = Arraylist.new()
    self.arraylist:initModules()    self:_InitWatermark()
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
        panel.Position.Y.Offset + 25
    )

    local delay = index * self.Config.LoadAnimDelay
    task.delay(delay, function()
        Tween(panel, ANIM.PanelLoad, {
            BackgroundTransparency = PALETTE.PanelBgTransparency,
            Position = UDim2.new(
                panel.Position.X.Scale,
                panel.Position.X.Offset,
                panel.Position.Y.Scale,
                panel.Position.Y.Offset - 25
            )
        }):Play()
    end)
end

-- ==================== WATERMARK ====================
function SolsticeUI:_InitWatermark()
    if not self.Config.ShowWatermark then return end

    local wm = Instance.new("Frame")
    wm.Name = "Watermark"
    wm.Size = UDim2.new(0, 200, 0, 60)
    wm.Position = UDim2.new(0, 12, 0, 8)
    wm.BackgroundTransparency = 1
    wm.Parent = self.HudGui

    local moixel = Instance.new("TextLabel")
    moixel.Size = UDim2.new(1, 0, 0, 22)
    moixel.BackgroundTransparency = 1
    moixel.Text = "Moixel"
    moixel.TextColor3 = Color3.fromRGB(200, 200, 205)
    moixel.Font = Enum.Font.SourceSansBold
    moixel.TextSize = 20
    moixel.TextXAlignment = Enum.TextXAlignment.Left
    moixel.Parent = wm
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, moixel) end

    local bilibili = Instance.new("TextLabel")
    bilibili.Size = UDim2.new(1, 0, 0, 18)
    bilibili.Position = UDim2.new(0, 0, 0, 20)
    bilibili.BackgroundTransparency = 1
    bilibili.Text = "bilibili"
    bilibili.TextColor3 = Color3.fromRGB(180, 180, 185)
    bilibili.Font = Enum.Font.SourceSansItalic
    bilibili.TextSize = 16
    bilibili.TextXAlignment = Enum.TextXAlignment.Left
    bilibili.Parent = wm
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, bilibili) end

    local solstice = Instance.new("TextLabel")
    solstice.Size = UDim2.new(1, 0, 0, 18)
    solstice.Position = UDim2.new(0, 0, 0, 38)
    solstice.BackgroundTransparency = 1
    solstice.Text = "Solstice"
    solstice.TextColor3 = Color3.fromRGB(160, 160, 170)
    solstice.Font = Enum.Font.SourceSansItalic
    solstice.TextSize = 16
    solstice.TextXAlignment = Enum.TextXAlignment.Left
    solstice.Parent = wm
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, solstice) end
end

-- ==================== SEARCH BAR ====================
function SolsticeUI:_InitSearchBar()
    if not self.Config.ShowSearchBar then return end

    local frame = Instance.new("Frame")
    frame.Name = "SearchBar"
    frame.Size = UDim2.new(0, 200, 0, 24)
    frame.Position = UDim2.new(0.5, -100, 0, 8)
    frame.BackgroundColor3 = PALETTE.SearchBg
    frame.BackgroundTransparency = 0.06
    frame.BorderSizePixel = 0
    frame.Parent = self.ClickGui
    Corner(frame, UDim.new(0, 4))

    local stroke = Instance.new("UIStroke")
    stroke.Color = PALETTE.PanelBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.45
    stroke.Parent = frame

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 24, 1, 0)
    icon.Position = UDim2.new(0, 6, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "🔍"
    icon.TextColor3 = PALETTE.Muted
    icon.Font = self.Config.Font
    icon.TextSize = 10
    icon.Parent = frame

    local box = Instance.new("TextBox")
    box.Name = "SearchBox"
    box.Size = UDim2.new(1, -34, 1, 0)
    box.Position = UDim2.new(0, 28, 0, 0)
    box.BackgroundTransparency = 1
    box.Text = ""
    box.PlaceholderText = "Search modules..."
    box.PlaceholderColor3 = PALETTE.SearchPlaceholder
    box.TextColor3 = PALETTE.ItemText
    box.Font = self.Config.Font
    box.TextSize = 12
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false
    box.Parent = frame
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, box) end

    self.SearchBox = box
    box:GetPropertyChangedSignal("Text"):Connect(function()
        self:_FilterModules(box.Text)
    end)
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
                        child.Visible = query == "" or string.find(string.lower(btn.Text), query, 1, true) ~= nil
                    end
                end
            end
        end
    end
end

-- ==================== ARRAY LIST ====================
function SolsticeUI:_InitArrayList()
    if not self.Config.ShowArrayList then return end

    self.ArrayListMaster = Instance.new("Frame")
    self.ArrayListMaster.Name = "ArrayListMaster"
    self.ArrayListMaster.AnchorPoint = Vector2.new(1, 0)
    self.ArrayListMaster.Position = UDim2.new(1, -8, 0, 6)
    self.ArrayListMaster.BackgroundTransparency = 1
    self.ArrayListMaster.Parent = self.HudGui

    self.ArrayListContent = Instance.new("Frame")
    self.ArrayListContent.Size = UDim2.new(1, 0, 1, 0)
    self.ArrayListContent.BackgroundTransparency = 1
    self.ArrayListContent.Parent = self.ArrayListMaster

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Padding = UDim.new(0, 2)
    layout.Parent = self.ArrayListContent
end

function SolsticeUI:_UpdateArrayList()
    if not self.ARRAYLIST_ENABLED then
        self.ArrayListMaster.Visible = false
        return
    end

    updateArraylist(self.arraylist, self.ArrayListContent)
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
    self.arraylist:setModuleState(name, tostring(value or ""), state)
    self:_UpdateArrayList()
end
-- ==================== NOTIFICATIONS ====================
function SolsticeUI:_InitNotifications()
    if not self.Config.ShowNotifications then return end
    self.NotifContainer = Instance.new("Frame")
    self.NotifContainer.Size = UDim2.new(0, 280, 0.5, 0)
    self.NotifContainer.Position = UDim2.new(1, -12, 0.92, 0)
    self.NotifContainer.AnchorPoint = Vector2.new(1, 1)
    self.NotifContainer.BackgroundTransparency = 1
    self.NotifContainer.Parent = self.HudGui

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Padding = UDim.new(0, 5)
    layout.Parent = self.NotifContainer
end

function SolsticeUI:Notify(text, dur)
    if not self.Config.ShowNotifications then return end
    dur = dur or 2.2
    local tw = math.min(GetTextWidth(text, self.Config.Font, 12) + 28, 280)

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, tw, 0, 28)
    holder.BackgroundTransparency = 1
    holder.Parent = self.NotifContainer

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 1, 0)
    card.Position = UDim2.new(0, tw + 40, 0, 0)
    card.BackgroundColor3 = PALETTE.PanelBg
    card.BackgroundTransparency = 0.03
    card.BorderSizePixel = 0
    card.Parent = holder
    Corner(card, UDim.new(0, 3))

    local stroke = Instance.new("UIStroke")
    stroke.Color = PALETTE.NotifBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.55
    stroke.Parent = card

    local gradLine = Instance.new("Frame")
    gradLine.Size = UDim2.new(1, 0, 0, 2)
    gradLine.BackgroundColor3 = PALETTE.ActiveGradientStart
    gradLine.BorderSizePixel = 0
    gradLine.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 1, -2)
    lbl.Position = UDim2.new(0, 5, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = PALETTE.ItemText
    lbl.Font = self.Config.Font
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Parent = card
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, lbl) end

    Tween(card, ANIM.NotifyIn, {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    task.delay(dur, function()
        if card and card.Parent then
            local fadeOut = Tween(card, ANIM.NotifyOut, {
                Position = UDim2.new(0, tw + 40, 0, 0),
                BackgroundTransparency = 1
            })
            fadeOut:Play()
            Tween(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            Tween(lbl, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            fadeOut.Completed:Connect(function()
                holder:Destroy()
            end)
        end
    end)
end

-- ==================== RENDER LOOP ====================
function SolsticeUI:_StartRenderLoop()
    local lastTime = tick()

    RunService.RenderStepped:Connect(function(dt)
        local currentTime = tick()
        local deltaTime = currentTime - lastTime
        lastTime = currentTime

        if deltaTime <= 0 or deltaTime > 1 then
            deltaTime = 1 / 60
        end

        if self.ARRAYLIST_ENABLED then
            for _, mod in ipairs(self.arraylist.mModules) do
                mod.arrayListAnim = MathUtils.lerp(mod.arrayListAnim, mod.enabled and 1.0 or 0.0, deltaTime * 14.0)
                mod.arrayListAnim = MathUtils.clamp(mod.arrayListAnim, 0.0, 1.0)
            end

            for _, ui in pairs(moduleUIs) do
                if ui.isExiting then
                    ui.exitAnim = MathUtils.lerp(ui.exitAnim, 0.0, deltaTime * 14.0)
                    ui.exitAnim = MathUtils.clamp(ui.exitAnim, 0.0, 1.0)
                end
            end

            self:_UpdateArrayList()
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
    panel.BackgroundTransparency = PALETTE.PanelBgTransparency
    panel.BorderSizePixel = 0
    panel.Parent = self.ClickGui
    Corner(panel, self.Config.PanelCornerRadius)

    local stroke = Instance.new("UIStroke")
    stroke.Color = PALETTE.PanelBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = panel

    panelData.Instance = panel

    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, self.Config.PanelHeaderHeight)
    header.BackgroundColor3 = PALETTE.HeaderBg
    header.BackgroundTransparency = 0.12
    header.BorderSizePixel = 0
    header.Text = ""
    header.AutoButtonColor = false
    header.Parent = panel
    Corner(header, UDim.new(0, 3))

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 18, 1, 0)
    iconLbl.Position = UDim2.new(0, 6, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = iconChar or "•"
    iconLbl.TextColor3 = PALETTE.HeaderIcon
    iconLbl.Font = self.Config.FontItalic
    iconLbl.TextSize = 10
    iconLbl.TextXAlignment = Enum.TextXAlignment.Center
    iconLbl.Parent = header
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, iconLbl) end

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -24, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = PALETTE.HeaderText
    title.Font = self.Config.Font
    title.TextSize = self.Config.HeaderTextSize
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, title) end

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -self.Config.PanelHeaderHeight)
    content.Position = UDim2.new(0, 0, 0, self.Config.PanelHeaderHeight)
    content.BackgroundTransparency = 1
    content.Parent = panel
    content.ClipsDescendants = true

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 0)
    list.Parent = content

    function panelData:UpdateHeight()
        local target = self.Collapsed and ui.Config.PanelHeaderHeight or self.CurrentExpandedHeight
        Tween(panel, ANIM.Expand, {
            Size = UDim2.new(0, ui.Config.PanelWidth, 0, target)
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
    btn.Parent = modContainer
    Corner(btn, UDim.new(0, 2))
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, btn) end

    local activeGrad = Instance.new("UIGradient")
    activeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, PALETTE.ActiveGradientStart),
        ColorSequenceKeypoint.new(1, PALETTE.ActiveGradientEnd)
    })
    activeGrad.Rotation = 0
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
    Corner(glowFrame, UDim.new(0, 2))

    local hasSettings = feat.settings and #feat.settings > 0
    local indicator = nil
    if hasSettings then
        indicator = Instance.new("TextButton")
        indicator.Name = "Indicator"
        indicator.Size = UDim2.new(0, 16, 1, 0)
        indicator.Position = UDim2.new(1, -20, 0, 0)
        indicator.BackgroundTransparency = 1
        indicator.Text = "+"
        indicator.TextColor3 = PALETTE.Muted
        indicator.Font = ui.Config.Font
        indicator.TextSize = 11
        indicator.AutoButtonColor = false
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
            ui:_SetModuleState(feat.name, true, ui.SavedConfig.modules[feat.name].value)
            if feat.callback then pcall(feat.callback, true) end
        end
    end

    btn.MouseEnter:Connect(function()
        if not enabled then
            Tween(btn, ANIM.Hover, {
                BackgroundColor3 = PALETTE.ItemHoverBg,
                BackgroundTransparency = 0.15
            }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not enabled then
            Tween(btn, ANIM.Hover, {
                BackgroundColor3 = PALETTE.ItemBg,
                BackgroundTransparency = PALETTE.ItemBgTransparency
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

            Tween(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight + 1)
            }):Play()
            task.delay(0.1, function()
                if enabled then
                    Tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight)
                    }):Play()
                end
            end)
        else
            Tween(btn, ANIM.Standard, {
                BackgroundColor3 = PALETTE.ItemBg,
                BackgroundTransparency = PALETTE.ItemBgTransparency,
                TextColor3 = PALETTE.ItemText
            }):Play()
            task.delay(0.15, function()
                if not enabled then activeGrad.Enabled = false end
            end)
        end
        if feat.callback then pcall(feat.callback, enabled) end
    end

    local function toggleSettings()
        if not settingsContainer then return end
        settingsExpanded = not settingsExpanded
        local targetH = settingsExpanded and (ui.Config.ItemHeight + setHeight) or ui.Config.ItemHeight

        Tween(modContainer, ANIM.SpringExpand, {
            Size = UDim2.new(1, 0, 0, targetH)
        }):Play()

        if settingsExpanded then
            settingsContainer.BackgroundTransparency = 1
            Tween(settingsContainer, TweenInfo.new(0.2), {
                BackgroundTransparency = PALETTE.SettingBgTransparency
            }):Play()
            for _, child in ipairs(settingsContainer:GetChildren()) do
                if child:IsA("Frame") then
                    child.BackgroundTransparency = 1
                    Tween(child, TweenInfo.new(0.15), {
                        BackgroundTransparency = PALETTE.SettingBgTransparency
                    }):Play()
                end
            end
        end

        panelData.CurrentExpandedHeight = panelData.CurrentExpandedHeight + (settingsExpanded and setHeight or -setHeight)
        panelData:UpdateHeight()
        if indicator then
            local targetRotation = settingsExpanded and 45 or 0
            Tween(indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
                BackgroundTransparency = 0.4
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
                    BackgroundTransparency = 0.5
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
    container.Parent = modContainer

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 1)
    list.Parent = container

    for _, s in ipairs(settings) do
        local height = ui.Config.SettingHeight
        if s.type == "slider" then height = ui.Config.SliderHeight
        elseif s.type == "color" then height = 24
        elseif s.type == "dropdown" then height = 24
        end

        setHeight = setHeight + height + 1

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, height)
        frame.BackgroundColor3 = PALETTE.SettingBg
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.Parent = container

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

-- ==================== TOGGLE SETTING ====================
function SolsticeUI:_CreateToggleSetting(frame, s, moduleName)
    local ui = self
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -50, 1, 0)
    nameLbl.Position = UDim2.new(0, 8, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = s.name
    nameLbl.TextColor3 = s.default and PALETTE.SettingValue or PALETTE.SettingText
    nameLbl.Font = ui.Config.Font
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, nameLbl) end

    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 28, 0, 14)
    switchBg.Position = UDim2.new(1, -36, 0.5, -7)
    switchBg.BackgroundColor3 = s.default and PALETTE.ToggleOn or PALETTE.ToggleOff
    switchBg.BorderSizePixel = 0
    switchBg.Parent = frame
    Corner(switchBg, UDim.new(0.5, 0))

    local switchKnob = Instance.new("Frame")
    switchKnob.Size = UDim2.new(0, 12, 0, 12)
    switchKnob.Position = s.default and UDim2.new(1, -13, 0.5, -6) or UDim2.new(0, 1, 0.5, -6)
    switchKnob.BackgroundColor3 = PALETTE.ToggleKnob
    switchKnob.BorderSizePixel = 0
    switchKnob.Parent = switchBg
    Corner(switchKnob, UDim.new(0.5, 0))

    local knobShadow = Instance.new("Frame")
    knobShadow.Size = UDim2.new(1, 4, 1, 4)
    knobShadow.Position = UDim2.new(0, -2, 0, -2)
    knobShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    knobShadow.BackgroundTransparency = 0.7
    knobShadow.BorderSizePixel = 0
    knobShadow.ZIndex = -1
    knobShadow.Parent = switchKnob
    Corner(knobShadow, UDim.new(0.5, 0))

    local val = s.default
    btn.MouseButton1Click:Connect(function()
        val = not val
        nameLbl.TextColor3 = val and PALETTE.SettingValue or PALETTE.SettingText

        Tween(switchBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = val and PALETTE.ToggleOn or PALETTE.ToggleOff
        }):Play()

        Tween(switchKnob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = val and UDim2.new(1, -13, 0.5, -6) or UDim2.new(0, 1, 0.5, -6)
        }):Play()

        Tween(switchKnob, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 14, 0, 14)
        }):Play()
        task.delay(0.1, function()
            Tween(switchKnob, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 12, 0, 12)
            }):Play()
        end)

        if s.callback then pcall(s.callback, val) end
    end)
end

-- ==================== SLIDER SETTING ====================
function SolsticeUI:_CreateSliderSetting(frame, s, moduleName)
    local ui = self

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0.5, 0, 0, 14)
    nameLbl.Position = UDim2.new(0, 8, 0, 2)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = s.name
    nameLbl.TextColor3 = PALETTE.SettingText
    nameLbl.Font = ui.Config.Font
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, nameLbl) end

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.4, 0, 0, 14)
    valLbl.Position = UDim2.new(0.55, 0, 0, 2)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = string.format("%.2f", s.default)
    valLbl.TextColor3 = PALETTE.SettingValue
    valLbl.Font = ui.Config.Font
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, valLbl) end

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -16, 0, 4)
    barBg.Position = UDim2.new(0, 8, 0, 22)
    barBg.BackgroundColor3 = PALETTE.SliderTrack
    barBg.BorderSizePixel = 0
    barBg.Parent = frame
    Corner(barBg, UDim.new(0.5, 0))

    local pct = (s.default - s.min) / (s.max - s.min)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = PALETTE.SliderFill
    fill.BorderSizePixel = 0
    fill.Parent = barBg
    Corner(fill, UDim.new(0.5, 0))

    local hitArea = Instance.new("TextButton")
    hitArea.Size = UDim2.new(1, 0, 1, 16)
    hitArea.Position = UDim2.new(0, 0, 0, -8)
    hitArea.BackgroundTransparency = 1
    hitArea.Text = ""
    hitArea.Parent = barBg
    hitArea.ZIndex = 10

    local thumbSize = 12
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, thumbSize, 0, thumbSize)
    thumb.Position = UDim2.new(pct, -thumbSize/2, 0.5, -thumbSize/2)
    thumb.BackgroundColor3 = PALETTE.SliderThumb
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 5
    thumb.Parent = barBg
    Corner(thumb, UDim.new(0.5, 0))

    local glowRing = Instance.new("Frame")
    glowRing.Size = UDim2.new(1, 8, 1, 8)
    glowRing.Position = UDim2.new(0, -4, 0, -4)
    glowRing.BackgroundColor3 = PALETTE.SliderThumbGlow
    glowRing.BackgroundTransparency = 0.75
    glowRing.BorderSizePixel = 0
    glowRing.ZIndex = 4
    glowRing.Parent = thumb
    Corner(glowRing, UDim.new(0.5, 0))

    local highlight = Instance.new("Frame")
    highlight.Size = UDim2.new(0.5, 0, 0.5, 0)
    highlight.Position = UDim2.new(0.25, 0, 0.15, 0)
    highlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    highlight.BackgroundTransparency = 0.3
    highlight.BorderSizePixel = 0
    highlight.ZIndex = 6
    highlight.Parent = thumb
    Corner(highlight, UDim.new(0.5, 0))

    local dragging = false
    local dragTouch = nil

    local function updateSlider(inputPos)
        local relX = inputPos.X - barBg.AbsolutePosition.X
        local sliderX = math.clamp(relX, 0, barBg.AbsoluteSize.X)
        local newPct = sliderX / math.max(barBg.AbsoluteSize.X, 1)

        Tween(fill, TweenInfo.new(0.05), {
            Size = UDim2.new(newPct, 0, 1, 0)
        }):Play()

        Tween(thumb, TweenInfo.new(0.05), {
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
                BackgroundTransparency = 0.35,
                Size = UDim2.new(1, 14, 1, 14),
                Position = UDim2.new(0, -7, 0, -7)
            }):Play()

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
            Tween(thumb, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, thumbSize, 0, thumbSize)
            }):Play()
            Tween(glowRing, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.75,
                Size = UDim2.new(1, 8, 1, 8),
                Position = UDim2.new(0, -4, 0, -4)
            }):Play()
        end
    end)

    frame.MouseEnter:Connect(function()
        Tween(barBg, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(58, 58, 68)}):Play()
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
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 0
    btn.Text = s.name
    btn.TextColor3 = PALETTE.SettingValue
    btn.Font = ui.Config.Font
    btn.TextSize = 11
    btn.Parent = frame
    Corner(btn, UDim.new(0, 2))
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, btn) end

    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 0, 1, 0)
    glow.BackgroundColor3 = PALETTE.PressGlow
    glow.BackgroundTransparency = 1
    glow.BorderSizePixel = 0
    glow.ZIndex = 0
    glow.Parent = btn
    Corner(glow, UDim.new(0, 2))

    btn.MouseEnter:Connect(function()
        Tween(btn, ANIM.Hover, {BackgroundTransparency = 0.1}):Play()
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, ANIM.Hover, {BackgroundTransparency = 0.3}):Play()
        Tween(btn, TweenInfo.new(0.1), {
            Size = UDim2.new(1, 0, 1, 0)
        }):Play()
        Tween(glow, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
    end)

    btn.MouseButton1Down:Connect(function()
        Tween(btn, TweenInfo.new(0.06), {
            Size = UDim2.new(0.97, 0, 0.92, 0),
            BackgroundTransparency = 0.02
        }):Play()
        Tween(glow, TweenInfo.new(0.06), {BackgroundTransparency = 0.35}):Play()
    end)

    btn.MouseButton1Up:Connect(function()
        Tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 0.1
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
    btn.Parent = frame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0.5, 0, 1, 0)
    nameLbl.Position = UDim2.new(0, 8, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = s.name
    nameLbl.TextColor3 = PALETTE.SettingText
    nameLbl.Font = ui.Config.Font
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, nameLbl) end

    local keyBg = Instance.new("Frame")
    keyBg.Size = UDim2.new(0, 50, 0, 18)
    keyBg.Position = UDim2.new(1, -58, 0.5, -9)
    keyBg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    keyBg.BackgroundTransparency = 0.2
    keyBg.BorderSizePixel = 0
    keyBg.Parent = frame
    Corner(keyBg, UDim.new(0, 3))

    local keyLbl = Instance.new("TextLabel")
    keyLbl.Size = UDim2.new(1, 0, 1, 0)
    keyLbl.BackgroundTransparency = 1
    keyLbl.Text = s.default and s.default.Name or "None"
    keyLbl.TextColor3 = PALETTE.SettingValue
    keyLbl.Font = ui.Config.Font
    keyLbl.TextSize = 11
    keyLbl.TextXAlignment = Enum.TextXAlignment.Center
    keyLbl.Parent = keyBg
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, keyLbl) end

    local listening = false
    local listenConn = nil

    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyLbl.Text = "..."
        keyLbl.TextColor3 = Color3.fromRGB(255, 200, 100)

        local pulseTween = Tween(keyBg, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 75)
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
                Tween(keyBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
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
    nameLbl.Position = UDim2.new(0, 8, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = s.name
    nameLbl.TextColor3 = PALETTE.SettingText
    nameLbl.Font = ui.Config.Font
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
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

    local boxSize = 11
    local spacing = 2
    local startX = ui.Config.PanelWidth - (#colors * (boxSize + spacing)) - 6

    for i, color in ipairs(colors) do
        local box = Instance.new("TextButton")
        box.Size = UDim2.new(0, boxSize, 0, boxSize)
        box.Position = UDim2.new(0, startX + (i-1) * (boxSize + spacing), 0.5, -boxSize/2)
        box.BackgroundColor3 = color
        box.BorderSizePixel = 0
        box.Text = ""
        box.Parent = frame
        Corner(box, UDim.new(0, 2))

        box.MouseEnter:Connect(function()
            Tween(box, TweenInfo.new(0.1), {
                Size = UDim2.new(0, boxSize+2, 0, boxSize+2),
                Position = UDim2.new(0, startX + (i-1) * (boxSize + spacing) - 1, 0.5, -boxSize/2 - 1)
            }):Play()
        end)
        box.MouseLeave:Connect(function()
            Tween(box, TweenInfo.new(0.1), {
                Size = UDim2.new(0, boxSize, 0, boxSize),
                Position = UDim2.new(0, startX + (i-1) * (boxSize + spacing), 0.5, -boxSize/2)
            }):Play()
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
    btn.Parent = frame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0.4, 0, 1, 0)
    nameLbl.Position = UDim2.new(0, 8, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = s.name
    nameLbl.TextColor3 = PALETTE.SettingText
    nameLbl.Font = ui.Config.Font
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, nameLbl) end

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.5, 0, 1, 0)
    valLbl.Position = UDim2.new(0.45, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = s.default or "Select..."
    valLbl.TextColor3 = PALETTE.SettingValue
    valLbl.Font = ui.Config.Font
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, valLbl) end

    btn.MouseButton1Click:Connect(function()
        if s.options then
            local current = valLbl.Text
            local idx = 1
            for i, opt in ipairs(s.options) do
                if opt == current then idx = i; break end
            end
            idx = idx % #s.options + 1
            valLbl.Text = s.options[idx]
            if s.callback then pcall(s.callback, s.options[idx]) end
        end
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
    self.arraylist = nil
    for k in pairs(moduleUIs) do moduleUIs[k] = nil end
end

return SolsticeUI
