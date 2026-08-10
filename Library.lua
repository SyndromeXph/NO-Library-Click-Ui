-- ============================================================
-- SolsticeUI v7.0 - Full Overhaul (Inspired by Vape V4)
-- Complete feature parity + original polish
-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

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

    TooltipBg = Color3.fromRGB(26, 25, 26),
    TooltipText = Color3.fromRGB(200, 200, 200),

    WindowBg = Color3.fromRGB(25, 26, 25),
    WindowHeader = Color3.fromRGB(20, 20, 20),
    WindowChildren = Color3.fromRGB(26, 25, 26),
    Divider = Color3.fromRGB(37, 37, 37),
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
    Fade = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Pulse = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true),
}

local DEFAULT_CONFIG = {
    PanelWidth = 220,
    PanelHeaderHeight = 41,
    ItemHeight = 40,
    SettingHeight = 30,
    SliderHeight = 50,
    TwoSliderHeight = 50,

    CornerRadius = UDim.new(0, 4),
    PanelCornerRadius = UDim.new(0, 4),

    Font = Enum.Font.SourceSans,
    FontBold = Enum.Font.SourceSansBold,
    FontItalic = Enum.Font.SourceSansItalic,
    TextSize = 17,
    HeaderTextSize = 17,
    SettingTextSize = 16,

    PanelSpacing = 235,
    StartX = 6,
    StartY = 6,

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
    ShowTooltips = true,
    ShowBlur = true,

    SaveConfig = true,
    ConfigPath = "SolsticeUI/config.json",
    ProfilesPath = "SolsticeUI/profiles/",

    LoadAnimDelay = 0.06,
    LoadAnimDuration = 0.4,
    ClickScale = 0.96,
    ClickScaleDuration = 0.06,
    ClickRestoreDuration = 0.12,

    GUIScale = 1,
    GUIKeybind = "RightShift",
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

local function randomString()
    local length = math.random(10, 100)
    local arr = {}
    for i = 1, length do
        arr[i] = string.char(math.random(32, 126))
    end
    return table.concat(arr)
end

-- ==================== DRAGGING (Vape Style) ====================
local function MakeDraggable(frame, handle, rescale)
    handle = handle or frame
    rescale = rescale or 1
    local drag, dragStart, startPos, dragTouch

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = (input.Position - Vector3.new(handle.AbsolutePosition.X, handle.AbsolutePosition.Y, 0))
            if delta.Y <= 30 * rescale then
                drag = true
                dragTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil
                dragStart = input.Position
                startPos = frame.Position
            end
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
        local pos = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + (delta.X * (1 / rescale)),
            startPos.Y.Scale, 
            startPos.Y.Offset + (delta.Y * (1 / rescale))
        )
        Tween(frame, TweenInfo.new(0.2), {Position = pos}):Play()
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

    -- Profiles system (Vape style)
    self.Profiles = {["default"] = {["Keybind"] = "", ["Selected"] = true}}
    self.CurrentProfile = "default"
    self.KeybindCaptured = false
    self.PressedKeybindKey = ""

    -- Saved config
    self.SavedConfig = {}
    if self.Config.SaveConfig then
        if isfile(self.Config.ConfigPath) then
            local success, decoded = pcall(function()
                return HttpService:JSONDecode(readfile(self.Config.ConfigPath))
            end)
            if success then 
                self.SavedConfig = decoded 
                if decoded.Profiles then
                    self.Profiles = decoded.Profiles
                end
                if decoded.CurrentProfile then
                    self.CurrentProfile = decoded.CurrentProfile
                end
                if decoded.GUIKeybind then
                    self.Config.GUIKeybind = decoded.GUIKeybind
                end
            end
        end
        if not isfolder("SolsticeUI") then makefolder("SolsticeUI") end
        if not isfolder(self.Config.ProfilesPath) then makefolder(self.Config.ProfilesPath) end
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
    self.ClickGui.Name = randomString()
    self.ClickGui.ResetOnSpawn = false
    self.ClickGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ClickGui.DisplayOrder = 999
    self.ClickGui.Parent = TargetParent
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(self.ClickGui)
        end
    end)

    self.HudGui = Instance.new("ScreenGui")
    self.HudGui.Name = randomString()
    self.HudGui.ResetOnSpawn = false
    self.HudGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.HudGui.Parent = TargetParent

    -- UIScale support (Vape style)
    self.MainRescale = Instance.new("UIScale")
    self.MainRescale.Scale = self.Config.GUIScale
    self.MainRescale.Parent = self.ClickGui

    -- Blur effect (Vape style)
    self.MainBlur = Instance.new("BlurEffect")
    self.MainBlur.Size = 25
    self.MainBlur.Parent = Lighting
    self.MainBlur.Enabled = false

    self.GUI_ENABLED = true
    self.ARRAYLIST_ENABLED = self.Config.ShowArrayList
    self.TOOLTIPS_ENABLED = self.Config.ShowTooltips
    self.EnabledModules = {}
    self.AllModules = {}
    self.Panels = {}
    self.Windows = {}
    self.CustomWindows = {}
    self.ArrayListItems = {}
    self.RainbowOffset = 0
    self.RainbowValue = 0
    self.NextPanelX = self.Config.StartX
    self.NextPanelY = self.Config.StartY
    self.PanelLoadQueue = {}
    self.CapturedSlider = nil
    self.HoldingControl = false

    self:_InitWatermark()
    self:_InitSearchBar()
    self:_InitArrayList()
    self:_InitNotifications()
    self:_InitTooltip()
    self:_StartRenderLoop()
    self:_BindToggleKey()
    self:_BindInputHandlers()
    self:_StartConfigSaver()

    return self
end

-- ==================== CONFIG SAVER ====================
function SolsticeUI:_StartConfigSaver()
    if not self.Config.SaveConfig then return end

    task.spawn(function()
        repeat
            task.wait(5)
            if self.Config.SaveConfig then
                local data = {
                    modules = self.SavedConfig.modules or {},
                    Profiles = self.Profiles,
                    CurrentProfile = self.CurrentProfile,
                    GUIKeybind = self.Config.GUIKeybind,
                    Windows = {},
                    CustomWindows = {},
                }
                -- Save window positions
                for name, win in pairs(self.Windows) do
                    data.Windows[name] = {
                        Position = {win.Object.Position.X.Scale, win.Object.Position.X.Offset, 
                                   win.Object.Position.Y.Scale, win.Object.Position.Y.Offset},
                        Visible = win.Object.Visible,
                        Expanded = win.ChildrenObject.Visible,
                    }
                end
                for name, win in pairs(self.CustomWindows) do
                    data.CustomWindows[name] = {
                        Position = {win.Object.Position.X.Scale, win.Object.Position.X.Offset,
                                   win.Object.Position.Y.Scale, win.Object.Position.Y.Offset},
                        Visible = win.Object.Visible,
                        Pinned = win.Api.Pinned,
                    }
                end

                local success, encoded = pcall(function()
                    return HttpService:JSONEncode(data)
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

-- ==================== PROFILES ====================
function SolsticeUI:SwitchProfile(profilename)
    self.Profiles[self.CurrentProfile]["Selected"] = false
    self.Profiles[profilename]["Selected"] = true
    self.CurrentProfile = profilename
    self:_SaveConfig()
    self:Notify("Switched to profile: " .. profilename, 2)
end

function SolsticeUI:_SaveConfig()
    if not self.Config.SaveConfig then return end
    local data = {
        modules = self.SavedConfig.modules or {},
        Profiles = self.Profiles,
        CurrentProfile = self.CurrentProfile,
        GUIKeybind = self.Config.GUIKeybind,
    }
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if success then
        pcall(function() writefile(self.Config.ConfigPath, encoded) end)
    end
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

function SolsticeUI:LoadedAnimation()
    local welcometext = Instance.new("TextLabel")
    welcometext.Name = "WelcomeText"
    welcometext.Size = UDim2.new(0, 300, 0, 25)
    welcometext.TextXAlignment = Enum.TextXAlignment.Left
    welcometext.Position = UDim2.new(0, 2, 0.05, 1)
    welcometext.BackgroundTransparency = 1
    welcometext.TextSize = 25
    welcometext.Text = "Press " .. self.Config.GUIKeybind .. " to open GUI"
    welcometext.TextColor3 = Color3.fromRGB(27, 42, 53)
    welcometext.Font = self.Config.Font
    welcometext.Parent = self.ClickGui

    local welcometext2 = welcometext:Clone()
    welcometext2.Position = UDim2.new(0, -1, 0, -1)
    welcometext2.TextColor3 = PALETTE.ActiveGradientStart
    welcometext2:GetPropertyChangedSignal("TextTransparency"):Connect(function()
        welcometext.TextTransparency = welcometext2.TextTransparency
    end)
    welcometext2.Parent = welcometext

    self:Notify("Finished Loading", "Press " .. string.upper(self.Config.GUIKeybind) .. " to open GUI", 4)

    task.delay(2.5, function()
        Tween(welcometext2, TweenInfo.new(2), {TextTransparency = 1}):Play()
        task.wait(2)
        if welcometext then welcometext:Destroy() end
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
    for _, winData in pairs(self.Windows) do
        local children = winData.ChildrenObject
        if children then
            for _, child in ipairs(children:GetChildren()) do
                if child:IsA("TextButton") then
                    local btnText = child:FindFirstChild("ButtonText")
                    if btnText then
                        child.Visible = query == "" or string.find(string.lower(btnText.Text), query, 1, true) ~= nil
                    end
                end
            end
        end
    end
end

-- ==================== TOOLTIP ====================
function SolsticeUI:_InitTooltip()
    if not self.Config.ShowTooltips then return end

    self.TooltipBox = Instance.new("TextLabel")
    self.TooltipBox.BackgroundColor3 = PALETTE.TooltipBg
    self.TooltipBox.Active = false
    self.TooltipBox.Text = "Placeholder"
    self.TooltipBox.ZIndex = 100
    self.TooltipBox.TextColor3 = PALETTE.TooltipText
    self.TooltipBox.Font = self.Config.Font
    self.TooltipBox.TextSize = 16
    self.TooltipBox.Visible = false
    self.TooltipBox.Parent = self.ClickGui
    Corner(self.TooltipBox, UDim.new(0, 4))
end

function SolsticeUI:ShowTooltip(text, x, y)
    if not self.TOOLTIPS_ENABLED or not self.TooltipBox then return end
    local textsize = TextService:GetTextSize(text, 16, self.TooltipBox.Font, Vector2.new(99999, 99999))
    self.TooltipBox.Text = text
    self.TooltipBox.Size = UDim2.new(0, 13 + textsize.X, 0, textsize.Y + 5)
    self.TooltipBox.Position = UDim2.new(0, x + 16, 0, y - (self.TooltipBox.Size.Y.Offset / 2) - 26)
    self.TooltipBox.Visible = true
end

function SolsticeUI:HideTooltip()
    if self.TooltipBox then
        self.TooltipBox.Visible = false
    end
end

-- ==================== ARRAY LIST ====================
function SolsticeUI:_InitArrayList()
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
    layout.Padding = UDim.new(0, 1)
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
            if bg and txt then
                local tw = GetTextWidth(txt.Text, self.Config.ArrayListFont, self.Config.ArrayListTextSize) + 10
                Tween(bg, TweenInfo.new(self.Config.ArrayListAnimSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Position = UDim2.new(0, tw + 50, 0, 0),
                    BackgroundTransparency = 1
                }):Play()
                Tween(txt, TweenInfo.new(self.Config.ArrayListAnimSpeed * 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(0, tw + 30, 0, 0),
                    TextTransparency = 1
                }):Play()
            end
            task.delay(self.Config.ArrayListAnimSpeed + 0.1, function()
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

            local txt = Instance.new("TextLabel")
            txt.Name = "TextLabel"
            txt.Size = UDim2.new(0, 0, 1, 0)
            txt.Position = UDim2.new(0, 0, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Font = self.Config.ArrayListFont
            txt.TextSize = self.Config.ArrayListTextSize
            txt.TextXAlignment = Enum.TextXAlignment.Right
            txt.TextTransparency = 1
            txt.ZIndex = 2
            txt.Parent = itemFrame
            if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, txt) end

            self.ArrayListItems[data.name] = itemFrame
        end

        itemFrame.Visible = true
        itemFrame.LayoutOrder = i

        local txt = itemFrame:FindFirstChild("TextLabel")
        local bgBar = itemFrame:FindFirstChild("BgBar")

        if txt then
            txt.Text = data.display
        end

        local tw = GetTextWidth(data.display, self.Config.ArrayListFont, self.Config.ArrayListTextSize) + 10
        if tw > maxW then maxW = tw end

        itemFrame.Size = UDim2.new(0, tw, 0, self.Config.ArrayListItemHeight)

        if txt then
            txt.Size = UDim2.new(0, tw, 1, 0)
        end
        if bgBar then
            bgBar.Size = UDim2.new(0, tw, 1, 0)
        end

        if isNew then
            if bgBar then
                bgBar.Position = UDim2.new(0, tw + 50, 0, 0)
                Tween(bgBar, TweenInfo.new(self.Config.ArrayListAnimSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = PALETTE.ArrayListBgTransparency
                }):Play()
            end
            if txt then
                txt.Position = UDim2.new(0, tw + 30, 0, 0)
                Tween(txt, TweenInfo.new(self.Config.ArrayListAnimSpeed * 0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, 0, 0),
                    TextTransparency = 0
                }):Play()
            end
        else
            if bgBar then
                bgBar.Position = UDim2.new(0, 0, 0, 0)
                bgBar.BackgroundTransparency = PALETTE.ArrayListBgTransparency
            end
            if txt then
                txt.Position = UDim2.new(0, 0, 0, 0)
                txt.TextTransparency = 0
            end
        end
    end

    self.ArrayListMaster.Size = UDim2.new(0, maxW, 0, #enabled * (self.Config.ArrayListItemHeight + 1))
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

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        for i, v in ipairs(self.NotifContainer:GetChildren()) do
            if v:IsA("Frame") then
                v.LayoutOrder = i
            end
        end
    end)
end

function SolsticeUI:Notify(topText, bottomText, duration, customIcon)
    if not self.Config.ShowNotifications then return end
    duration = duration or 2.2

    local offset = #self.NotifContainer:GetChildren()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 266, 0, 75)
    frame.Position = UDim2.new(1, -262, 1, -(150 + 80 * offset))
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = self.NotifContainer
    frame.LayoutOrder = offset
    Corner(frame, UDim.new(0, 4))

    local frame2 = Instance.new("Frame")
    frame2.BackgroundColor3 = PALETTE.ActiveGradientStart
    frame2.Size = UDim2.new(1, 0, 0, 4)
    frame2.Position = UDim2.new(0, 0, 1, -4)
    frame2.BorderSizePixel = 0
    frame2.Parent = frame

    local frame3 = frame2:Clone()
    frame3.Size = UDim2.new(1, 0, 0, 2)
    frame3.Position = UDim2.new(0, 0, 0, 0)
    frame3.Parent = frame2
    Corner(frame2, UDim.new(0, 4))

    local icon = Instance.new("ImageLabel")
    icon.Name = "IconLabel"
    icon.Image = customIcon or ""
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(0, -6, 0, -8)
    icon.Size = UDim2.new(0, 60, 0, 60)
    icon.Parent = frame

    local textlabel1 = Instance.new("TextLabel")
    textlabel1.Font = Enum.Font.SourceSansBold
    textlabel1.TextSize = 18
    textlabel1.TextColor3 = Color3.new(1, 1, 1)
    textlabel1.BackgroundTransparency = 1
    textlabel1.Position = UDim2.new(0, 46, 0, 12)
    textlabel1.TextXAlignment = Enum.TextXAlignment.Left
    textlabel1.TextYAlignment = Enum.TextYAlignment.Top
    textlabel1.Text = topText
    textlabel1.Parent = frame

    local textlabel2 = textlabel1:Clone()
    textlabel2.Position = UDim2.new(0, 46, 0, 40)
    textlabel2.Font = Enum.Font.SourceSans
    textlabel2.TextColor3 = Color3.new(0.5, 0.5, 0.5)
    textlabel2.RichText = true
    textlabel2.Text = bottomText or ""
    textlabel2.Parent = frame

    -- Slide in animation
    frame.Position = UDim2.new(1, 0, 1, frame.Position.Y.Offset)
    Tween(frame, ANIM.NotifyIn, {Position = UDim2.new(1, -262, 1, frame.Position.Y.Offset)}):Play()

    task.spawn(function()
        pcall(function()
            Tween(frame2, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 4)}):Play()
            task.wait(duration)
            Tween(frame, ANIM.NotifyOut, {
                Position = UDim2.new(1, 0, 1, frame.Position.Y.Offset),
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.3)
            frame:Destroy()
        end)
    end)

    return frame
end

-- ==================== RENDER LOOP ====================
function SolsticeUI:_StartRenderLoop()
    RunService.RenderStepped:Connect(function(dt)
        -- Rainbow value for color sliders
        self.RainbowValue = (self.RainbowValue + dt * 0.01) % 1

        -- ArrayList rainbow
        if self.ARRAYLIST_ENABLED then
            self.RainbowOffset = (self.RainbowOffset + dt * self.Config.ArrayListRainbowSpeed) % 1
            for name, itemFrame in pairs(self.ArrayListItems) do
                if itemFrame.Visible then
                    local txt = itemFrame:FindFirstChild("TextLabel")
                    if txt then
                        local hue = (self.RainbowOffset + (itemFrame.LayoutOrder - 1) * 0.055) % 1
                        txt.TextColor3 = HSVtoRGB(hue, 0.78, 1)
                    end
                end
            end
        end
    end)
end

-- ==================== INPUT HANDLERS ====================
function SolsticeUI:_BindToggleKey()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[self.Config.GUIKeybind] and not self.KeybindCaptured then
            self.GUI_ENABLED = not self.GUI_ENABLED
            self.ClickGui.Enabled = self.GUI_ENABLED
            if self.Config.ShowBlur then
                self.MainBlur.Enabled = self.GUI_ENABLED
            end
            -- Update custom windows visibility
            for _, win in pairs(self.CustomWindows) do
                if win.Api and win.Api.CheckVis then
                    win.Api.CheckVis()
                end
            end
        end

        if input.KeyCode == Enum.KeyCode.LeftControl then
            self.HoldingControl = true
        end

        -- Keybind capture
        if self.KeybindCaptured and input.KeyCode ~= Enum.KeyCode.LeftShift then
            local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            self.PressedKeybindKey = (keyName ~= "Unknown" and keyName or "")
        end

        -- Module keybinds
        if not self.KeybindCaptured then
            for name, mod in pairs(self.AllModules) do
                if mod.Keybind and mod.Keybind ~= "" and input.KeyCode == Enum.KeyCode[mod.Keybind] then
                    if mod.Toggle then
                        mod.Toggle()
                        self:Notify("Module Toggled", name .. ' <font color="#FFFFFF">has been</font> <font color="' .. 
                            (mod.Enabled() and '#32CD32' or '#E60000') .. '">' .. (mod.Enabled() and "Enabled" or "Disabled") .. '</font><font color="#FFFFFF">!</font>', 1)
                    end
                end
            end
            -- Profile keybinds
            for profname, profile in pairs(self.Profiles) do
                if profile.Keybind and profile.Keybind ~= "" and input.KeyCode == Enum.KeyCode[profile.Keybind] and profname ~= self.CurrentProfile then
                    self:SwitchProfile(profname)
                end
            end
        end

        -- Ctrl + arrow keys for slider微调
        if self.HoldingControl and self.CapturedSlider then
            if input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.Right then
                local delta = input.KeyCode == Enum.KeyCode.Left and -1 or 1
                if self.CapturedSlider.Type == "Slider" then
                    self.CapturedSlider.Api.SetValue(self.CapturedSlider.Api.Value + delta)
                elseif self.CapturedSlider.Type == "ColorSlider" then
                    self.CapturedSlider.Api.SetValue(self.CapturedSlider.Api.Value + (delta * 0.01))
                elseif self.CapturedSlider.Type == "TwoSlider" then
                    self.CapturedSlider.Api.SetValue(self.CapturedSlider.Api.Value + delta)
                end
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftControl then
            self.HoldingControl = false
        end
    end)
end

function SolsticeUI:_BindInputHandlers()
    -- Additional input handling if needed
end

-- ==================== CREATE WINDOW (Vape Style) ====================
function SolsticeUI:CreateWindow(name, icon, position, visible)
    local windowapi = {}
    local currentexpandedbutton = nil

    local windowtitle = Instance.new("TextButton")
    windowtitle.Text = ""
    windowtitle.AutoButtonColor = false
    windowtitle.BackgroundColor3 = PALETTE.WindowBg
    windowtitle.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.PanelHeaderHeight)
    windowtitle.Position = position or UDim2.new(0, self.NextPanelX, 0, self.NextPanelY)
    windowtitle.Name = name .. "Window"
    windowtitle.Visible = visible ~= false
    windowtitle.Parent = self.ClickGui
    Corner(windowtitle)

    local windowicon = Instance.new("ImageLabel")
    windowicon.Size = UDim2.new(0, 16, 0, 16)
    windowicon.Image = icon or ""
    windowicon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    windowicon.Name = "WindowIcon"
    windowicon.BackgroundTransparency = 1
    windowicon.Position = UDim2.new(0, 10, 0, 13)
    windowicon.Parent = windowtitle

    local windowtext = Instance.new("TextLabel")
    windowtext.Size = UDim2.new(0, 155, 0, self.Config.PanelHeaderHeight)
    windowtext.BackgroundTransparency = 1
    windowtext.Name = "WindowTitle"
    windowtext.Position = UDim2.new(0, 36, 0, 0)
    windowtext.TextXAlignment = Enum.TextXAlignment.Left
    windowtext.Font = self.Config.Font
    windowtext.TextSize = self.Config.HeaderTextSize
    windowtext.Text = name
    windowtext.TextColor3 = PALETTE.HeaderText
    windowtext.Parent = windowtitle
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, windowtext) end

    local expandbutton = Instance.new("ImageButton")
    expandbutton.Active = true
    expandbutton.Size = UDim2.new(0, 9, 0, 4)
    expandbutton.Image = ""
    expandbutton.Position = UDim2.new(1, -20, 0, 19)
    expandbutton.Name = "ExpandButton"
    expandbutton.BackgroundTransparency = 1
    expandbutton.Rotation = 180
    expandbutton.Parent = windowtitle
    local arrowText = Instance.new("TextLabel")
    arrowText.Size = UDim2.new(1, 0, 1, 0)
    arrowText.BackgroundTransparency = 1
    arrowText.Text = "▲"
    arrowText.TextColor3 = PALETTE.Muted
    arrowText.TextSize = 8
    arrowText.Parent = expandbutton

    local children = Instance.new("Frame")
    children.BackgroundTransparency = 1
    children.Size = UDim2.new(1, 0, 1, -4)
    children.Position = UDim2.new(0, 0, 0, self.Config.PanelHeaderHeight)
    children.Visible = false
    children.Parent = windowtitle

    local children2 = Instance.new("Frame")
    children2.BackgroundTransparency = 1
    children2.Size = UDim2.new(1, 0, 1, -4)
    children2.Position = UDim2.new(0, 0, 0, self.Config.PanelHeaderHeight)
    children2.Visible = false
    children2.Name = "SettingsChildren"
    children2.Parent = windowtitle

    local uilistlayout = Instance.new("UIListLayout")
    uilistlayout.SortOrder = Enum.SortOrder.LayoutOrder
    uilistlayout.Parent = children

    local uilistlayout2 = Instance.new("UIListLayout")
    uilistlayout2.SortOrder = Enum.SortOrder.LayoutOrder
    uilistlayout2.Parent = children2

    uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if children.Visible then
            windowtitle.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.PanelHeaderHeight + uilistlayout.AbsoluteContentSize.Y * (1 / self.MainRescale.Scale))
        end
    end)

    uilistlayout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if children2.Visible then
            windowtitle.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.PanelHeaderHeight + uilistlayout2.AbsoluteContentSize.Y * (1 / self.MainRescale.Scale))
        end
    end)

    local noexpand = false
    MakeDraggable(windowtitle, windowtitle, self.MainRescale.Scale)

    self.Windows[name] = {
        Object = windowtitle,
        ChildrenObject = children,
        Api = windowapi,
        Type = "Window"
    }

    windowapi.SetVisible = function(value)
        windowtitle.Visible = value
    end

    windowapi.ExpandToggle = function()
        if noexpand == false then
            children.Visible = not children.Visible
            if children.Visible then
                expandbutton.Rotation = 0
                windowtitle.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.PanelHeaderHeight + uilistlayout.AbsoluteContentSize.Y * (1 / self.MainRescale.Scale))
            else
                expandbutton.Rotation = 180
                windowtitle.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.PanelHeaderHeight)
            end
        end
    end

    windowtitle.MouseButton2Click:Connect(windowapi.ExpandToggle)
    expandbutton.MouseButton1Click:Connect(windowapi.ExpandToggle)
    expandbutton.MouseButton2Click:Connect(windowapi.ExpandToggle)

    -- ==================== CREATE OPTIONS BUTTON ====================
    windowapi.CreateOptionsButton = function(naame, temporaryfunction, temporaryfunction2, expandedmenu, temporaryfunction3, hovertext)
        local buttonapi = {}
        local amount = #children:GetChildren()

        local button = Instance.new("TextButton")
        button.Name = naame .. "Button"
        button.AutoButtonColor = false
        button.Size = UDim2.new(1, 0, 0, self.Config.ItemHeight)
        button.BorderSizePixel = 0
        button.BackgroundColor3 = PALETTE.WindowChildren
        button.Text = ""
        button.LayoutOrder = amount
        button.Parent = children

        local buttonactiveborder = Instance.new("Frame")
        buttonactiveborder.BackgroundTransparency = 0.75
        buttonactiveborder.BackgroundColor3 = Color3.new(0, 0, 0)
        buttonactiveborder.BorderSizePixel = 0
        buttonactiveborder.Size = UDim2.new(1, 0, 0, 1)
        buttonactiveborder.Position = UDim2.new(0, 0, 1, -1)
        buttonactiveborder.Visible = false
        buttonactiveborder.Parent = button

        local button2 = Instance.new("ImageButton")
        button2.BackgroundTransparency = 1
        button2.Size = UDim2.new(0, 3, 0, 16)
        button2.Position = UDim2.new(1, -21, 0, 12)
        button2.Name = "OptionsButton"
        button2.Image = ""
        button2.Parent = button
        local arrowBtn = Instance.new("TextLabel")
        arrowBtn.Size = UDim2.new(1, 0, 1, 0)
        arrowBtn.BackgroundTransparency = 1
        arrowBtn.Text = "›"
        arrowBtn.TextColor3 = PALETTE.Muted
        arrowBtn.TextSize = 18
        arrowBtn.Parent = button2

        local buttontext = Instance.new("TextLabel")
        buttontext.BackgroundTransparency = 1
        buttontext.Name = "ButtonText"
        buttontext.Text = naame
        buttontext.Size = UDim2.new(0, 120, 0, self.Config.ItemHeight - 2)
        buttontext.Active = false
        buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
        buttontext.TextSize = self.Config.TextSize
        buttontext.Font = self.Config.Font
        buttontext.TextXAlignment = Enum.TextXAlignment.Left
        buttontext.Position = UDim2.new(0, 10, 0, 0)
        buttontext.Parent = button
        if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, buttontext) end

        local children2_local = Instance.new("Frame")
        children2_local.Size = UDim2.new(1, 0, 0, 0)
        children2_local.BackgroundTransparency = 1
        children2_local.LayoutOrder = amount
        children2_local.Visible = false
        children2_local.Name = naame .. "Children"
        children2_local.Parent = children

        local uilistlayout_local = Instance.new("UIListLayout")
        uilistlayout_local.SortOrder = Enum.SortOrder.LayoutOrder
        uilistlayout_local.Parent = children2_local
        uilistlayout_local:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            children2_local.Size = UDim2.new(0, self.Config.PanelWidth, 0, uilistlayout_local.AbsoluteContentSize.Y * (1 / self.MainRescale.Scale))
        end)

        -- Keybind
        local bindbkg = Instance.new("TextButton")
        bindbkg.Text = ""
        bindbkg.AutoButtonColor = false
        bindbkg.Size = UDim2.new(0, 20, 0, 21)
        bindbkg.Position = UDim2.new(1, -56, 0, 9)
        bindbkg.BorderSizePixel = 0
        bindbkg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bindbkg.BackgroundTransparency = 0.8
        bindbkg.Visible = false
        bindbkg.Parent = button
        Corner(bindbkg, UDim.new(0, 4))

        local bindimg = Instance.new("ImageLabel")
        bindimg.Image = ""
        bindimg.BackgroundTransparency = 1
        bindimg.ImageTransparency = 0.2
        bindimg.Size = UDim2.new(0, 12, 0, 12)
        bindimg.Position = UDim2.new(0, 4, 0, 5)
        bindimg.Active = false
        bindimg.Parent = bindbkg
        local keyIcon = Instance.new("TextLabel")
        keyIcon.Size = UDim2.new(1, 0, 1, 0)
        keyIcon.BackgroundTransparency = 1
        keyIcon.Text = "⌨"
        keyIcon.TextColor3 = PALETTE.Muted
        keyIcon.TextSize = 10
        keyIcon.Parent = bindimg

        local bindtext = Instance.new("TextLabel")
        bindtext.Active = false
        bindtext.BackgroundTransparency = 1
        bindtext.Text = ""
        bindtext.TextSize = 16
        bindtext.Parent = bindbkg
        bindtext.Font = self.Config.Font
        bindtext.Size = UDim2.new(1, 0, 1, 0)
        bindtext.TextColor3 = Color3.fromRGB(201, 201, 201)
        bindtext.Visible = false

        local bindtext2 = Instance.new("TextLabel")
        bindtext2.Text = "PRESS A KEY TO BIND"
        bindtext2.Size = UDim2.new(0, 150, 0, 40)
        bindtext2.Font = self.Config.Font
        bindtext2.TextSize = 17
        bindtext2.TextColor3 = Color3.fromRGB(201, 201, 201)
        bindtext2.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
        bindtext2.BorderSizePixel = 0
        bindtext2.Visible = false
        bindtext2.Parent = button

        -- Tooltip
        if hovertext and type(hovertext) == "string" then
            button.MouseEnter:Connect(function() 
                local pos = UserInputService:GetMouseLocation()
                self:ShowTooltip(hovertext, pos.X, pos.Y)
            end)
            button.MouseMoved:Connect(function(x, y)
                self:ShowTooltip(hovertext, x, y)
            end)
            button.MouseLeave:Connect(function()
                self:HideTooltip()
            end)
        end

        buttonapi.Enabled = false
        buttonapi.Keybind = ""
        buttonapi.Name = naame
        buttonapi.HasExtraText = type(temporaryfunction3) == "function"
        buttonapi.GetExtraText = buttonapi.HasExtraText and temporaryfunction3 or function() return "" end
        local newsize = UDim2.new(0, 20, 0, 21)

        buttonapi.SetKeybind = function(key)
            if key == "" then
                buttonapi.Keybind = key
                newsize = UDim2.new(0, 20, 0, 21)
                bindbkg.Size = newsize
                bindbkg.Visible = true
                bindbkg.Position = UDim2.new(1, -(36 + newsize.X.Offset), 0, 9)
                bindimg.Visible = true
                bindtext.Visible = false
                bindtext.Text = key
            else
                local textsize = TextService:GetTextSize(key, 16, bindtext.Font, Vector2.new(99999, 99999))
                newsize = UDim2.new(0, 13 + textsize.X, 0, 21)
                buttonapi.Keybind = key
                bindbkg.Visible = true
                bindbkg.Size = newsize
                bindbkg.Position = UDim2.new(1, -(36 + newsize.X.Offset), 0, 9)
                bindimg.Visible = false
                bindtext.Visible = true
                bindtext.Text = key
            end
        end

        buttonapi.ToggleButton = function(clicked)
            buttonapi.Enabled = not buttonapi.Enabled
            if buttonapi.Enabled then
                button.BackgroundColor3 = PALETTE.ActiveBg
                buttonactiveborder.Visible = true
                buttontext.TextColor3 = PALETTE.ActiveText
                temporaryfunction()
            else
                button.BackgroundColor3 = PALETTE.WindowChildren
                buttonactiveborder.Visible = false
                buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
                temporaryfunction2()
            end
            self:_SetModuleState(naame, buttonapi.Enabled)
        end

        buttonapi.ExpandToggle = function()
            if children2_local.Visible then
                for _, v in pairs(children:GetChildren()) do
                    if v:IsA("TextButton") then
                        v.Visible = true
                    end
                end
                children2_local.Visible = false
                noexpand = false
                windowtitle.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.PanelHeaderHeight + uilistlayout.AbsoluteContentSize.Y)
            else
                for _, v in pairs(children:GetChildren()) do
                    if v:IsA("TextButton") then
                        v.Visible = false
                    end
                end
                button.Visible = true
                children2_local.Visible = true
                noexpand = true
                windowtitle.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.PanelHeaderHeight + 45 + uilistlayout_local.AbsoluteContentSize.Y * (1 / self.MainRescale.Scale))
                currentexpandedbutton = buttonapi
            end
        end

        -- Create settings methods
        buttonapi.CreateToggle = function(togglename, tempfunc, tempfunc2, default)
            return self:_CreateWindowToggle(children2_local, togglename, tempfunc, tempfunc2, default)
        end

        buttonapi.CreateSlider = function(slidername, min, max, tempfunc, defaultvalue, percent)
            return self:_CreateWindowSlider(children2_local, slidername, min, max, tempfunc, defaultvalue, percent)
        end

        buttonapi.CreateTwoSlider = function(slidername, min, max, tempfunc, decimal, defaultvalue, defaultvalue2)
            return self:_CreateWindowTwoSlider(children2_local, slidername, min, max, tempfunc, decimal, defaultvalue, defaultvalue2)
        end

        buttonapi.CreateColorSlider = function(slidername, tempfunc)
            return self:_CreateWindowColorSlider(children2_local, slidername, tempfunc)
        end

        buttonapi.CreateDropdown = function(dropname, options, tempfunc)
            return self:_CreateWindowDropdown(children2_local, dropname, options, tempfunc)
        end

        buttonapi.CreateTextList = function(listname, placeholder, tempfunc, tempfunc2)
            return self:_CreateWindowTextList(children2_local, listname, placeholder, tempfunc, tempfunc2)
        end

        button.MouseButton1Click:Connect(function() buttonapi.ToggleButton(true) end)
        button.MouseEnter:Connect(function() 
            bindbkg.Visible = true
            if not buttonapi.Enabled then
                Tween(button, ANIM.Hover, {BackgroundColor3 = Color3.fromRGB(31, 30, 31)}):Play()
            end
        end)
        button.MouseLeave:Connect(function() 
            self:HideTooltip()
            if buttonapi.Keybind == "" then
                bindbkg.Visible = false 
            end
            if not buttonapi.Enabled then
                Tween(button, ANIM.Hover, {BackgroundColor3 = PALETTE.WindowChildren}):Play()
            end
        end)

        bindbkg.MouseButton1Click:Connect(function()
            if not self.KeybindCaptured then
                self.KeybindCaptured = true
                task.spawn(function()
                    bindtext2.Visible = true
                    repeat task.wait() until self.PressedKeybindKey ~= ""
                    local newKey = self.PressedKeybindKey
                    buttonapi.SetKeybind((newKey == buttonapi.Keybind and "" or newKey))
                    self.PressedKeybindKey = ""
                    self.KeybindCaptured = false
                    bindtext2.Visible = false
                end)
            end
        end)

        button.MouseButton2Click:Connect(buttonapi.ExpandToggle)
        button2.MouseButton1Click:Connect(buttonapi.ExpandToggle)

        self.AllModules[naame] = {
            Button = button,
            Enabled = function() return buttonapi.Enabled end,
            Toggle = function() buttonapi.ToggleButton(true) end,
            Keybind = buttonapi.Keybind,
            SetKeybind = buttonapi.SetKeybind,
            Api = buttonapi,
        }

        return buttonapi
    end

    -- ==================== CREATE DIVIDER ====================
    windowapi.CreateDivider = function(text)
        local amount = #children:GetChildren()
        if text then
            local dividerlabel = Instance.new("TextLabel")
            dividerlabel.Size = UDim2.new(1, 0, 0, 30)
            dividerlabel.BackgroundColor3 = PALETTE.WindowHeader
            dividerlabel.BorderSizePixel = 0
            dividerlabel.TextColor3 = Color3.fromRGB(85, 84, 85)
            dividerlabel.TextSize = 14
            dividerlabel.Font = self.Config.Font
            dividerlabel.Text = "    " .. text
            dividerlabel.TextXAlignment = Enum.TextXAlignment.Left
            dividerlabel.LayoutOrder = amount
            dividerlabel.Parent = children
        end
        local divider = Instance.new("Frame")
        divider.Size = UDim2.new(1, 0, 0, 1)
        divider.Name = "Divider"
        divider.LayoutOrder = amount + (text and 1 or 0)
        divider.BackgroundColor3 = PALETTE.Divider
        divider.BorderSizePixel = 0
        divider.Parent = children
    end

    self.NextPanelX = self.NextPanelX + self.Config.PanelSpacing

    return windowapi
end

-- ==================== CREATE CUSTOM WINDOW (HUD Style - Pinnable) ====================
function SolsticeUI:CreateCustomWindow(name, icon, position, visible)
    local windowapi = {}

    local windowtitle = Instance.new("TextButton")
    windowtitle.Text = ""
    windowtitle.AutoButtonColor = false
    windowtitle.BackgroundColor3 = PALETTE.WindowBg
    windowtitle.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.PanelHeaderHeight)
    windowtitle.Position = position or UDim2.new(0, 20, 0, 20)
    windowtitle.Name = name .. "CustomWindow"
    windowtitle.Visible = visible ~= false
    windowtitle.Parent = self.HudGui
    Corner(windowtitle)

    local windowicon = Instance.new("ImageLabel")
    windowicon.Size = UDim2.new(0, 16, 0, 16)
    windowicon.Image = icon or ""
    windowicon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    windowicon.Name = "WindowIcon"
    windowicon.BackgroundTransparency = 1
    windowicon.Position = UDim2.new(0, 10, 0, 13)
    windowicon.Parent = windowtitle

    local windowtext = Instance.new("TextLabel")
    windowtext.Size = UDim2.new(0, 155, 0, self.Config.PanelHeaderHeight)
    windowtext.BackgroundTransparency = 1
    windowtext.Name = "WindowTitle"
    windowtext.Position = UDim2.new(0, 36, 0, 0)
    windowtext.TextXAlignment = Enum.TextXAlignment.Left
    windowtext.Font = self.Config.Font
    windowtext.TextSize = self.Config.HeaderTextSize
    windowtext.Text = name
    windowtext.TextColor3 = PALETTE.HeaderText
    windowtext.Parent = windowtitle
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, windowtext) end

    local expandbutton = Instance.new("ImageButton")
    expandbutton.AutoButtonColor = false
    expandbutton.Size = UDim2.new(0, 16, 0, 16)
    expandbutton.Position = UDim2.new(1, -47, 0, 13)
    expandbutton.BackgroundTransparency = 1
    expandbutton.Name = "PinButton"
    expandbutton.Parent = windowtitle
    local pinText = Instance.new("TextLabel")
    pinText.Size = UDim2.new(1, 0, 1, 0)
    pinText.BackgroundTransparency = 1
    pinText.Text = "📌"
    pinText.TextSize = 12
    pinText.Parent = expandbutton

    local optionsbutton = Instance.new("ImageButton")
    optionsbutton.AutoButtonColor = false
    optionsbutton.Size = UDim2.new(0, 10, 0, 20)
    optionsbutton.Position = UDim2.new(1, -16, 0, 11)
    optionsbutton.Name = "OptionsButton"
    optionsbutton.BackgroundTransparency = 1
    optionsbutton.Parent = windowtitle
    local moreText = Instance.new("TextLabel")
    moreText.Size = UDim2.new(1, 0, 1, 0)
    moreText.BackgroundTransparency = 1
    moreText.Text = "⋮"
    moreText.TextColor3 = PALETTE.Muted
    moreText.TextSize = 14
    moreText.Parent = optionsbutton

    local children = Instance.new("Frame")
    children.BackgroundTransparency = 1
    children.Size = UDim2.new(0, self.Config.PanelWidth, 0, 300)
    children.Position = UDim2.new(0, 0, 1, 0)
    children.Visible = true
    children.Parent = windowtitle

    local children2 = Instance.new("Frame")
    children2.BackgroundTransparency = 1
    children2.Size = UDim2.new(1, 0, 1, -4)
    children2.Position = UDim2.new(0, 0, 0, self.Config.PanelHeaderHeight)
    children2.Visible = false
    children2.Parent = windowtitle

    local uilistlayout = Instance.new("UIListLayout")
    uilistlayout.SortOrder = Enum.SortOrder.LayoutOrder
    uilistlayout.Parent = children2
    uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if children2.Visible then
            windowtitle.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.PanelHeaderHeight + uilistlayout.AbsoluteContentSize.Y)
        end
    end)

    MakeDraggable(windowtitle, windowtitle, self.MainRescale.Scale)

    windowapi.Pinned = false
    windowapi.RealVis = visible ~= false

    windowapi.CheckVis = function()
        if windowapi.RealVis then
            if self.ClickGui.Enabled then
                windowtitle.Visible = true
                windowtext.Visible = true
                windowtitle.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.PanelHeaderHeight)
                windowtitle.BackgroundTransparency = 0
                windowicon.Visible = true
                expandbutton.Visible = true
                optionsbutton.Visible = true
            else
                if windowapi.Pinned then
                    windowtitle.Visible = true
                    windowtext.Visible = false
                    windowtitle.Size = UDim2.new(0, self.Config.PanelWidth, 0, 0)
                    windowtitle.BackgroundTransparency = 1
                    windowicon.Visible = false
                    expandbutton.Visible = false
                    optionsbutton.Visible = false
                    children2.Visible = false
                    children.Visible = true
                else
                    windowtitle.Visible = false
                end
            end
        else
            windowtitle.Visible = false
        end
    end

    windowapi.SetVisible = function(value)
        windowapi.RealVis = value
        windowapi.CheckVis()
    end

    windowapi.ExpandToggle = function()
        if children2.Visible then
            children2.Visible = false
            children.Visible = true
            windowtitle.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.PanelHeaderHeight)
        else
            children2.Visible = true
            children.Visible = false
            windowtitle.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.PanelHeaderHeight + uilistlayout.AbsoluteContentSize.Y)
        end
    end

    windowapi.PinnedToggle = function()
        windowapi.Pinned = not windowapi.Pinned
        if windowapi.Pinned then
            pinText.TextTransparency = 0
        else
            pinText.TextTransparency = 0.5
        end
        windowapi.CheckVis()
    end

    self.ClickGui:GetPropertyChangedSignal("Enabled"):Connect(windowapi.CheckVis)
    windowapi.CheckVis()

    expandbutton.MouseButton1Click:Connect(windowapi.PinnedToggle)
    windowtitle.MouseButton2Click:Connect(windowapi.ExpandToggle)
    optionsbutton.MouseButton1Click:Connect(windowapi.ExpandToggle)

    self.CustomWindows[name] = {
        Object = windowtitle,
        ChildrenObject = children,
        Api = windowapi,
        Type = "CustomWindow"
    }

    -- Settings creation methods
    windowapi.CreateToggle = function(togglename, tempfunc, tempfunc2, default)
        return self:_CreateWindowToggle(children2, togglename, tempfunc, tempfunc2, default)
    end

    windowapi.CreateSlider = function(slidername, min, max, tempfunc, defaultvalue, percent)
        return self:_CreateWindowSlider(children2, slidername, min, max, tempfunc, defaultvalue, percent)
    end

    windowapi.CreateColorSlider = function(slidername, tempfunc)
        return self:_CreateWindowColorSlider(children2, slidername, tempfunc)
    end

    windowapi.GetCustomChildren = function()
        return children
    end

    return windowapi
end

-- ==================== WINDOW SETTING CREATORS ====================
function SolsticeUI:_CreateWindowToggle(parent, name, tempfunc, tempfunc2, default)
    local buttonapi = {}
    local amount = #parent:GetChildren()

    local buttontext = Instance.new("TextLabel")
    buttontext.BackgroundTransparency = 1
    buttontext.Name = "ButtonText"
    buttontext.Text = "   " .. name
    buttontext.Name = name
    buttontext.LayoutOrder = amount
    buttontext.Size = UDim2.new(1, 0, 0, 30)
    buttontext.Active = false
    buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
    buttontext.TextSize = self.Config.SettingTextSize
    buttontext.Font = self.Config.Font
    buttontext.TextXAlignment = Enum.TextXAlignment.Left
    buttontext.Position = UDim2.new(0, 10, 0, 0)
    buttontext.Parent = parent
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, buttontext) end

    local toggleframe1 = Instance.new("TextButton")
    toggleframe1.AutoButtonColor = false
    toggleframe1.Size = UDim2.new(0, 22, 0, 12)
    toggleframe1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleframe1.BorderSizePixel = 0
    toggleframe1.Text = ""
    toggleframe1.Name = "ToggleFrame1"
    toggleframe1.Position = UDim2.new(1, -32, 0, 10)
    toggleframe1.Parent = buttontext
    Corner(toggleframe1, UDim.new(0, 16))

    local toggleframe2 = Instance.new("Frame")
    toggleframe2.Size = UDim2.new(0, 8, 0, 8)
    toggleframe2.Active = false
    toggleframe2.Position = UDim2.new(0, 2, 0, 2)
    toggleframe2.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
    toggleframe2.BorderSizePixel = 0
    toggleframe2.Parent = toggleframe1
    Corner(toggleframe2, UDim.new(0, 16))

    buttonapi.Enabled = false
    buttonapi.Keybind = ""
    buttonapi.Default = default

    buttonapi.ToggleButton = function(toggle, first)
        buttonapi.Enabled = toggle
        if buttonapi.Enabled then
            if not first then
                Tween(toggleframe1, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                    BackgroundColor3 = PALETTE.ActiveBg
                }):Play()
            else
                toggleframe1.BackgroundColor3 = PALETTE.ActiveBg
            end
            Tween(toggleframe2, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0, 12, 0, 2)
            }):Play()
            if tempfunc then tempfunc() end
        else
            if not first then
                Tween(toggleframe1, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                }):Play()
            else
                toggleframe1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
            Tween(toggleframe2, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0, 2, 0, 2)
            }):Play()
            if tempfunc2 then tempfunc2() end
        end
    end

    buttonapi.ToggleButton(default, true)
    toggleframe1.MouseButton1Click:Connect(function() buttonapi.ToggleButton(not buttonapi.Enabled, false) end)
    toggleframe1.MouseEnter:Connect(function()
        if buttonapi.Enabled == false then
            Tween(toggleframe1, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            }):Play()
        end
    end)
    toggleframe1.MouseLeave:Connect(function()
        if buttonapi.Enabled == false then
            Tween(toggleframe1, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            }):Play()
        end
    end)

    return buttonapi
end

function SolsticeUI:_CreateWindowSlider(parent, name, min, max, tempfunc, defaultvalue, percent)
    local sliderapi = {}
    local amount = #parent:GetChildren()

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.SliderHeight)
    frame.BackgroundTransparency = 1
    frame.ClipsDescendants = true
    frame.LayoutOrder = amount
    frame.Name = name
    frame.Parent = parent

    local text1 = Instance.new("TextLabel")
    text1.Font = self.Config.Font
    text1.TextXAlignment = Enum.TextXAlignment.Left
    text1.Text = "   " .. name
    text1.Size = UDim2.new(1, 0, 0, 25)
    text1.TextColor3 = Color3.fromRGB(162, 162, 162)
    text1.BackgroundTransparency = 1
    text1.TextSize = self.Config.SettingTextSize
    text1.Parent = frame

    local text2 = Instance.new("TextLabel")
    text2.Font = self.Config.Font
    text2.TextXAlignment = Enum.TextXAlignment.Right
    text2.Text = tostring((defaultvalue or min)) .. ".0 " .. (percent and "%" or " ") .. " "
    text2.Size = UDim2.new(1, 0, 0, 25)
    text2.TextColor3 = Color3.fromRGB(162, 162, 162)
    text2.BackgroundTransparency = 1
    text2.TextSize = self.Config.SettingTextSize
    text2.Parent = frame

    local slider1 = Instance.new("Frame")
    slider1.Size = UDim2.new(0, self.Config.PanelWidth - 20, 0, 2)
    slider1.BorderSizePixel = 0
    slider1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slider1.Position = UDim2.new(0, 10, 0, 32)
    slider1.Name = "Slider"
    slider1.Parent = frame

    local slider2 = Instance.new("Frame")
    slider2.Size = UDim2.new(math.clamp(((defaultvalue or min) / max), 0.02, 0.97), 0, 1, 0)
    slider2.BackgroundColor3 = PALETTE.ActiveBg
    slider2.Name = "FillSlider"
    slider2.Parent = slider1

    local slider3 = Instance.new("ImageButton")
    slider3.AutoButtonColor = false
    slider3.Size = UDim2.new(0, 24, 0, 16)
    slider3.BackgroundColor3 = Color3.fromRGB(25, 26, 25)
    slider3.BorderSizePixel = 0
    slider3.Position = UDim2.new(1, -11, 0, -7)
    slider3.Parent = slider2
    slider3.Name = "ButtonSlider"

    sliderapi.Value = (defaultvalue or min)
    sliderapi.Max = max

    sliderapi.SetValue = function(val)
        val = math.clamp(val, min, max)
        sliderapi.Value = val
        slider2.Size = UDim2.new(math.clamp((val / max), 0.02, 0.97), 0, 1, 0)
        text2.Text = sliderapi.Value .. ".0 " .. (percent and "%" or " ") .. " "
        if tempfunc then tempfunc(val) end
    end

    local function RelativeXY(GuiObject, location)
        local x = location.X - GuiObject.AbsolutePosition.X
        local y = location.Y - GuiObject.AbsolutePosition.Y
        local xm, ym = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
        x = math.clamp(x, 0, xm)
        y = math.clamp(y, 0, ym)
        return x, y, x/xm, y/ym
    end

    slider3.MouseButton1Down:Connect(function()
        local x, y, xscale, yscale = RelativeXY(slider1, UserInputService:GetMouseLocation())
        sliderapi.SetValue(math.floor(min + ((max - min) * xscale)))
        slider2.Size = UDim2.new(xscale, 0, 1, 0)

        local move
        local kill
        move = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local x, y, xscale, yscale = RelativeXY(slider1, UserInputService:GetMouseLocation())
                sliderapi.SetValue(math.floor(min + ((max - min) * xscale)))
                slider2.Size = UDim2.new(xscale, 0, 1, 0)
            end
        end)
        kill = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.CapturedSlider = {Type = "Slider", Object = frame, Api = sliderapi}
                move:Disconnect()
                kill:Disconnect()
            end
        end)
    end)

    return sliderapi
end

function SolsticeUI:_CreateWindowTwoSlider(parent, name, min, max, tempfunc, decimal, defaultvalue, defaultvalue2)
    local sliderapi = {}
    local amount = #parent:GetChildren()

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.TwoSliderHeight)
    frame.BackgroundTransparency = 1
    frame.ClipsDescendants = true
    frame.LayoutOrder = amount
    frame.Name = name
    frame.Parent = parent

    local text1 = Instance.new("TextLabel")
    text1.Font = self.Config.Font
    text1.TextXAlignment = Enum.TextXAlignment.Left
    text1.Text = "   " .. name
    text1.Size = UDim2.new(1, 0, 0, 25)
    text1.TextColor3 = Color3.fromRGB(162, 162, 162)
    text1.BackgroundTransparency = 1
    text1.TextSize = self.Config.SettingTextSize
    text1.Parent = frame

    local text2 = Instance.new("TextLabel")
    text2.Font = self.Config.Font
    text2.TextXAlignment = Enum.TextXAlignment.Right
    local text2string = tostring((defaultvalue2 or max) / 10)
    text2.Text = (decimal and (string.len(text2string) > 1 and text2string or text2string..".0   ") or (defaultvalue2 or max) .. ".0   ")
    text2.Size = UDim2.new(1, 0, 0, 25)
    text2.TextColor3 = Color3.fromRGB(162, 162, 162)
    text2.BackgroundTransparency = 1
    text2.TextSize = self.Config.SettingTextSize
    text2.Parent = frame

    local text3 = Instance.new("TextLabel")
    text3.Font = self.Config.Font
    text3.TextColor3 = Color3.fromRGB(162, 162, 162)
    text3.BackgroundTransparency = 1
    text3.TextXAlignment = Enum.TextXAlignment.Right
    text3.Size = UDim2.new(1, -77, 0, 25)
    text3.TextSize = self.Config.SettingTextSize
    local text3string = tostring((defaultvalue or min) / 10)
    text3.Text = (decimal and (string.len(text3string) > 1 and text3string or text3string..".0") or (defaultvalue or min) .. ".0")
    text3.Parent = frame

    local text4 = Instance.new("TextLabel")
    text4.Size = UDim2.new(0, 12, 0, 6)
    text4.Text = "↔"
    text4.BackgroundTransparency = 1
    text4.Position = UDim2.new(0, 154, 0, 10)
    text4.TextColor3 = PALETTE.Muted
    text4.Parent = frame

    local slider1 = Instance.new("Frame")
    slider1.Size = UDim2.new(0, self.Config.PanelWidth - 20, 0, 2)
    slider1.BorderSizePixel = 0
    slider1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slider1.Position = UDim2.new(0, 10, 0, 32)
    slider1.Name = "Slider"
    slider1.Parent = frame

    local slider2 = Instance.new("Frame")
    slider2.Size = UDim2.new(1, 0, 1, 0)
    slider2.BackgroundColor3 = PALETTE.ActiveBg
    slider2.Name = "FillSlider"
    slider2.Parent = slider1

    local slider3 = Instance.new("ImageButton")
    slider3.AutoButtonColor = false
    slider3.Size = UDim2.new(0, 16, 0, 16)
    slider3.BackgroundColor3 = Color3.fromRGB(25, 26, 25)
    slider3.BorderSizePixel = 0
    slider3.Position = UDim2.new(1, -8, 1, -9)
    slider3.Parent = slider1
    slider3.Name = "ButtonSlider"

    local slider4 = slider3:Clone()
    slider4.Rotation = 180
    slider4.Position = UDim2.new(1, -8, 1, -9)
    slider4.Name = "ButtonSlider2"
    slider4.Parent = slider1

    slider3:GetPropertyChangedSignal("Position"):Connect(function()
        slider2.Size = UDim2.new(0, slider4.AbsolutePosition.X - slider3.AbsolutePosition.X, 1, 0)
        slider2.Position = UDim2.new(slider3.Position.X.Scale, 0, 0, 0)
    end)
    slider4:GetPropertyChangedSignal("Position"):Connect(function()
        slider2.Size = UDim2.new(0, slider4.AbsolutePosition.X - slider3.AbsolutePosition.X, 1, 0)
        slider2.Position = UDim2.new(slider3.Position.X.Scale, 0, 0, 0)
    end)

    slider3.Position = UDim2.new((defaultvalue and (defaultvalue == min and 0 or defaultvalue/max) or 0), -8, 1, -9)
    slider4.Position = UDim2.new((defaultvalue2 and (defaultvalue2 == max and 1 or defaultvalue2/max) or 1), -8, 1, -9)
    slider2.Size = UDim2.new(0, slider4.AbsolutePosition.X - slider3.AbsolutePosition.X, 1, 0)
    slider2.Position = UDim2.new(slider3.Position.X.Scale, 0, 0, 0)

    sliderapi.Value = (defaultvalue or min)
    sliderapi.Value2 = (defaultvalue2 or max)
    sliderapi.Max = max

    local function RelativeXY(GuiObject, location)
        local x = location.X - GuiObject.AbsolutePosition.X
        local y = location.Y - GuiObject.AbsolutePosition.Y
        local xm, ym = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
        x = math.clamp(x, 0, xm)
        y = math.clamp(y, 0, ym)
        return x, y, x/xm, y/ym
    end

    sliderapi.SetValue = function(val)
        val = math.clamp(val, min, max)
        sliderapi.Value = val
        Tween(slider3, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            Position = UDim2.new((val / max), -8, 1, -9)
        }):Play()
        local stringthing = tostring(sliderapi.Value / 10)
        text3.Text = (decimal and (string.len(stringthing) > 1 and stringthing or stringthing..".0") or sliderapi.Value .. ".0")
        if tempfunc then tempfunc(val) end
    end

    sliderapi.SetValue2 = function(val)
        val = math.clamp(val, min, max)
        sliderapi.Value2 = val
        Tween(slider4, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            Position = UDim2.new((val / max), -8, 1, -9)
        }):Play()
        local stringthing = tostring(sliderapi.Value2 / 10)
        text2.Text = (decimal and (string.len(stringthing) > 1 and stringthing or stringthing..".0").."   " or sliderapi.Value2 .. ".0   ")
        if tempfunc then tempfunc(val) end
    end

    sliderapi.GetRandomValue = function()
        return Random.new():NextNumber(sliderapi.Value, sliderapi.Value2)
    end

    slider3.MouseButton1Down:Connect(function()
        local x, y, xscale, yscale = RelativeXY(slider1, UserInputService:GetMouseLocation())
        sliderapi.SetValue(math.floor(min + ((max - min) * xscale)))

        local move
        local kill
        move = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local x, y, xscale, yscale = RelativeXY(slider1, UserInputService:GetMouseLocation())
                sliderapi.SetValue(math.floor(min + ((max - min) * xscale)))
            end
        end)
        kill = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.CapturedSlider = {Type = "TwoSlider", Object = frame, Api = sliderapi}
                move:Disconnect()
                kill:Disconnect()
            end
        end)
    end)

    slider4.MouseButton1Down:Connect(function()
        local x, y, xscale, yscale = RelativeXY(slider1, UserInputService:GetMouseLocation())
        sliderapi.SetValue2(math.floor(min + ((max - min) * xscale)))

        local move
        local kill
        move = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local x, y, xscale, yscale = RelativeXY(slider1, UserInputService:GetMouseLocation())
                sliderapi.SetValue2(math.floor(min + ((max - min) * xscale)))
            end
        end)
        kill = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                move:Disconnect()
                kill:Disconnect()
            end
        end)
    end)

    return sliderapi
end

function SolsticeUI:_CreateWindowColorSlider(parent, name, tempfunc)
    local min, max = 0, 1
    local sliderapi = {}
    local amount = #parent:GetChildren()

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.SliderHeight)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = amount
    frame.Name = name
    frame.Parent = parent

    local text1 = Instance.new("TextLabel")
    text1.Font = self.Config.Font
    text1.TextXAlignment = Enum.TextXAlignment.Left
    text1.Text = "   " .. name
    text1.Size = UDim2.new(1, 0, 0, 25)
    text1.TextColor3 = Color3.fromRGB(162, 162, 162)
    text1.BackgroundTransparency = 1
    text1.TextSize = self.Config.SettingTextSize
    text1.Parent = frame

    local text2 = Instance.new("Frame")
    text2.Size = UDim2.new(0, 12, 0, 12)
    text2.Position = UDim2.new(1, -22, 0, 9)
    text2.BackgroundColor3 = Color3.fromHSV(0.44, 1, 1)
    text2.Parent = frame
    Corner(text2, UDim.new(0, 4))

    local slider1 = Instance.new("TextButton")
    slider1.AutoButtonColor = false
    slider1.Text = ""
    slider1.Size = UDim2.new(0, self.Config.PanelWidth - 20, 0, 2)
    slider1.BorderSizePixel = 0
    slider1.BackgroundColor3 = Color3.new(1, 1, 1)
    slider1.Position = UDim2.new(0, 10, 0, 32)
    slider1.Name = "Slider"
    slider1.Parent = frame

    local uigradient = Instance.new("UIGradient")
    uigradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
        ColorSequenceKeypoint.new(0.1, Color3.fromHSV(0.1, 1, 1)),
        ColorSequenceKeypoint.new(0.2, Color3.fromHSV(0.2, 1, 1)),
        ColorSequenceKeypoint.new(0.3, Color3.fromHSV(0.3, 1, 1)),
        ColorSequenceKeypoint.new(0.4, Color3.fromHSV(0.4, 1, 1)),
        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
        ColorSequenceKeypoint.new(0.6, Color3.fromHSV(0.6, 1, 1)),
        ColorSequenceKeypoint.new(0.7, Color3.fromHSV(0.7, 1, 1)),
        ColorSequenceKeypoint.new(0.8, Color3.fromHSV(0.8, 1, 1)),
        ColorSequenceKeypoint.new(0.9, Color3.fromHSV(0.9, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
    })
    uigradient.Parent = slider1

    local slider3 = Instance.new("ImageButton")
    slider3.AutoButtonColor = false
    slider3.Size = UDim2.new(0, 24, 0, 16)
    slider3.BackgroundColor3 = Color3.fromRGB(25, 26, 25)
    slider3.BorderSizePixel = 0
    slider3.Position = UDim2.new(0.44, -11, 0, -7)
    slider3.Parent = slider1
    slider3.Name = "ButtonSlider"

    sliderapi.Value = 0.44
    sliderapi.RainbowValue = false

    sliderapi.SetValue = function(val)
        val = math.clamp(val, min, max)
        text2.BackgroundColor3 = Color3.fromHSV(val, 1, 1)
        sliderapi.Value = val
        Tween(slider3, TweenInfo.new(0.05), {
            Position = UDim2.new(math.clamp(val, 0.02, 0.95), -9, 0, -7)
        }):Play()
        if tempfunc then tempfunc(val) end
    end

    sliderapi.SetRainbow = function(val)
        sliderapi.RainbowValue = val
        if sliderapi.RainbowValue then
            task.spawn(function()
                repeat
                    task.wait()
                    if sliderapi.RainbowValue then
                        sliderapi.SetValue(self.RainbowValue)
                    end
                until not sliderapi.RainbowValue
            end)
        end
    end

    local function RelativeXY(GuiObject, location)
        local x = location.X - GuiObject.AbsolutePosition.X
        local y = location.Y - GuiObject.AbsolutePosition.Y
        local xm, ym = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
        x = math.clamp(x, 0, xm)
        y = math.clamp(y, 0, ym)
        return x, y, x/xm, y/ym
    end

    local click = false
    slider1.MouseButton1Down:Connect(function()
        click = true
        task.delay(0.3, function() click = false end)
        if click then
            sliderapi.SetRainbow(not sliderapi.RainbowValue)
        end

        local x, y, xscale, yscale = RelativeXY(slider1, UserInputService:GetMouseLocation())
        sliderapi.SetValue(min + ((max - min) * xscale))

        local move
        local kill
        move = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local x, y, xscale, yscale = RelativeXY(slider1, UserInputService:GetMouseLocation())
                sliderapi.SetValue(min + ((max - min) * xscale))
            end
        end)
        kill = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.CapturedSlider = {Type = "ColorSlider", Object = frame, Api = sliderapi}
                move:Disconnect()
                kill:Disconnect()
            end
        end)
    end)

    return sliderapi
end

function SolsticeUI:_CreateWindowDropdown(parent, name, options, tempfunc)
    local dropapi = {}
    local list = options or {}
    local amount2 = #parent:GetChildren()

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, self.Config.PanelWidth, 0, 40)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = amount2
    frame.Name = name
    frame.Parent = parent

    local drop1 = Instance.new("TextButton")
    drop1.AutoButtonColor = false
    drop1.Size = UDim2.new(0, self.Config.PanelWidth - 20, 0, 30)
    drop1.Position = UDim2.new(0, 10, 0, 10)
    drop1.Parent = frame
    drop1.BorderSizePixel = 0
    drop1.ZIndex = 2
    drop1.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
    drop1.TextSize = self.Config.SettingTextSize
    drop1.TextXAlignment = Enum.TextXAlignment.Left
    drop1.TextColor3 = Color3.fromRGB(162, 162, 162)
    drop1.Text = "  " .. name .. " - " .. (list[1] or "")
    drop1.TextTruncate = Enum.TextTruncate.AtEnd
    drop1.Font = self.Config.Font
    Corner(drop1)

    local thing = Instance.new("Frame")
    thing.Size = UDim2.new(1, 2, 1, 2)
    thing.BorderSizePixel = 0
    thing.Position = UDim2.new(0, -1, 0, -1)
    thing.ZIndex = 1
    thing.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    thing.Parent = drop1
    Corner(thing)

    local dropframe = Instance.new("Frame")
    dropframe.ZIndex = 3
    dropframe.Parent = drop1
    dropframe.Position = UDim2.new(0, 0, 1, 0)
    dropframe.BackgroundTransparency = 1
    dropframe.BorderSizePixel = 0
    dropframe.Visible = false

    drop1.MouseButton1Click:Connect(function()
        dropframe.Visible = not dropframe.Visible
    end)

    dropapi.Value = (list[1] or "")
    dropapi.Default = dropapi.Value

    dropapi.UpdateList = function(val)
        list = val
        for _, child in pairs(dropframe:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local placeholder = 0
        for numbe, listobj in pairs(val) do
            if listobj ~= dropapi.Value then
                local drop2 = Instance.new("TextButton")
                dropframe.Size = UDim2.new(0, self.Config.PanelWidth - 20, 0, placeholder + 20)
                drop2.Text = listobj
                drop2.LayoutOrder = numbe
                drop2.TextColor3 = Color3.new(1, 1, 1)
                drop2.AutoButtonColor = false
                drop2.Size = UDim2.new(0, self.Config.PanelWidth - 20, 0, 20)
                drop2.Position = UDim2.new(0, 2, 0, placeholder - 1)
                drop2.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
                drop2.Font = self.Config.Font
                drop2.TextSize = 14
                drop2.ZIndex = 4
                drop2.BorderSizePixel = 0
                drop2.Name = listobj
                drop2.Parent = dropframe
                drop2.MouseButton1Click:Connect(function()
                    dropapi.Value = listobj
                    drop1.Text = "  " .. name .. " - " .. listobj
                    dropframe.Visible = false
                    if tempfunc then tempfunc(listobj) end
                    dropapi.UpdateList(list)
                end)
                placeholder = placeholder + 20
            end
        end
    end

    dropapi.SetValue = function(listobj)
        dropapi.Value = listobj
        drop1.Text = "  " .. name .. " - " .. listobj
        dropframe.Visible = false
        if tempfunc then tempfunc(listobj) end
        dropapi.UpdateList(list)
    end

    dropapi.UpdateList(list)

    return dropapi
end

function SolsticeUI:_CreateWindowTextList(parent, name, placeholder, tempfunc, tempfunc2)
    local textapi = {}
    local amount = #parent:GetChildren()

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, self.Config.PanelWidth, 0, 40)
    frame.BackgroundTransparency = 1
    frame.ClipsDescendants = true
    frame.LayoutOrder = amount
    frame.Name = name
    frame.Parent = parent

    local textboxbkg = Instance.new("Frame")
    textboxbkg.BackgroundTransparency = 0.3
    textboxbkg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    textboxbkg.Name = "AddBoxBKG"
    textboxbkg.Size = UDim2.new(0, self.Config.PanelWidth - 20, 0, 31)
    textboxbkg.Position = UDim2.new(0, 10, 0, 5)
    textboxbkg.ClipsDescendants = true
    textboxbkg.Parent = frame
    Corner(textboxbkg)

    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(0, self.Config.PanelWidth - 61, 1, 0)
    textbox.Position = UDim2.new(0, 11, 0, 0)
    textbox.TextXAlignment = Enum.TextXAlignment.Left
    textbox.Name = "AddBox"
    textbox.BackgroundTransparency = 1
    textbox.TextColor3 = Color3.new(1, 1, 1)
    textbox.PlaceholderColor3 = Color3.fromRGB(200, 200, 200)
    textbox.Font = self.Config.Font
    textbox.Text = ""
    textbox.PlaceholderText = placeholder or "Add item..."
    textbox.TextSize = self.Config.SettingTextSize
    textbox.Parent = textboxbkg

    local addbutton = Instance.new("TextButton")
    addbutton.BorderSizePixel = 0
    addbutton.Name = "AddButton"
    addbutton.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
    addbutton.Position = UDim2.new(0, self.Config.PanelWidth - 46, 0, 8)
    addbutton.AutoButtonColor = false
    addbutton.Size = UDim2.new(0, 16, 0, 16)
    addbutton.Text = "+"
    addbutton.TextColor3 = PALETTE.ActiveBg
    addbutton.TextSize = 14
    addbutton.Parent = textboxbkg

    local scrollframebkg = Instance.new("Frame")
    scrollframebkg.ZIndex = 2
    scrollframebkg.Name = "ScrollingFrameBKG"
    scrollframebkg.Size = UDim2.new(0, self.Config.PanelWidth, 0, 3)
    scrollframebkg.BackgroundTransparency = 1
    scrollframebkg.LayoutOrder = amount
    scrollframebkg.Parent = parent

    local scrollframe = Instance.new("ScrollingFrame")
    scrollframe.ZIndex = 2
    scrollframe.Size = UDim2.new(0, self.Config.PanelWidth - 20, 0, 3)
    scrollframe.Position = UDim2.new(0, 10, 0, 0)
    scrollframe.BackgroundTransparency = 1
    scrollframe.ScrollBarThickness = 0
    scrollframe.ScrollBarImageColor3 = Color3.new(0, 0, 0)
    scrollframe.LayoutOrder = amount
    scrollframe.Parent = scrollframebkg

    local uilistlayout3 = Instance.new("UIListLayout")
    uilistlayout3.Padding = UDim.new(0, 3)
    uilistlayout3.Parent = scrollframe
    uilistlayout3:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollframe.CanvasSize = UDim2.new(0, 0, 0, uilistlayout3.AbsoluteContentSize.Y)
        scrollframe.Size = UDim2.new(0, self.Config.PanelWidth - 20, 0, math.clamp(uilistlayout3.AbsoluteContentSize.Y, 1, 105))
        scrollframebkg.Size = UDim2.new(0, self.Config.PanelWidth, 0, math.clamp(uilistlayout3.AbsoluteContentSize.Y, 1, 105) + 3)
    end)

    textapi.Object = frame
    textapi.ScrollingObject = scrollframebkg
    textapi.ObjectList = {}

    textapi.RefreshValues = function(tab)
        textapi.ObjectList = tab
        for _, child in pairs(scrollframe:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for i, v in pairs(textapi.ObjectList) do
            local itemframe = Instance.new("TextButton")
            itemframe.Size = UDim2.new(0, self.Config.PanelWidth - 20, 0, 33)
            itemframe.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
            itemframe.BorderSizePixel = 0
            itemframe.Text = ""
            itemframe.AutoButtonColor = false
            itemframe.Parent = scrollframe
            Corner(itemframe)

            local itemtext = Instance.new("TextLabel")
            itemtext.BackgroundTransparency = 1
            itemtext.Size = UDim2.new(0, self.Config.PanelWidth - 27, 0, 33)
            itemtext.Name = "ItemText"
            itemtext.Position = UDim2.new(0, 8, 0, 0)
            itemtext.Font = self.Config.Font
            itemtext.TextSize = self.Config.SettingTextSize
            itemtext.Text = v
            itemtext.TextXAlignment = Enum.TextXAlignment.Left
            itemtext.TextColor3 = Color3.fromRGB(163, 163, 163)
            itemtext.Parent = itemframe

            local deletebutton = Instance.new("TextButton")
            deletebutton.Size = UDim2.new(0, 16, 0, 16)
            deletebutton.BackgroundTransparency = 1
            deletebutton.AutoButtonColor = false
            deletebutton.ZIndex = 2
            deletebutton.Text = "×"
            deletebutton.TextColor3 = Color3.fromRGB(255, 100, 100)
            deletebutton.TextSize = 14
            deletebutton.Position = UDim2.new(1, -20, 0, 8)
            deletebutton.Parent = itemframe
            deletebutton.MouseButton1Click:Connect(function()
                table.remove(textapi.ObjectList, i)
                textapi.RefreshValues(textapi.ObjectList)
                if tempfunc2 then tempfunc2(i) end
            end)
        end
    end

    addbutton.MouseButton1Click:Connect(function() 
        if textbox.Text ~= "" then
            table.insert(textapi.ObjectList, textbox.Text)
            textapi.RefreshValues(textapi.ObjectList)
            if tempfunc then tempfunc(textbox.Text) end
            textbox.Text = ""
        end
    end)

    return textapi
end

-- ==================== ORIGINAL CATEGORY SYSTEM (Preserved) ====================
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

-- ==================== CREATE FEATURE (Original Preserved) ====================
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

-- ==================== CREATE SETTINGS (Original Preserved) ====================
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
        elseif s.type == "twoslider" then height = ui.Config.TwoSliderHeight
        elseif s.type == "textlist" then height = 40
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
        elseif s.type == "twoslider" then
            ui:_CreateTwoSliderSetting(frame, s, moduleName)
        elseif s.type == "textlist" then
            ui:_CreateTextListSetting(frame, s, moduleName)
        end
    end

    setHeight = math.max(0, setHeight - 1)
    container.Size = UDim2.new(1, 0, 0, setHeight)
    return container, setHeight
end
