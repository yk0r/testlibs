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
        Text = "WELCOME",
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

            makePadding(sectionInner, 10, 10, 10, 10)

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
            makeListLayout(elemContainer, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 4)

            -- ── SECTION OBJECT ────────────────────────────
            local Section = {}
            Section._container = elemContainer
            Section._elemOrder = 0

            local function nextOrder()
                Section._elemOrder = Section._elemOrder + 1
                return Section._elemOrder
            end

            -- ── HELPER: Element with hover effect (matches web: hover:bg-white/[0.02]) ──
            local function makeElement(height)
                local el = newFrame({
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, height or 40),
                    Parent = Section._container,
                    ZIndex = 8,
                })
                el.LayoutOrder = nextOrder()
                makeCorner(el, 6)

                el.MouseEnter:Connect(function()
                    tween(el, Theme.Fast, { BackgroundTransparency = 0.98 })
                end)
                el.MouseLeave:Connect(function()
                    tween(el, Theme.Fast, { BackgroundTransparency = 1 })
                end)

                return el
            end

            local function animateEntry(el, ...)
                local labels = {...}
                for _, l in ipairs(labels) do
                    if l and l.TextTransparency ~= nil then
                        l.TextTransparency = 1
                    end
                end
                task.defer(function()
                    for _, l in ipairs(labels) do
                        if l and l.TextTransparency ~= nil then
                            tween(l, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), { TextTransparency = 0 })
                        end
                    end
                end)
            end

            -- ── TOGGLE ────────────────────────────────────
            -- Matches web: pill switch with sliding indicator
            function Section:CreateToggle(config)
                config = config or {}
                local label       = config.Label       or "Toggle"
                local desc        = config.Description
                local default     = config.CurrentValue
                if default == nil then default = config.Default end
                if default == nil then default = false end
                local callback    = config.Callback    or function() end

                local currentValue = default
                local elH = desc and 50 or 40

                local el = makeElement(elH)

                -- Label
                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Color3.fromRGB(200, 200, 210),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = desc and UDim2.new(1, -60, 0, 20) or UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 12, 0, desc and 6 or 0),
                    Parent = el,
                    ZIndex = 9,
                })

                local descLbl = nil
                if desc then
                    descLbl = newLabel({
                        Text = desc,
                        TextColor3 = Color3.fromRGB(80, 80, 90),
                        Font = Enum.Font.Gotham,
                        TextSize = 10,
                        Size = UDim2.new(1, -60, 0, 14),
                        Position = UDim2.new(0, 12, 0, 26),
                        Parent = el,
                        ZIndex = 9,
                    })
                end

                animateEntry(el, lbl, descLbl)

                -- Switch pill: 40x20px (web: w-10 h-5 rounded-full p-[3px])
                local switchFrame = newFrame({
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -52, 0.5, -10),
                    Parent = el,
                    ZIndex = 9,
                })
                makeCorner(switchFrame, 10)
                local switchStroke = makeStroke(switchFrame, Color3.fromRGB(255,255,255), 1, 0.9)

                -- Indicator: 14x14 circle (web: w-3.5 h-3.5 rounded-full)
                local indicator = newFrame({
                    Size = UDim2.new(0, 14, 0, 14),
                    BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                    Parent = switchFrame,
                    ZIndex = 10,
                })
                makeCorner(indicator, 7)
                indicator.AnchorPoint = Vector2.new(0, 0.5)

                -- Web: indicator slides x from 3 (OFF) to 23 (ON)
                local function setToggleVisual(enabled, animated)
                    local info = animated and TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) or TweenInfo.new(0)
                    if enabled then
                        -- ON: bg=cyan/10, border=cyan/50, indicator=cyan-400 at right
                        tween(switchFrame, info, { BackgroundColor3 = Theme.AccentBG })
                        tween(switchStroke, info, { Color = Theme.AccentDim, Transparency = 0.5 })
                        tween(indicator, info, { Position = UDim2.new(0, 23, 0.5, 0) })
                        tween(indicator, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { BackgroundColor3 = Theme.Accent })
                    else
                        -- OFF: bg=white/5, border=white/10, indicator=white/20 at left
                        tween(switchFrame, info, { BackgroundColor3 = Color3.fromRGB(13, 13, 15) })
                        tween(switchStroke, info, { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 })
                        tween(indicator, info, { Position = UDim2.new(0, 3, 0.5, 0) })
                        tween(indicator, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.fromRGB(60, 60, 70) })
                    end
                end

                -- Set initial state
                if currentValue then
                    switchFrame.BackgroundColor3 = Theme.AccentBG
                    switchStroke.Color = Theme.AccentDim
                    switchStroke.Transparency = 0.5
                    indicator.Position = UDim2.new(0, 23, 0.5, 0)
                    indicator.BackgroundColor3 = Theme.Accent
                else
                    switchFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 15)
                    indicator.Position = UDim2.new(0, 3, 0.5, 0)
                    indicator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                end

                -- Click handler
                local interact = newButton({
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = el,
                    ZIndex = 12,
                })

                interact.MouseButton1Click:Connect(function()
                    currentValue = not currentValue
                    setToggleVisual(currentValue, true)
                    pcall(callback, currentValue)
                end)

                local ToggleObj = {}
                function ToggleObj:Set(newValue)
                    currentValue = newValue
                    setToggleVisual(currentValue, true)
                    pcall(callback, currentValue)
                end
                function ToggleObj:Get() return currentValue end

                return ToggleObj
            end

            -- ── SLIDER ────────────────────────────────────
            -- Matches web: value badge + thin track with fill
            function Section:CreateSlider(config)
                config = config or {}
                local label       = config.Label       or "Slider"
                local min         = config.Min         or 0
                local max         = config.Max         or 100
                local default     = config.CurrentValue
                if default == nil then default = config.Default end
                if default == nil then default = min end
                local suffix      = config.Suffix      or ""
                local increment   = config.Increment   or 1
                local callback    = config.Callback     or function() end

                local currentValue = clamp(default, min, max)

                local el = makeElement(55)

                -- Label
                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Color3.fromRGB(200, 200, 210),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(0, 0, 0, 20),
                    Position = UDim2.new(0, 12, 0, 6),
                    Parent = el,
                    ZIndex = 9,
                })
                lbl.AutomaticSize = Enum.AutomaticSize.X

                -- Value badge (web: text-xs font-mono text-cyan-400 bg-cyan-500/10 px-1.5 py-0.5 rounded border border-cyan-500/20)
                local badgeFrame = newFrame({
                    BackgroundColor3 = Theme.AccentBG,
                    Size = UDim2.new(0, 50, 0, 18),
                    Position = UDim2.new(1, -62, 0, 7),
                    Parent = el,
                    ZIndex = 9,
                })
                makeCorner(badgeFrame, 4)
                makeStroke(badgeFrame, Theme.AccentDim, 1, 0.7)

                local valueLabel = newLabel({
                    Text = tostring(currentValue) .. (suffix ~= "" and suffix or ""),
                    TextColor3 = Theme.Accent,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = badgeFrame,
                    ZIndex = 10,
                })
                valueLabel.TextXAlignment = Enum.TextXAlignment.Center

                animateEntry(el, lbl, valueLabel)

                -- Track (web: h-1.5 bg-white/5 rounded-full border border-white/5)
                local track = newFrame({
                    BackgroundColor3 = Color3.fromRGB(13, 13, 15),
                    Size = UDim2.new(1, -24, 0, 6),
                    Position = UDim2.new(0, 12, 1, -14),
                    Parent = el,
                    ZIndex = 9,
                })
                makeCorner(track, 3)
                makeStroke(track, Color3.fromRGB(255,255,255), 1, 0.95)

                -- Fill (web: bg-cyan-500, width = percentage)
                local pct = (currentValue - min) / math.max(max - min, 0.001)
                local fill = newFrame({
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(pct, 0, 1, 0),
                    Parent = track,
                    ZIndex = 10,
                })
                makeCorner(fill, 3)

                -- Interact area for dragging
                local sliderInteract = newButton({
                    Size = UDim2.new(1, -24, 0, 20),
                    Position = UDim2.new(0, 12, 1, -22),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = el,
                    ZIndex = 11,
                })

                local SLDragging = false

                sliderInteract.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        SLDragging = true
                    end
                end)

                sliderInteract.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        SLDragging = false
                    end
                end)

                sliderInteract.MouseButton1Down:Connect(function()
                    local Loop
                    Loop = RunService.Stepped:Connect(function()
                        if SLDragging then
                            local mouseLocation = UserInputService:GetMouseLocation().X
                            local relX = math.clamp(mouseLocation - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                            local newPct = relX / track.AbsoluteSize.X
                            local NewValue = min + newPct * (max - min)
                            NewValue = math.floor(NewValue / increment + 0.5) * (increment * 10000000) / 10000000
                            NewValue = math.clamp(NewValue, min, max)

                            local finalPct = (NewValue - min) / math.max(max - min, 0.001)
                            tween(fill, TweenInfo.new(0.15, Enum.EasingStyle.Quart), { Size = UDim2.new(finalPct, 0, 1, 0) })
                            valueLabel.Text = tostring(NewValue) .. (suffix ~= "" and suffix or "")

                            if currentValue ~= NewValue then
                                pcall(callback, NewValue)
                                currentValue = NewValue
                            end
                        else
                            Loop:Disconnect()
                        end
                    end)
                end)

                local SliderObj = {}
                function SliderObj:Set(newVal)
                    newVal = math.clamp(newVal, min, max)
                    currentValue = newVal
                    local p = (newVal - min) / math.max(max - min, 0.001)
                    tween(fill, TweenInfo.new(0.3, Enum.EasingStyle.Quart), { Size = UDim2.new(p, 0, 1, 0) })
                    valueLabel.Text = tostring(newVal) .. (suffix ~= "" and suffix or "")
                    pcall(callback, newVal)
                end
                function SliderObj:Get() return currentValue end

                return SliderObj
            end

            -- ── DROPDOWN ──────────────────────────────────
            -- Matches web: column layout with select button, expand for options
            function Section:CreateDropdown(config)
                config = config or {}
                local label           = config.Name or config.Label or "Dropdown"
                local options         = config.Options or {}
                local multipleOptions = config.MultipleOptions or false
                local callback        = config.Callback or function() end

                local currentOption = config.CurrentOption or config.Default
                if currentOption == nil then currentOption = options[1] end
                if type(currentOption) == "string" then currentOption = {currentOption} end
                if not multipleOptions and type(currentOption) == "table" then currentOption = {currentOption[1]} end
                if currentOption == nil then currentOption = {} end

                local closedH = 58
                local opened = false
                local Debounce = false

                local el = makeElement(closedH)
                el.ClipsDescendants = true

                -- Label (web: text-sm font-semibold text-white/80)
                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Color3.fromRGB(200, 200, 210),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, -24, 0, 16),
                    Position = UDim2.new(0, 12, 0, 4),
                    Parent = el,
                    ZIndex = 9,
                })

                -- Select button (web: px-3 py-2 bg-white/5 border border-white/10 rounded-md text-xs text-white/70)
                local selectBtn = newFrame({
                    BackgroundColor3 = Color3.fromRGB(13, 13, 15),
                    Size = UDim2.new(1, -24, 0, 28),
                    Position = UDim2.new(0, 12, 0, 24),
                    Parent = el,
                    ZIndex = 9,
                })
                makeCorner(selectBtn, 5)
                makeStroke(selectBtn, Color3.fromRGB(255,255,255), 1, 0.9)

                local selLabel = newLabel({
                    Text = currentOption[1] or "None",
                    TextColor3 = Color3.fromRGB(160, 160, 170),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 12,
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    Parent = selectBtn,
                    ZIndex = 10,
                })
                selLabel.TextTruncate = Enum.TextTruncate.AtEnd

                -- Chevron (web: ChevronDown icon, rotates on open)
                local chevron = newLabel({
                    Text = "▾",
                    TextColor3 = Color3.fromRGB(100, 100, 110),
                    Font = Enum.Font.GothamBold,
                    TextSize = 10,
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -24, 0, 0),
                    Parent = selectBtn,
                    ZIndex = 10,
                })

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

                animateEntry(el, lbl, selLabel)

                -- Options list
                local listFrame = Instance.new("ScrollingFrame")
                listFrame.Name = "List"
                listFrame.BackgroundTransparency = 1
                listFrame.Size = UDim2.new(1, -24, 0, 100)
                listFrame.Position = UDim2.new(0, 12, 0, closedH)
                listFrame.BorderSizePixel = 0
                listFrame.ScrollBarThickness = 2
                listFrame.ScrollBarImageTransparency = 0.7
                listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
                listFrame.Visible = false
                listFrame.Parent = el
                listFrame.ZIndex = 9
                makePadding(listFrame, 0, 0, 2, 0)
                makeListLayout(listFrame, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 2)

                local DropdownSelected = Theme.AccentBG
                local DropdownUnselected = Color3.fromRGB(20, 22, 26)

                local function SetDropdownOptions()
                    for _, Option in ipairs(options) do
                        local optFrame = newFrame({
                            Name = Option,
                            BackgroundColor3 = table.find(currentOption, Option) and DropdownSelected or DropdownUnselected,
                            Size = UDim2.new(1, 0, 0, 26),
                            Parent = listFrame,
                            ZIndex = 10,
                        })
                        makeCorner(optFrame, 4)

                        local optTitle = newLabel({
                            Text = Option,
                            TextColor3 = table.find(currentOption, Option) and Theme.Accent or Color3.fromRGB(140, 140, 150),
                            Font = Enum.Font.GothamSemibold,
                            TextSize = 12,
                            Size = UDim2.new(1, -16, 1, 0),
                            Position = UDim2.new(0, 8, 0, 0),
                            Parent = optFrame,
                            ZIndex = 11,
                        })

                        local optInteract = newButton({
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = "",
                            Parent = optFrame,
                            ZIndex = 50,
                        })

                        optInteract.MouseButton1Click:Connect(function()
                            if not multipleOptions and table.find(currentOption, Option) then return end

                            if table.find(currentOption, Option) then
                                table.remove(currentOption, table.find(currentOption, Option))
                            else
                                if not multipleOptions then table.clear(currentOption) end
                                table.insert(currentOption, Option)
                            end

                            updateSelectedText()
                            pcall(callback, currentOption)

                            -- Update option colors
                            for _, droption in ipairs(listFrame:GetChildren()) do
                                if droption:IsA("Frame") and droption.Name ~= "UIPadding" then
                                    local isSelected = table.find(currentOption, droption.Name)
                                    droption.BackgroundColor3 = isSelected and DropdownSelected or DropdownUnselected
                                    local t = droption:FindFirstChildOfClass("TextLabel")
                                    if t then t.TextColor3 = isSelected and Theme.Accent or Color3.fromRGB(140, 140, 150) end
                                end
                            end

                            -- Auto-close for single select
                            if not multipleOptions then
                                task.wait(0.1)
                                opened = false
                                tween(el, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, closedH) })
                                tween(chevron, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { Rotation = 0 })
                                for _, DropdownOpt in ipairs(listFrame:GetChildren()) do
                                    if DropdownOpt:IsA("Frame") and DropdownOpt.Name ~= "UIPadding" then
                                        tween(DropdownOpt, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
                                        local t = DropdownOpt:FindFirstChildOfClass("TextLabel")
                                        if t then tween(t, TweenInfo.new(0.2), { TextTransparency = 1 }) end
                                    end
                                end
                                task.wait(0.2)
                                listFrame.Visible = false
                            end
                            Debounce = false
                        end)
                    end
                end
                SetDropdownOptions()

                -- Click to toggle
                local interact = newButton({
                    Size = UDim2.new(1, 0, 0, closedH),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = el,
                    ZIndex = 11,
                })

                interact.MouseButton1Click:Connect(function()
                    if Debounce then return end

                    if opened then
                        -- Close
                        Debounce = true
                        opened = false
                        tween(el, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, closedH) })
                        tween(chevron, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { Rotation = 0 })
                        for _, DropdownOpt in ipairs(listFrame:GetChildren()) do
                            if DropdownOpt:IsA("Frame") and DropdownOpt.Name ~= "UIPadding" then
                                tween(DropdownOpt, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
                                local t = DropdownOpt:FindFirstChildOfClass("TextLabel")
                                if t then tween(t, TweenInfo.new(0.2), { TextTransparency = 1 }) end
                            end
                        end
                        task.wait(0.25)
                        listFrame.Visible = false
                        Debounce = false
                    else
                        -- Open
                        opened = true
                        local optCount = 0
                        for _ in ipairs(options) do optCount = optCount + 1 end
                        local openH = closedH + math.min(optCount * 28, 100) + 8
                        tween(el, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, openH) })
                        tween(chevron, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { Rotation = 180 })
                        listFrame.Visible = true
                        for _, DropdownOpt in ipairs(listFrame:GetChildren()) do
                            if DropdownOpt:IsA("Frame") and DropdownOpt.Name ~= "UIPadding" then
                                DropdownOpt.BackgroundTransparency = 0
                                local t = DropdownOpt:FindFirstChildOfClass("TextLabel")
                                if t then t.TextTransparency = 0 end
                            end
                        end
                    end
                end)

                local DropdownObj = {}
                function DropdownObj:Set(newOption)
                    if typeof(newOption) == "string" then newOption = {newOption} end
                    currentOption = newOption
                    if not multipleOptions then currentOption = {currentOption[1]} end
                    updateSelectedText()
                    pcall(callback, currentOption)
                    for _, droption in ipairs(listFrame:GetChildren()) do
                        if droption:IsA("Frame") and droption.Name ~= "UIPadding" then
                            local isSelected = table.find(currentOption, droption.Name)
                            droption.BackgroundColor3 = isSelected and DropdownSelected or DropdownUnselected
                            local t = droption:FindFirstChildOfClass("TextLabel")
                            if t then t.TextColor3 = isSelected and Theme.Accent or Color3.fromRGB(140, 140, 150) end
                        end
                    end
                end
                function DropdownObj:Get() return currentOption end
                function DropdownObj:Refresh(optionsTable)
                    options = optionsTable
                    for _, opt in ipairs(listFrame:GetChildren()) do
                        if opt:IsA("Frame") and opt.Name ~= "UIPadding" then opt:Destroy() end
                    end
                    SetDropdownOptions()
                end

                return DropdownObj
            end

            -- ── KEYBIND ───────────────────────────────────
            -- Matches web: simple pill button for key display
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

                local el = makeElement(40)

                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Color3.fromRGB(200, 200, 210),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, -100, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    Parent = el,
                    ZIndex = 9,
                })

                -- Key button (web: px-3 py-1 rounded-sm text-[10px] font-mono border uppercase tracking-widest)
                local keyBtn = newButton({
                    Name = "KeyBtn",
                    Text = string.upper(currentKeybind),
                    TextColor3 = Color3.fromRGB(100, 100, 110),
                    Font = Enum.Font.GothamBold,
                    TextSize = 10,
                    Size = UDim2.new(0, 50, 0, 24),
                    Position = UDim2.new(1, -62, 0.5, -12),
                    BackgroundColor3 = Color3.fromRGB(13, 13, 15),
                    BackgroundTransparency = 0,
                    Parent = el,
                    ZIndex = 10,
                })
                makeCorner(keyBtn, 4)
                makeStroke(keyBtn, Color3.fromRGB(255,255,255), 1, 0.9)

                animateEntry(el, lbl)

                -- Click to start listening
                keyBtn.MouseButton1Click:Connect(function()
                    CheckingForKey = not CheckingForKey
                    if CheckingForKey then
                        -- Active: cyan style
                        tween(keyBtn, Theme.Fast, { BackgroundColor3 = Theme.AccentBG })
                        tween(keyBtn, Theme.Fast, { TextColor3 = Theme.Accent })
                        keyBtn.Text = "..."
                    else
                        -- Default: white/5 style
                        tween(keyBtn, Theme.Fast, { BackgroundColor3 = Color3.fromRGB(13, 13, 15) })
                        tween(keyBtn, Theme.Fast, { TextColor3 = Color3.fromRGB(100, 100, 110) })
                        keyBtn.Text = string.upper(currentKeybind)
                    end
                end)

                -- Key input handling
                UserInputService.InputBegan:Connect(function(input, processed)
                    if CheckingForKey then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            local SplitMessage = string.split(tostring(input.KeyCode), ".")
                            local NewKeyNoEnum = SplitMessage[3]
                            keyBtn.Text = string.upper(tostring(NewKeyNoEnum))
                            currentKeybind = tostring(NewKeyNoEnum)
                            CheckingForKey = false
                            -- Restore default style
                            tween(keyBtn, Theme.Fast, { BackgroundColor3 = Color3.fromRGB(13, 13, 15) })
                            tween(keyBtn, Theme.Fast, { TextColor3 = Color3.fromRGB(100, 100, 110) })
                            if callOnChange then
                                pcall(callback, tostring(NewKeyNoEnum))
                            end
                        end
                    elseif not callOnChange and currentKeybind ~= nil and input.KeyCode == Enum.KeyCode[currentKeybind] and not processed then
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

                -- Auto-resize button based on text
                keyBtn:GetPropertyChangedSignal("Text"):Connect(function()
                    local textW = TextService:GetTextSize(keyBtn.Text, 10, Enum.Font.GothamBold, Vector2.new(200, 24)).X
                    tween(keyBtn, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
                        Size = UDim2.new(0, textW + 20, 0, 24)
                    })
                end)

                local KeybindObj = {}
                function KeybindObj:Set(newKeybind)
                    keyBtn.Text = string.upper(tostring(newKeybind))
                    currentKeybind = tostring(newKeybind)
                    if callOnChange then
                        pcall(callback, tostring(newKeybind))
                    end
                end
                function KeybindObj:Get() return currentKeybind end

                return KeybindObj
            end

            -- ── BUTTON ────────────────────────────────────
            -- Matches web: full-width styled button with variants (primary/secondary/danger)
            function Section:CreateButton(config)
                config = config or {}
                local label    = config.Name or config.Label or "Button"
                local variant  = config.Variant or "primary" -- primary / secondary / danger
                local callback = config.Callback or function() end

                local el = makeElement(40)
                -- Override hover for button - handled by the button itself
                el.BackgroundTransparency = 1

                -- Variant colors (web: primary=cyan, secondary=white, danger=red)
                local bgColors = {
                    primary   = Theme.AccentBG,
                    secondary = Color3.fromRGB(13, 13, 15),
                    danger    = Color3.fromRGB(60, 15, 15),
                }
                local borderColors = {
                    primary   = Theme.AccentDim,
                    secondary = Color3.fromRGB(255,255,255),
                    danger    = Color3.fromRGB(200, 60, 60),
                }
                local borderTransparencies = {
                    primary   = 0.5,
                    secondary = 0.9,
                    danger    = 0.5,
                }
                local textColors = {
                    primary   = Theme.Accent,
                    secondary = Color3.fromRGB(150, 150, 160),
                    danger    = Color3.fromRGB(240, 100, 100),
                }
                local hoverBgColors = {
                    primary   = Theme.AccentBGHov,
                    secondary = Color3.fromRGB(25, 25, 30),
                    danger    = Color3.fromRGB(80, 20, 20),
                }

                -- Full-width button
                local btn = newButton({
                    Name = "Btn",
                    Text = string.upper(label),
                    TextColor3 = textColors[variant] or textColors.primary,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    Size = UDim2.new(1, -24, 0, 34),
                    Position = UDim2.new(0, 12, 0.5, -17),
                    BackgroundColor3 = bgColors[variant] or bgColors.primary,
                    BackgroundTransparency = 0,
                    Parent = el,
                    ZIndex = 9,
                })
                makeCorner(btn, 6)
                makeStroke(btn, borderColors[variant] or borderColors.primary, 1, borderTransparencies[variant] or 0.5)

                animateEntry(el)

                -- Hover effects
                btn.MouseEnter:Connect(function()
                    tween(btn, Theme.Fast, { BackgroundColor3 = hoverBgColors[variant] or hoverBgColors.primary })
                end)
                btn.MouseLeave:Connect(function()
                    tween(btn, Theme.Fast, { BackgroundColor3 = bgColors[variant] or bgColors.primary })
                end)

                -- Click with callback error handling
                btn.MouseButton1Click:Connect(function()
                    local Success, Response = pcall(callback)

                    if not Success then
                        tween(btn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.fromRGB(85, 0, 0) })
                        btn.Text = "CALLBACK ERROR"
                        task.wait(0.5)
                        btn.Text = string.upper(label)
                        tween(btn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { BackgroundColor3 = bgColors[variant] or bgColors.primary })
                    else
                        -- Flash effect
                        tween(btn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { BackgroundColor3 = hoverBgColors[variant] or hoverBgColors.primary })
                        task.wait(0.15)
                        tween(btn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { BackgroundColor3 = bgColors[variant] or bgColors.primary })
                    end
                end)

                local BtnObj = {}
                function BtnObj:Set(newLabel)
                    btn.Text = string.upper(newLabel)
                end

                return BtnObj
            end

            -- ── COLOR PICKER ──────────────────────────────
            -- Matches web: label + hex text + swatch, click to expand HSV picker
            -- FIXED: hue bar uses ImageLabel (TextButton has no Image property!)
            function Section:CreateColorPicker(config)
                config = config or {}
                local label    = config.Name or config.Label or "Color"
                local default  = config.Color or config.Default or Color3.fromRGB(76, 201, 240)
                local callback = config.Callback or function() end

                local currentValue = default
                local closedH = 40
                local opened = false

                local el = makeElement(closedH)
                el.ClipsDescendants = true

                -- Label
                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Color3.fromRGB(200, 200, 210),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, -120, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    Parent = el,
                    ZIndex = 9,
                })

                -- Hex text (web: text-[10px] font-mono text-white/30 uppercase)
                local hexLabel = newLabel({
                    Text = colorToHex(default),
                    TextColor3 = Color3.fromRGB(80, 80, 90),
                    Font = Enum.Font.GothamBold,
                    TextSize = 10,
                    Size = UDim2.new(0, 60, 1, 0),
                    Position = UDim2.new(1, -100, 0, 0),
                    Parent = el,
                    ZIndex = 9,
                })
                hexLabel.TextXAlignment = Enum.TextXAlignment.Right

                -- Color swatch (web: w-6 h-6 rounded border border-white/10)
                local swatch = newFrame({
                    BackgroundColor3 = default,
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(1, -36, 0.5, -12),
                    Parent = el,
                    ZIndex = 9,
                })
                makeCorner(swatch, 4)
                makeStroke(swatch, Color3.fromRGB(255,255,255), 1, 0.9)

                animateEntry(el, lbl, hexLabel)

                -- ── Picker area (below closedH, absolute positioned) ──
                local pickerArea = newFrame({
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -24, 0, 70),
                    Position = UDim2.new(0, 12, 0, closedH),
                    Parent = el,
                    ZIndex = 9,
                })

                -- Saturation-Value area (ImageLabel - correct type for Image property!)
                local mainCP = Instance.new("ImageLabel")
                mainCP.Name = "MainCP"
                mainCP.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                mainCP.BorderSizePixel = 0
                mainCP.Size = UDim2.new(1, 0, 0, 45)
                mainCP.Position = UDim2.new(0, 0, 0, 0)
                mainCP.Image = "rbxassetid://4155801252"
                mainCP.ImageTransparency = 1
                mainCP.ScaleType = Enum.ScaleType.Stretch
                mainCP.Parent = pickerArea
                mainCP.ZIndex = 10
                makeCorner(mainCP, 4)

                -- Main point indicator
                local mainPoint = Instance.new("ImageLabel")
                mainPoint.BackgroundTransparency = 1
                mainPoint.Size = UDim2.new(0, 10, 0, 10)
                mainPoint.Image = "rbxassetid://6279300645"
                mainPoint.ImageColor3 = Color3.fromRGB(255, 255, 255)
                mainPoint.ImageTransparency = 1
                mainPoint.AnchorPoint = Vector2.new(0.5, 0.5)
                mainPoint.Parent = mainCP
                mainPoint.ZIndex = 11

                -- Hue bar (ImageLabel, NOT TextButton - that was the bug!)
                local hueBar = Instance.new("ImageLabel")
                hueBar.Name = "HueBar"
                hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                hueBar.BorderSizePixel = 0
                hueBar.Size = UDim2.new(1, 0, 0, 10)
                hueBar.Position = UDim2.new(0, 0, 0, 51)
                hueBar.Image = "rbxassetid://4155801252"
                hueBar.ImageTransparency = 1
                hueBar.Parent = pickerArea
                hueBar.ZIndex = 10
                makeCorner(hueBar, 5)

                -- Hue point indicator
                local huePoint = Instance.new("ImageLabel")
                huePoint.BackgroundTransparency = 1
                huePoint.Size = UDim2.new(0, 10, 0, 10)
                huePoint.Image = "rbxassetid://6279300645"
                huePoint.ImageColor3 = Color3.fromRGB(255, 255, 255)
                huePoint.ImageTransparency = 1
                huePoint.AnchorPoint = Vector2.new(0.5, 0.5)
                huePoint.Parent = hueBar
                huePoint.ZIndex = 11

                -- HSV state
                local h, s, v = default:ToHSV()
                local mouse = Players.LocalPlayer:GetMouse()
                local mainDragging = false
                local sliderDragging = false

                local function updateDisplay()
                    -- Main point position (scale-based for responsiveness)
                    mainPoint.Position = UDim2.new(s, 0, 1 - v, 0)
                    mainPoint.ImageColor3 = Color3.fromHSV(h, s, v)
                    -- Hue point position
                    huePoint.Position = UDim2.new(h, 0, 0.5, 0)
                    huePoint.ImageColor3 = Color3.fromHSV(h, 1, 1)
                    -- MainCP background = pure hue
                    mainCP.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    -- Update swatch + hex
                    currentValue = Color3.fromHSV(h, s, v)
                    swatch.BackgroundColor3 = currentValue
                    hexLabel.Text = colorToHex(currentValue)
                end
                updateDisplay()

                -- Interaction overlays (invisible TextButtons for click/drag)
                local mainInteract = Instance.new("TextButton")
                mainInteract.BackgroundTransparency = 1
                mainInteract.Size = UDim2.new(1, 0, 1, 0)
                mainInteract.Text = ""
                mainInteract.AutoButtonColor = false
                mainInteract.Parent = mainCP
                mainInteract.ZIndex = 12

                local hueInteract = Instance.new("TextButton")
                hueInteract.BackgroundTransparency = 1
                hueInteract.Size = UDim2.new(1, 0, 1, 0)
                hueInteract.Text = ""
                hueInteract.AutoButtonColor = false
                hueInteract.Parent = hueBar
                hueInteract.ZIndex = 12

                -- Mouse release
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        mainDragging = false
                        sliderDragging = false
                    end
                end)

                mainInteract.InputBegan:Connect(function(input)
                    if opened and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        mainDragging = true
                    end
                end)

                hueInteract.InputBegan:Connect(function(input)
                    if opened and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        sliderDragging = true
                    end
                end)

                -- RenderStepped drag loop
                local renderConn
                renderConn = RunService.RenderStepped:Connect(function()
                    if mainDragging then
                        local localX = math.clamp(mouse.X - mainCP.AbsolutePosition.X, 0, mainCP.AbsoluteSize.X)
                        local localY = math.clamp(mouse.Y - mainCP.AbsolutePosition.Y, 0, mainCP.AbsoluteSize.Y)
                        s = localX / mainCP.AbsoluteSize.X
                        v = 1 - (localY / mainCP.AbsoluteSize.Y)
                        updateDisplay()
                        pcall(callback, currentValue)
                    end
                    if sliderDragging then
                        local localX = math.clamp(mouse.X - hueBar.AbsolutePosition.X, 0, hueBar.AbsoluteSize.X)
                        h = localX / hueBar.AbsoluteSize.X
                        updateDisplay()
                        pcall(callback, currentValue)
                    end
                end)

                -- Click to open/close
                local interact = newButton({
                    Size = UDim2.new(1, 0, 0, closedH),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = el,
                    ZIndex = 13,
                })

                interact.MouseButton1Click:Connect(function()
                    if not opened then
                        opened = true
                        tween(el, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, closedH + 70 + 8) })
                        tween(mainCP, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { ImageTransparency = 0 })
                        tween(mainPoint, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { ImageTransparency = 0 })
                        tween(hueBar, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { ImageTransparency = 0 })
                        tween(huePoint, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), { ImageTransparency = 0 })
                    else
                        opened = false
                        tween(el, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, closedH) })
                        tween(mainCP, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { ImageTransparency = 1 })
                        tween(mainPoint, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { ImageTransparency = 1 })
                        tween(hueBar, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { ImageTransparency = 1 })
                        tween(huePoint, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { ImageTransparency = 1 })
                    end
                end)

                -- Cleanup on destroy
                el.Destroying:Connect(function()
                    if renderConn then renderConn:Disconnect() end
                end)

                local ColorObj = {}
                function ColorObj:Set(rgbColor)
                    currentValue = rgbColor
                    h, s, v = rgbColor:ToHSV()
                    updateDisplay()
                end
                function ColorObj:Get() return currentValue end

                return ColorObj
            end

            -- ── INPUT / TEXT FIELD ────────────────────────
            -- Matches web: column layout with label on top, input below
            function Section:CreateTextField(config)
                config = config or {}
                local label       = config.Name or config.Label or "Input"
                local placeholder = config.PlaceholderText or config.Placeholder or ""
                local default     = config.CurrentValue or config.Default or ""
                local callback    = config.Callback or function() end
                local removeTextAfterFocusLost = config.RemoveTextAfterFocusLost or false

                local el = makeElement(62)

                -- Label on top
                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Color3.fromRGB(200, 200, 210),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, -24, 0, 18),
                    Position = UDim2.new(0, 12, 0, 4),
                    Parent = el,
                    ZIndex = 9,
                })

                -- Input field below
                local inputFrame = newFrame({
                    BackgroundColor3 = Color3.fromRGB(13, 13, 15),
                    Size = UDim2.new(1, -24, 0, 28),
                    Position = UDim2.new(0, 12, 0, 26),
                    Parent = el,
                    ZIndex = 10,
                })
                makeCorner(inputFrame, 5)
                local inputStroke = makeStroke(inputFrame, Color3.fromRGB(255,255,255), 1, 0.9)

                local inputBox = Instance.new("TextBox")
                inputBox.Name = "InputBox"
                inputBox.BackgroundTransparency = 1
                inputBox.BorderSizePixel = 0
                inputBox.Size = UDim2.new(1, -12, 1, 0)
                inputBox.Position = UDim2.new(0, 6, 0, 0)
                inputBox.Text = default
                inputBox.PlaceholderText = placeholder
                inputBox.TextColor3 = Color3.fromRGB(160, 160, 170)
                inputBox.PlaceholderColor3 = Color3.fromRGB(60, 60, 70)
                inputBox.Font = Enum.Font.GothamSemibold
                inputBox.TextSize = 12
                inputBox.TextXAlignment = Enum.TextXAlignment.Left
                inputBox.ClearTextOnFocus = false
                inputBox.Parent = inputFrame
                inputBox.ZIndex = 11

                animateEntry(el, lbl)

                -- Focus effect: accent border
                inputBox.Focused:Connect(function()
                    tween(inputStroke, Theme.Fast, { Color = Theme.AccentDim, Transparency = 0.5 })
                end)
                inputBox.FocusLost:Connect(function()
                    tween(inputStroke, Theme.Fast, { Color = Color3.fromRGB(255,255,255), Transparency = 0.9 })
                    local Success = pcall(function()
                        callback(inputBox.Text)
                    end)

                    if not Success then
                        tween(inputFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.fromRGB(85, 0, 0) })
                        lbl.Text = "Callback Error"
                        task.wait(0.5)
                        lbl.Text = label
                        tween(inputFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), { BackgroundColor3 = Color3.fromRGB(13, 13, 15) })
                    end

                    if removeTextAfterFocusLost then
                        inputBox.Text = ""
                    end
                end)

                local TFObj = {}
                function TFObj:Set(text)
                    inputBox.Text = text
                    pcall(callback, text)
                end
                function TFObj:Get() return inputBox.Text end

                return TFObj
            end

            -- ── LABEL ─────────────────────────────────────
            -- Matches web: simple text element
            function Section:CreateLabel(config)
                config = config or {}
                local text        = config.Text or ""
                local color       = config.Color

                local el = makeElement(32)

                local lbl = newLabel({
                    Text = text,
                    TextColor3 = color or Color3.fromRGB(130, 130, 140),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 12,
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    Parent = el,
                    ZIndex = 9,
                })
                lbl.TextWrapped = true

                if color then
                    el.BackgroundColor3 = color
                    el.BackgroundTransparency = 0.85
                end

                animateEntry(el, lbl)

                local LabelObj = {}
                function LabelObj:Set(newText, newColor)
                    lbl.Text = newText or text
                    if newColor then
                        el.BackgroundColor3 = newColor
                        el.BackgroundTransparency = 0.85
                        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end

                return LabelObj
            end

            -- ── PARAGRAPH ─────────────────────────────────
            -- Matches web: Title + Content layout
            function Section:CreateParagraph(config)
                config = config or {}
                local title   = config.Title   or "Paragraph"
                local content = config.Content or ""

                local el = makeElement(60)
                el.AutomaticSize = Enum.AutomaticSize.Y

                local titleLbl = newLabel({
                    Text = title,
                    TextColor3 = Color3.fromRGB(200, 200, 210),
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    Size = UDim2.new(1, -24, 0, 20),
                    Position = UDim2.new(0, 12, 0, 6),
                    Parent = el,
                    ZIndex = 9,
                })

                local contentLbl = newLabel({
                    Text = content,
                    TextColor3 = Color3.fromRGB(130, 130, 140),
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    Size = UDim2.new(1, -24, 0, 0),
                    Position = UDim2.new(0, 12, 0, 26),
                    Parent = el,
                    ZIndex = 9,
                })
                contentLbl.AutomaticSize = Enum.AutomaticSize.Y
                contentLbl.TextWrapped = true

                animateEntry(el, titleLbl, contentLbl)

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
