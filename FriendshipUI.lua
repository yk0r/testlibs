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
                    Parent = Section._container,
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
            -- Strictly aligned with Rayfield CreateToggle logic
            function Section:CreateToggle(config)
                config = config or {}
                local label       = config.Label       or "Toggle"
                local desc        = config.Description
                local default     = config.CurrentValue
                if default == nil then default = config.Default end
                if default == nil then default = false end
                local callback    = config.Callback    or function() end

                local currentValue = default
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

                local descLbl = nil
                if desc then
                    descLbl = newLabel({
                        Text = desc,
                        TextColor3 = Theme.TextDim,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        Size = UDim2.new(1, -70, 0, 14),
                        Position = UDim2.new(0, 12, 0, 28),
                        Parent = card,
                        ZIndex = 9,
                    })
                end

                animateEntry(card, cardStroke, lbl, descLbl)

                -- Switch frame (Rayfield-style: outer frame + indicator that slides)
                local switchFrame = newFrame({
                    Size = UDim2.new(0, 40, 0, 22),
                    Position = UDim2.new(1, -54, 0.5, -11),
                    BackgroundColor3 = Theme.ToggleBackground or Color3.fromRGB(35, 35, 40),
                    Parent = card,
                    ZIndex = 9,
                })
                makeCorner(switchFrame, 11)
                local switchStroke = makeStroke(switchFrame, Color3.fromRGB(80, 80, 90), 1, 0.5)

                -- Indicator (Rayfield: slides between Position UDim2.new(1,-40,0.5,0) and UDim2.new(1,-20,0.5,0))
                local indicator = newFrame({
                    Size = UDim2.new(0, 17, 0, 17),
                    BackgroundColor3 = Theme.ToggleDisabled or Color3.fromRGB(150, 150, 160),
                    Parent = switchFrame,
                    ZIndex = 10,
                })
                makeCorner(indicator, 99)
                local indStroke = makeStroke(indicator, Color3.fromRGB(100, 100, 110), 1, 0.5)

                -- Rayfield-style initial state: disabled = right-40, enabled = right-20
                local function setToggleVisual(enabled, animated)
                    local info = animated and TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) or TweenInfo.new(0)
                    if enabled then
                        tween(indicator, info, { Position = UDim2.new(1, -20, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
                        tween(indicator, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { BackgroundColor3 = Theme.ToggleEnabled or Theme.Accent })
                        tween(indStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Color = Theme.ToggleEnabledStroke or Theme.AccentDim })
                        tween(switchStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Color = Theme.ToggleEnabledOuterStroke or Theme.AccentDim })
                    else
                        tween(indicator, info, { Position = UDim2.new(1, -40, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
                        tween(indicator, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { BackgroundColor3 = Theme.ToggleDisabled or Color3.fromRGB(150, 150, 160) })
                        tween(indStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Color = Theme.ToggleDisabledStroke or Color3.fromRGB(100, 100, 110) })
                        tween(switchStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Color = Theme.ToggleDisabledOuterStroke or Color3.fromRGB(80, 80, 90) })
                    end
                end

                -- Set initial position without animation
                if currentValue then
                    indicator.Position = UDim2.new(1, -20, 0.5, 0)
                    indicator.AnchorPoint = Vector2.new(0, 0.5)
                    indicator.BackgroundColor3 = Theme.ToggleEnabled or Theme.Accent
                    indStroke.Color = Theme.ToggleEnabledStroke or Theme.AccentDim
                    switchStroke.Color = Theme.ToggleEnabledOuterStroke or Theme.AccentDim
                else
                    indicator.Position = UDim2.new(1, -40, 0.5, 0)
                    indicator.AnchorPoint = Vector2.new(0, 0.5)
                end

                -- Rayfield-style click: flash bg + stroke, then toggle, then restore
                local interact = newButton({
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = card,
                    ZIndex = 12,
                })

                interact.MouseButton1Click:Connect(function()
                    currentValue = not currentValue
                    -- Rayfield: flash hover then restore
                    tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_ElementHov })
                    tween(cardStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 1 })

                    setToggleVisual(currentValue, true)

                    task.defer(function()
                        task.wait(0.3)
                        tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_Element })
                        tween(cardStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 0 })
                    end)

                    pcall(callback, currentValue)
                end)

                local ToggleObj = {}
                function ToggleObj:Set(newValue)
                    currentValue = newValue
                    -- Rayfield-style :Set with size bounce (12→17 indicator)
                    tween(indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0, 12, 0, 12) })
                    tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_ElementHov })
                    tween(cardStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 1 })

                    setToggleVisual(currentValue, true)

                    task.defer(function()
                        task.wait(0.1)
                        tween(indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0, 17, 0, 17) })
                        task.wait(0.3)
                        tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_Element })
                        tween(cardStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 0 })
                    end)

                    pcall(callback, currentValue)
                end
                function ToggleObj:Get() return currentValue end

                return ToggleObj
            end

            -- ── SLIDER ────────────────────────────────────
            -- Strictly aligned with Rayfield CreateSlider logic (RunService.Stepped dragging)
            function Section:CreateSlider(config)
                config = config or {}
                local label       = config.Label       or "Slider"
                local range       = config.Range       or {config.Min or 0, config.Max or 100}
                local min         = range[1]
                local max         = range[2]
                local default     = config.CurrentValue
                if default == nil then default = config.Default end
                if default == nil then default = min end
                local suffix      = config.Suffix      or ""
                local increment   = config.Increment   or 1
                local callback    = config.Callback     or function() end

                local currentValue = clamp(default, min, max)

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
                    Text = tostring(currentValue) .. (suffix ~= "" and " " .. suffix or ""),
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

                -- Slider track (Rayfield-style: Main frame with Progress child)
                local sliderMain = newFrame({
                    BackgroundColor3 = Theme.SliderBackground or Color3.fromRGB(40, 42, 48),
                    Size = UDim2.new(1, -24, 0, 5),
                    Position = UDim2.new(0, 12, 1, -14),
                    Parent = card,
                    ZIndex = 9,
                })
                makeCorner(sliderMain, 99)
                local sliderMainStroke = makeStroke(sliderMain, Theme.SliderStroke or Color3.fromRGB(60, 62, 68), 1, 0.4)

                local progressWidth = sliderMain.AbsoluteSize.X * ((currentValue - min) / math.max(max - min, 0.001))
                if progressWidth < 5 then progressWidth = 5 end

                local sliderProgress = newFrame({
                    BackgroundColor3 = Theme.SliderProgress or Theme.Accent,
                    Size = UDim2.new(0, progressWidth, 1, 0),
                    Parent = sliderMain,
                    ZIndex = 10,
                })
                makeCorner(sliderProgress, 99)
                local sliderProgressStroke = makeStroke(sliderProgress, Theme.SliderStroke or Color3.fromRGB(60, 62, 68), 1, 0.3)

                -- Rayfield-style: Interact button for dragging
                local sliderInteract = newButton({
                    Size = UDim2.new(1, -24, 0, 20),
                    Position = UDim2.new(0, 12, 1, -22),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = card,
                    ZIndex = 11,
                })

                local SLDragging = false

                -- Rayfield logic: InputBegan starts drag + hides strokes
                sliderInteract.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        tween(sliderMainStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 1 })
                        tween(sliderProgressStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 1 })
                        SLDragging = true
                    end
                end)

                -- Rayfield logic: InputEnded stops drag + restores strokes
                sliderInteract.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        tween(sliderMainStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 0.4 })
                        tween(sliderProgressStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 0.3 })
                        SLDragging = false
                    end
                end)

                -- Rayfield logic: MouseButton1Down starts Stepped loop
                sliderInteract.MouseButton1Down:Connect(function()
                    local Current = sliderProgress.AbsolutePosition.X + sliderProgress.AbsoluteSize.X
                    local Start = Current
                    local Location = UserInputService:GetMouseLocation().X

                    local Loop
                    Loop = RunService.Stepped:Connect(function()
                        if SLDragging then
                            Location = UserInputService:GetMouseLocation().X
                            Current = Current + 0.025 * (Location - Start)

                            if Location < sliderMain.AbsolutePosition.X then
                                Location = sliderMain.AbsolutePosition.X
                            elseif Location > sliderMain.AbsolutePosition.X + sliderMain.AbsoluteSize.X then
                                Location = sliderMain.AbsolutePosition.X + sliderMain.AbsoluteSize.X
                            end

                            if Current < sliderMain.AbsolutePosition.X + 5 then
                                Current = sliderMain.AbsolutePosition.X + 5
                            elseif Current > sliderMain.AbsolutePosition.X + sliderMain.AbsoluteSize.X then
                                Current = sliderMain.AbsolutePosition.X + sliderMain.AbsoluteSize.X
                            end

                            if Current <= Location and (Location - Start) < 0 then
                                Start = Location
                            elseif Current >= Location and (Location - Start) > 0 then
                                Start = Location
                            end

                            tween(sliderProgress, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                                Size = UDim2.new(0, Current - sliderMain.AbsolutePosition.X, 1, 0)
                            })

                            local NewValue = min + (Location - sliderMain.AbsolutePosition.X) / sliderMain.AbsoluteSize.X * (max - min)
                            -- Rayfield increment rounding
                            NewValue = math.floor(NewValue / increment + 0.5) * (increment * 10000000) / 10000000
                            NewValue = math.clamp(NewValue, min, max)

                            valueLabel.Text = tostring(NewValue) .. (suffix ~= "" and " " .. suffix or "")

                            if currentValue ~= NewValue then
                                pcall(callback, NewValue)
                                currentValue = NewValue
                            end
                        else
                            -- Rayfield: snap to final position when released
                            local finalPos = Location - sliderMain.AbsolutePosition.X
                            if finalPos < 5 then finalPos = 5 end
                            tween(sliderProgress, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                                Size = UDim2.new(0, finalPos, 1, 0)
                            })
                            Loop:Disconnect()
                        end
                    end)
                end)

                local SliderObj = {}
                function SliderObj:Set(newVal)
                    newVal = math.clamp(newVal, min, max)
                    local pct = (newVal - min) / math.max(max - min, 0.001)
                    local newW = sliderMain.AbsoluteSize.X * pct
                    if newW < 5 then newW = 5 end
                    tween(sliderProgress, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, newW, 1, 0)
                    })
                    valueLabel.Text = tostring(newVal) .. (suffix ~= "" and " " .. suffix or "")
                    pcall(callback, newVal)
                    currentValue = newVal
                end
                function SliderObj:Get() return currentValue end

                return SliderObj
            end

            -- ── DROPDOWN ──────────────────────────────────
            -- Strictly aligned with Rayfield CreateDropdown logic (debounce, animated open/close, MultiOption support)
            function Section:CreateDropdown(config)
                config = config or {}
                local label           = config.Name or config.Label or "Dropdown"
                local options         = config.Options or {}
                local multipleOptions = config.MultipleOptions or false
                local callback        = config.Callback or function() end

                -- Rayfield-style CurrentOption as table
                local currentOption = config.CurrentOption or config.Default
                if currentOption == nil then
                    currentOption = options[1]
                end
                if type(currentOption) == "string" then
                    currentOption = {currentOption}
                end
                if not multipleOptions and type(currentOption) == "table" then
                    currentOption = {currentOption[1]}
                end
                if currentOption == nil then currentOption = {} end

                local closedH = 45
                local Debounce = false

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

                -- Rayfield-style Selected text
                local selLabel = newLabel({
                    Text = "None",
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, -50, 0, 18),
                    Position = UDim2.new(0, 12, 0, 20),
                    Parent = card,
                    ZIndex = 9,
                })
                selLabel.TextTruncate = Enum.TextTruncate.AtEnd

                -- Rayfield logic for display text
                local function updateSelectedText()
                    if multipleOptions then
                        if #currentOption == 1 then
                            selLabel.Text = currentOption[1]
                        elseif #currentOption == 0 then
                            selLabel.Text = "None"
                        else
                            selLabel.Text = "Various"
                        end
                    else
                        selLabel.Text = currentOption[1] or "None"
                    end
                end
                updateSelectedText()

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

                -- Options list (Rayfield-style: ScrollingFrame with option frames)
                local listFrame = Instance.new("ScrollingFrame")
                listFrame.Name = "List"
                listFrame.BackgroundTransparency = 1
                listFrame.Size = UDim2.new(1, 0, 0, 130)
                listFrame.Position = UDim2.new(0, 0, 0, closedH)
                listFrame.BorderSizePixel = 0
                listFrame.ScrollBarThickness = 2
                listFrame.ScrollBarImageTransparency = 0.7
                listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
                listFrame.Visible = false
                listFrame.Parent = card
                listFrame.ZIndex = 9
                makePadding(listFrame, 0, 10, 2, 10)
                makeListLayout(listFrame, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 2)

                local DropdownUnselected = Color3.fromRGB(30, 32, 38)
                local DropdownSelected = Theme.AccentBG

                -- Rayfield-style SetDropdownOptions function
                local function SetDropdownOptions()
                    for _, Option in ipairs(options) do
                        local optFrame = newFrame({
                            Name = Option,
                            BackgroundColor3 = table.find(currentOption, Option) and DropdownSelected or DropdownUnselected,
                            BackgroundTransparency = 0,
                            Size = UDim2.new(1, 0, 0, 28),
                            Parent = listFrame,
                            ZIndex = 10,
                        })
                        makeCorner(optFrame, 4)
                        local optStroke = makeStroke(optFrame, Color3.fromRGB(255,255,255), 1, 0.9)

                        local optTitle = newLabel({
                            Text = Option,
                            TextColor3 = table.find(currentOption, Option) and Theme.Accent or Color3.fromRGB(160, 160, 170),
                            Font = Enum.Font.GothamSemibold,
                            TextSize = 12,
                            Size = UDim2.new(1, -16, 1, 0),
                            Position = UDim2.new(0, 8, 0, 0),
                            Parent = optFrame,
                            ZIndex = 11,
                        })
                        optTitle.TextXAlignment = Enum.TextXAlignment.Left

                        local optInteract = newButton({
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = "",
                            Parent = optFrame,
                            ZIndex = 50,
                        })

                        optInteract.MouseButton1Click:Connect(function()
                            -- Rayfield: if already selected and single-select, return
                            if not multipleOptions and table.find(currentOption, Option) then
                                return
                            end

                            -- Rayfield: toggle selection
                            if table.find(currentOption, Option) then
                                table.remove(currentOption, table.find(currentOption, Option))
                            else
                                if not multipleOptions then
                                    table.clear(currentOption)
                                end
                                table.insert(currentOption, Option)
                                tween(optStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { Transparency = 1 })
                                tween(optFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { BackgroundColor3 = DropdownSelected })
                                Debounce = true
                            end

                            updateSelectedText()
                            pcall(callback, currentOption)

                            -- Rayfield: update all option colors
                            for _, droption in ipairs(listFrame:GetChildren()) do
                                if droption:IsA("Frame") and droption.Name ~= "Placeholder" then
                                    if not table.find(currentOption, droption.Name) then
                                        tween(droption, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { BackgroundColor3 = DropdownUnselected })
                                    end
                                end
                            end

                            -- Rayfield: if single-select, auto-close after selection
                            if not multipleOptions then
                                task.wait(0.1)
                                tween(card, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(1, 0, 0, closedH) })
                                for _, DropdownOpt in ipairs(listFrame:GetChildren()) do
                                    if DropdownOpt:IsA("Frame") and DropdownOpt.Name ~= "Placeholder" then
                                        tween(DropdownOpt, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 })
                                        local s = DropdownOpt:FindFirstChildOfClass("UIStroke")
                                        if s then tween(s, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { Transparency = 1 }) end
                                        local t = DropdownOpt:FindFirstChildOfClass("TextLabel")
                                        if t then tween(t, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { TextTransparency = 1 }) end
                                    end
                                end
                                tween(listFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { ScrollBarImageTransparency = 1 })
                                tween(chevron, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { Rotation = 180 })
                                task.wait(0.35)
                                listFrame.Visible = false
                            end
                            Debounce = false
                        end)
                    end
                end
                SetDropdownOptions()

                -- Rayfield-style Interact for open/close toggle
                local interact = newButton({
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = card,
                    ZIndex = 11,
                })

                -- Rayfield: initial chevron rotation (closed = 180)
                chevron.Rotation = 180

                interact.MouseButton1Click:Connect(function()
                    -- Rayfield: flash animation
                    tween(card, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_ElementHov })
                    tween(cardStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { Transparency = 1 })
                    task.wait(0.1)
                    tween(card, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_Element })
                    tween(cardStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { Transparency = 0 })

                    if Debounce then return end

                    if listFrame.Visible then
                        -- Close
                        Debounce = true
                        tween(card, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(1, 0, 0, closedH) })
                        for _, DropdownOpt in ipairs(listFrame:GetChildren()) do
                            if DropdownOpt:IsA("Frame") and DropdownOpt.Name ~= "Placeholder" then
                                tween(DropdownOpt, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 })
                                local s = DropdownOpt:FindFirstChildOfClass("UIStroke")
                                if s then tween(s, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { Transparency = 1 }) end
                                local t = DropdownOpt:FindFirstChildOfClass("TextLabel")
                                if t then tween(t, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { TextTransparency = 1 }) end
                            end
                        end
                        tween(listFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { ScrollBarImageTransparency = 1 })
                        tween(chevron, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { Rotation = 180 })
                        task.wait(0.35)
                        listFrame.Visible = false
                        Debounce = false
                    else
                        -- Open
                        tween(card, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), { Size = UDim2.new(1, 0, 0, 180) })
                        listFrame.Visible = true
                        tween(listFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { ScrollBarImageTransparency = 0.7 })
                        tween(chevron, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { Rotation = 0 })
                        for _, DropdownOpt in ipairs(listFrame:GetChildren()) do
                            if DropdownOpt:IsA("Frame") and DropdownOpt.Name ~= "Placeholder" then
                                if DropdownOpt.Name ~= selLabel.Text then
                                    local s = DropdownOpt:FindFirstChildOfClass("UIStroke")
                                    if s then tween(s, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { Transparency = 0 }) end
                                end
                                tween(DropdownOpt, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
                                local t = DropdownOpt:FindFirstChildOfClass("TextLabel")
                                if t then tween(t, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { TextTransparency = 0 }) end
                            end
                        end
                    end
                end)

                local DropdownObj = {}
                function DropdownObj:Set(newOption)
                    if typeof(newOption) == "string" then
                        newOption = {newOption}
                    end
                    currentOption = newOption
                    if not multipleOptions then
                        currentOption = {currentOption[1]}
                    end
                    updateSelectedText()
                    pcall(callback, currentOption)
                    -- Update option colors
                    for _, droption in ipairs(listFrame:GetChildren()) do
                        if droption:IsA("Frame") and droption.Name ~= "Placeholder" then
                            if not table.find(currentOption, droption.Name) then
                                droption.BackgroundColor3 = DropdownUnselected
                            else
                                droption.BackgroundColor3 = DropdownSelected
                            end
                        end
                    end
                end
                function DropdownObj:Get() return currentOption end
                function DropdownObj:Refresh(optionsTable)
                    options = optionsTable
                    for _, opt in ipairs(listFrame:GetChildren()) do
                        if opt:IsA("Frame") and opt.Name ~= "Placeholder" then
                            opt:Destroy()
                        end
                    end
                    SetDropdownOptions()
                    -- Apply colors
                    for _, droption in ipairs(listFrame:GetChildren()) do
                        if droption:IsA("Frame") and droption.Name ~= "Placeholder" then
                            if not table.find(currentOption, droption.Name) then
                                droption.BackgroundColor3 = DropdownUnselected
                            else
                                droption.BackgroundColor3 = DropdownSelected
                            end
                        end
                    end
                    -- If open, make visible immediately
                    if listFrame.Visible then
                        for _, DropdownOpt in ipairs(listFrame:GetChildren()) do
                            if DropdownOpt:IsA("Frame") and DropdownOpt.Name ~= "Placeholder" then
                                DropdownOpt.BackgroundTransparency = 0
                                local t = DropdownOpt:FindFirstChildOfClass("TextLabel")
                                if t then t.TextTransparency = 0 end
                                if not table.find(currentOption, DropdownOpt.Name) then
                                    local s = DropdownOpt:FindFirstChildOfClass("UIStroke")
                                    if s then s.Transparency = 0 end
                                end
                            end
                        end
                    end
                end

                return DropdownObj
            end

            -- ── KEYBIND ───────────────────────────────────
            -- Strictly aligned with Rayfield CreateKeybind logic (FocusLost, InputBegan, HoldToInteract, CallOnChange)
            function Section:CreateKeybind(config)
                config = config or {}
                local label           = config.Name or config.Label or "Keybind"
                local callback        = config.Callback or function() end
                local holdToInteract  = config.HoldToInteract or false
                local callOnChange    = config.CallOnChange or false

                local currentKeybind = config.CurrentKeybind or config.Default
                if currentKeybind == nil then currentKeybind = "Unknown" end
                if typeof(currentKeybind) == "EnumItem" then
                    local splitMsg = string.split(tostring(currentKeybind), ".")
                    currentKeybind = splitMsg[3] or currentKeybind.Name
                end
                currentKeybind = tostring(currentKeybind)

                local CheckingForKey = false

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

                -- Rayfield-style: KeybindFrame containing KeybindBox TextBox
                local keybindFrame = newFrame({
                    BackgroundColor3 = Theme.InputBackground or Color3.fromRGB(30, 32, 38),
                    Size = UDim2.new(0, 70, 0, 30),
                    Position = UDim2.new(1, -82, 0.5, -15),
                    Parent = card,
                    ZIndex = 10,
                })
                makeCorner(keybindFrame, 4)
                local keyStroke = makeStroke(keybindFrame, Theme.InputStroke or Color3.fromRGB(255,255,255), 1, 0.9)

                local keybindBox = Instance.new("TextBox")
                keybindBox.Name = "KeybindBox"
                keybindBox.BackgroundTransparency = 1
                keybindBox.BorderSizePixel = 0
                keybindBox.Size = UDim2.new(1, 0, 1, 0)
                keybindBox.Position = UDim2.new(0, 0, 0, 0)
                keybindBox.Text = currentKeybind
                keybindBox.TextColor3 = Theme.TextDim
                keybindBox.PlaceholderText = ""
                keybindBox.Font = Enum.Font.GothamBold
                keybindBox.TextSize = 11
                keybindBox.TextXAlignment = Enum.TextXAlignment.Center
                keybindBox.ClearTextOnFocus = false
                keybindBox.Parent = keybindFrame
                keybindBox.ZIndex = 11

                -- Rayfield-style: initial size based on text
                keybindFrame.Size = UDim2.new(0, keybindBox.TextBounds.X + 24, 0, 30)

                animateEntry(card, cardStroke, lbl)

                -- Rayfield logic: Focused = start listening
                keybindBox.Focused:Connect(function()
                    CheckingForKey = true
                    keybindBox.Text = ""
                end)

                -- Rayfield logic: FocusLost = stop listening, restore if empty
                keybindBox.FocusLost:Connect(function()
                    CheckingForKey = false
                    if keybindBox.Text == nil or keybindBox.Text == "" then
                        keybindBox.Text = currentKeybind
                    end
                end)

                -- Rayfield logic: InputBegan handles both binding and key activation
                local keybindConnection
                keybindConnection = UserInputService.InputBegan:Connect(function(input, processed)
                    if CheckingForKey then
                        -- Binding mode: capture new key
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            local SplitMessage = string.split(tostring(input.KeyCode), ".")
                            local NewKeyNoEnum = SplitMessage[3]
                            keybindBox.Text = tostring(NewKeyNoEnum)
                            currentKeybind = tostring(NewKeyNoEnum)
                            keybindBox:ReleaseFocus()

                            if callOnChange then
                                pcall(callback, tostring(NewKeyNoEnum))
                            end
                        end
                    elseif not callOnChange and currentKeybind ~= nil and input.KeyCode == Enum.KeyCode[currentKeybind] and not processed then
                        -- Activation mode: key was pressed
                        local Held = true
                        local Connection
                        Connection = input.Changed:Connect(function(prop)
                            if prop == "UserInputState" then
                                Connection:Disconnect()
                                Held = false
                            end
                        end)

                        if not holdToInteract then
                            pcall(callback)
                        else
                            task.wait(0.25)
                            if Held then
                                local Loop
                                Loop = RunService.Stepped:Connect(function()
                                    if not Held then
                                        pcall(callback, false)
                                        Loop:Disconnect()
                                    else
                                        pcall(callback, true)
                                    end
                                end)
                            end
                        end
                    end
                end)

                -- Rayfield-style: auto-resize frame based on text
                keybindBox:GetPropertyChangedSignal("Text"):Connect(function()
                    tween(keybindFrame, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, keybindBox.TextBounds.X + 24, 0, 30)
                    })
                end)

                local KeybindObj = {}
                function KeybindObj:Set(newKeybind)
                    keybindBox.Text = tostring(newKeybind)
                    currentKeybind = tostring(newKeybind)
                    keybindBox:ReleaseFocus()
                    if callOnChange then
                        pcall(callback, tostring(newKeybind))
                    end
                end
                function KeybindObj:Get() return currentKeybind end

                return KeybindObj
            end

            -- ── BUTTON ────────────────────────────────────
            -- Strictly aligned with Rayfield CreateButton logic (flash animation, callback error handling)
            function Section:CreateButton(config)
                config = config or {}
                local label    = config.Name or config.Label or "Button"
                local callback = config.Callback or function() end

                local card, cardStroke = makeCard(45)

                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    Parent = card,
                    ZIndex = 9,
                })

                -- Rayfield-style: ElementIndicator (right side dot/indicator)
                local indicator = newLabel({
                    Text = "→",
                    TextColor3 = Theme.TextDim,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -30, 0, 0),
                    Parent = card,
                    ZIndex = 9,
                })
                indicator.TextTransparency = 0.9

                animateEntry(card, cardStroke, lbl)

                -- Rayfield-style: Interact button
                local interact = newButton({
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = card,
                    ZIndex = 11,
                })

                interact.MouseButton1Click:Connect(function()
                    local Success, Response = pcall(callback)

                    if not Success then
                        -- Rayfield: error state - red background, hide indicator
                        tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.fromRGB(85, 0, 0) })
                        tween(indicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
                        tween(cardStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 1 })
                        lbl.Text = "Callback Error"
                        task.wait(0.5)
                        lbl.Text = label
                        tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_Element })
                        tween(indicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { TextTransparency = 0.9 })
                        tween(cardStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 0 })
                    else
                        -- Rayfield: success - flash hover, hide indicator/stroke, then restore
                        tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_ElementHov })
                        tween(indicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { TextTransparency = 1 })
                        tween(cardStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 1 })
                        task.wait(0.2)
                        tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_Element })
                        tween(indicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { TextTransparency = 0.9 })
                        tween(cardStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 0 })
                    end
                end)

                -- Rayfield-style hover
                card.MouseEnter:Connect(function()
                    tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_ElementHov })
                    tween(indicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { TextTransparency = 0.7 })
                end)
                card.MouseLeave:Connect(function()
                    tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_Element })
                    tween(indicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { TextTransparency = 0.9 })
                end)

                local BtnObj = {}
                function BtnObj:Set(newLabel)
                    lbl.Text = newLabel
                end

                return BtnObj
            end

            -- ── COLOR PICKER ──────────────────────────────
            -- Strictly aligned with Rayfield CreateColorPicker logic (HSV dragging, hex input, RGB inputs)
            function Section:CreateColorPicker(config)
                config = config or {}
                local label    = config.Name or config.Label or "Color"
                local default  = config.Color or config.Default or Color3.fromRGB(76, 201, 240)
                local callback = config.Callback or function() end

                config.Color = default

                local closedH = 45
                local opened = false

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

                -- Rayfield-style: CPBackground (display swatch that expands into picker)
                local cpBackground = newFrame({
                    BackgroundColor3 = default,
                    BackgroundTransparency = 0,
                    Size = UDim2.new(0, 39, 0, 22),
                    Position = UDim2.new(1, -51, 0.5, -11),
                    Parent = card,
                    ZIndex = 9,
                })
                makeCorner(cpBackground, 4)

                -- Display (small color square, fades when picker opens)
                local display = newFrame({
                    BackgroundColor3 = default,
                    BackgroundTransparency = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = cpBackground,
                    ZIndex = 10,
                })
                makeCorner(display, 4)

                animateEntry(card, cardStroke, lbl)

                -- ── Picker area (inside card, below closedH) ──
                local pickerArea = newFrame({
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 75),
                    Position = UDim2.new(0, 0, 0, closedH),
                    Parent = card,
                    ZIndex = 9,
                })
                makePadding(pickerArea, 4, 12, 4, 12)
                makeListLayout(pickerArea, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 4)

                -- HSV Main picker area (ImageLabel for saturation-value)
                local mainCP = Instance.new("ImageLabel")
                mainCP.Name = "MainCP"
                mainCP.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                mainCP.BackgroundTransparency = 1
                mainCP.BorderSizePixel = 0
                mainCP.Size = UDim2.new(1, 0, 0, 40)
                mainCP.Position = UDim2.new(0, 0, 0, 0)
                mainCP.Image = "rbxassetid://4155801252"
                mainCP.ImageTransparency = 1
                mainCP.ScaleType = Enum.ScaleType.Stretch
                mainCP.Parent = pickerArea
                mainCP.ZIndex = 10

                local mainPoint = Instance.new("ImageLabel")
                mainPoint.Name = "MainPoint"
                mainPoint.BackgroundTransparency = 1
                mainPoint.Size = UDim2.new(0, 10, 0, 10)
                mainPoint.Position = UDim2.new(0, 0, 0, 0)
                mainPoint.Image = "rbxassetid://6279300645"
                mainPoint.ImageColor3 = Color3.fromRGB(255, 255, 255)
                mainPoint.ImageTransparency = 1
                mainPoint.Parent = mainCP
                mainPoint.ZIndex = 11

                -- Hue slider bar
                local colorSlider = Instance.new("TextButton")
                colorSlider.Name = "ColorSlider"
                colorSlider.BackgroundTransparency = 1
                colorSlider.BorderSizePixel = 0
                colorSlider.Size = UDim2.new(1, 0, 0, 10)
                colorSlider.Position = UDim2.new(0, 0, 0, 44)
                colorSlider.Text = ""
                colorSlider.Image = "rbxassetid://4155801252"
                colorSlider.Parent = pickerArea
                colorSlider.ZIndex = 10

                local sliderPoint = Instance.new("ImageLabel")
                sliderPoint.Name = "SliderPoint"
                sliderPoint.BackgroundTransparency = 1
                sliderPoint.Size = UDim2.new(0, 10, 0, 10)
                sliderPoint.Position = UDim2.new(0, 0, 0.5, 0)
                sliderPoint.AnchorPoint = Vector2.new(0, 0.5)
                sliderPoint.Image = "rbxassetid://6279300645"
                sliderPoint.ImageColor3 = Color3.fromRGB(255, 255, 255)
                sliderPoint.Parent = colorSlider
                sliderPoint.ZIndex = 11

                -- Hex input row
                local hexRow = newFrame({
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 22),
                    Parent = pickerArea,
                    ZIndex = 10,
                })
                makeListLayout(hexRow, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 6)

                -- RGB inputs row (3 small boxes)
                local rgbRow = newFrame({
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 22),
                    Parent = pickerArea,
                    ZIndex = 10,
                })
                makeListLayout(rgbRow, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 4)

                -- ── HSV state ──
                local h, s, v = default:ToHSV()
                local mouse = Players.LocalPlayer:GetMouse()
                local mainDragging = false
                local sliderDragging = false

                local function setDisplay()
                    mainPoint.Position = UDim2.new(s, -mainPoint.AbsoluteSize.X/2, 1-v, -mainPoint.AbsoluteSize.Y/2)
                    mainPoint.ImageColor3 = Color3.fromHSV(h, s, v)
                    cpBackground.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    display.BackgroundColor3 = Color3.fromHSV(h, s, v)
                    -- Slider point
                    local x = h * colorSlider.AbsoluteSize.X
                    sliderPoint.Position = UDim2.new(0, x - sliderPoint.AbsoluteSize.X/2, 0.5, 0)
                    sliderPoint.ImageColor3 = Color3.fromHSV(h, 1, 1)
                end
                setDisplay()

                -- Rayfield-style: mouse release connection
                local colorPickerInputConnection
                colorPickerInputConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        mainDragging = false
                        sliderDragging = false
                    end
                end)

                mainCP.InputBegan:Connect(function(input)
                    if opened and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        mainDragging = true
                    end
                end)
                colorSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliderDragging = true
                    end
                end)

                -- Rayfield-style: RenderStepped drag loop
                local colorPickerRenderConnection
                colorPickerRenderConnection = RunService.RenderStepped:Connect(function()
                    if mainDragging then
                        local localX = math.clamp(mouse.X - mainCP.AbsolutePosition.X, 0, mainCP.AbsoluteSize.X)
                        local localY = math.clamp(mouse.Y - mainCP.AbsolutePosition.Y, 0, mainCP.AbsoluteSize.Y)
                        mainPoint.Position = UDim2.new(0, localX - mainPoint.AbsoluteSize.X/2, 0, localY - mainPoint.AbsoluteSize.Y/2)
                        s = localX / mainCP.AbsoluteSize.X
                        v = 1 - (localY / mainCP.AbsoluteSize.Y)
                        display.BackgroundColor3 = Color3.fromHSV(h, s, v)
                        mainPoint.ImageColor3 = Color3.fromHSV(h, s, v)
                        cpBackground.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        config.Color = Color3.fromHSV(h, s, v)
                        pcall(callback, Color3.fromHSV(h, s, v))
                    end
                    if sliderDragging then
                        local localX = math.clamp(mouse.X - colorSlider.AbsolutePosition.X, 0, colorSlider.AbsoluteSize.X)
                        h = localX / colorSlider.AbsoluteSize.X
                        display.BackgroundColor3 = Color3.fromHSV(h, s, v)
                        sliderPoint.Position = UDim2.new(0, localX - sliderPoint.AbsoluteSize.X/2, 0.5, 0)
                        sliderPoint.ImageColor3 = Color3.fromHSV(h, 1, 1)
                        cpBackground.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        mainPoint.ImageColor3 = Color3.fromHSV(h, s, v)
                        config.Color = Color3.fromHSV(h, s, v)
                        pcall(callback, Color3.fromHSV(h, s, v))
                    end
                end)

                -- Rayfield-style: Interact to open/close
                local interact = newButton({
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = card,
                    ZIndex = 12,
                })

                interact.MouseButton1Down:Connect(function()
                    task.spawn(function()
                        tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_ElementHov })
                        tween(cardStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 1 })
                        task.wait(0.2)
                        tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_Element })
                        tween(cardStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 0 })
                    end)

                    if not opened then
                        opened = true
                        -- Rayfield: animate display shrink, card expand, show picker
                        tween(cpBackground, TweenInfo.new(0.45, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 18, 0, 15) })
                        task.wait(0.1)
                        tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Size = UDim2.new(1, 0, 0, 120) })
                        tween(cpBackground, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 173, 0, 86) })
                        tween(display, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 })
                        tween(interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Size = UDim2.new(0.574, 0, 1, 0) })
                        tween(interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Position = UDim2.new(0.289, 0, 0.5, 0) })
                        tween(mainPoint, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { ImageTransparency = 0 })
                        tween(mainCP, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { ImageTransparency = 0.1 })
                        tween(cpBackground, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
                    else
                        opened = false
                        tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Size = UDim2.new(1, 0, 0, closedH) })
                        tween(cpBackground, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Size = UDim2.new(0, 39, 0, 22) })
                        tween(interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Size = UDim2.new(1, 0, 1, 0) })
                        tween(interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Position = UDim2.new(0.5, 0, 0.5, 0) })
                        tween(display, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundTransparency = 0 })
                        tween(mainPoint, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { ImageTransparency = 1 })
                        tween(mainCP, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { ImageTransparency = 1 })
                        tween(cpBackground, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundTransparency = 1 })
                    end
                end)

                -- Rayfield-style: hover
                card.MouseEnter:Connect(function()
                    tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_ElementHov })
                end)
                card.MouseLeave:Connect(function()
                    tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_Element })
                end)

                -- Cleanup on destroy
                card.Destroying:Connect(function()
                    if colorPickerRenderConnection then colorPickerRenderConnection:Disconnect() end
                    if colorPickerInputConnection then colorPickerInputConnection:Disconnect() end
                end)

                local ColorObj = {}
                function ColorObj:Set(rgbColor)
                    config.Color = rgbColor
                    h, s, v = rgbColor:ToHSV()
                    setDisplay()
                end
                function ColorObj:Get() return config.Color end

                return ColorObj
            end

            -- ── INPUT / TEXT FIELD ────────────────────────
            -- Strictly aligned with Rayfield CreateInput logic (auto-resize InputFrame, callback error, RemoveTextAfterFocusLost)
            function Section:CreateTextField(config)
                config = config or {}
                local label       = config.Name or config.Label or "Input"
                local placeholder = config.PlaceholderText or config.Placeholder or ""
                local default     = config.CurrentValue or config.Default or ""
                local callback    = config.Callback or function() end
                local removeTextAfterFocusLost = config.RemoveTextAfterFocusLost or false

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

                -- Rayfield-style: InputFrame container
                local inputFrame = newFrame({
                    BackgroundColor3 = Theme.InputBackground or Color3.fromRGB(30, 32, 38),
                    Size = UDim2.new(0, 100, 0, 30),
                    Position = UDim2.new(1, -112, 0.5, -15),
                    Parent = card,
                    ZIndex = 10,
                })
                makeCorner(inputFrame, 4)
                local inputStroke = makeStroke(inputFrame, Theme.InputStroke or Color3.fromRGB(255,255,255), 1, 0.9)

                local inputBox = Instance.new("TextBox")
                inputBox.Name = "InputBox"
                inputBox.BackgroundTransparency = 1
                inputBox.BorderSizePixel = 0
                inputBox.Size = UDim2.new(1, 0, 1, 0)
                inputBox.Text = default
                inputBox.PlaceholderText = placeholder
                inputBox.TextColor3 = Color3.fromRGB(180, 180, 190)
                inputBox.PlaceholderColor3 = Theme.TextFaint
                inputBox.Font = Enum.Font.GothamSemibold
                inputBox.TextSize = 11
                inputBox.TextXAlignment = Enum.TextXAlignment.Left
                inputBox.ClearTextOnFocus = false
                inputBox.Parent = inputFrame
                inputBox.ZIndex = 11
                makePadding(inputBox, 0, 6, 0, 6)

                -- Rayfield-style: initial size
                inputFrame.Size = UDim2.new(0, inputBox.TextBounds.X + 24, 0, 30)

                animateEntry(card, cardStroke, lbl)

                -- Rayfield-style: auto-resize InputFrame
                inputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    tween(inputFrame, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, inputBox.TextBounds.X + 24, 0, 30)
                    })
                end)

                -- Rayfield-style: FocusLost with callback error handling
                inputBox.FocusLost:Connect(function()
                    local Success, Response = pcall(function()
                        callback(inputBox.Text)
                        config.CurrentValue = inputBox.Text
                    end)

                    if not Success then
                        tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.fromRGB(85, 0, 0) })
                        tween(cardStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 1 })
                        lbl.Text = "Callback Error"
                        task.wait(0.5)
                        lbl.Text = label
                        tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_Element })
                        tween(cardStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { Transparency = 0 })
                    end

                    if removeTextAfterFocusLost then
                        inputBox.Text = ""
                    end
                end)

                -- Rayfield-style: hover
                card.MouseEnter:Connect(function()
                    tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_ElementHov })
                end)
                card.MouseLeave:Connect(function()
                    tween(card, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.BG_Element })
                end)

                local TFObj = {}
                function TFObj:Set(text)
                    inputBox.Text = text
                    config.CurrentValue = text
                    pcall(callback, text)
                end
                function TFObj:Get() return inputBox.Text end

                return TFObj
            end

            -- ── LABEL ─────────────────────────────────────
            -- Strictly aligned with Rayfield CreateLabel logic (SecondaryElementBackground style, optional icon/color)
            function Section:CreateLabel(config)
                config = config or {}
                local text        = config.Text or ""
                local color       = config.Color

                local card, cardStroke = makeCard(32)

                -- Rayfield-style: uses SecondaryElementBackground when no color override
                if color then
                    card.BackgroundColor3 = color
                    card.BackgroundTransparency = 0.8
                    cardStroke.Color = color
                    cardStroke.Transparency = 0.7
                else
                    card.BackgroundColor3 = Theme.BG_ElementHov or Color3.fromRGB(30, 32, 38)
                end

                local lbl = newLabel({
                    Text = text,
                    TextColor3 = color and Color3.fromRGB(255,255,255) or Theme.TextDim,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 12,
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    Parent = card,
                    ZIndex = 9,
                })
                lbl.TextWrapped = true

                -- Rayfield-style: entry animation (transparency fade in)
                if color then
                    animateEntry(card, cardStroke, lbl)
                else
                    animateEntry(card, cardStroke, lbl)
                end

                local LabelObj = {}
                function LabelObj:Set(newText, newColor)
                    lbl.Text = newText or text
                    if newColor then
                        card.BackgroundColor3 = newColor
                        cardStroke.Color = newColor
                    end
                end

                return LabelObj
            end

            -- ── PARAGRAPH ─────────────────────────────────
            -- Strictly aligned with Rayfield CreateParagraph logic (Title + Content, SecondaryElementBackground)
            function Section:CreateParagraph(config)
                config = config or {}
                local title   = config.Title   or "Paragraph"
                local content = config.Content or ""

                local card, cardStroke = makeCard(60)
                card.AutomaticSize = Enum.AutomaticSize.Y

                -- Rayfield-style: SecondaryElementBackground
                card.BackgroundColor3 = Theme.BG_ElementHov or Color3.fromRGB(30, 32, 38)

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
