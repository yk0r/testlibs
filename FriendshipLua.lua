--[[
    Friendship.Lua UI Library
    Roblox Executor Script UI Library
    
    Design System:
    - Theme: Dark cyberpunk / hacker aesthetic
    - Accent: Cyan (#4CC9F0)
    - Background: Near-black (#08090A)
    - Style: Sharp edges, subtle glow, grid overlay
    
    Components: Window, Tab, Section, Toggle, Slider, 
                Dropdown, Keybind, Button, ColorPicker, 
                TextField, Notification
    
    Usage:
        local Library = loadstring(...)()
        -- OR if local:
        local Library = require(script.FriendshipLua)
        
        local Window = Library:CreateWindow({
            Title = "My Script",
            SubTitle = "Premium Scripts",
            Size = UDim2.fromOffset(700, 450),
        })
        
        local Tab = Window:CreateTab("Combat", "rbxassetid://...")
        local Section = Tab:CreateSection("Aimbot Settings")
        
        Section:CreateToggle({ Label = "Enabled", Default = false, Callback = function(v) end })
        Section:CreateSlider({ Label = "FOV", Min = 0, Max = 360, Default = 120, Suffix = "°", Callback = function(v) end })
        Section:CreateDropdown({ Label = "Target Part", Options = {"Head","Torso","Random"}, Default = "Head", Callback = function(v) end })
        Section:CreateKeybind({ Label = "Aimbot Key", Default = Enum.KeyCode.Q, Callback = function(key) end })
        Section:CreateButton({ Label = "Execute", Callback = function() end })
        Section:CreateColorPicker({ Label = "ESP Color", Default = Color3.fromRGB(76,201,240), Callback = function(c) end })
        Section:CreateTextField({ Label = "Coordinates", Placeholder = "0, 0, 0", Callback = function(v) end })
        
        Library:Notify({ Title = "System", Content = "Loaded!", Duration = 3 })
]]

-- ============================================================
--  SERVICES
-- ============================================================
local function getService(name)
    local ok, svc = pcall(function() return game:GetService(name) end)
    if ok then
        return if (rawget(_G, "cloneref")) then cloneref(svc) else svc
    end
end

local UserInputService = getService("UserInputService")
local TweenService     = getService("TweenService")
local Players          = getService("Players")
local RunService       = getService("RunService")
local CoreGui          = getService("CoreGui")
local TextService      = getService("TextService")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
--  UTILITY
-- ============================================================
local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function lerp(a, b, t) return a + (b - a) * t end

local function clamp(v, min, max)
    return math.max(min, math.min(max, v))
end

local function round(n, decimals)
    local m = 10 ^ (decimals or 0)
    return math.floor(n * m + 0.5) / m
end

local function hexToColor(hex)
    hex = hex:gsub("#","")
    return Color3.fromRGB(
        tonumber(hex:sub(1,2), 16),
        tonumber(hex:sub(3,4), 16),
        tonumber(hex:sub(5,6), 16)
    )
end

local function colorToHex(c)
    return string.format("#%02X%02X%02X",
        math.floor(c.R * 255 + 0.5),
        math.floor(c.G * 255 + 0.5),
        math.floor(c.B * 255 + 0.5)
    )
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function makeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(255,255,255)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.9
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function makePadding(parent, top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.Parent = parent
    return p
end

local function makeListLayout(parent, dir, align, padding)
    local l = Instance.new("UIListLayout")
    l.FillDirection     = dir   or Enum.FillDirection.Vertical
    l.HorizontalAlignment = align or Enum.HorizontalAlignment.Left
    l.SortOrder         = Enum.SortOrder.LayoutOrder
    l.Padding           = UDim.new(0, padding or 0)
    l.Parent = parent
    return l
end

local function makeSizeConstraint(parent, minX, minY, maxX, maxY)
    local c = Instance.new("UISizeConstraint")
    c.MinSize = Vector2.new(minX or 0, minY or 0)
    c.MaxSize = Vector2.new(maxX or math.huge, maxY or math.huge)
    c.Parent = parent
    return c
end

-- Create a Frame helper
local function newFrame(props)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(0,0,0)
    f.BackgroundTransparency = props.BackgroundTransparency or 0
    f.BorderSizePixel = 0
    f.Size = props.Size or UDim2.new(1, 0, 0, 30)
    f.Position = props.Position or UDim2.new(0,0,0,0)
    if props.Name then f.Name = props.Name end
    if props.Parent then f.Parent = props.Parent end
    if props.ZIndex then f.ZIndex = props.ZIndex end
    if props.ClipsDescendants ~= nil then f.ClipsDescendants = props.ClipsDescendants end
    return f
end

local function newLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    l.Text = props.Text or ""
    l.TextColor3 = props.TextColor3 or Color3.fromRGB(255,255,255)
    l.TextTransparency = props.TextTransparency or 0
    l.Font = props.Font or Enum.Font.GothamBold
    l.TextSize = props.TextSize or 13
    l.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    l.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
    l.Size = props.Size or UDim2.new(1, 0, 0, 24)
    l.Position = props.Position or UDim2.new(0,0,0,0)
    if props.Name then l.Name = props.Name end
    if props.Parent then l.Parent = props.Parent end
    if props.RichText ~= nil then l.RichText = props.RichText end
    return l
end

local function newButton(props)
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(30,30,35)
    b.BackgroundTransparency = props.BackgroundTransparency or 0
    b.BorderSizePixel = 0
    b.Text = props.Text or ""
    b.TextColor3 = props.TextColor3 or Color3.fromRGB(255,255,255)
    b.Font = props.Font or Enum.Font.GothamBold
    b.TextSize = props.TextSize or 12
    b.Size = props.Size or UDim2.new(1, 0, 0, 32)
    b.Position = props.Position or UDim2.new(0,0,0,0)
    b.AutoButtonColor = false
    if props.Name then b.Name = props.Name end
    if props.Parent then b.Parent = props.Parent end
    return b
end

local function newImage(props)
    local i = Instance.new("ImageLabel")
    i.BackgroundTransparency = 1
    i.BorderSizePixel = 0
    i.Image = props.Image or ""
    i.ImageColor3 = props.ImageColor3 or Color3.fromRGB(255,255,255)
    i.ImageTransparency = props.ImageTransparency or 0
    i.Size = props.Size or UDim2.new(0, 20, 0, 20)
    i.Position = props.Position or UDim2.new(0,0,0,0)
    if props.Name then i.Name = props.Name end
    if props.Parent then i.Parent = props.Parent end
    return i
end

-- ============================================================
--  THEME
-- ============================================================
local Theme = {
    -- Backgrounds
    BG_Main        = Color3.fromRGB(8,   9,   10),
    BG_Window      = Color3.fromRGB(12,  13,  15),
    BG_Sidebar     = Color3.fromRGB(6,   7,   9),
    BG_Header      = Color3.fromRGB(0,   0,   0),   -- bg-black/20
    BG_Footer      = Color3.fromRGB(0,   0,   0),
    BG_Element     = Color3.fromRGB(18,  20,  23),
    BG_ElementHov  = Color3.fromRGB(22,  24,  28),
    BG_Dropdown    = Color3.fromRGB(26,  27,  30),
    BG_Tag         = Color3.fromRGB(10,  30,  38),

    -- Accent (Cyan)
    Accent         = Color3.fromRGB(76,  201, 240),
    AccentDim      = Color3.fromRGB(40,  100, 130),
    AccentBG       = Color3.fromRGB(12,  38,  50),
    AccentBGHov    = Color3.fromRGB(18,  55,  75),

    -- Text
    Text           = Color3.fromRGB(200, 200, 200),
    TextDim        = Color3.fromRGB(100, 100, 110),
    TextFaint      = Color3.fromRGB(55,  58,  65),
    TextAccent     = Color3.fromRGB(76,  201, 240),

    -- Borders
    Border         = Color3.fromRGB(255, 255, 255),   -- use with transparency
    BorderAccent   = Color3.fromRGB(76,  201, 240),

    -- Status
    Success        = Color3.fromRGB(80,  220, 120),
    Danger         = Color3.fromRGB(240, 80,  80),
    Warning        = Color3.fromRGB(240, 180, 60),

    -- Tweens
    Fast           = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Medium         = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Slow           = TweenInfo.new(0.4,  Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Spring         = TweenInfo.new(0.35, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
}

-- ============================================================
--  LIBRARY CORE
-- ============================================================
local FriendshipLib = {}
FriendshipLib.__index = FriendshipLib

FriendshipLib._notifQueue = {}
FriendshipLib._windows    = {}

-- ============================================================
--  NOTIFICATION SYSTEM
-- ============================================================
function FriendshipLib:_initNotifContainer()
    if self._notifContainer then return end

    local screenGui = self._screenGui
    local container = newFrame({
        Name = "NotifContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 280, 1, 0),
        Position = UDim2.new(1, -296, 0, 0),
        Parent = screenGui,
        ZIndex = 100,
    })

    local layout = makeListLayout(container, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, 8)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    makePadding(container, 0, 0, 24, 0)

    self._notifContainer = container
    self._notifCount = 0
end

function FriendshipLib:Notify(config)
    self:_initNotifContainer()

    local title    = config.Title    or "Notification"
    local content  = config.Content  or ""
    local duration = config.Duration or 3
    local icon     = config.Icon     or nil -- accent dot by default

    self._notifCount = (self._notifCount or 0) + 1
    local order = self._notifCount

    -- Notif card
    local card = newFrame({
        Name = "Notif_" .. order,
        BackgroundColor3 = Color3.fromRGB(15, 16, 19),
        Size = UDim2.new(1, 0, 0, 0),      -- height auto via AutomaticSize
        BackgroundTransparency = 0,
        Parent = self._notifContainer,
        ZIndex = 101,
    })
    card.LayoutOrder = order
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.ClipsDescendants = false

    makeCorner(card, 6)
    local stroke = makeStroke(card, Theme.AccentDim, 1, 0.5)

    -- Left accent bar
    local bar = newFrame({
        Name = "AccentBar",
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 2, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = card,
        ZIndex = 102,
    })
    makeCorner(bar, 2)

    -- Inner content layout
    local inner = newFrame({
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Parent = card,
        ZIndex = 102,
    })
    inner.AutomaticSize = Enum.AutomaticSize.Y
    makePadding(inner, 10, 6, 10, 4)
    makeListLayout(inner, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 3)

    -- Dot + title row
    local titleRow = newFrame({
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        Parent = inner,
        ZIndex = 102,
    })
    makeListLayout(titleRow, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 6)
    titleRow.AutomaticSize = Enum.AutomaticSize.XY

    local dot = newFrame({
        Name = "Dot",
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 6, 0, 6),
        Parent = titleRow,
        ZIndex = 103,
    })
    dot.AnchorPoint = Vector2.new(0, 0.5)
    makeCorner(dot, 99)

    -- Align dot vertically
    local dotWrap = newFrame({
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 6, 0, 14),
        Parent = titleRow,
        ZIndex = 103,
    })
    dot.Parent = dotWrap

    local titleLabel = newLabel({
        Text = string.upper(title),
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        Size = UDim2.new(0, 0, 0, 14),
        Parent = titleRow,
        ZIndex = 103,
    })
    titleLabel.AutomaticSize = Enum.AutomaticSize.X

    local contentLabel = newLabel({
        Text = content,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = inner,
        ZIndex = 102,
    })
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.TextWrapped = true

    -- Progress bar (duration indicator)
    local progressBG = newFrame({
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.95,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        Parent = card,
        ZIndex = 103,
    })
    local progressBar = newFrame({
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = progressBG,
        ZIndex = 104,
    })

    -- Slide in animation
    card.Position = UDim2.new(1, 20, 0, 0)
    card.BackgroundTransparency = 1
    tween(card, Theme.Medium, { BackgroundTransparency = 0 })
    tween(card, Theme.Medium, { Position = UDim2.new(0, 0, 0, 0) })

    -- Progress tween
    task.delay(0.3, function()
        tween(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0)
        })
    end)

    -- Auto dismiss
    task.delay(duration + 0.3, function()
        tween(card, Theme.Medium, { BackgroundTransparency = 1 })
        tween(card, Theme.Medium, { Position = UDim2.new(1, 20, 0, 0) })
        task.delay(0.35, function()
            card:Destroy()
        end)
    end)

    return card
end

-- ============================================================
--  DRAGGING UTILITY
-- ============================================================
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
--  WINDOW
-- ============================================================
function FriendshipLib:CreateWindow(config)
    config = config or {}
    local title    = config.Title    or "Friendship.Lua"
    local subtitle = config.SubTitle or "Premium Scripts"
    local size     = config.Size     or UDim2.fromOffset(700, 450)
    local position = config.Position or UDim2.new(0.5, -350, 0.5, -225)
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FriendshipLua_" .. title:gsub("%s","")
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Try CoreGui, fallback to PlayerGui
    local ok = pcall(function()
        if syn then
            syn.protect_gui(screenGui)
        end
        screenGui.Parent = CoreGui
    end)
    if not ok then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    self._screenGui = screenGui

    -- Background overlay (behind window)
    local bgOverlay = newFrame({
        Name = "BG_Overlay",
        BackgroundColor3 = Theme.BG_Main,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = screenGui,
        ZIndex = 1,
    })

    -- Grid overlay effect
    local gridOverlay = newFrame({
        Name = "GridOverlay",
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = screenGui,
        ZIndex = 2,
    })

    -- Main window frame
    local mainWindow = newFrame({
        Name = "MainWindow",
        BackgroundColor3 = Theme.BG_Window,
        Size = size,
        Position = position,
        Parent = screenGui,
        ZIndex = 3,
        ClipsDescendants = true,
    })
    makeCorner(mainWindow, 12)
    makeStroke(mainWindow, Color3.fromRGB(255,255,255), 1, 0.9)

    -- ── SIDEBAR ──────────────────────────────────────────────
    local sidebar = newFrame({
        Name = "Sidebar",
        BackgroundColor3 = Theme.BG_Sidebar,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = mainWindow,
        ZIndex = 4,
    })

    -- Brand logo area
    local brandArea = newFrame({
        Name = "BrandArea",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = sidebar,
        ZIndex = 5,
    })
    makePadding(brandArea, 0, 0, 0, 18)

    local logoBox = newFrame({
        Name = "LogoBox",
        BackgroundColor3 = Theme.AccentBG,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 18, 0.5, -14),
        Parent = brandArea,
        ZIndex = 6,
    })
    makeCorner(logoBox, 5)
    makeStroke(logoBox, Theme.AccentDim, 1, 0.4)

    newLabel({
        Text = "F",
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = logoBox,
        ZIndex = 7,
    }).TextXAlignment = Enum.TextXAlignment.Center

    -- Dot indicator on logo
    local logoDot = newFrame({
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(1, -3, 0, -3),
        Parent = logoBox,
        ZIndex = 7,
    })
    makeCorner(logoDot, 99)

    -- Title text
    local titleLabel = newLabel({
        Text = title:match("^([^%.]+)") or title,
        TextColor3 = Color3.fromRGB(220,220,220),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Size = UDim2.new(0, 120, 0, 16),
        Position = UDim2.new(0, 56, 0.5, -16),
        Parent = brandArea,
        ZIndex = 6,
    })

    local titleExt = title:match("%.(.+)$")
    if titleExt then
        local extLabel = newLabel({
            Text = "." .. titleExt,
            TextColor3 = Theme.Accent,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            Size = UDim2.new(0, 120, 0, 16),
            Position = UDim2.new(0, 56 + TextService:GetTextSize(title:match("^([^%.]+)"), 13, Enum.Font.GothamBold, Vector2.new(200,20)).X, 0.5, -16),
            Parent = brandArea,
            ZIndex = 6,
        })
        _ = extLabel -- suppress unused warning
    end

    local subLabel = newLabel({
        Text = string.upper(subtitle),
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        Size = UDim2.new(0, 120, 0, 12),
        Position = UDim2.new(0, 56, 0.5, 3),
        Parent = brandArea,
        ZIndex = 6,
    })
    _ = subLabel

    -- Sidebar separator
    local sidebarSep = newFrame({
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.95,
        Size = UDim2.new(1, -28, 0, 1),
        Position = UDim2.new(0, 14, 0, 60),
        Parent = sidebar,
        ZIndex = 5,
    })
    _ = sidebarSep

    -- Tab nav container
    local navContainer = newFrame({
        Name = "NavContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -108),
        Position = UDim2.new(0, 0, 0, 66),
        Parent = sidebar,
        ZIndex = 5,
    })
    makePadding(navContainer, 0, 8, 0, 8)
    makeListLayout(navContainer, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 2)

    -- Sidebar bottom (user area)
    local sidebarBottom = newFrame({
        Name = "SidebarBottom",
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.8,
        Size = UDim2.new(1, 0, 0, 48),
        Position = UDim2.new(0, 0, 1, -48),
        Parent = sidebar,
        ZIndex = 5,
    })
    makeStroke(sidebarBottom, Color3.fromRGB(255,255,255), 1, 0.95)
    makePadding(sidebarBottom, 0, 0, 0, 18)

    newLabel({
        Text = "Welcome back,",
        TextColor3 = Color3.fromRGB(180,180,180),
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Size = UDim2.new(1, -18, 0, 12),
        Position = UDim2.new(0, 0, 0, 10),
        Parent = sidebarBottom,
        ZIndex = 6,
    })

    local playerName = "User"
    pcall(function() playerName = LocalPlayer.Name end)

    newLabel({
        Text = string.upper(playerName),
        TextColor3 = Theme.TextAccent,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        Size = UDim2.new(1, -18, 0, 12),
        Position = UDim2.new(0, 0, 0, 24),
        Parent = sidebarBottom,
        ZIndex = 6,
    })

    -- ── MAIN CONTENT AREA ──────────────────────────────────
    local contentArea = newFrame({
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.new(0, 200, 0, 0),
        Parent = mainWindow,
        ZIndex = 4,
    })

    -- Header
    local header = newFrame({
        Name = "Header",
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.8,
        Size = UDim2.new(1, 0, 0, 48),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = contentArea,
        ZIndex = 5,
    })
    makeStroke(header, Color3.fromRGB(255,255,255), 1, 0.95)

    -- Breadcrumb left
    local breadcrumbContainer = newFrame({
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 180, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        Parent = header,
        ZIndex = 6,
    })
    makeListLayout(breadcrumbContainer, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 6)
    breadcrumbContainer.AutomaticSize = Enum.AutomaticSize.X

    local breadcrumbMeta = newLabel({
        Text = "CURRENT CATEGORY",
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = breadcrumbContainer,
        ZIndex = 6,
    })
    breadcrumbMeta.AutomaticSize = Enum.AutomaticSize.X

    local chevron = newLabel({
        Text = "›",
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Size = UDim2.new(0, 10, 1, 0),
        Parent = breadcrumbContainer,
        ZIndex = 6,
    })
    _ = chevron

    local breadcrumbActive = newLabel({
        Name = "BreadcrumbActive",
        Text = "Home",
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = breadcrumbContainer,
        ZIndex = 6,
    })
    breadcrumbActive.AutomaticSize = Enum.AutomaticSize.X

    -- Close button (top right of header)
    local closeBtn = newButton({
        Name = "CloseBtn",
        Text = "×",
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -34, 0.5, -12),
        Parent = header,
        ZIndex = 6,
    })
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, Theme.Fast, { TextColor3 = Theme.Danger })
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, Theme.Fast, { TextColor3 = Theme.TextDim })
    end)
    closeBtn.MouseButton1Click:Connect(function()
        tween(mainWindow, Theme.Medium, { Size = UDim2.fromOffset(size.X.Offset, 0) })
        task.delay(0.3, function()
            mainWindow.Visible = false
        end)
    end)

    -- Minimize button
    local minBtn = newButton({
        Name = "MinBtn",
        Text = "—",
        BackgroundTransparency = 1,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -62, 0.5, -12),
        Parent = header,
        ZIndex = 6,
    })
    minBtn.MouseEnter:Connect(function()
        tween(minBtn, Theme.Fast, { TextColor3 = Theme.Accent })
    end)
    minBtn.MouseLeave:Connect(function()
        tween(minBtn, Theme.Fast, { TextColor3 = Theme.TextDim })
    end)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tween(mainWindow, Theme.Medium, { Size = UDim2.fromOffset(size.X.Offset, 48) })
        else
            tween(mainWindow, Theme.Spring, { Size = size })
        end
    end)

    -- Tab content pages container
    local pagesContainer = newFrame({
        Name = "PagesContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -80),
        Position = UDim2.new(0, 0, 0, 48),
        Parent = contentArea,
        ZIndex = 5,
        ClipsDescendants = false,
    })
    makePadding(pagesContainer, 16, 16, 16, 16)

    -- Footer / Status bar
    local footer = newFrame({
        Name = "Footer",
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.6,
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 1, -32),
        Parent = contentArea,
        ZIndex = 5,
    })
    makeStroke(footer, Color3.fromRGB(255,255,255), 1, 0.95)

    -- Footer left
    local footerLeft = newFrame({
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Parent = footer,
        ZIndex = 6,
    })

    -- Status indicator
    local statusDot = newFrame({
        BackgroundColor3 = Theme.Success,
        Size = UDim2.new(0, 5, 0, 5),
        Position = UDim2.new(0, 0, 0.5, -2.5),
        Parent = footerLeft,
        ZIndex = 7,
    })
    makeCorner(statusDot, 99)

    local statusLabel = newLabel({
        Text = "STATUS: INJECTED",
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Parent = footerLeft,
        ZIndex = 6,
    })
    _ = statusLabel

    local dividerDot = newLabel({
        Text = "·",
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        Size = UDim2.new(0, 6, 1, 0),
        Position = UDim2.new(0, 110, 0, 0),
        Parent = footerLeft,
        ZIndex = 6,
    })
    _ = dividerDot

    local buildLabel = newLabel({
        Text = "BUILD: V1.0.4A",
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(0, 122, 0, 0),
        Parent = footerLeft,
        ZIndex = 6,
    })
    _ = buildLabel

    -- Footer right (branding) — anchored to bottom-right of footer
    local footerBrand = newLabel({
        Text = string.upper(title),
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(1, -132, 0, 0),
        Parent = footer,
        ZIndex = 6,
    })
    footerBrand.TextXAlignment = Enum.TextXAlignment.Right

    -- Make header draggable
    makeDraggable(mainWindow, header)

    -- Toggle visibility keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            mainWindow.Visible = not mainWindow.Visible
        end
    end)

    -- Entry animation
    mainWindow.BackgroundTransparency = 1
    mainWindow.Size = UDim2.fromOffset(size.X.Offset * 0.95, size.Y.Offset * 0.95)
    mainWindow.Position = UDim2.new(0.5, -size.X.Offset * 0.475, 0.5, -size.Y.Offset * 0.475)

    task.defer(function()
        tween(mainWindow, Theme.Spring, {
            BackgroundTransparency = 0,
            Size = size,
            Position = position,
        })
    end)

    -- ── WINDOW OBJECT ──────────────────────────────────────
    local Window = {}
    Window._tabs           = {}
    Window._activeTab      = nil
    Window._navContainer   = navContainer
    Window._pagesContainer = pagesContainer
    Window._breadcrumb     = breadcrumbActive
    Window._lib            = self

    function Window:CreateTab(name, icon)
        local tabIndex = #self._tabs + 1

        -- Nav button
        local navBtn = newButton({
            Name = "NavBtn_" .. name,
            BackgroundColor3 = Color3.fromRGB(0,0,0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.TextFaint,
            Font = Enum.Font.GothamSemibold,
            TextSize = 12,
            Size = UDim2.new(1, -4, 0, 34),
            Parent = self._navContainer,
            ZIndex = 6,
        })
        makeCorner(navBtn, 6)

        -- Active indicator line
        local indicator = newFrame({
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 2, 0.5, 0),
            Position = UDim2.new(0, 0, 0.25, 0),
            Parent = navBtn,
            ZIndex = 8,
        })
        makeCorner(indicator, 1)

        -- Icon dot (default, always present for no-icon tabs)
        local iconDot = nil

        if icon and icon ~= "" then
            -- Image icon provided
            newImage({
                Image = icon,
                ImageColor3 = Theme.TextFaint,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, 12, 0.5, -7),
                Parent = navBtn,
                ZIndex = 8,
            })
        else
            -- Default minimal dot icon
            iconDot = newFrame({
                Name = "IconDot",
                BackgroundColor3 = Theme.TextFaint,
                Size = UDim2.new(0, 5, 0, 5),
                Position = UDim2.new(0, 14, 0.5, -2.5),
                Parent = navBtn,
                ZIndex = 8,
            })
            makeCorner(iconDot, 99)
        end

        local nameLabel = newLabel({
            Text = name,
            TextColor3 = Theme.TextDim,
            Font = Enum.Font.GothamSemibold,
            TextSize = 12,
            Size = UDim2.new(1, -36, 1, 0),
            Position = UDim2.new(0, 30, 0, 0),
            Parent = navBtn,
            ZIndex = 7,
        })

        -- Page content wrapped in a scrolling frame
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = "Page_" .. name
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollFrame.ScrollBarThickness = 3
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255,255,255)
        scrollFrame.ScrollBarImageTransparency = 0.85
        scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        scrollFrame.Visible = false
        scrollFrame.ZIndex = 5
        scrollFrame.Parent = self._pagesContainer
        makePadding(scrollFrame, 0, 0, 12, 0)

        -- Two-column container using UIListLayout
        local columnsFrame = newFrame({
            Name = "Columns",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = scrollFrame,
            ZIndex = 5,
        })
        columnsFrame.AutomaticSize = Enum.AutomaticSize.Y

        local columnsLayout = Instance.new("UIListLayout")
        columnsLayout.FillDirection = Enum.FillDirection.Horizontal
        columnsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        columnsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        columnsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        columnsLayout.Padding = UDim.new(0, 12)
        columnsLayout.Parent = columnsFrame

        -- Left column
        local leftCol = newFrame({
            Name = "LeftCol",
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -6, 0, 0),
            Parent = columnsFrame,
            ZIndex = 5,
        })
        leftCol.AutomaticSize = Enum.AutomaticSize.Y
        makeListLayout(leftCol, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 12)

        -- Right column
        local rightCol = newFrame({
            Name = "RightCol",
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -6, 0, 0),
            Parent = columnsFrame,
            ZIndex = 5,
        })
        rightCol.AutomaticSize = Enum.AutomaticSize.Y
        makeListLayout(rightCol, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 12)

        -- Tab object
        local Tab = {}
        Tab._page         = scrollFrame
        Tab._leftCol      = leftCol
        Tab._rightCol     = rightCol
        Tab._navBtn       = navBtn
        Tab._nameLabel    = nameLabel
        Tab._indicator    = indicator
        Tab._iconDot      = iconDot
        Tab._window       = self
        Tab._sectionOrder = 0

        function Tab:_setActive(active)
            if active then
                tween(navBtn, Theme.Fast, {
                    BackgroundColor3 = Theme.AccentBG,
                    BackgroundTransparency = 0,
                })
                tween(nameLabel, Theme.Fast, { TextColor3 = Theme.Accent })
                tween(indicator, Theme.Fast, { BackgroundTransparency = 0 })
                if iconDot then
                    tween(iconDot, Theme.Fast, { BackgroundColor3 = Theme.Accent })
                end
                self._page.Visible = true
            else
                tween(navBtn, Theme.Fast, {
                    BackgroundColor3 = Color3.fromRGB(0,0,0),
                    BackgroundTransparency = 1,
                })
                tween(nameLabel, Theme.Fast, { TextColor3 = Theme.TextDim })
                tween(indicator, Theme.Fast, { BackgroundTransparency = 1 })
                if iconDot then
                    tween(iconDot, Theme.Fast, { BackgroundColor3 = Theme.TextFaint })
                end
                self._page.Visible = false
            end
        end

        navBtn.MouseButton1Click:Connect(function()
            if self._activeTab then
                self._activeTab:_setActive(false)
            end
            self._activeTab = Tab
            Tab:_setActive(true)
            self._breadcrumb.Text = name
        end)

        navBtn.MouseEnter:Connect(function()
            if self._activeTab ~= Tab then
                tween(navBtn, Theme.Fast, {
                    BackgroundColor3 = Theme.BG_ElementHov,
                    BackgroundTransparency = 0,
                })
                tween(nameLabel, Theme.Fast, { TextColor3 = Color3.fromRGB(180,180,180) })
            end
        end)

        navBtn.MouseLeave:Connect(function()
            if self._activeTab ~= Tab then
                tween(navBtn, Theme.Fast, {
                    BackgroundTransparency = 1,
                })
                tween(nameLabel, Theme.Fast, { TextColor3 = Theme.TextDim })
            end
        end)

        table.insert(self._tabs, Tab)

        -- Auto select first tab
        if #self._tabs == 1 then
            task.defer(function()
                if self._activeTab then
                    self._activeTab:_setActive(false)
                end
                self._activeTab = Tab
                Tab:_setActive(true)
                self._breadcrumb.Text = name
            end)
        end

        -- ── CREATE SECTION ────────────────────────────────
        function Tab:CreateSection(title)
            Tab._sectionOrder = Tab._sectionOrder + 1

            -- Alternate between left and right column
            local targetCol = (Tab._sectionOrder % 2 == 1) and self._leftCol or self._rightCol

            local sectionWrap = newFrame({
                Name = "Section_" .. title,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                Parent = targetCol,
                ZIndex = 5,
            })
            sectionWrap.LayoutOrder = Tab._sectionOrder
            sectionWrap.AutomaticSize = Enum.AutomaticSize.Y

            local sectionInner = newFrame({
                BackgroundColor3 = Theme.BG_Element,
                BackgroundTransparency = 0,
                Size = UDim2.new(1, 0, 0, 0),
                Parent = sectionWrap,
                ZIndex = 6,
            })
            sectionInner.AutomaticSize = Enum.AutomaticSize.Y
            makeCorner(sectionInner, 8)
            makeStroke(sectionInner, Color3.fromRGB(255,255,255), 1, 0.93)
            makeListLayout(sectionInner, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 4)

            makePadding(sectionInner, 8, 8, 8, 8)

            -- Section header
            local sectionHeader = newFrame({
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Parent = sectionInner,
                ZIndex = 7,
            })
            makeListLayout(sectionHeader, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 10)

            local sectionTitle = newLabel({
                Text = string.upper(title),
                TextColor3 = Theme.TextFaint,
                Font = Enum.Font.GothamBold,
                TextSize = 9,
                Size = UDim2.new(1, 0, 1, 0),
                Parent = sectionHeader,
                ZIndex = 8,
            })

            -- Elements container
            local elemContainer = newFrame({
                Name = "Elements",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                Parent = sectionInner,
                ZIndex = 7,
            })
            elemContainer.AutomaticSize = Enum.AutomaticSize.Y
            makeListLayout(elemContainer, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 6)

            -- ── SECTION OBJECT ────────────────────────────
            local Section = {}
            Section._container = elemContainer
            Section._elemOrder = 0

            local function nextOrder()
                Section._elemOrder = Section._elemOrder + 1
                return Section._elemOrder
            end

            -- ── HELPER: Element card with entry animation ──
            local function makeCard(height)
                local card = newFrame({
                    BackgroundColor3 = Theme.BG_Element,
                    Size = UDim2.new(1, 0, 0, height or 45),
                    Parent = self._container,
                    ZIndex = 8,
                })
                card.LayoutOrder = nextOrder()
                makeCorner(card, 6)
                local cardStroke = makeStroke(card, Color3.fromRGB(255,255,255), 1, 0.9)

                -- Hover
                card.MouseEnter:Connect(function()
                    tween(card, Theme.Fast, { BackgroundColor3 = Theme.BG_ElementHov })
                end)
                card.MouseLeave:Connect(function()
                    tween(card, Theme.Fast, { BackgroundColor3 = Theme.BG_Element })
                end)

                return card, cardStroke
            end

            local function animateEntry(card, cardStroke, ...)
                card.BackgroundTransparency = 1
                cardStroke.Transparency = 1
                local labels = {...}
                for _, l in ipairs(labels) do
                    if l and l.TextTransparency ~= nil then
                        l.TextTransparency = 1
                    end
                end
                task.defer(function()
                    tween(card, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
                    tween(cardStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { Transparency = 0 })
                    for _, l in ipairs(labels) do
                        if l and l.TextTransparency ~= nil then
                            tween(l, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
                        end
                    end
                end)
            end

            -- ── TOGGLE ────────────────────────────────────
            function Section:CreateToggle(config)
                config = config or {}
                local label    = config.Label    or "Toggle"
                local desc     = config.Description
                local default  = config.Default  ~= nil and config.Default or false
                local callback = config.Callback or function() end

                local checked = default
                local cardH = desc and 55 or 45

                local card, cardStroke = makeCard(cardH)

                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = desc and UDim2.new(1, -70, 0, 20) or UDim2.new(1, -70, 1, 0),
                    Position = UDim2.new(0, 12, 0, desc and 8 or 0),
                    Parent = card,
                    ZIndex = 9,
                })

                if desc then
                    local descLbl = newLabel({
                        Text = desc,
                        TextColor3 = Theme.TextDim,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        Size = UDim2.new(1, -70, 0, 14),
                        Position = UDim2.new(0, 12, 0, 28),
                        Parent = card,
                        ZIndex = 9,
                    })
                    animateEntry(card, cardStroke, lbl, descLbl)
                else
                    animateEntry(card, cardStroke, lbl)
                end

                -- Switch frame
                local switchFrame = newFrame({
                    Size = UDim2.new(0, 40, 0, 22),
                    Position = UDim2.new(1, -54, 0.5, -11),
                    BackgroundColor3 = Color3.fromRGB(35, 35, 40),
                    Parent = card,
                    ZIndex = 9,
                })
                makeCorner(switchFrame, 11)
                local switchStroke = makeStroke(switchFrame, Color3.fromRGB(80, 80, 90), 1, 0.5)

                local indicator = newFrame({
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 3, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(150, 150, 160),
                    Parent = switchFrame,
                    ZIndex = 10,
                })
                makeCorner(indicator, 99)
                local indStroke = makeStroke(indicator, Color3.fromRGB(100, 100, 110), 1, 0.5)

                local interact = newButton({
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = card,
                    ZIndex = 12,
                })

                local function updateToggle(state)
                    if state then
                        tween(indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(1, -19, 0.5, -8) })
                        tween(indicator, Theme.Medium, { BackgroundColor3 = Theme.Accent })
                        tween(indStroke, Theme.Medium, { Color = Theme.AccentDim })
                        tween(switchFrame, Theme.Medium, { BackgroundColor3 = Theme.AccentBG })
                        tween(switchStroke, Theme.Medium, { Color = Theme.AccentDim })
                    else
                        tween(indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(0, 3, 0.5, -8) })
                        tween(indicator, Theme.Medium, { BackgroundColor3 = Color3.fromRGB(150, 150, 160) })
                        tween(indStroke, Theme.Medium, { Color = Color3.fromRGB(100, 100, 110) })
                        tween(switchFrame, Theme.Medium, { BackgroundColor3 = Color3.fromRGB(35, 35, 40) })
                        tween(switchStroke, Theme.Medium, { Color = Color3.fromRGB(80, 80, 90) })
                    end
                end

                if checked then updateToggle(true) end

                interact.MouseButton1Click:Connect(function()
                    checked = not checked
                    updateToggle(checked)
                    pcall(callback, checked)
                end)

                local ToggleObj = {}
                function ToggleObj:Set(value) checked = value; updateToggle(value); pcall(callback, value) end
                function ToggleObj:Get() return checked end

                return ToggleObj
            end

            -- ── SLIDER ────────────────────────────────────
            function Section:CreateSlider(config)
                config = config or {}
                local label    = config.Label    or "Slider"
                local min      = config.Min      or 0
                local max      = config.Max      or 100
                local default  = config.Default  ~= nil and config.Default or min
                local suffix   = config.Suffix   or ""
                local callback = config.Callback or function() end

                local value = clamp(default, min, max)

                local card, cardStroke = makeCard(45)

                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(0, 0, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    Parent = card,
                    ZIndex = 9,
                })
                lbl.AutomaticSize = Enum.AutomaticSize.X

                local valueLabel = newLabel({
                    Text = tostring(value) .. suffix,
                    TextColor3 = Theme.Accent,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    Size = UDim2.new(0, 60, 1, 0),
                    Position = UDim2.new(1, -72, 0, 0),
                    Parent = card,
                    ZIndex = 9,
                })
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right

                animateEntry(card, cardStroke, lbl, valueLabel)

                -- Track bar
                local trackBG = newFrame({
                    BackgroundColor3 = Color3.fromRGB(40, 42, 48),
                    Size = UDim2.new(1, -24, 0, 5),
                    Position = UDim2.new(0, 12, 1, -14),
                    Parent = card,
                    ZIndex = 9,
                })
                makeCorner(trackBG, 99)

                local fillPct = (value - min) / math.max(max - min, 0.001)
                local trackFill = newFrame({
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(fillPct, 0, 1, 0),
                    Parent = trackBG,
                    ZIndex = 10,
                })
                makeCorner(trackFill, 99)

                -- Interact for dragging
                local trackInteract = newButton({
                    Size = UDim2.new(1, -24, 0, 20),
                    Position = UDim2.new(0, 12, 1, -22),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = card,
                    ZIndex = 11,
                })

                local draggingSlider = false
                local function updateSlider(inputX)
                    local pct = clamp((inputX - trackBG.AbsolutePosition.X) / trackBG.AbsoluteSize.X, 0, 1)
                    value = round(min + (max - min) * pct)
                    valueLabel.Text = tostring(value) .. suffix
                    tween(trackFill, Theme.Fast, { Size = UDim2.new(pct, 0, 1, 0) })
                    pcall(callback, value)
                end

                trackInteract.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = true
                        updateSlider(input.Position.X)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateSlider(input.Position.X)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = false
                    end
                end)

                local SliderObj = {}
                function SliderObj:Set(v)
                    value = clamp(v, min, max)
                    local pct = (value - min) / math.max(max - min, 0.001)
                    valueLabel.Text = tostring(value) .. suffix
                    tween(trackFill, Theme.Fast, { Size = UDim2.new(pct, 0, 1, 0) })
                    pcall(callback, value)
                end
                function SliderObj:Get() return value end

                return SliderObj
            end

            -- ── DROPDOWN ──────────────────────────────────
            function Section:CreateDropdown(config)
                config = config or {}
                local label    = config.Label    or "Dropdown"
                local options  = config.Options  or {}
                local default  = config.Default  or options[1]
                local callback = config.Callback or function() end

                local selected = default
                local isOpen   = false
                local closedH = 45
                local optH = 28
                local openH = closedH + math.min(#options, 5) * optH + 8

                local card, cardStroke = makeCard(closedH)
                card.ClipsDescendants = true

                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Theme.TextDim,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 11,
                    Size = UDim2.new(1, -50, 0, 16),
                    Position = UDim2.new(0, 12, 0, 6),
                    Parent = card,
                    ZIndex = 9,
                })

                local selLabel = newLabel({
                    Text = selected or "Select...",
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, -50, 0, 18),
                    Position = UDim2.new(0, 12, 0, 20),
                    Parent = card,
                    ZIndex = 9,
                })
                selLabel.TextTruncate = Enum.TextTruncate.AtEnd

                local chevron = newLabel({
                    Text = "v",
                    TextColor3 = Theme.TextDim,
                    Font = Enum.Font.GothamBold,
                    TextSize = 10,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -30, 0, 22),
                    Parent = card,
                    ZIndex = 9,
                })

                animateEntry(card, cardStroke, lbl, selLabel)

                -- Options list
                local listFrame = newFrame({
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, openH - closedH),
                    Position = UDim2.new(0, 0, 0, closedH),
                    Parent = card,
                    ZIndex = 9,
                })
                makePadding(listFrame, 0, 12, 4, 12)
                makeListLayout(listFrame, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 2)

                local optButtons = {}
                for i, opt in ipairs(options) do
                    local optBtn = newButton({
                        BackgroundColor3 = opt == selected and Theme.AccentBG or Color3.fromRGB(30, 32, 38),
                        BackgroundTransparency = 0,
                        Text = opt,
                        TextColor3 = opt == selected and Theme.Accent or Color3.fromRGB(160, 160, 170),
                        Font = Enum.Font.GothamSemibold,
                        TextSize = 12,
                        Size = UDim2.new(1, 0, 0, optH),
                        Parent = listFrame,
                        ZIndex = 10,
                    })
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    makeCorner(optBtn, 4)
                    makePadding(optBtn, 0, 8, 0, 8)
                    local optStroke = makeStroke(optBtn, Color3.fromRGB(255,255,255), 1, 0.92)
                    optStroke.Transparency = 1

                    optBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        selLabel.Text = opt
                        -- Update all option colors
                        for _, ob in ipairs(optButtons) do
                            if ob._optName == opt then
                                tween(ob, Theme.Fast, { BackgroundColor3 = Theme.AccentBG })
                                tween(ob, Theme.Fast, { TextColor3 = Theme.Accent })
                            else
                                tween(ob, Theme.Fast, { BackgroundColor3 = Color3.fromRGB(30, 32, 38) })
                                tween(ob, Theme.Fast, { TextColor3 = Color3.fromRGB(160, 160, 170) })
                            end
                        end
                        -- Close
                        isOpen = false
                        tween(card, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(1, 0, 0, closedH) })
                        tween(chevron, Theme.Fast, { Rotation = 0 })
                        pcall(callback, opt)
                    end)

                    optBtn.MouseEnter:Connect(function()
                        if optBtn._optName ~= selected then
                            tween(optBtn, Theme.Fast, { BackgroundColor3 = Color3.fromRGB(40, 42, 50) })
                        end
                    end)
                    optBtn.MouseLeave:Connect(function()
                        if optBtn._optName ~= selected then
                            tween(optBtn, Theme.Fast, { BackgroundColor3 = Color3.fromRGB(30, 32, 38) })
                        end
                    end)

                    optBtn._optName = opt
                    table.insert(optButtons, optBtn)
                end

                local interact = newButton({
                    Size = UDim2.new(1, 0, 0, closedH),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = card,
                    ZIndex = 11,
                })

                interact.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        tween(card, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(1, 0, 0, openH) })
                        tween(chevron, Theme.Fast, { Rotation = 180 })
                    else
                        tween(card, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(1, 0, 0, closedH) })
                        tween(chevron, Theme.Fast, { Rotation = 0 })
                    end
                end)

                local DropdownObj = {}
                function DropdownObj:Set(opt)
                    selected = opt
                    selLabel.Text = opt
                    for _, ob in ipairs(optButtons) do
                        if ob._optName == opt then
                            tween(ob, Theme.Fast, { BackgroundColor3 = Theme.AccentBG, TextColor3 = Theme.Accent })
                        else
                            tween(ob, Theme.Fast, { BackgroundColor3 = Color3.fromRGB(30, 32, 38), TextColor3 = Color3.fromRGB(160, 160, 170) })
                        end
                    end
                    pcall(callback, opt)
                end
                function DropdownObj:Get() return selected end
                function DropdownObj:Refresh(newOptions)
                    for _, ob in ipairs(optButtons) do ob:Destroy() end
                    optButtons = {}
                    for _, opt in ipairs(newOptions) do
                        local optBtn = newButton({
                            BackgroundColor3 = opt == selected and Theme.AccentBG or Color3.fromRGB(30, 32, 38),
                            BackgroundTransparency = 0,
                            Text = opt,
                            TextColor3 = opt == selected and Theme.Accent or Color3.fromRGB(160, 160, 170),
                            Font = Enum.Font.GothamSemibold,
                            TextSize = 12,
                            Size = UDim2.new(1, 0, 0, optH),
                            Parent = listFrame,
                            ZIndex = 10,
                        })
                        optBtn.TextXAlignment = Enum.TextXAlignment.Left
                        makeCorner(optBtn, 4)
                        makePadding(optBtn, 0, 8, 0, 8)
                        optBtn._optName = opt
                        table.insert(optButtons, optBtn)
                    end
                    openH = closedH + math.min(#newOptions, 5) * optH + 8
                end

                return DropdownObj
            end

            -- ── KEYBIND ───────────────────────────────────
            function Section:CreateKeybind(config)
                config = config or {}
                local label    = config.Label    or "Keybind"
                local default  = config.Default  or Enum.KeyCode.Unknown
                local callback = config.Callback or function() end

                local currentKey = default
                local isBinding  = false

                local card, cardStroke = makeCard(45)

                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, -100, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    Parent = card,
                    ZIndex = 9,
                })

                local keyBox = Instance.new("TextBox")
                keyBox.Name = "KeybindBox"
                keyBox.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
                keyBox.BackgroundTransparency = 0
                keyBox.BorderSizePixel = 0
                keyBox.Size = UDim2.new(0, 70, 0, 28)
                keyBox.Position = UDim2.new(1, -82, 0.5, -14)
                keyBox.Text = currentKey.Name
                keyBox.TextColor3 = Theme.TextDim
                keyBox.PlaceholderText = ""
                keyBox.Font = Enum.Font.GothamBold
                keyBox.TextSize = 11
                keyBox.TextXAlignment = Enum.TextXAlignment.Center
                keyBox.ClearTextOnFocus = false
                keyBox.Parent = card
                keyBox.ZIndex = 10
                makeCorner(keyBox, 4)
                local keyStroke = makeStroke(keyBox, Color3.fromRGB(255,255,255), 1, 0.9)

                animateEntry(card, cardStroke, lbl)

                keyBox.Focused:Connect(function()
                    isBinding = true
                    keyBox.Text = ""
                    tween(keyBox, Theme.Fast, { BackgroundColor3 = Theme.AccentBG, TextColor3 = Theme.Accent })
                    tween(keyStroke, Theme.Fast, { Color = Theme.AccentDim, Transparency = 0.4 })
                end)

                keyBox.FocusLost:Connect(function()
                    isBinding = false
                    if keyBox.Text == "" then
                        keyBox.Text = currentKey.Name
                    end
                    tween(keyBox, Theme.Fast, { BackgroundColor3 = Color3.fromRGB(30, 32, 38), TextColor3 = Theme.TextDim })
                    tween(keyStroke, Theme.Fast, { Color = Color3.fromRGB(255,255,255), Transparency = 0.9 })
                end)

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if isBinding and not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        keyBox.Text = currentKey.Name
                        keyBox:ReleaseFocus()
                        pcall(callback, currentKey)
                    end
                end)

                -- Auto-resize key box
                keyBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local textW = TextService:GetTextSize(keyBox.Text, 11, Enum.Font.GothamBold, Vector2.new(200, 28)).X
                    tween(keyBox, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, textW + 24, 0, 28) })
                end)

                local KeybindObj = {}
                function KeybindObj:Set(key) currentKey = key; keyBox.Text = key.Name; pcall(callback, key) end
                function KeybindObj:Get() return currentKey end

                return KeybindObj
            end

            -- ── BUTTON ────────────────────────────────────
            function Section:CreateButton(config)
                config = config or {}
                local label    = config.Label    or "Button"
                local variant  = config.Variant  or "primary"
                local callback = config.Callback or function() end

                local variantStyles = {
                    primary   = { bg = Theme.AccentBG,      bgH = Theme.AccentBGHov,    text = Theme.Accent,  border = Theme.AccentDim },
                    secondary = { bg = Color3.fromRGB(30,32,38), bgH = Color3.fromRGB(40,42,50), text = Color3.fromRGB(180,180,190), border = Color3.fromRGB(60,62,70) },
                    danger    = { bg = Color3.fromRGB(40,12,12),  bgH = Color3.fromRGB(55,16,16), text = Theme.Danger,  border = Color3.fromRGB(120,40,40) },
                }
                local style = variantStyles[variant] or variantStyles.primary

                local card, cardStroke = makeCard(45)
                card.BackgroundColor3 = style.bg
                cardStroke.Color = style.border
                cardStroke.Transparency = 0.5

                local lbl = newLabel({
                    Text = string.upper(label),
                    TextColor3 = style.text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = card,
                    ZIndex = 9,
                })
                lbl.TextXAlignment = Enum.TextXAlignment.Center

                animateEntry(card, cardStroke, lbl)

                local interact = newButton({
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = card,
                    ZIndex = 11,
                })

                interact.MouseButton1Click:Connect(function()
                    -- Flash animation (Rayfield-style)
                    tween(card, Theme.Fast, { BackgroundColor3 = style.bgH })
                    tween(cardStroke, Theme.Fast, { Transparency = 1 })
                    tween(lbl, Theme.Fast, { TextTransparency = 0.3 })
                    task.delay(0.2, function()
                        tween(card, Theme.Fast, { BackgroundColor3 = style.bg })
                        tween(cardStroke, Theme.Fast, { Transparency = 0.5 })
                        tween(lbl, Theme.Fast, { TextTransparency = 0 })
                    end)
                    pcall(callback)
                end)

                interact.MouseEnter:Connect(function()
                    tween(card, Theme.Fast, { BackgroundColor3 = style.bgH })
                end)
                interact.MouseLeave:Connect(function()
                    tween(card, Theme.Fast, { BackgroundColor3 = style.bg })
                end)

                local BtnObj = {}
                function BtnObj:SetLabel(text) lbl.Text = string.upper(text) end

                return BtnObj
            end

            -- ── COLOR PICKER ──────────────────────────────
            function Section:CreateColorPicker(config)
                config = config or {}
                local label    = config.Label    or "Color"
                local default  = config.Default  or Color3.fromRGB(76, 201, 240)
                local callback = config.Callback or function() end

                local currentColor = default
                local pickerOpen   = false
                local closedH = 45
                local openH = 130

                local card, cardStroke = makeCard(closedH)
                card.ClipsDescendants = true

                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, -100, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    Parent = card,
                    ZIndex = 9,
                })

                local hexLabel = newLabel({
                    Text = colorToHex(currentColor),
                    TextColor3 = Theme.TextDim,
                    Font = Enum.Font.GothamBold,
                    TextSize = 9,
                    Size = UDim2.new(0, 50, 1, 0),
                    Position = UDim2.new(1, -90, 0, 0),
                    Parent = card,
                    ZIndex = 9,
                })

                local swatch = newButton({
                    BackgroundColor3 = currentColor,
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(1, -36, 0.5, -12),
                    Parent = card,
                    ZIndex = 9,
                })
                makeCorner(swatch, 4)
                makeStroke(swatch, Color3.fromRGB(255,255,255), 1, 0.85)

                animateEntry(card, cardStroke, lbl)

                -- Picker panel (inside card, below header area)
                local pickerPanel = newFrame({
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, openH - closedH),
                    Position = UDim2.new(0, 0, 0, closedH),
                    Parent = card,
                    ZIndex = 9,
                })
                makePadding(pickerPanel, 4, 12, 4, 12)
                makeListLayout(pickerPanel, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 6)

                local channels = {
                    { name = "R", color = Color3.fromRGB(220,70,70),  getter = function(c) return math.floor(c.R*255) end, setter = function(c,v) return Color3.fromRGB(v, math.floor(c.G*255), math.floor(c.B*255)) end },
                    { name = "G", color = Color3.fromRGB(70,200,80),  getter = function(c) return math.floor(c.G*255) end, setter = function(c,v) return Color3.fromRGB(math.floor(c.R*255), v, math.floor(c.B*255)) end },
                    { name = "B", color = Color3.fromRGB(70,120,220), getter = function(c) return math.floor(c.B*255) end, setter = function(c,v) return Color3.fromRGB(math.floor(c.R*255), math.floor(c.G*255), v) end },
                }

                local channelSliders = {}

                for _, ch in ipairs(channels) do
                    local chRow = newFrame({
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 18),
                        Parent = pickerPanel,
                        ZIndex = 10,
                    })
                    makeListLayout(chRow, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 6)

                    newLabel({
                        Text = ch.name,
                        TextColor3 = ch.color,
                        Font = Enum.Font.GothamBold,
                        TextSize = 10,
                        Size = UDim2.new(0, 10, 1, 0),
                        Parent = chRow,
                        ZIndex = 11,
                    })

                    local chTrack = newFrame({
                        BackgroundColor3 = Color3.fromRGB(40, 42, 48),
                        Size = UDim2.new(1, -60, 0, 5),
                        Parent = chRow,
                        ZIndex = 11,
                    })
                    makeCorner(chTrack, 99)

                    local fillPct = ch.getter(currentColor) / 255
                    local chFill = newFrame({
                        BackgroundColor3 = ch.color,
                        Size = UDim2.new(fillPct, 0, 1, 0),
                        Parent = chTrack,
                        ZIndex = 12,
                    })
                    makeCorner(chFill, 99)

                    local valLbl = newLabel({
                        Text = tostring(ch.getter(currentColor)),
                        TextColor3 = Theme.TextDim,
                        Font = Enum.Font.GothamBold,
                        TextSize = 9,
                        Size = UDim2.new(0, 30, 1, 0),
                        Parent = chRow,
                        ZIndex = 11,
                    })
                    valLbl.TextXAlignment = Enum.TextXAlignment.Right

                    -- Drag logic
                    local draggingCh = false
                    chTrack.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingCh = true
                            local pct = clamp((input.Position.X - chTrack.AbsolutePosition.X) / chTrack.AbsoluteSize.X, 0, 1)
                            local v = math.floor(pct * 255)
                            valLbl.Text = tostring(v)
                            tween(chFill, Theme.Fast, { Size = UDim2.new(pct, 0, 1, 0) })
                            currentColor = ch.setter(currentColor, v)
                            tween(swatch, Theme.Fast, { BackgroundColor3 = currentColor })
                            hexLabel.Text = colorToHex(currentColor)
                            pcall(callback, currentColor)
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if draggingCh and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            local pct = clamp((input.Position.X - chTrack.AbsolutePosition.X) / chTrack.AbsoluteSize.X, 0, 1)
                            local v = math.floor(pct * 255)
                            valLbl.Text = tostring(v)
                            tween(chFill, Theme.Fast, { Size = UDim2.new(pct, 0, 1, 0) })
                            currentColor = ch.setter(currentColor, v)
                            tween(swatch, Theme.Fast, { BackgroundColor3 = currentColor })
                            hexLabel.Text = colorToHex(currentColor)
                            pcall(callback, currentColor)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingCh = false
                        end
                    end)

                    table.insert(channelSliders, { fill = chFill, valLbl = valLbl, ch = ch })
                end

                swatch.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    if pickerOpen then
                        -- Update sliders
                        for _, cs in ipairs(channelSliders) do
                            local v = cs.ch.getter(currentColor)
                            cs.valLbl.Text = tostring(v)
                            tween(cs.fill, Theme.Fast, { Size = UDim2.new(v/255, 0, 1, 0) })
                        end
                        tween(card, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(1, 0, 0, openH) })
                    else
                        tween(card, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(1, 0, 0, closedH) })
                    end
                end)

                local ColorObj = {}
                function ColorObj:Set(color)
                    currentColor = color
                    tween(swatch, Theme.Fast, { BackgroundColor3 = color })
                    hexLabel.Text = colorToHex(color)
                    pcall(callback, color)
                end
                function ColorObj:Get() return currentColor end

                return ColorObj
            end

            -- ── TEXT FIELD / INPUT ────────────────────────
            function Section:CreateTextField(config)
                config = config or {}
                local label       = config.Label       or "Input"
                local placeholder = config.Placeholder or ""
                local default     = config.Default     or ""
                local callback    = config.Callback    or function() end

                local card, cardStroke = makeCard(45)

                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(0, 0, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    Parent = card,
                    ZIndex = 9,
                })
                lbl.AutomaticSize = Enum.AutomaticSize.X

                local inputBox = Instance.new("TextBox")
                inputBox.Name = "InputBox"
                inputBox.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
                inputBox.BackgroundTransparency = 0
                inputBox.BorderSizePixel = 0
                inputBox.Size = UDim2.new(0, 100, 0, 28)
                inputBox.Position = UDim2.new(1, -112, 0.5, -14)
                inputBox.Text = default
                inputBox.PlaceholderText = placeholder
                inputBox.TextColor3 = Color3.fromRGB(180, 180, 190)
                inputBox.PlaceholderColor3 = Theme.TextFaint
                inputBox.Font = Enum.Font.GothamSemibold
                inputBox.TextSize = 11
                inputBox.TextXAlignment = Enum.TextXAlignment.Left
                inputBox.ClearTextOnFocus = false
                inputBox.Parent = card
                inputBox.ZIndex = 10
                makeCorner(inputBox, 4)
                local inputStroke = makeStroke(inputBox, Color3.fromRGB(255,255,255), 1, 0.9)
                makePadding(inputBox, 0, 6, 0, 6)

                animateEntry(card, cardStroke, lbl)

                -- Auto-resize
                inputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local textW = TextService:GetTextSize(inputBox.Text, 11, Enum.Font.GothamSemibold, Vector2.new(500, 28)).X
                    local newW = math.max(textW + 24, 60)
                    tween(inputBox, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, newW, 0, 28) })
                end)

                inputBox.Focused:Connect(function()
                    tween(inputBox, Theme.Fast, { BackgroundColor3 = Color3.fromRGB(38, 40, 48) })
                    tween(inputStroke, Theme.Fast, { Color = Theme.AccentDim, Transparency = 0.4 })
                end)

                inputBox.FocusLost:Connect(function(enterPressed)
                    tween(inputBox, Theme.Fast, { BackgroundColor3 = Color3.fromRGB(30, 32, 38) })
                    tween(inputStroke, Theme.Fast, { Color = Color3.fromRGB(255,255,255), Transparency = 0.9 })
                    if enterPressed then
                        pcall(callback, inputBox.Text)
                    end
                end)

                local TFObj = {}
                function TFObj:Set(text) inputBox.Text = text; pcall(callback, text) end
                function TFObj:Get() return inputBox.Text end

                return TFObj
            end

            -- ── LABEL ─────────────────────────────────────
            function Section:CreateLabel(config)
                config = config or {}
                local text  = config.Text  or ""
                local color = config.Color

                local card, cardStroke = makeCard(32)

                local lbl = newLabel({
                    Text = text,
                    TextColor3 = color or Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    Parent = card,
                    ZIndex = 9,
                })
                lbl.TextWrapped = true

                if color then
                    card.BackgroundColor3 = color
                    card.BackgroundTransparency = 0.85
                    cardStroke.Color = color
                    cardStroke.Transparency = 0.7
                end

                animateEntry(card, cardStroke, lbl)

                local LabelObj = {}
                function LabelObj:Set(newText) lbl.Text = newText end

                return LabelObj
            end

            -- ── PARAGRAPH ─────────────────────────────────
            function Section:CreateParagraph(config)
                config = config or {}
                local title   = config.Title   or "Paragraph"
                local content = config.Content or ""

                local card, cardStroke = makeCard(60)
                card.AutomaticSize = Enum.AutomaticSize.Y

                local titleLbl = newLabel({
                    Text = title,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    Size = UDim2.new(1, -24, 0, 20),
                    Position = UDim2.new(0, 12, 0, 6),
                    Parent = card,
                    ZIndex = 9,
                })

                local contentLbl = newLabel({
                    Text = content,
                    TextColor3 = Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    Size = UDim2.new(1, -24, 0, 0),
                    Position = UDim2.new(0, 12, 0, 26),
                    Parent = card,
                    ZIndex = 9,
                })
                contentLbl.AutomaticSize = Enum.AutomaticSize.Y
                contentLbl.TextWrapped = true

                if color then
                    card.BackgroundColor3 = color or Theme.BG_Element
                    cardStroke.Color = color or Color3.fromRGB(255,255,255)
                end

                animateEntry(card, cardStroke, titleLbl, contentLbl)

                local ParagraphObj = {}
                function ParagraphObj:Set(newConfig)
                    titleLbl.Text = newConfig.Title or title
                    contentLbl.Text = newConfig.Content or content
                end

                return ParagraphObj
            end

            return Section
        end -- CreateSection

        return Tab
    end -- CreateTab

    -- ── WINDOW LEVEL METHODS ──────────────────────────────
    function Window:SetStatus(text, color)
        statusLabel.Text = "STATUS: " .. string.upper(text)
        if color then
            tween(statusDot, Theme.Fast, { BackgroundColor3 = color })
        end
    end

    function Window:Show()
        mainWindow.Visible = true
        tween(mainWindow, Theme.Spring, {
            Size = size,
            BackgroundTransparency = 0,
        })
    end

    function Window:Hide()
        tween(mainWindow, Theme.Medium, {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(size.X.Offset * 0.95, size.Y.Offset * 0.95),
        })
        task.delay(0.3, function() mainWindow.Visible = false end)
    end

    function Window:Destroy()
        screenGui:Destroy()
    end

    table.insert(FriendshipLib._windows, Window)
    return Window
end -- CreateWindow

-- ============================================================
--  LIBRARY LEVEL METHODS
-- ============================================================
function FriendshipLib:DestroyAll()
    for _, w in ipairs(self._windows) do
        pcall(function() w:Destroy() end)
    end
    self._windows = {}
end

-- ============================================================
--  RETURN LIBRARY
-- ============================================================

-- Support both require() and direct execution:
--   require()      -> returns FriendshipLib directly
--   Direct exec    -> sets _G.FriendshipLib for later use
--   loadstring()() -> returns FriendshipLib directly

if rawget(_G, "FriendshipLib") then
    -- Already loaded, update the global reference
    _G.FriendshipLib = FriendshipLib
else
    _G.FriendshipLib = FriendshipLib
end

return FriendshipLib
