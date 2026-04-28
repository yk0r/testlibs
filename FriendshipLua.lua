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
            Size = UDim2.fromOffset(850, 580),
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
    local size     = config.Size     or UDim2.fromOffset(850, 580)
    local position = config.Position or UDim2.new(0.5, -425, 0.5, -290)
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
    makeCorner(mainWindow, 6)
    makeStroke(mainWindow, Color3.fromRGB(255,255,255), 1, 0.9)

    -- Subtle glow shadow
    local shadow = newFrame({
        Name = "Shadow",
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.97,
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        Parent = mainWindow,
        ZIndex = 2,
    })
    makeCorner(shadow, 12)

    -- ── SIDEBAR ──────────────────────────────────────────────
    local sidebar = newFrame({
        Name = "Sidebar",
        BackgroundColor3 = Theme.BG_Sidebar,
        Size = UDim2.new(0, 220, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = mainWindow,
        ZIndex = 4,
    })
    makeStroke(sidebar, Color3.fromRGB(255,255,255), 1, 0.95)

    -- Brand logo area
    local brandArea = newFrame({
        Name = "BrandArea",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 78),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = sidebar,
        ZIndex = 5,
    })
    makePadding(brandArea, 0, 0, 0, 28)

    local logoBox = newFrame({
        Name = "LogoBox",
        BackgroundColor3 = Theme.AccentBG,
        Size = UDim2.new(0, 34, 0, 34),
        Position = UDim2.new(0, 28, 0.5, -17),
        Parent = brandArea,
        ZIndex = 6,
    })
    makeCorner(logoBox, 6)
    makeStroke(logoBox, Theme.AccentDim, 1, 0.4)

    newLabel({
        Text = "F",
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = logoBox,
        ZIndex = 7,
    }).TextXAlignment = Enum.TextXAlignment.Center

    -- Dot indicator on logo
    local logoDot = newFrame({
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(1, -4, 0, -4),
        Parent = logoBox,
        ZIndex = 7,
    })
    makeCorner(logoDot, 99)

    -- Title text
    local titleLabel = newLabel({
        Text = title:match("^([^%.]+)") or title,
        TextColor3 = Color3.fromRGB(220,220,220),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Size = UDim2.new(0, 130, 0, 18),
        Position = UDim2.new(0, 72, 0.5, -18),
        Parent = brandArea,
        ZIndex = 6,
    })

    local titleExt = title:match("%.(.+)$")
    if titleExt then
        local extLabel = newLabel({
            Text = "." .. titleExt,
            TextColor3 = Theme.Accent,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            Size = UDim2.new(0, 130, 0, 18),
            Position = UDim2.new(0, 72 + TextService:GetTextSize(title:match("^([^%.]+)"), 15, Enum.Font.GothamBold, Vector2.new(200,20)).X, 0.5, -18),
            Parent = brandArea,
            ZIndex = 6,
        })
        _ = extLabel -- suppress unused warning
    end

    local subLabel = newLabel({
        Text = string.upper(subtitle),
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        Size = UDim2.new(0, 130, 0, 14),
        Position = UDim2.new(0, 72, 0.5, 4),
        Parent = brandArea,
        ZIndex = 6,
    })
    _ = subLabel

    -- Sidebar separator
    local sidebarSep = newFrame({
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.95,
        Size = UDim2.new(1, -28, 0, 1),
        Position = UDim2.new(0, 14, 0, 78),
        Parent = sidebar,
        ZIndex = 5,
    })
    _ = sidebarSep

    -- Tab nav container
    local navContainer = newFrame({
        Name = "NavContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -140),
        Position = UDim2.new(0, 0, 0, 88),
        Parent = sidebar,
        ZIndex = 5,
    })
    makePadding(navContainer, 0, 10, 0, 10)
    makeListLayout(navContainer, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 2)

    -- Sidebar bottom (user area)
    local sidebarBottom = newFrame({
        Name = "SidebarBottom",
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.8,
        Size = UDim2.new(1, 0, 0, 62),
        Position = UDim2.new(0, 0, 1, -62),
        Parent = sidebar,
        ZIndex = 5,
    })
    makeStroke(sidebarBottom, Color3.fromRGB(255,255,255), 1, 0.95)
    makePadding(sidebarBottom, 0, 0, 0, 24)

    newLabel({
        Text = "Welcome back,",
        TextColor3 = Color3.fromRGB(180,180,180),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Size = UDim2.new(1, -24, 0, 16),
        Position = UDim2.new(0, 0, 0, 13),
        Parent = sidebarBottom,
        ZIndex = 6,
    })

    local playerName = "User"
    pcall(function() playerName = LocalPlayer.Name end)

    newLabel({
        Text = string.upper(playerName),
        TextColor3 = Theme.TextAccent,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Size = UDim2.new(1, -24, 0, 14),
        Position = UDim2.new(0, 0, 0, 31),
        Parent = sidebarBottom,
        ZIndex = 6,
    })

    -- ── MAIN CONTENT AREA ──────────────────────────────────
    local contentArea = newFrame({
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -220, 1, 0),
        Position = UDim2.new(0, 220, 0, 0),
        Parent = mainWindow,
        ZIndex = 4,
    })

    -- Header
    local header = newFrame({
        Name = "Header",
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.8,
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = contentArea,
        ZIndex = 5,
    })
    makeStroke(header, Color3.fromRGB(255,255,255), 1, 0.95)

    -- Breadcrumb left
    local breadcrumbContainer = newFrame({
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        Parent = header,
        ZIndex = 6,
    })
    makeListLayout(breadcrumbContainer, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 8)
    breadcrumbContainer.AutomaticSize = Enum.AutomaticSize.X

    local breadcrumbMeta = newLabel({
        Text = "CURRENT CATEGORY",
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = breadcrumbContainer,
        ZIndex = 6,
    })
    breadcrumbMeta.AutomaticSize = Enum.AutomaticSize.X

    local chevron = newLabel({
        Text = "›",
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
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
        TextSize = 13,
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
        TextSize = 18,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -40, 0.5, -14),
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
        TextSize = 12,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -72, 0.5, -14),
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
            tween(mainWindow, Theme.Medium, { Size = UDim2.fromOffset(size.X.Offset, 60) })
        else
            tween(mainWindow, Theme.Spring, { Size = size })
        end
    end)

    -- Tab content pages container
    local pagesContainer = newFrame({
        Name = "PagesContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -100),
        Position = UDim2.new(0, 0, 0, 60),
        Parent = contentArea,
        ZIndex = 5,
        ClipsDescendants = true,
    })
    makePadding(pagesContainer, 28, 28, 20, 28)

    -- Footer / Status bar
    local footer = newFrame({
        Name = "Footer",
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.6,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 1, -40),
        Parent = contentArea,
        ZIndex = 5,
    })
    makeStroke(footer, Color3.fromRGB(255,255,255), 1, 0.95)

    -- Footer left
    local footerLeft = newFrame({
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        Parent = footer,
        ZIndex = 6,
    })
    makeListLayout(footerLeft, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 14)

    -- Status indicator
    local statusDot = newFrame({
        BackgroundColor3 = Theme.Success,
        Size = UDim2.new(0, 6, 0, 6),
        Parent = footerLeft,
        ZIndex = 7,
    })
    makeCorner(statusDot, 99)

    local statusLabel = newLabel({
        Text = "STATUS: INJECTED",
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        Size = UDim2.new(0, 120, 1, 0),
        Parent = footerLeft,
        ZIndex = 6,
    })
    _ = statusLabel

    local dividerDot = newLabel({
        Text = "·",
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        Size = UDim2.new(0, 8, 1, 0),
        Parent = footerLeft,
        ZIndex = 6,
    })
    _ = dividerDot

    local buildLabel = newLabel({
        Text = "BUILD: V1.0.4A",
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        Size = UDim2.new(0, 120, 1, 0),
        Parent = footerLeft,
        ZIndex = 6,
    })
    _ = buildLabel

    -- Footer right (branding)
    newLabel({
        Text = string.upper(title),
        TextColor3 = Theme.TextFaint,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0.6, 0, 0, 0),
        Parent = footer,
        ZIndex = 6,
    }).TextXAlignment = Enum.TextXAlignment.Right

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
            TextSize = 13,
            Size = UDim2.new(1, -8, 0, 42),
            Parent = self._navContainer,
            ZIndex = 6,
        })
        makeCorner(navBtn, 8)

        -- Layout inside button
        local btnInner = newFrame({
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = navBtn,
            ZIndex = 7,
        })
        makeListLayout(btnInner, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 10)
        makePadding(btnInner, 0, 0, 0, 14)

        -- Active indicator line
        local indicator = newFrame({
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 2, 0.5, 0),
            Position = UDim2.new(0, 0, 0.25, 0),
            Parent = navBtn,
            ZIndex = 8,
        })
        makeCorner(indicator, 2)

        -- Icon (if provided, otherwise use a default shape)
        local iconFrame = newFrame({
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 18, 1, 0),
            Parent = btnInner,
            ZIndex = 7,
        })

        if icon and icon ~= "" then
            newImage({
                Image = icon,
                ImageColor3 = Theme.TextFaint,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 0, 0.5, -8),
                Parent = iconFrame,
                ZIndex = 8,
            })
        else
            -- Default minimal dot icon
            local iconDot = newFrame({
                BackgroundColor3 = Theme.TextFaint,
                Size = UDim2.new(0, 6, 0, 6),
                Position = UDim2.new(0, 5, 0.5, -3),
                Parent = iconFrame,
                ZIndex = 8,
            })
            makeCorner(iconDot, 99)
            iconFrame._dot = iconDot
        end

        local nameLabel = newLabel({
            Text = name,
            TextColor3 = Theme.TextDim,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            Size = UDim2.new(1, -28, 1, 0),
            Parent = btnInner,
            ZIndex = 7,
        })

        -- Page frame for this tab
        local page = newFrame({
            Name = "Page_" .. name,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            Parent = self._pagesContainer,
            ZIndex = 5,
        })
        page.AutomaticSize = Enum.AutomaticSize.None

        -- Two-column grid layout
        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.new(0.5, -10, 0, 0)
        grid.CellPadding = UDim2.fromOffset(16, 20)
        grid.FillDirection = Enum.FillDirection.Horizontal
        grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
        grid.VerticalAlignment = Enum.VerticalAlignment.Top
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.Parent = page

        -- Wrap in a scrolling frame
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = "ScrollFrame"
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollFrame.ScrollBarThickness = 3
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255,255,255)
        scrollFrame.ScrollBarImageTransparency = 0.85
        scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        scrollFrame.Parent = self._pagesContainer

        local scrollGrid = Instance.new("UIGridLayout")
        scrollGrid.CellSize = UDim2.new(0.5, -10, 0, 0)
        scrollGrid.CellPadding = UDim2.fromOffset(16, 20)
        scrollGrid.FillDirection = Enum.FillDirection.Horizontal
        scrollGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
        scrollGrid.VerticalAlignment = Enum.VerticalAlignment.Top
        scrollGrid.SortOrder = Enum.SortOrder.LayoutOrder
        scrollGrid.Parent = scrollFrame

        scrollFrame.Visible = false

        -- Tab object
        local Tab = {}
        Tab._page         = scrollFrame
        Tab._grid         = scrollGrid
        Tab._navBtn       = navBtn
        Tab._nameLabel    = nameLabel
        Tab._indicator    = indicator
        Tab._iconFrame    = iconFrame
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
                if iconFrame._dot then
                    tween(iconFrame._dot, Theme.Fast, { BackgroundColor3 = Theme.Accent })
                end
                self._page.Visible = true
            else
                tween(navBtn, Theme.Fast, {
                    BackgroundColor3 = Color3.fromRGB(0,0,0),
                    BackgroundTransparency = 1,
                })
                tween(nameLabel, Theme.Fast, { TextColor3 = Theme.TextDim })
                tween(indicator, Theme.Fast, { BackgroundTransparency = 1 })
                if iconFrame._dot then
                    tween(iconFrame._dot, Theme.Fast, { BackgroundColor3 = Theme.TextFaint })
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
            navBtn.MouseButton1Click:Fire()
        end

        -- ── CREATE SECTION ────────────────────────────────
        function Tab:CreateSection(title)
            Tab._sectionOrder = Tab._sectionOrder + 1

            local sectionWrap = newFrame({
                Name = "Section_" .. title,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                Parent = self._page,
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

            makePadding(sectionInner, 12, 10, 12, 10)

            -- Section header
            local sectionHeader = newFrame({
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                Parent = sectionInner,
                ZIndex = 7,
            })
            makeListLayout(sectionHeader, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 10)

            local sectionTitle = newLabel({
                Text = string.upper(title),
                TextColor3 = Theme.TextFaint,
                Font = Enum.Font.GothamBold,
                TextSize = 9,
                Size = UDim2.new(0, 0, 1, 0),
                Parent = sectionHeader,
                ZIndex = 8,
            })
            sectionTitle.AutomaticSize = Enum.AutomaticSize.X

            -- Separator line
            local sepLine = newFrame({
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BackgroundTransparency = 0.9,
                Size = UDim2.new(1, 0, 0, 1),
                Parent = sectionHeader,
                ZIndex = 7,
            })
            sepLine.AutomaticSize = Enum.AutomaticSize.None
            -- Fill remaining width via layout
            local sepFrame = newFrame({
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Parent = sectionHeader,
                ZIndex = 7,
            })
            sepFrame.AutomaticSize = Enum.AutomaticSize.None
            newFrame({
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BackgroundTransparency = 0.9,
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 0.5, 0),
                Parent = sepFrame,
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
            makeListLayout(elemContainer, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 0)

            -- ── SECTION OBJECT ────────────────────────────
            local Section = {}
            Section._container = elemContainer
            Section._elemOrder = 0

            local function nextOrder()
                Section._elemOrder = Section._elemOrder + 1
                return Section._elemOrder
            end

            -- ── TOGGLE ────────────────────────────────────
            function Section:CreateToggle(config)
                config = config or {}
                local label    = config.Label    or "Toggle"
                local desc     = config.Description
                local default  = config.Default  ~= nil and config.Default or false
                local callback = config.Callback or function() end

                local checked = default

                local row = newButton({
                    BackgroundColor3 = Color3.fromRGB(0,0,0),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, desc and 52 or 40),
                    Parent = self._container,
                    ZIndex = 8,
                })
                row.LayoutOrder = nextOrder()
                makeCorner(row, 6)

                local rowInner = newFrame({
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = row,
                    ZIndex = 9,
                })
                makePadding(rowInner, 0, 8, 0, 10)

                local textStack = newFrame({
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -52, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Parent = rowInner,
                    ZIndex = 9,
                })
                makeListLayout(textStack, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 2)

                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Color3.fromRGB(180,180,180),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, 0, 0, 18),
                    Parent = textStack,
                    ZIndex = 9,
                })

                if desc then
                    newLabel({
                        Text = desc,
                        TextColor3 = Theme.TextFaint,
                        Font = Enum.Font.Gotham,
                        TextSize = 10,
                        Size = UDim2.new(1, 0, 0, 14),
                        Parent = textStack,
                        ZIndex = 9,
                    })
                end

                -- Toggle switch background
                local switchBG = newFrame({
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    BackgroundTransparency = 0.95,
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -48, 0.5, -10),
                    Parent = rowInner,
                    ZIndex = 9,
                })
                makeCorner(switchBG, 99)
                makeStroke(switchBG, Color3.fromRGB(255,255,255), 1, 0.9)

                local switchThumb = newFrame({
                    BackgroundColor3 = Color3.fromRGB(80,85,95),
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 3, 0.5, -7),
                    Parent = switchBG,
                    ZIndex = 10,
                })
                makeCorner(switchThumb, 99)

                local function updateSwitch(state)
                    if state then
                        tween(switchBG, Theme.Fast, {
                            BackgroundColor3 = Theme.AccentBG,
                            BackgroundTransparency = 0,
                        })
                        tween(switchThumb, Theme.Fast, {
                            Position = UDim2.new(0, 23, 0.5, -7),
                            BackgroundColor3 = Theme.Accent,
                        })
                        tween(lbl, Theme.Fast, { TextColor3 = Color3.fromRGB(210,210,215) })
                    else
                        tween(switchBG, Theme.Fast, {
                            BackgroundColor3 = Color3.fromRGB(255,255,255),
                            BackgroundTransparency = 0.95,
                        })
                        tween(switchThumb, Theme.Fast, {
                            Position = UDim2.new(0, 3, 0.5, -7),
                            BackgroundColor3 = Color3.fromRGB(80,85,95),
                        })
                        tween(lbl, Theme.Fast, { TextColor3 = Color3.fromRGB(180,180,180) })
                    end
                end

                if checked then updateSwitch(true) end

                row.MouseButton1Click:Connect(function()
                    checked = not checked
                    updateSwitch(checked)
                    pcall(callback, checked)
                end)

                row.MouseEnter:Connect(function()
                    tween(row, Theme.Fast, {
                        BackgroundColor3 = Color3.fromRGB(255,255,255),
                        BackgroundTransparency = 0.98,
                    })
                end)
                row.MouseLeave:Connect(function()
                    tween(row, Theme.Fast, {
                        BackgroundTransparency = 1,
                    })
                end)

                local ToggleObj = {}
                function ToggleObj:Set(value)
                    checked = value
                    updateSwitch(value)
                    pcall(callback, value)
                end
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

                local wrap = newFrame({
                    BackgroundColor3 = Color3.fromRGB(0,0,0),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 58),
                    Parent = self._container,
                    ZIndex = 8,
                })
                wrap.LayoutOrder = nextOrder()
                makeCorner(wrap, 6)
                makePadding(wrap, 8, 10, 8, 10)

                -- Top row: label + value tag
                local topRow = newFrame({
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 22),
                    Parent = wrap,
                    ZIndex = 9,
                })

                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Color3.fromRGB(180,180,180),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, -80, 1, 0),
                    Parent = topRow,
                    ZIndex = 9,
                })

                local valueTag = newFrame({
                    BackgroundColor3 = Theme.AccentBG,
                    Size = UDim2.new(0, 70, 0, 18),
                    Position = UDim2.new(1, -70, 0.5, -9),
                    Parent = topRow,
                    ZIndex = 9,
                })
                makeCorner(valueTag, 4)
                makeStroke(valueTag, Theme.AccentDim, 1, 0.5)

                local valueLabel = newLabel({
                    Text = tostring(value) .. suffix,
                    TextColor3 = Theme.Accent,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = valueTag,
                    ZIndex = 10,
                })
                valueLabel.TextXAlignment = Enum.TextXAlignment.Center

                -- Track
                local trackBG = newFrame({
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    BackgroundTransparency = 0.95,
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 34),
                    Parent = wrap,
                    ZIndex = 9,
                })
                makeCorner(trackBG, 99)
                makeStroke(trackBG, Color3.fromRGB(255,255,255), 1, 0.95)

                local fillPct = (value - min) / (max - min)

                local trackFill = newFrame({
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(fillPct, 0, 1, 0),
                    Parent = trackBG,
                    ZIndex = 10,
                })
                makeCorner(trackFill, 99)

                -- Thumb
                local thumb = newFrame({
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(fillPct, -6, 0.5, -6),
                    Parent = trackBG,
                    ZIndex = 11,
                })
                makeCorner(thumb, 99)
                makeStroke(thumb, Theme.AccentDim, 2, 0.3)

                -- Drag logic
                local draggingSlider = false

                local function updateSlider(inputX)
                    local trackAbsPos  = trackBG.AbsolutePosition.X
                    local trackAbsSize = trackBG.AbsoluteSize.X
                    local pct = clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
                    value = round(min + (max - min) * pct)
                    valueLabel.Text = tostring(value) .. suffix
                    tween(trackFill, Theme.Fast, { Size = UDim2.new(pct, 0, 1, 0) })
                    tween(thumb, Theme.Fast, { Position = UDim2.new(pct, -6, 0.5, -6) })
                    pcall(callback, value)
                end

                trackBG.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                        updateSlider(input.Position.X)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input.Position.X)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)

                wrap.MouseEnter:Connect(function()
                    tween(wrap, Theme.Fast, {
                        BackgroundColor3 = Color3.fromRGB(255,255,255),
                        BackgroundTransparency = 0.98,
                    })
                    tween(lbl, Theme.Fast, { TextColor3 = Color3.fromRGB(210,210,215) })
                end)
                wrap.MouseLeave:Connect(function()
                    tween(wrap, Theme.Fast, { BackgroundTransparency = 1 })
                    tween(lbl, Theme.Fast, { TextColor3 = Color3.fromRGB(180,180,180) })
                end)

                local SliderObj = {}
                function SliderObj:Set(v)
                    value = clamp(v, min, max)
                    local pct = (value - min) / (max - min)
                    valueLabel.Text = tostring(value) .. suffix
                    tween(trackFill, Theme.Fast, { Size = UDim2.new(pct, 0, 1, 0) })
                    tween(thumb, Theme.Fast, { Position = UDim2.new(pct, -6, 0.5, -6) })
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

                local wrap = newFrame({
                    BackgroundColor3 = Color3.fromRGB(0,0,0),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 58),
                    Parent = self._container,
                    ZIndex = 8,
                })
                wrap.LayoutOrder = nextOrder()
                makeCorner(wrap, 6)
                makePadding(wrap, 8, 10, 8, 10)

                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Color3.fromRGB(180,180,180),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, 0, 0, 20),
                    Parent = wrap,
                    ZIndex = 9,
                })

                local btnRow = newButton({
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    BackgroundTransparency = 0.93,
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 24),
                    TextColor3 = Color3.fromRGB(160,160,160),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 12,
                    Parent = wrap,
                    ZIndex = 9,
                })
                makeCorner(btnRow, 4)
                makeStroke(btnRow, Color3.fromRGB(255,255,255), 1, 0.9)
                makePadding(btnRow, 0, 6, 0, 8)

                local selLabel = newLabel({
                    Text = selected or "Select...",
                    TextColor3 = Color3.fromRGB(160,160,160),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 12,
                    Size = UDim2.new(1, -22, 1, 0),
                    Parent = btnRow,
                    ZIndex = 10,
                })
                selLabel.TextTruncate = Enum.TextTruncate.AtEnd

                local chevronLbl = newLabel({
                    Text = "▾",
                    TextColor3 = Color3.fromRGB(120,120,130),
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    Size = UDim2.new(0, 16, 1, 0),
                    Position = UDim2.new(1, -18, 0, 0),
                    Parent = btnRow,
                    ZIndex = 10,
                })

                -- Dropdown list (rendered above section in ZIndex)
                local listFrame = newFrame({
                    Name = "DropdownList",
                    BackgroundColor3 = Theme.BG_Dropdown,
                    BackgroundTransparency = 0,
                    Size = UDim2.new(1, 0, 0, math.min(#options, 5) * 28 + 8),
                    Position = UDim2.new(0, 0, 1, 4),
                    ClipsDescendants = true,
                    ZIndex = 50,
                    Parent = btnRow,
                })
                makeCorner(listFrame, 4)
                makeStroke(listFrame, Color3.fromRGB(255,255,255), 1, 0.9)
                makeListLayout(listFrame, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 0)
                makePadding(listFrame, 4, 6, 4, 6)
                listFrame.Visible = false
                listFrame.Size = UDim2.new(1, 0, 0, 0)

                for _, opt in ipairs(options) do
                    local optBtn = newButton({
                        BackgroundColor3 = Color3.fromRGB(0,0,0),
                        BackgroundTransparency = 1,
                        Text = opt,
                        TextColor3 = opt == selected and Theme.Accent or Color3.fromRGB(140,140,150),
                        Font = Enum.Font.GothamSemibold,
                        TextSize = 12,
                        Size = UDim2.new(1, 0, 0, 28),
                        Parent = listFrame,
                        ZIndex = 51,
                    })
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    makePadding(optBtn, 0, 0, 0, 8)
                    makeCorner(optBtn, 4)

                    optBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        selLabel.Text = opt
                        for _, child in ipairs(listFrame:GetChildren()) do
                            if child:IsA("TextButton") then
                                tween(child, Theme.Fast, {
                                    TextColor3 = child.Text == opt and Theme.Accent or Color3.fromRGB(140,140,150)
                                })
                            end
                        end
                        isOpen = false
                        tween(listFrame, Theme.Fast, { Size = UDim2.new(1, 0, 0, 0) })
                        task.delay(0.15, function() listFrame.Visible = false end)
                        tween(chevronLbl, Theme.Fast, { Rotation = 0 })
                        pcall(callback, opt)
                    end)

                    optBtn.MouseEnter:Connect(function()
                        tween(optBtn, Theme.Fast, {
                            BackgroundColor3 = Color3.fromRGB(255,255,255),
                            BackgroundTransparency = 0.95,
                        })
                    end)
                    optBtn.MouseLeave:Connect(function()
                        tween(optBtn, Theme.Fast, { BackgroundTransparency = 1 })
                    end)
                end

                btnRow.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        listFrame.Visible = true
                        tween(listFrame, Theme.Fast, {
                            Size = UDim2.new(1, 0, 0, math.min(#options, 5) * 28 + 8)
                        })
                        tween(chevronLbl, Theme.Fast, { Rotation = 180 })
                    else
                        tween(listFrame, Theme.Fast, { Size = UDim2.new(1, 0, 0, 0) })
                        task.delay(0.15, function() listFrame.Visible = false end)
                        tween(chevronLbl, Theme.Fast, { Rotation = 0 })
                    end
                end)

                wrap.MouseEnter:Connect(function()
                    tween(wrap, Theme.Fast, {
                        BackgroundColor3 = Color3.fromRGB(255,255,255),
                        BackgroundTransparency = 0.98,
                    })
                    tween(lbl, Theme.Fast, { TextColor3 = Color3.fromRGB(210,210,215) })
                end)
                wrap.MouseLeave:Connect(function()
                    tween(wrap, Theme.Fast, { BackgroundTransparency = 1 })
                    tween(lbl, Theme.Fast, { TextColor3 = Color3.fromRGB(180,180,180) })
                end)

                local DropdownObj = {}
                function DropdownObj:Set(opt)
                    selected = opt
                    selLabel.Text = opt
                    pcall(callback, opt)
                end
                function DropdownObj:Get() return selected end
                function DropdownObj:Refresh(newOptions)
                    for _, child in ipairs(listFrame:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, opt in ipairs(newOptions) do
                        local optBtn = newButton({
                            BackgroundColor3 = Color3.fromRGB(0,0,0),
                            BackgroundTransparency = 1,
                            Text = opt,
                            TextColor3 = opt == selected and Theme.Accent or Color3.fromRGB(140,140,150),
                            Font = Enum.Font.GothamSemibold,
                            TextSize = 12,
                            Size = UDim2.new(1, 0, 0, 28),
                            Parent = listFrame,
                            ZIndex = 51,
                        })
                        optBtn.TextXAlignment = Enum.TextXAlignment.Left
                        makePadding(optBtn, 0, 0, 0, 8)
                    end
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

                local row = newFrame({
                    BackgroundColor3 = Color3.fromRGB(0,0,0),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40),
                    Parent = self._container,
                    ZIndex = 8,
                })
                row.LayoutOrder = nextOrder()
                makeCorner(row, 6)
                makePadding(row, 0, 8, 0, 10)

                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Color3.fromRGB(180,180,180),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, -90, 1, 0),
                    Parent = row,
                    ZIndex = 9,
                })

                local keyBtn = newButton({
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    BackgroundTransparency = 0.95,
                    Text = currentKey.Name,
                    TextColor3 = Theme.TextFaint,
                    Font = Enum.Font.GothamBold,
                    TextSize = 10,
                    Size = UDim2.new(0, 78, 0, 24),
                    Position = UDim2.new(1, -86, 0.5, -12),
                    Parent = row,
                    ZIndex = 9,
                })
                makeCorner(keyBtn, 4)
                makeStroke(keyBtn, Color3.fromRGB(255,255,255), 1, 0.9)

                keyBtn.MouseButton1Click:Connect(function()
                    isBinding = not isBinding
                    if isBinding then
                        keyBtn.Text = "PRESS KEY..."
                        tween(keyBtn, Theme.Fast, {
                            BackgroundColor3 = Theme.AccentBG,
                            BackgroundTransparency = 0,
                            TextColor3 = Theme.Accent,
                        })
                        makeStroke(keyBtn, Theme.AccentDim, 1, 0.3)
                    else
                        keyBtn.Text = currentKey.Name
                        tween(keyBtn, Theme.Fast, {
                            BackgroundColor3 = Color3.fromRGB(255,255,255),
                            BackgroundTransparency = 0.95,
                            TextColor3 = Theme.TextFaint,
                        })
                    end
                end)

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if isBinding and not gameProcessed then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            isBinding = false
                            keyBtn.Text = currentKey.Name
                            tween(keyBtn, Theme.Fast, {
                                BackgroundColor3 = Color3.fromRGB(255,255,255),
                                BackgroundTransparency = 0.95,
                                TextColor3 = Theme.TextFaint,
                            })
                            pcall(callback, currentKey)
                        end
                    end
                end)

                row.MouseEnter:Connect(function()
                    tween(row, Theme.Fast, {
                        BackgroundColor3 = Color3.fromRGB(255,255,255),
                        BackgroundTransparency = 0.98,
                    })
                end)
                row.MouseLeave:Connect(function()
                    tween(row, Theme.Fast, { BackgroundTransparency = 1 })
                end)

                local KeybindObj = {}
                function KeybindObj:Set(key)
                    currentKey = key
                    keyBtn.Text = key.Name
                    pcall(callback, key)
                end
                function KeybindObj:Get() return currentKey end

                return KeybindObj
            end

            -- ── BUTTON ────────────────────────────────────
            function Section:CreateButton(config)
                config = config or {}
                local label    = config.Label    or "Button"
                local variant  = config.Variant  or "primary" -- primary | secondary | danger
                local callback = config.Callback or function() end

                local variantStyles = {
                    primary   = { bg = Theme.AccentBG,                   bgH = Theme.AccentBGHov,              text = Theme.Accent,                    border = Theme.AccentDim },
                    secondary = { bg = Color3.fromRGB(22,24,28),         bgH = Color3.fromRGB(28,30,35),       text = Color3.fromRGB(160,160,170),      border = Color3.fromRGB(60,62,70) },
                    danger    = { bg = Color3.fromRGB(40,12,12),         bgH = Color3.fromRGB(55,16,16),       text = Theme.Danger,                     border = Color3.fromRGB(120,40,40) },
                }
                local style = variantStyles[variant] or variantStyles.primary

                local wrap = newFrame({
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 48),
                    Parent = self._container,
                    ZIndex = 8,
                })
                wrap.LayoutOrder = nextOrder()
                makePadding(wrap, 6, 8, 6, 8)

                local btn = newButton({
                    BackgroundColor3 = style.bg,
                    BackgroundTransparency = 0,
                    Text = string.upper(label),
                    TextColor3 = style.text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = wrap,
                    ZIndex = 9,
                })
                makeCorner(btn, 6)
                makeStroke(btn, style.border, 1, 0.4)

                btn.MouseEnter:Connect(function()
                    tween(btn, Theme.Fast, { BackgroundColor3 = style.bgH })
                end)
                btn.MouseLeave:Connect(function()
                    tween(btn, Theme.Fast, { BackgroundColor3 = style.bg })
                end)
                btn.MouseButton1Down:Connect(function()
                    tween(btn, Theme.Fast, { Size = UDim2.new(0.97, 0, 0.95, 0), Position = UDim2.new(0.015, 0, 0.025, 0) })
                end)
                btn.MouseButton1Up:Connect(function()
                    tween(btn, Theme.Fast, { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0) })
                end)
                btn.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)

                local BtnObj = {}
                function BtnObj:SetLabel(text)
                    btn.Text = string.upper(text)
                end

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

                local row = newFrame({
                    BackgroundColor3 = Color3.fromRGB(0,0,0),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40),
                    Parent = self._container,
                    ZIndex = 8,
                })
                row.LayoutOrder = nextOrder()
                makeCorner(row, 6)
                makePadding(row, 0, 8, 0, 10)

                local lbl = newLabel({
                    Text = label,
                    TextColor3 = Color3.fromRGB(180,180,180),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, -100, 1, 0),
                    Parent = row,
                    ZIndex = 9,
                })

                local hexLabel = newLabel({
                    Text = colorToHex(currentColor),
                    TextColor3 = Theme.TextFaint,
                    Font = Enum.Font.GothamBold,
                    TextSize = 9,
                    Size = UDim2.new(0, 58, 1, 0),
                    Position = UDim2.new(1, -92, 0, 0),
                    Parent = row,
                    ZIndex = 9,
                })
                hexLabel.TextXAlignment = Enum.TextXAlignment.Right

                local swatch = newButton({
                    BackgroundColor3 = currentColor,
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(1, -32, 0.5, -12),
                    Parent = row,
                    ZIndex = 9,
                })
                makeCorner(swatch, 4)
                makeStroke(swatch, Color3.fromRGB(255,255,255), 1, 0.85)

                -- Color picker panel (simplified: RGB sliders)
                local pickerPanel = newFrame({
                    BackgroundColor3 = Theme.BG_Dropdown,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 4),
                    ZIndex = 40,
                    Parent = row,
                    ClipsDescendants = true,
                })
                makeCorner(pickerPanel, 6)
                makeStroke(pickerPanel, Color3.fromRGB(255,255,255), 1, 0.9)
                makePadding(pickerPanel, 8, 8, 8, 8)
                pickerPanel.Visible = false

                local panelLayout = makeListLayout(pickerPanel, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 6)
                _ = panelLayout

                local channels = {
                    { name = "R", color = Color3.fromRGB(220,70,70),  getter = function(c) return math.floor(c.R*255) end, setter = function(c,v) return Color3.fromRGB(v, math.floor(c.G*255), math.floor(c.B*255)) end },
                    { name = "G", color = Color3.fromRGB(70,200,80),  getter = function(c) return math.floor(c.G*255) end, setter = function(c,v) return Color3.fromRGB(math.floor(c.R*255), v, math.floor(c.B*255)) end },
                    { name = "B", color = Color3.fromRGB(70,120,220), getter = function(c) return math.floor(c.B*255) end, setter = function(c,v) return Color3.fromRGB(math.floor(c.R*255), math.floor(c.G*255), v) end },
                }

                local channelSliders = {}

                for _, ch in ipairs(channels) do
                    local chRow = newFrame({
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        Parent = pickerPanel,
                        ZIndex = 41,
                    })
                    makeListLayout(chRow, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 6)

                    newLabel({
                        Text = ch.name,
                        TextColor3 = ch.color,
                        Font = Enum.Font.GothamBold,
                        TextSize = 10,
                        Size = UDim2.new(0, 10, 1, 0),
                        Parent = chRow,
                        ZIndex = 42,
                    })

                    local trackBG2 = newFrame({
                        BackgroundColor3 = Color3.fromRGB(255,255,255),
                        BackgroundTransparency = 0.9,
                        Size = UDim2.new(1, -50, 0, 6),
                        Parent = chRow,
                        ZIndex = 42,
                    })
                    makeCorner(trackBG2, 99)

                    local fillPct2 = ch.getter(currentColor) / 255
                    local fill2 = newFrame({
                        BackgroundColor3 = ch.color,
                        Size = UDim2.new(fillPct2, 0, 1, 0),
                        Parent = trackBG2,
                        ZIndex = 43,
                    })
                    makeCorner(fill2, 99)

                    local valLbl = newLabel({
                        Text = tostring(ch.getter(currentColor)),
                        TextColor3 = Theme.TextFaint,
                        Font = Enum.Font.GothamBold,
                        TextSize = 9,
                        Size = UDim2.new(0, 30, 1, 0),
                        Parent = chRow,
                        ZIndex = 42,
                    })
                    valLbl.TextXAlignment = Enum.TextXAlignment.Right

                    local draggingCh = false
                    trackBG2.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            draggingCh = true
                            local pct = clamp((input.Position.X - trackBG2.AbsolutePosition.X) / trackBG2.AbsoluteSize.X, 0, 1)
                            local v = math.floor(pct * 255)
                            valLbl.Text = tostring(v)
                            tween(fill2, Theme.Fast, { Size = UDim2.new(pct, 0, 1, 0) })
                            currentColor = ch.setter(currentColor, v)
                            tween(swatch, Theme.Fast, { BackgroundColor3 = currentColor })
                            hexLabel.Text = colorToHex(currentColor)
                            pcall(callback, currentColor)
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if draggingCh and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local pct = clamp((input.Position.X - trackBG2.AbsolutePosition.X) / trackBG2.AbsoluteSize.X, 0, 1)
                            local v = math.floor(pct * 255)
                            valLbl.Text = tostring(v)
                            tween(fill2, Theme.Fast, { Size = UDim2.new(pct, 0, 1, 0) })
                            currentColor = ch.setter(currentColor, v)
                            tween(swatch, Theme.Fast, { BackgroundColor3 = currentColor })
                            hexLabel.Text = colorToHex(currentColor)
                            pcall(callback, currentColor)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            draggingCh = false
                        end
                    end)

                    table.insert(channelSliders, { fill = fill2, valLbl = valLbl, ch = ch })
                end

                swatch.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    if pickerOpen then
                        pickerPanel.Visible = true
                        -- Update sliders to current color
                        for _, cs in ipairs(channelSliders) do
                            local v = cs.ch.getter(currentColor)
                            cs.valLbl.Text = tostring(v)
                            tween(cs.fill, Theme.Fast, { Size = UDim2.new(v/255, 0, 1, 0) })
                        end
                        tween(pickerPanel, Theme.Fast, { Size = UDim2.new(1, 0, 0, 100) })
                    else
                        tween(pickerPanel, Theme.Fast, { Size = UDim2.new(1, 0, 0, 0) })
                        task.delay(0.15, function() pickerPanel.Visible = false end)
                    end
                end)

                row.MouseEnter:Connect(function()
                    tween(row, Theme.Fast, {
                        BackgroundColor3 = Color3.fromRGB(255,255,255),
                        BackgroundTransparency = 0.98,
                    })
                end)
                row.MouseLeave:Connect(function()
                    tween(row, Theme.Fast, { BackgroundTransparency = 1 })
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

            -- ── TEXT FIELD ────────────────────────────────
            function Section:CreateTextField(config)
                config = config or {}
                local label       = config.Label       or "Input"
                local placeholder = config.Placeholder or ""
                local default     = config.Default     or ""
                local callback    = config.Callback    or function() end

                local wrap = newFrame({
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 60),
                    Parent = self._container,
                    ZIndex = 8,
                })
                wrap.LayoutOrder = nextOrder()
                makePadding(wrap, 6, 10, 6, 10)
                makeListLayout(wrap, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 4)

                newLabel({
                    Text = label,
                    TextColor3 = Color3.fromRGB(180,180,180),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    Size = UDim2.new(1, 0, 0, 18),
                    Parent = wrap,
                    ZIndex = 9,
                })

                local inputBox = Instance.new("TextBox")
                inputBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
                inputBox.BackgroundTransparency = 0.93
                inputBox.BorderSizePixel = 0
                inputBox.Size = UDim2.new(1, 0, 0, 26)
                inputBox.Text = default
                inputBox.PlaceholderText = placeholder
                inputBox.TextColor3 = Color3.fromRGB(170,170,180)
                inputBox.PlaceholderColor3 = Theme.TextFaint
                inputBox.Font = Enum.Font.GothamSemibold
                inputBox.TextSize = 12
                inputBox.TextXAlignment = Enum.TextXAlignment.Left
                inputBox.ClearTextOnFocus = false
                inputBox.Parent = wrap
                inputBox.ZIndex = 9
                makeCorner(inputBox, 4)
                makeStroke(inputBox, Color3.fromRGB(255,255,255), 1, 0.9)
                makePadding(inputBox, 0, 6, 0, 8)

                inputBox.Focused:Connect(function()
                    tween(inputBox, Theme.Fast, {
                        BackgroundTransparency = 0.88,
                    })
                    -- Animate stroke color change
                    for _, s in ipairs(inputBox:GetChildren()) do
                        if s:IsA("UIStroke") then
                            tween(s, Theme.Fast, {
                                Color = Theme.AccentDim,
                                Transparency = 0.4,
                            })
                        end
                    end
                end)

                inputBox.FocusLost:Connect(function(enterPressed)
                    tween(inputBox, Theme.Fast, { BackgroundTransparency = 0.93 })
                    for _, s in ipairs(inputBox:GetChildren()) do
                        if s:IsA("UIStroke") then
                            tween(s, Theme.Fast, {
                                Color = Color3.fromRGB(255,255,255),
                                Transparency = 0.9,
                            })
                        end
                    end
                    if enterPressed then
                        pcall(callback, inputBox.Text)
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

            -- ── LABEL (read-only info) ─────────────────────
            function Section:CreateLabel(config)
                config = config or {}
                local text  = config.Text  or ""
                local color = config.Color or Theme.TextDim

                local wrap = newFrame({
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Parent = self._container,
                    ZIndex = 8,
                })
                wrap.LayoutOrder = nextOrder()
                makePadding(wrap, 4, 10, 4, 10)

                local lbl = newLabel({
                    Text = text,
                    TextColor3 = color,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = wrap,
                    ZIndex = 9,
                })
                lbl.TextWrapped = true

                local LabelObj = {}
                function LabelObj:Set(newText)
                    lbl.Text = newText
                end

                return LabelObj
            end

            -- ── SEPARATOR ─────────────────────────────────
            function Section:CreateSeparator()
                local sep = newFrame({
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    BackgroundTransparency = 0.92,
                    Size = UDim2.new(1, -16, 0, 1),
                    Parent = self._container,
                    ZIndex = 8,
                })
                sep.LayoutOrder = nextOrder()
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

