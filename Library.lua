-- ============================================================
-- SolsticeUI v7.0 - Premium Visual Overhaul
-- Glassmorphism ArrayList, Smooth Spring Animations, Modern Aesthetics
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

-- ==================== MODERN PALETTE ====================
local PALETTE = {
    PanelBg = Color3.fromRGB(12, 12, 16),
    PanelBgTransparency = 0.08,
    PanelBorder = Color3.fromRGB(55, 55, 65),
    GlassBg = Color3.fromRGB(18, 18, 24),
    GlassTransparency = 0.15,
    GlassBorder = Color3.fromRGB(80, 80, 95),
    GlassGlow = Color3.fromRGB(255, 165, 200),
    HeaderBg = Color3.fromRGB(22, 22, 28),
    HeaderText = Color3.fromRGB(210, 210, 215),
    HeaderIcon = Color3.fromRGB(140, 140, 155),
    ItemBg = Color3.fromRGB(24, 24, 30),
    ItemBgTransparency = 0.25,
    ItemText = Color3.fromRGB(220, 220, 225),
    ItemHoverBg = Color3.fromRGB(38, 38, 48),
    ActiveBg = Color3.fromRGB(255, 160, 195),
    ActiveText = Color3.fromRGB(10, 10, 14),
    ActiveGradientStart = Color3.fromRGB(255, 160, 195),
    ActiveGradientEnd = Color3.fromRGB(200, 140, 255),
    ActiveGlow = Color3.fromRGB(255, 140, 190),
    PressBg = Color3.fromRGB(255, 120, 170),
    PressGlow = Color3.fromRGB(255, 90, 150),
    SettingBg = Color3.fromRGB(14, 14, 18),
    SettingBgTransparency = 0.1,
    SettingText = Color3.fromRGB(170, 170, 180),
    SettingValue = Color3.fromRGB(235, 235, 240),
    SettingHover = Color3.fromRGB(24, 24, 30),
    SliderTrack = Color3.fromRGB(45, 45, 55),
    SliderFill = Color3.fromRGB(200, 200, 210),
    SliderThumb = Color3.fromRGB(255, 255, 255),
    SliderThumbGlow = Color3.fromRGB(255, 180, 210),
    ToggleOff = Color3.fromRGB(45, 45, 55),
    ToggleOn = Color3.fromRGB(255, 150, 190),
    ToggleKnob = Color3.fromRGB(255, 255, 255),
    SearchBg = Color3.fromRGB(20, 20, 26),
    SearchPlaceholder = Color3.fromRGB(85, 85, 95),
    ArrayListBg = Color3.fromRGB(14, 14, 20),
    ArrayListBgTransparency = 0.12,
    ArrayListBorder = Color3.fromRGB(60, 60, 75),
    ArrayListGlow = Color3.fromRGB(255, 150, 190),
    Muted = Color3.fromRGB(115, 115, 125),
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(10, 10, 14),
    NotifBorder = Color3.fromRGB(255, 160, 195),
    Shadow = Color3.fromRGB(0, 0, 0),
}

-- ==================== ADVANCED ANIMATION PRESETS ====================
local ANIM = {
    Quick = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Standard = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    BounceIn = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    BounceOut = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In),
    Expand = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    SpringExpand = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Hover = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Slide = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    ArrayIn = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    ArrayOut = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
    ArraySlide = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    ArrayFade = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    NotifyIn = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    NotifyOut = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    PanelLoad = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

local DEFAULT_CONFIG = {
    PanelWidth = 150,
    PanelHeaderHeight = 22,
    ItemHeight = 18,
    SettingHeight = 32,
    SliderHeight = 42,
    CornerRadius = UDim.new(0, 4),
    PanelCornerRadius = UDim.new(0, 6),
    Font = Enum.Font.SourceSansSemibold,
    FontItalic = Enum.Font.SourceSansItalic,
    TextSize = 12,
    HeaderTextSize = 12,
    PanelSpacing = 165,
    StartX = 25,
    StartY = 50,
    ArrayListFont = Enum.Font.SourceSansBold,
    ArrayListTextSize = 14,
    ArrayListItemHeight = 18,
    ArrayListRainbowSpeed = 0.4,
    ArrayListAnimSpeed = 0.35,
    ArrayListCornerRadius = UDim.new(0, 6),
    ArrayListPadding = 10,
    ArrayListItemPadding = 6,
    ArrayListMaxWidth = 280,
    UseCustomFont = true,
    CustomFontName = "SFDisplay",
    Parent = nil,
    ShowSearchBar = true,
    ShowArrayList = true,
    ShowNotifications = true,
    ShowWatermark = true,
    SaveConfig = true,
    ConfigPath = "SolsticeUI/config.json",
    LoadAnimDelay = 0.07,
    LoadAnimDuration = 0.45,
    ClickScale = 0.95,
    ClickScaleDuration = 0.07,
    ClickRestoreDuration = 0.14,
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

local function CreateShadow(parent, offset, blur, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, offset * 2, 1, offset * 2)
    shadow.Position = UDim2.new(0, -offset, 0, -offset)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = PALETTE.Shadow
    shadow.ImageTransparency = transparency or 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
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
        panel.Position.X.Scale, panel.Position.X.Offset,
        panel.Position.Y.Scale, panel.Position.Y.Offset + 30
    )
    local delay = index * self.Config.LoadAnimDelay
    task.delay(delay, function()
        Tween(panel, ANIM.PanelLoad, {
            BackgroundTransparency = PALETTE.PanelBgTransparency,
            Position = UDim2.new(
                panel.Position.X.Scale, panel.Position.X.Offset,
                panel.Position.Y.Scale, panel.Position.Y.Offset - 30
            )
        }):Play()
    end)
end

-- ==================== WATERMARK ====================
function SolsticeUI:_InitWatermark()
    if not self.Config.ShowWatermark then return end
    local wm = Instance.new("Frame")
    wm.Name = "Watermark"
    wm.Size = UDim2.new(0, 200, 0, 65)
    wm.Position = UDim2.new(0, 15, 0, 10)
    wm.BackgroundTransparency = 1
    wm.Parent = self.HudGui
    local moixel = Instance.new("TextLabel")
    moixel.Size = UDim2.new(1, 0, 0, 24)
    moixel.BackgroundTransparency = 1
    moixel.Text = "Moixel"
    moixel.TextColor3 = Color3.fromRGB(205, 205, 210)
    moixel.Font = Enum.Font.SourceSansBold
    moixel.TextSize = 22
    moixel.TextXAlignment = Enum.TextXAlignment.Left
    moixel.Parent = wm
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, moixel) end
    local bilibili = Instance.new("TextLabel")
    bilibili.Size = UDim2.new(1, 0, 0, 18)
    bilibili.Position = UDim2.new(0, 0, 0, 22)
    bilibili.BackgroundTransparency = 1
    bilibili.Text = "bilibili"
    bilibili.TextColor3 = Color3.fromRGB(185, 185, 190)
    bilibili.Font = Enum.Font.SourceSansItalic
    bilibili.TextSize = 16
    bilibili.TextXAlignment = Enum.TextXAlignment.Left
    bilibili.Parent = wm
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, bilibili) end
    local solstice = Instance.new("TextLabel")
    solstice.Size = UDim2.new(1, 0, 0, 18)
    solstice.Position = UDim2.new(0, 0, 0, 40)
    solstice.BackgroundTransparency = 1
    solstice.Text = "Solstice"
    solstice.TextColor3 = Color3.fromRGB(165, 165, 175)
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
    frame.Size = UDim2.new(0, 220, 0, 26)
    frame.Position = UDim2.new(0.5, -110, 0, 10)
    frame.BackgroundColor3 = PALETTE.SearchBg
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.Parent = self.ClickGui
    Corner(frame, UDim.new(0, 6))
    local stroke = Instance.new("UIStroke")
    stroke.Color = PALETTE.PanelBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = frame
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 26, 1, 0)
    icon.Position = UDim2.new(0, 8, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "🔍"
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

-- ==================== PREMIUM ARRAY LIST ====================
function SolsticeUI:_InitArrayList()
    self.ArrayListMaster = Instance.new("Frame")
    self.ArrayListMaster.Name = "ArrayListMaster"
    self.ArrayListMaster.AnchorPoint = Vector2.new(1, 0)
    self.ArrayListMaster.Position = UDim2.new(1, -12, 0, 10)
    self.ArrayListMaster.BackgroundTransparency = 1
    self.ArrayListMaster.Parent = self.HudGui
    self.ArrayListContent = Instance.new("Frame")
    self.ArrayListContent.Size = UDim2.new(1, 0, 1, 0)
    self.ArrayListContent.BackgroundTransparency = 1
    self.ArrayListContent.Parent = self.ArrayListMaster
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.Padding = UDim.new(0, 3)
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
    -- Animate out removed items
    for name, itemFrame in pairs(self.ArrayListItems) do
        if not activeNames[name] and itemFrame.Visible then
            itemFrame.Visible = false
            local container = itemFrame:FindFirstChild("Container")
            local txt = itemFrame:FindFirstChild("TextLabel")
            local bg = itemFrame:FindFirstChild("BgFrame")
            local glow = itemFrame:FindFirstChild("GlowFrame")
            local border = itemFrame:FindFirstChild("BorderFrame")
            local tw = GetTextWidth(txt.Text, self.Config.ArrayListFont, self.Config.ArrayListTextSize) + self.Config.ArrayListPadding * 2
            if container then
                Tween(container, ANIM.ArrayOut, {Position = UDim2.new(0, tw + 60, 0, 0)}):Play()
            end
            if bg then
                Tween(bg, TweenInfo.new(self.Config.ArrayListAnimSpeed * 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            end
            if glow then
                Tween(glow, TweenInfo.new(self.Config.ArrayListAnimSpeed * 0.6), {BackgroundTransparency = 1}):Play()
            end
            if border then
                Tween(border, TweenInfo.new(self.Config.ArrayListAnimSpeed * 0.6), {BackgroundTransparency = 1}):Play()
            end
            if txt then
                Tween(txt, TweenInfo.new(self.Config.ArrayListAnimSpeed * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1, Position = UDim2.new(0, tw + 40, 0, 0)}):Play()
            end
            task.delay(self.Config.ArrayListAnimSpeed + 0.15, function()
                if itemFrame and itemFrame.Parent then itemFrame.Visible = false end
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
            local container = Instance.new("Frame")
            container.Name = "Container"
            container.Size = UDim2.new(1, 0, 1, 0)
            container.BackgroundTransparency = 1
            container.Parent = itemFrame
            local glowFrame = Instance.new("Frame")
            glowFrame.Name = "GlowFrame"
            glowFrame.Size = UDim2.new(1, 8, 1, 8)
            glowFrame.Position = UDim2.new(0, -4, 0, -4)
            glowFrame.BackgroundColor3 = PALETTE.ArrayListGlow
            glowFrame.BackgroundTransparency = 1
            glowFrame.BorderSizePixel = 0
            glowFrame.ZIndex = 1
            glowFrame.Parent = container
            Corner(glowFrame, UDim.new(0, 8))
            local bgFrame = Instance.new("Frame")
            bgFrame.Name = "BgFrame"
            bgFrame.Size = UDim2.new(1, 0, 1, 0)
            bgFrame.BackgroundColor3 = PALETTE.ArrayListBg
            bgFrame.BackgroundTransparency = 1
            bgFrame.BorderSizePixel = 0
            bgFrame.ZIndex = 2
            bgFrame.Parent = container
            Corner(bgFrame, self.Config.ArrayListCornerRadius)
            local borderFrame = Instance.new("Frame")
            borderFrame.Name = "BorderFrame"
            borderFrame.Size = UDim2.new(1, 2, 1, 2)
            borderFrame.Position = UDim2.new(0, -1, 0, -1)
            borderFrame.BackgroundTransparency = 1
            borderFrame.BorderSizePixel = 0
            borderFrame.ZIndex = 1
            borderFrame.Parent = container
            Corner(borderFrame, UDim.new(0, 7))
            local borderStroke = Instance.new("UIStroke")
            borderStroke.Color = PALETTE.ArrayListBorder
            borderStroke.Thickness = 1
            borderStroke.Transparency = 1
            borderStroke.Parent = borderFrame
            local gradOverlay = Instance.new("UIGradient")
            gradOverlay.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 210))
            })
            gradOverlay.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.92),
                NumberSequenceKeypoint.new(0.5, 0.95),
                NumberSequenceKeypoint.new(1, 0.88)
            })
            gradOverlay.Rotation = 90
            gradOverlay.Parent = bgFrame
            local txt = Instance.new("TextLabel")
            txt.Name = "TextLabel"
            txt.Size = UDim2.new(0, 0, 1, 0)
            txt.Position = UDim2.new(0, self.Config.ArrayListItemPadding, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Font = self.Config.ArrayListFont
            txt.TextSize = self.Config.ArrayListTextSize
            txt.TextXAlignment = Enum.TextXAlignment.Right
            txt.TextTransparency = 1
            txt.ZIndex = 3
            txt.Parent = container
            if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, txt) end
            local accentLine = Instance.new("Frame")
            accentLine.Name = "AccentLine"
            accentLine.Size = UDim2.new(0, 2, 0.6, 0)
            accentLine.Position = UDim2.new(0, 0, 0.2, 0)
            accentLine.BackgroundColor3 = PALETTE.ActiveGradientStart
            accentLine.BackgroundTransparency = 1
            accentLine.BorderSizePixel = 0
            accentLine.ZIndex = 3
            accentLine.Parent = container
            Corner(accentLine, UDim.new(0, 1))
            self.ArrayListItems[data.name] = itemFrame
        end
        itemFrame.Visible = true
        itemFrame.LayoutOrder = i
        local container = itemFrame:FindFirstChild("Container")
        local txt = itemFrame:FindFirstChild("TextLabel")
        local bgFrame = itemFrame:FindFirstChild("BgFrame")
        local glowFrame = itemFrame:FindFirstChild("GlowFrame")
        local borderFrame = itemFrame:FindFirstChild("BorderFrame")
        local accentLine = container and container:FindFirstChild("AccentLine")
        if txt then txt.Text = data.display end
        local tw = GetTextWidth(data.display, self.Config.ArrayListFont, self.Config.ArrayListTextSize) + self.Config.ArrayListPadding * 2
        tw = math.min(tw, self.Config.ArrayListMaxWidth)
        if tw > maxW then maxW = tw end
        itemFrame.Size = UDim2.new(0, tw, 0, self.Config.ArrayListItemHeight)
        if txt then txt.Size = UDim2.new(0, tw - self.Config.ArrayListItemPadding * 2, 1, 0) end
        if isNew then
            if container then
                container.Position = UDim2.new(0, tw + 50, 0, 0)
                Tween(container, ANIM.ArrayIn, {Position = UDim2.new(0, 0, 0, 0)}):Play()
            end
            if bgFrame then
                Tween(bgFrame, TweenInfo.new(self.Config.ArrayListAnimSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = PALETTE.ArrayListBgTransparency}):Play()
            end
            if glowFrame then
                Tween(glowFrame, TweenInfo.new(self.Config.ArrayListAnimSpeed * 1.2), {BackgroundTransparency = 0.85}):Play()
            end
            if borderFrame then
                local borderStroke = borderFrame:FindFirstChildOfClass("UIStroke")
                if borderStroke then
                    Tween(borderStroke, TweenInfo.new(self.Config.ArrayListAnimSpeed), {Transparency = 0.5}):Play()
                end
            end
            if txt then
                txt.Position = UDim2.new(0, tw + 30, 0, 0)
                Tween(txt, TweenInfo.new(self.Config.ArrayListAnimSpeed * 0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, self.Config.ArrayListItemPadding, 0, 0), TextTransparency = 0}):Play()
            end
            if accentLine then
                task.delay(0.2, function()
                    Tween(accentLine, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.3}):Play()
                end)
            end
        else
            if container then container.Position = UDim2.new(0, 0, 0, 0) end
            if bgFrame then bgFrame.BackgroundTransparency = PALETTE.ArrayListBgTransparency end
            if glowFrame then glowFrame.BackgroundTransparency = 0.85 end
            if borderFrame then
                local borderStroke = borderFrame:FindFirstChildOfClass("UIStroke")
                if borderStroke then borderStroke.Transparency = 0.5 end
            end
            if txt then
                txt.Position = UDim2.new(0, self.Config.ArrayListItemPadding, 0, 0)
                txt.TextTransparency = 0
            end
            if accentLine then accentLine.BackgroundTransparency = 0.3 end
        end
    end
    self.ArrayListMaster.Size = UDim2.new(0, maxW, 0, #enabled * (self.Config.ArrayListItemHeight + 3))
end

function SolsticeUI:_SetModuleState(name, state, value)
    if not self.EnabledModules[name] then
        self.EnabledModules[name] = {state = false, value = ""}
    end
    self.EnabledModules[name].state = state
    if value ~= nil then self.EnabledModules[name].value = value end
    self:_SaveModuleState(name, state, value)
    self:_UpdateArrayList()
end

-- ==================== NOTIFICATIONS ====================
function SolsticeUI:_InitNotifications()
    if not self.Config.ShowNotifications then return end
    self.NotifContainer = Instance.new("Frame")
    self.NotifContainer.Size = UDim2.new(0, 300, 0.5, 0)
    self.NotifContainer.Position = UDim2.new(1, -15, 0.92, 0)
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
    local tw = math.min(GetTextWidth(text, self.Config.Font, 12) + 32, 300)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, tw, 0, 32)
    holder.BackgroundTransparency = 1
    holder.Parent = self.NotifContainer
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 10, 1, 10)
    glow.Position = UDim2.new(0, -5, 0, -5)
    glow.BackgroundColor3 = PALETTE.NotifBorder
    glow.BackgroundTransparency = 0.9
    glow.BorderSizePixel = 0
    glow.ZIndex = 1
    glow.Parent = holder
    Corner(glow, UDim.new(0, 8))
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 1, 0)
    card.Position = UDim2.new(0, tw + 50, 0, 0)
    card.BackgroundColor3 = PALETTE.PanelBg
    card.BackgroundTransparency = 0.02
    card.BorderSizePixel = 0
    card.ZIndex = 2
    card.Parent = holder
    Corner(card, UDim.new(0, 5))
    local stroke = Instance.new("UIStroke")
    stroke.Color = PALETTE.NotifBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = card
    local gradLine = Instance.new("Frame")
    gradLine.Size = UDim2.new(1, 0, 0, 2)
    gradLine.BackgroundColor3 = PALETTE.ActiveGradientStart
    gradLine.BorderSizePixel = 0
    gradLine.ZIndex = 3
    gradLine.Parent = card
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 1, -2)
    lbl.Position = UDim2.new(0, 6, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = PALETTE.ItemText
    lbl.Font = self.Config.Font
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.ZIndex = 3
    lbl.Parent = card
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, lbl) end
    Tween(card, ANIM.NotifyIn, {Position = UDim2.new(0, 0, 0, 0)}):Play()
    task.delay(dur, function()
        if card and card.Parent then
            local fadeOut = Tween(card, ANIM.NotifyOut, {Position = UDim2.new(0, tw + 50, 0, 0), BackgroundTransparency = 1})
            fadeOut:Play()
            Tween(stroke, TweenInfo.new(0.35), {Transparency = 1}):Play()
            Tween(lbl, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
            Tween(glow, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            fadeOut.Completed:Connect(function() holder:Destroy() end)
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
                    local container = itemFrame:FindFirstChild("Container")
                    if container then
                        local txt = container:FindFirstChild("TextLabel")
                        local accentLine = container:FindFirstChild("AccentLine")
                        if txt then
                            local hue = (self.RainbowOffset + (itemFrame.LayoutOrder - 1) * 0.06) % 1
                            local color = HSVtoRGB(hue, 0.75, 1)
                            txt.TextColor3 = color
                            if accentLine then accentLine.BackgroundColor3 = color end
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
    CreateShadow(panel, 12, 0, 0.7)
    local stroke = Instance.new("UIStroke")
    stroke.Color = PALETTE.PanelBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.35
    stroke.Parent = panel
    panelData.Instance = panel
    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, self.Config.PanelHeaderHeight)
    header.BackgroundColor3 = PALETTE.HeaderBg
    header.BackgroundTransparency = 0.1
    header.BorderSizePixel = 0
    header.Text = ""
    header.AutoButtonColor = false
    header.Parent = panel
    Corner(header, UDim.new(0, 4))
    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 20, 1, 0)
    iconLbl.Position = UDim2.new(0, 8, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = iconChar or "•"
    iconLbl.TextColor3 = PALETTE.HeaderIcon
    iconLbl.Font = self.Config.FontItalic
    iconLbl.TextSize = 11
    iconLbl.TextXAlignment = Enum.TextXAlignment.Center
    iconLbl.Parent = header
    if self.Config.UseCustomFont then FontLoader.setFont(self.Config.CustomFontName, iconLbl) end
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -26, 1, 0)
    title.Position = UDim2.new(0, 22, 0, 0)
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
    list.Padding = UDim.new(0, 1)
    list.Parent = content
    function panelData:UpdateHeight()
        local target = self.Collapsed and ui.Config.PanelHeaderHeight or self.CurrentExpandedHeight
        Tween(panel, ANIM.Expand, {Size = UDim2.new(0, ui.Config.PanelWidth, 0, target)}):Play()
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
    task.delay(0.05, function() panelData:UpdateHeight() end)
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
    Corner(btn, UDim.new(0, 3))
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
    Corner(glowFrame, UDim.new(0, 3))
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
            Tween(btn, ANIM.Hover, {BackgroundColor3 = PALETTE.ItemHoverBg, BackgroundTransparency = 0.12}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not enabled then
            Tween(btn, ANIM.Hover, {BackgroundColor3 = PALETTE.ItemBg, BackgroundTransparency = PALETTE.ItemBgTransparency}):Play()
        end
    end)
    local function doToggle()
        if featType == "button" then return end
        enabled = not enabled
        ui:_SetModuleState(feat.name, enabled)
        if enabled then
            Tween(btn, ANIM.Standard, {BackgroundColor3 = PALETTE.ActiveBg, BackgroundTransparency = 0, TextColor3 = PALETTE.ActiveText}):Play()
            activeGrad.Enabled = true
            Tween(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight + 2)}):Play()
            task.delay(0.1, function()
                if enabled then
                    Tween(btn, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight)}):Play()
                end
            end)
        else
            Tween(btn, ANIM.Standard, {BackgroundColor3 = PALETTE.ItemBg, BackgroundTransparency = PALETTE.ItemBgTransparency, TextColor3 = PALETTE.ItemText}):Play()
            task.delay(0.18, function()
                if not enabled then activeGrad.Enabled = false end
            end)
        end
        if feat.callback then pcall(feat.callback, enabled) end
    end
    local function toggleSettings()
        if not settingsContainer then return end
        settingsExpanded = not settingsExpanded
        local targetH = settingsExpanded and (ui.Config.ItemHeight + setHeight) or ui.Config.ItemHeight
        Tween(modContainer, ANIM.SpringExpand, {Size = UDim2.new(1, 0, 0, targetH)}):Play()
        if settingsExpanded then
            settingsContainer.BackgroundTransparency = 1
            Tween(settingsContainer, TweenInfo.new(0.25), {BackgroundTransparency = PALETTE.SettingBgTransparency}):Play()
            for _, child in ipairs(settingsContainer:GetChildren()) do
                if child:IsA("Frame") then
                    child.BackgroundTransparency = 1
                    Tween(child, TweenInfo.new(0.18), {BackgroundTransparency = PALETTE.SettingBgTransparency}):Play()
                end
            end
        end
        panelData.CurrentExpandedHeight = panelData.CurrentExpandedHeight + (settingsExpanded and setHeight or -setHeight)
        panelData:UpdateHeight()
        if indicator then
            local targetRotation = settingsExpanded and 45 or 0
            Tween(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()
        end
    end
    if featType == "button" then
        btn.MouseButton1Down:Connect(function()
            Tween(btn, TweenInfo.new(ui.Config.ClickScaleDuration), {Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight * ui.Config.ClickScale), BackgroundColor3 = PALETTE.PressBg, BackgroundTransparency = 0}):Play()
            Tween(glowFrame, TweenInfo.new(0.08), {BackgroundTransparency = 0.35}):Play()
        end)
        btn.MouseButton1Up:Connect(function()
            Tween(btn, TweenInfo.new(ui.Config.ClickRestoreDuration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight), BackgroundColor3 = PALETTE.ItemBg, BackgroundTransparency = PALETTE.ItemBgTransparency}):Play()
            Tween(glowFrame, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, ANIM.Hover, {Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight), BackgroundColor3 = PALETTE.ItemBg, BackgroundTransparency = PALETTE.ItemBgTransparency}):Play()
            Tween(glowFrame, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            if feat.callback then pcall(feat.callback) end
            ui:Notify(feat.name .. " executed", 1.2)
        end)
    else
        btn.MouseButton1Down:Connect(function()
            if not enabled then
                Tween(btn, TweenInfo.new(ui.Config.ClickScaleDuration), {Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight * ui.Config.ClickScale)}):Play()
                Tween(glowFrame, TweenInfo.new(0.08), {BackgroundTransparency = 0.45}):Play()
            end
        end)
        btn.MouseButton1Up:Connect(function()
            if not enabled then
                Tween(btn, TweenInfo.new(ui.Config.ClickRestoreDuration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight)}):Play()
            end
            Tween(glowFrame, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
        end)
        btn.MouseLeave:Connect(function()
            if not enabled then
                Tween(btn, ANIM.Hover, {Size = UDim2.new(1, 0, 0, ui.Config.ItemHeight)}):Play()
            end
            Tween(glowFrame, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
        end)
        btn.MouseButton1Click:Connect(doToggle)
    end
    if indicator then
        indicator.MouseButton1Click:Connect(function() toggleSettings() end)
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
        elseif s.type == "color" then height = 26
        elseif s.type == "dropdown" then height = 26
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
    nameLbl.Size = UDim2.new(1, -55, 1, 0)
    nameLbl.Position = UDim2.new(0, 10, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = s.name
    nameLbl.TextColor3 = s.default and PALETTE.SettingValue or PALETTE.SettingText
    nameLbl.Font = ui.Config.Font
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, nameLbl) end
    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 30, 0, 15)
    switchBg.Position = UDim2.new(1, -38, 0.5, -7.5)
    switchBg.BackgroundColor3 = s.default and PALETTE.ToggleOn or PALETTE.ToggleOff
    switchBg.BorderSizePixel = 0
    switchBg.Parent = frame
    Corner(switchBg, UDim.new(0.5, 0))
    local switchKnob = Instance.new("Frame")
    switchKnob.Size = UDim2.new(0, 13, 0, 13)
    switchKnob.Position = s.default and UDim2.new(1, -14, 0.5, -6.5) or UDim2.new(0, 1, 0.5, -6.5)
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
        Tween(switchBg, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = val and PALETTE.ToggleOn or PALETTE.ToggleOff}):Play()
        Tween(switchKnob, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = val and UDim2.new(1, -14, 0.5, -6.5) or UDim2.new(0, 1, 0.5, -6.5)}):Play()
        Tween(switchKnob, TweenInfo.new(0.12), {Size = UDim2.new(0, 15, 0, 15)}):Play()
        task.delay(0.12, function()
            Tween(switchKnob, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 13, 0, 13)}):Play()
        end)
        if s.callback then pcall(s.callback, val) end
    end)
end

-- ==================== SLIDER SETTING ====================
function SolsticeUI:_CreateSliderSetting(frame, s, moduleName)
    local ui = self
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0.5, 0, 0, 15)
    nameLbl.Position = UDim2.new(0, 10, 0, 2)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = s.name
    nameLbl.TextColor3 = PALETTE.SettingText
    nameLbl.Font = ui.Config.Font
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, nameLbl) end
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.4, 0, 0, 15)
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
    barBg.Size = UDim2.new(1, -18, 0, 5)
    barBg.Position = UDim2.new(0, 9, 0, 24)
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
    hitArea.Size = UDim2.new(1, 0, 1, 18)
    hitArea.Position = UDim2.new(0, 0, 0, -9)
    hitArea.BackgroundTransparency = 1
    hitArea.Text = ""
    hitArea.Parent = barBg
    hitArea.ZIndex = 10
    local thumbSize = 13
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, thumbSize, 0, thumbSize)
    thumb.Position = UDim2.new(pct, -thumbSize/2, 0.5, -thumbSize/2)
    thumb.BackgroundColor3 = PALETTE.SliderThumb
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 5
    thumb.Parent = barBg
    Corner(thumb, UDim.new(0.5, 0))
    local glowRing = Instance.new("Frame")
    glowRing.Size = UDim2.new(1, 10, 1, 10)
    glowRing.Position = UDim2.new(0, -5, 0, -5)
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
        Tween(fill, TweenInfo.new(0.06), {Size = UDim2.new(newPct, 0, 1, 0)}):Play()
        Tween(thumb, TweenInfo.new(0.06), {Position = UDim2.new(newPct, -thumbSize/2, 0.5, -thumbSize/2)}):Play()
        local val = s.min + (s.max - s.min) * newPct
        val = math.floor(val * 100) / 100
        valLbl.Text = string.format("%.2f", val)
        if s.callback then pcall(s.callback, val) end
        if ui.EnabledModules[moduleName] then
            ui:_SetModuleState(moduleName, true, val)
        end
    end
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil
            Tween(thumb, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, thumbSize + 5, 0, thumbSize + 5)}):Play()
            Tween(glowRing, TweenInfo.new(0.14), {BackgroundTransparency = 0.3, Size = UDim2.new(1, 16, 1, 16), Position = UDim2.new(0, -8, 0, -8)}):Play()
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragTouch and input == dragTouch then dragging = false; dragTouch = nil
            elseif not dragTouch then dragging = false end
            Tween(thumb, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, thumbSize, 0, thumbSize)}):Play()
            Tween(glowRing, TweenInfo.new(0.18), {BackgroundTransparency = 0.75, Size = UDim2.new(1, 10, 1, 10), Position = UDim2.new(0, -5, 0, -5)}):Play()
        end
    end)
    frame.MouseEnter:Connect(function()
        Tween(barBg, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}):Play()
    end)
    frame.MouseLeave:Connect(function()
        Tween(barBg, TweenInfo.new(0.18), {BackgroundColor3 = PALETTE.SliderTrack}):Play()
    end)
end

-- ==================== BUTTON SETTING ====================
function SolsticeUI:_CreateButtonSetting(frame, s)
    local ui = self
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(52, 52, 62)
    btn.BackgroundTransparency = 0.25
    btn.BorderSizePixel = 0
    btn.Text = s.name
    btn.TextColor3 = PALETTE.SettingValue
    btn.Font = ui.Config.Font
    btn.TextSize = 11
    btn.Parent = frame
    Corner(btn, UDim.new(0, 3))
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, btn) end
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 0, 1, 0)
    glow.BackgroundColor3 = PALETTE.PressGlow
    glow.BackgroundTransparency = 1
    glow.BorderSizePixel = 0
    glow.ZIndex = 0
    glow.Parent = btn
    Corner(glow, UDim.new(0, 3))
    btn.MouseEnter:Connect(function()
        Tween(btn, ANIM.Hover, {BackgroundTransparency = 0.08}):Play()
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, ANIM.Hover, {BackgroundTransparency = 0.25}):Play()
        Tween(btn, TweenInfo.new(0.12), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        Tween(glow, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        Tween(btn, TweenInfo.new(0.07), {Size = UDim2.new(0.97, 0, 0.92, 0), BackgroundTransparency = 0.02}):Play()
        Tween(glow, TweenInfo.new(0.07), {BackgroundTransparency = 0.3}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(btn, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0.08}):Play()
        Tween(glow, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
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
    nameLbl.Position = UDim2.new(0, 10, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = s.name
    nameLbl.TextColor3 = PALETTE.SettingText
    nameLbl.Font = ui.Config.Font
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = frame
    if ui.Config.UseCustomFont then FontLoader.setFont(ui.Config.CustomFontName, nameLbl) end
    local keyBg = Instance.new("Frame")
    keyBg.Size = UDim2.new(0, 52, 0, 19)
    keyBg.Position = UDim2.new(1, -60, 0.5, -9.5)
    keyBg.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
    keyBg.BackgroundTransparency = 0.15
    keyBg.BorderSizePixel = 0
    keyBg.Parent = frame
    Corner(keyBg, UDim.new(0, 4))
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
        local pulseTween = Tween(keyBg, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true), {BackgroundColor3 = Color3.fromRGB(62, 62, 78)})
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
                Tween(keyBg, TweenInfo.new(0.22), {BackgroundColor3 = Color3.fromRGB(42, 42, 50)}):Play()
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
        box.Parent = frame
        Corner(box, UDim.new(0, 3))
        box.MouseEnter:Connect(function()
            Tween(box, TweenInfo.new(0.12), {Size = UDim2.new(0, boxSize+3, 0, boxSize+3), Position = UDim2.new(0, startX + (i-1) * (boxSize + spacing) - 1.5, 0.5, -boxSize/2 - 1.5)}):Play()
        end)
        box.MouseLeave:Connect(function()
            Tween(box, TweenInfo.new(0.12), {Size = UDim2.new(0, boxSize, 0, boxSize), Position = UDim2.new(0, startX + (i-1) * (boxSize + spacing), 0.5, -boxSize/2)}):Play()
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
    nameLbl.Position = UDim2.new(0, 10, 0, 0)
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
    self.ArrayListItems = {}
end

return SolsticeUI
