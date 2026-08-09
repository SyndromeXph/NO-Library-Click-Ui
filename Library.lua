-- ============================================================
-- SolsticeUI v2.0 - Pixel-Perfect Recreation
-- Features: Exact styling, smooth animations, mobile touch support
-- ArrayList slide animations, proper rounded corners, full palette
-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

-- ==================== LIBRARY ====================
local SolsticeUI = {}
SolsticeUI.__index = SolsticeUI

-- Exact color palette from screenshot analysis
local PALETTE = {
    -- Panel
    PanelBg = Color3.fromRGB(20, 20, 24),
    PanelBgTransparency = 0.06,
    PanelBorder = Color3.fromRGB(42, 42, 50),

    -- Header
    HeaderBg = Color3.fromRGB(30, 30, 36),
    HeaderText = Color3.fromRGB(190, 190, 195),
    HeaderIcon = Color3.fromRGB(130, 130, 140),

    -- Item (unselected)
    ItemBg = Color3.fromRGB(28, 28, 34),
    ItemBgTransparency = 0.25,
    ItemText = Color3.fromRGB(205, 205, 210),

    -- Item (selected) - pink/purple gradient
    ActiveStart = Color3.fromRGB(255, 170, 205),
    ActiveEnd = Color3.fromRGB(215, 155, 245),
    ActiveText = Color3.fromRGB(22, 22, 28),

    -- Settings
    SettingBg = Color3.fromRGB(16, 16, 20),
    SettingBgTransparency = 0.12,
    SettingText = Color3.fromRGB(150, 150, 160),
    SettingValue = Color3.fromRGB(215, 215, 220),

    -- Slider
    SliderTrack = Color3.fromRGB(50, 50, 58),
    SliderFill = Color3.fromRGB(195, 195, 205),
    SliderThumb = Color3.fromRGB(255, 255, 255),
    SliderThumbGlow = Color3.fromRGB(255, 195, 225),

    -- Toggle
    ToggleOff = Color3.fromRGB(50, 50, 58),
    ToggleOn = Color3.fromRGB(255, 155, 195),
    ToggleKnob = Color3.fromRGB(255, 255, 255),

    -- Search
    SearchBg = Color3.fromRGB(26, 26, 32),
    SearchPlaceholder = Color3.fromRGB(95, 95, 105),

    -- ArrayList
    ArrayListBg = Color3.fromRGB(18, 18, 22),
    ArrayListBgTransparency = 0.15,

    -- Misc
    Muted = Color3.fromRGB(115, 115, 125),
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(18, 18, 22),

    -- Notification
    NotifBorder = Color3.fromRGB(255, 170, 205),
}

-- Default config
local DEFAULT_CONFIG = {
    PanelWidth = 138,
    PanelHeaderHeight = 20,
    ItemHeight = 17,
    SettingHeight = 30,
    SliderHeight = 38,

    CornerRadius = UDim.new(0, 3),
    PanelCornerRadius = UDim.new(0, 4),

    Font = Enum.Font.SourceSansSemibold,
    FontItalic = Enum.Font.SourceSansItalic,
    TextSize = 12,
    HeaderTextSize = 12,

    PanelSpacing = 152,
    StartX = 20,
    StartY = 45,

    ArrayListFont = Enum.Font.SourceSansBold,
    ArrayListTextSize = 14,
    ArrayListItemHeight = 15,
    ArrayListRainbowSpeed = 0.35,
    ArrayListAnimSpeed = 0.25,

    Parent = nil,
    ShowSearchBar = true,
    ShowArrayList = true,
    ShowNotifications = true,
    ShowWatermark = true,
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

-- ==================== DRAGGING (Mouse + Touch) ====================
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

    self:_InitWatermark()
    self:_InitSearchBar()
    self:_InitArrayList()
    self:_InitNotifications()
    self:_StartRenderLoop()
    self:_BindToggleKey()

    return self
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
    moixel.Position = UDim2.new(0, 0, 0, 0)
    moixel.BackgroundTransparency = 1
    moixel.Text = "Moixel"
    moixel.TextColor3 = Color3.fromRGB(200, 200, 205)
    moixel.Font = Enum.Font.SourceSansBold
    moixel.TextSize = 20
    moixel.TextXAlignment = Enum.TextXAlignment.Left
    moixel.Parent = wm

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
end

-- ==================== SEARCH BAR ====================
function SolsticeUI:_InitSearchBar()
    if not self.Config.ShowSearchBar then return end

    local frame = Instance.new("Frame")
    frame.Name = "SearchBar"
    frame.Size = UDim2.new(0, 200, 0, 24)
    frame.Position = UDim2.new(0.5, -100, 0, 8)
    frame.BackgroundColor3 = PALETTE.SearchBg
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel = 0
    frame.Parent = self.ClickGui
    Corner(frame, UDim.new(0, 4))

    local stroke = Instance.new("UIStroke")
    stroke.Color = PALETTE.PanelBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.5
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

-- ==================== ARRAY LIST (with slide animations) ====================
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

    -- Sort by text width (longest first)
    table.sort(enabled, function(a, b)
        return GetTextWidth(a.display, self.Config.ArrayListFont, self.Config.ArrayListTextSize) >
               GetTextWidth(b.display, self.Config.ArrayListFont, self.Config.ArrayListTextSize)
    end)

    -- Mark all existing items as potentially removed
    local activeNames = {}
    for _, data in ipairs(enabled) do
        activeNames[data.name] = true
    end

    -- Animate out removed items
    for name, item in pairs(self.ArrayListItems) do
        if not activeNames[name] and item.Visible then
            item.Visible = false
            -- Slide out animation
            local bg = item:FindFirstChild("Bg")
            if bg then
                TweenService:Create(bg, TweenInfo.new(self.Config.ArrayListAnimSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(0, GetTextWidth(item.Text, self.Config.ArrayListFont, self.Config.ArrayListTextSize) + 20, 0, 0),
                    BackgroundTransparency = 1
                }):Play()
                TweenService:Create(item, TweenInfo.new(self.Config.ArrayListAnimSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    TextTransparency = 1
                }):Play()
            end
            task.delay(self.Config.ArrayListAnimSpeed, function()
                if item and item.Parent then
                    item.Visible = false
                end
            end)
        end
    end

    local maxW = 0
    for i, data in ipairs(enabled) do
        local item = self.ArrayListItems[data.name]
        local isNew = false

        if not item then
            isNew = true
            item = Instance.new("TextLabel")
            item.Name = data.name .. "_AL"
            item.BackgroundTransparency = 1
            item.Font = self.Config.ArrayListFont
            item.TextSize = self.Config.ArrayListTextSize
            item.TextXAlignment = Enum.TextXAlignment.Right
            item.TextTransparency = 1
            item.Parent = self.ArrayListContent

            -- Background bar for each item
            local bg = Instance.new("Frame")
            bg.Name = "Bg"
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.Position = UDim2.new(0, 0, 0, 0)
            bg.BackgroundColor3 = PALETTE.ArrayListBg
            bg.BackgroundTransparency = 1
            bg.BorderSizePixel = 0
            bg.ZIndex = 0
            bg.Parent = item

            self.ArrayListItems[data.name] = item
        end

        item.Text = data.display
        item.Visible = true
        item.LayoutOrder = i

        local tw = GetTextWidth(data.display, self.Config.ArrayListFont, self.Config.ArrayListTextSize) + 8
        if tw > maxW then maxW = tw end

        item.Size = UDim2.new(0, tw, 0, self.Config.ArrayListItemHeight)

        local bg = item:FindFirstChild("Bg")
        if bg then
            bg.Size = UDim2.new(0, tw, 1, 0)
        end

        -- Animate in (slide from right)
        if isNew then
            item.Position = UDim2.new(0, tw + 20, 0, 0)
            TweenService:Create(item, TweenInfo.new(self.Config.ArrayListAnimSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 0),
                TextTransparency = 0
            }):Play()
            if bg then
                bg.Position = UDim2.new(0, tw + 20, 0, 0)
                TweenService:Create(bg, TweenInfo.new(self.Config.ArrayListAnimSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = PALETTE.ArrayListBgTransparency
                }):Play()
            end
        else
            -- Reset transparency for re-showing items
            item.TextTransparency = 0
            item.Position = UDim2.new(0, 0, 0, 0)
            if bg then
                bg.BackgroundTransparency = PALETTE.ArrayListBgTransparency
                bg.Position = UDim2.new(0, 0, 0, 0)
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
    card.BackgroundTransparency = 0.04
    card.BorderSizePixel = 0
    card.Parent = holder
    Corner(card, UDim.new(0, 3))

    local stroke = Instance.new("UIStroke")
    stroke.Color = PALETTE.NotifBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = card

    local gradLine = Instance.new("Frame")
    gradLine.Size = UDim2.new(1, 0, 0, 2)
    gradLine.BackgroundColor3 = PALETTE.ActiveStart
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

    -- Pop in animation with Back easing
    TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    task.delay(dur, function()
        if card and card.Parent then
            local fadeOut = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0, tw + 40, 0, 0),
                BackgroundTransparency = 1
            })
            fadeOut:Play()
            TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            TweenService:Create(lbl, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
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
            for name, item in pairs(self.ArrayListItems) do
                if item.Visible then
                    local hue = (self.RainbowOffset + (item.LayoutOrder - 1) * 0.055) % 1
                    item.TextColor3 = HSVtoRGB(hue, 0.78, 1)
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

    -- Main panel
    local panel = Instance.new("Frame")
    panel.Name = name .. "Panel"
    panel.Size = UDim2.new(0, self.Config.PanelWidth, 0, self.Config.PanelHeaderHeight)
    panel.Position = position
    panel.BackgroundColor3 = PALETTE.PanelBg
    panel.BackgroundTransparency = PALETTE.PanelBgTransparency
    panel.BorderSizePixel = 0
    panel.Parent = self.ClickGui
    Corner(panel, self.Config.PanelCornerRadius)

    -- Border stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = PALETTE.PanelBorder
    stroke.Thickness = 1
    stroke.Transparency = 0.45
    stroke.Parent = panel

    panelData.Instance = panel

    -- Header
    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, self.Config.PanelHeaderHeight)
    header.BackgroundColor3 = PALETTE.HeaderBg
    header.BackgroundTransparency = 0.15
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

    -- Content area
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
        TweenService:Create(panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, ui.Config.PanelWidth, 0, target)
        }):Play()
    end

    function panelData:ToggleCollapse()
        self.Collapsed = not self.Collapsed
        self:UpdateHeight()
    end

    header.MouseButton1Click:Connect(function() panelData:ToggleCollapse() end)
    MakeDraggable(panel, header)

    -- Create all features
    for i, feat in ipairs(features or {}) do
        ui:_CreateFeature(content, panelData, feat)
    end

    task.delay(0.05, function()
        panelData:UpdateHeight()
    end)

    table.insert(self.Panels, panelData)
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

    -- Main button with subtle background
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

    -- Active gradient (horizontal pink -> purple)
    local activeGrad = Instance.new("UIGradient")
    activeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, PALETTE.ActiveStart),
        ColorSequenceKeypoint.new(1, PALETTE.ActiveEnd)
    })
    activeGrad.Rotation = 0
    activeGrad.Enabled = false
    activeGrad.Parent = btn

    -- Settings indicator
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

    -- Toggle logic
    local function doToggle()
        if featType == "button" then return end
        enabled = not enabled
        ui:_SetModuleState(feat.name, enabled)
        if enabled then
            TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0,
                TextColor3 = PALETTE.ActiveText
            }):Play()
            activeGrad.Enabled = true
        else
            TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = PALETTE.ItemBgTransparency,
                TextColor3 = PALETTE.ItemText
            }):Play()
            task.delay(0.15, function()
                if not enabled then activeGrad.Enabled = false end
            end)
        end
        if feat.callback then pcall(feat.callback, enabled) end
    end

    -- Settings expand/collapse with animation
    local function toggleSettings()
        if not settingsContainer then return end
        settingsExpanded = not settingsExpanded
        local targetH = settingsExpanded and (ui.Config.ItemHeight + setHeight) or ui.Config.ItemHeight

        TweenService:Create(modContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, targetH)
        }):Play()

        if settingsExpanded then
            settingsContainer.BackgroundTransparency = 1
            TweenService:Create(settingsContainer, TweenInfo.new(0.2), {
                BackgroundTransparency = PALETTE.SettingBgTransparency
            }):Play()
            for _, child in ipairs(settingsContainer:GetChildren()) do
                if child:IsA("Frame") then
                    child.BackgroundTransparency = 1
                    TweenService:Create(child, TweenInfo.new(0.15), {
                        BackgroundTransparency = PALETTE.SettingBgTransparency
                    }):Play()
                end
            end
        end

        panelData.CurrentExpandedHeight = panelData.CurrentExpandedHeight + (settingsExpanded and setHeight or -setHeight)
        panelData:UpdateHeight()
        if indicator then
            indicator.Text = settingsExpanded and "−" or "+"
        end
    end

    -- Click handlers
    if featType == "button" then
        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundTransparency = 0.15}):Play()
            task.delay(0.08, function()
                TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundTransparency = PALETTE.ItemBgTransparency}):Play()
            end)
            if feat.callback then pcall(feat.callback) end
            ui:Notify(feat.name .. " executed", 1.2)
        end)
    else
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
        settingsContainer, setHeight = ui:_CreateSettings(modContainer, panelData, feat.settings)
    end
end

-- ==================== CREATE SETTINGS ====================
function SolsticeUI:_CreateSettings(modContainer, panelData, settings)
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
            ui:_CreateToggleSetting(frame, s)
        elseif s.type == "slider" then
            ui:_CreateSliderSetting(frame, s)
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
function SolsticeUI:_CreateToggleSetting(frame, s)
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

    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 26, 0, 12)
    switchBg.Position = UDim2.new(1, -34, 0.5, -6)
    switchBg.BackgroundColor3 = s.default and PALETTE.ToggleOn or PALETTE.ToggleOff
    switchBg.BorderSizePixel = 0
    switchBg.Parent = frame
    Corner(switchBg, UDim.new(0.5, 0))

    local switchKnob = Instance.new("Frame")
    switchKnob.Size = UDim2.new(0, 10, 0, 10)
    switchKnob.Position = s.default and UDim2.new(1, -11, 0.5, -5) or UDim2.new(0, 1, 0.5, -5)
    switchKnob.BackgroundColor3 = PALETTE.ToggleKnob
    switchKnob.BorderSizePixel = 0
    switchKnob.Parent = switchBg
    Corner(switchKnob, UDim.new(0.5, 0))

    local val = s.default
    btn.MouseButton1Click:Connect(function()
        val = not val
        nameLbl.TextColor3 = val and PALETTE.SettingValue or PALETTE.SettingText
        TweenService:Create(switchBg, TweenInfo.new(0.15), {
            BackgroundColor3 = val and PALETTE.ToggleOn or PALETTE.ToggleOff
        }):Play()
        TweenService:Create(switchKnob, TweenInfo.new(0.15), {
            Position = val and UDim2.new(1, -11, 0.5, -5) or UDim2.new(0, 1, 0.5, -5)
        }):Play()
        if s.callback then pcall(s.callback, val) end
    end)
end

-- ==================== SLIDER SETTING ====================
function SolsticeUI:_CreateSliderSetting(frame, s)
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

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -16, 0, 2)
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

    local thumbSize = 8
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, thumbSize, 0, thumbSize)
    thumb.Position = UDim2.new(pct, -thumbSize/2, 0.5, -thumbSize/2)
    thumb.BackgroundColor3 = PALETTE.SliderThumb
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 3
    thumb.Parent = barBg
    Corner(thumb, UDim.new(0.5, 0))

    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 4, 1, 4)
    glow.Position = UDim2.new(0, -2, 0, -2)
    glow.BackgroundColor3 = PALETTE.SliderThumbGlow
    glow.BackgroundTransparency = 0.65
    glow.BorderSizePixel = 0
    glow.ZIndex = 2
    glow.Parent = thumb
    Corner(glow, UDim.new(0.5, 0))

    local dragging = false
    local dragTouch = nil

    local function updateSlider(inputPos)
        local relX = inputPos.X - barBg.AbsolutePosition.X
        local sliderX = math.clamp(relX, 0, barBg.AbsoluteSize.X)
        local newPct = sliderX / math.max(barBg.AbsoluteSize.X, 1)
        fill.Size = UDim2.new(newPct, 0, 1, 0)
        thumb.Position = UDim2.new(newPct, -thumbSize/2, 0.5, -thumbSize/2)
        local val = s.min + (s.max - s.min) * newPct
        val = math.floor(val * 100) / 100
        valLbl.Text = string.format("%.2f", val)
        if s.callback then pcall(s.callback, val) end
        if ui.EnabledModules[s.moduleName] then
            ui:_SetModuleState(s.moduleName, true, val)
        end
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil
            updateSlider(input.Position)
        end
    end)

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
        end
    end)
end

-- ==================== BUTTON SETTING ====================
function SolsticeUI:_CreateButtonSetting(frame, s)
    local ui = self
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(52, 52, 60)
    btn.BackgroundTransparency = 0.35
    btn.BorderSizePixel = 0
    btn.Text = s.name
    btn.TextColor3 = PALETTE.SettingValue
    btn.Font = ui.Config.Font
    btn.TextSize = 11
    btn.Parent = frame
    Corner(btn, UDim.new(0, 2))

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundTransparency = 0.08}):Play()
        task.delay(0.08, function()
            TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundTransparency = 0.35}):Play()
        end)
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

    local keyLbl = Instance.new("TextLabel")
    keyLbl.Size = UDim2.new(0.4, 0, 1, 0)
    keyLbl.Position = UDim2.new(0.55, 0, 0, 0)
    keyLbl.BackgroundTransparency = 1
    keyLbl.Text = s.default and s.default.Name or "None"
    keyLbl.TextColor3 = PALETTE.SettingValue
    keyLbl.Font = ui.Config.Font
    keyLbl.TextSize = 11
    keyLbl.TextXAlignment = Enum.TextXAlignment.Right
    keyLbl.Parent = frame

    local listening = false
    local listenConn = nil

    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyLbl.Text = "..."
        keyLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
        listenConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if listenConn then listenConn:Disconnect() end
                listening = false
                local newKey = input.KeyCode
                keyLbl.Text = newKey.Name
                keyLbl.TextColor3 = PALETTE.SettingValue
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
