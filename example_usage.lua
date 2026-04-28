--[[
    Friendship.Lua — Example Usage
    Tab icons use Lucide names (e.g. "swords", "eye", "zap", "settings")
    Full list: https://lucide.dev/icons
]]

-- ── Load Library & Icons ──────────────────────────────────
local Library = loadstring(game:HttpGet("https://github.com/yk0r/testlibs/raw/refs/heads/main/FriendshipUI.lua"))()

-- Load Lucide icon data (required for tab icons to show properly)
-- The library will try to auto-load from GitHub, but if that fails,
-- load it explicitly and pass it in:
local ok, IconData = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/latte-soft/lucide-roblox/master/lib/Icons.luau"))()
end)
if ok and IconData then
    Library:SetIconData(IconData)
end

-- ── Window ────────────────────────────────────────────
local Window = Library:CreateWindow({
    Title     = "Friendship.Lua",
    SubTitle  = "Premium Scripts",
    Size      = UDim2.fromOffset(700, 450),
    ToggleKey = Enum.KeyCode.RightShift,
})

-- ── Combat Tab ────────────────────────────────────────
local CombatTab = Window:CreateTab("Combat", "swords")

local Aimbot = CombatTab:CreateSection("Aimbot")

Aimbot:CreateToggle({
    Label    = "Enabled",
    Default  = false,
    Callback = function(v) end,
})

Aimbot:CreateKeybind({
    Label   = "Hotkey",
    Default = Enum.KeyCode.Q,
    Callback = function(key) end,
})

Aimbot:CreateSlider({
    Label   = "FOV",
    Min     = 0,
    Max     = 360,
    Default = 120,
    Suffix  = "°",
    Callback = function(v) end,
})

Aimbot:CreateDropdown({
    Label    = "Target Part",
    Options  = {"Head", "Torso", "Nearest"},
    Default  = "Head",
    Callback = function(v) end,
})

-- ── Visuals Tab ───────────────────────────────────────
local VisualsTab = Window:CreateTab("Visuals", "eye")

local ESP = VisualsTab:CreateSection("ESP")

ESP:CreateToggle({ Label = "Box ESP",    Default = true,  Callback = function() end })
ESP:CreateToggle({ Label = "Tracer",     Default = false, Callback = function() end })
ESP:CreateColorPicker({
    Label    = "Color",
    Default  = Color3.fromRGB(76, 201, 240),
    Callback = function(c) end,
})

ESP:CreateDropdown({
    Label    = "Tracer Origin",
    Options  = {"Bottom", "Center", "Mouse"},
    Default  = "Bottom",
    Callback = function(v) end,
})

ESP:CreateSlider({
    Label    = "Max Distance",
    Min      = 100, Max = 5000, Default = 2500,
    Suffix   = " studs",
    Callback = function(v) end,
})

-- ── Movement Tab ──────────────────────────────────────
local MoveTab = Window:CreateTab("Movement", "zap")

local Move = MoveTab:CreateSection("Movement")

Move:CreateToggle({
    Label    = "Speed Hack",
    Default  = false,
    Callback = function(v)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v and 50 or 16
        end)
    end,
})

Move:CreateSlider({
    Label    = "Walk Speed",
    Min      = 16, Max = 250, Default = 16,
    Callback = function(v)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
        end)
    end,
})

Move:CreateKeybind({
    Label   = "Fly",
    Default = Enum.KeyCode.F,
    Callback = function(key) end,
})

local Teleport = MoveTab:CreateSection("Teleport")

Teleport:CreateTextField({
    Label       = "Coordinates",
    Placeholder = "0, 0, 0",
    Callback    = function(text) end,
})

Teleport:CreateButton({
    Label    = "Go",
    Variant  = "primary",
    Callback = function()
        Library:Notify({ Title = "Teleport", Content = "Moving...", Duration = 2 })
    end,
})

-- ── Misc Tab ──────────────────────────────────────────
local MiscTab = Window:CreateTab("Misc", "settings")

local GameSection = MiscTab:CreateSection("Game")

GameSection:CreateToggle({
    Label    = "Full Bright",
    Default  = false,
    Callback = function(v)
        pcall(function()
            local l = game:GetService("Lighting")
            l.Brightness = v and 5 or 1
            l.Ambient    = v and Color3.new(1,1,1) or Color3.fromRGB(127,127,127)
        end)
    end,
})

GameSection:CreateToggle({
    Label    = "Remove Fog",
    Default  = false,
    Callback = function(v)
        pcall(function()
            game:GetService("Lighting").FogEnd = v and 1e9 or 1000
        end)
    end,
})

GameSection:CreateParagraph({
    Title   = "Note",
    Content = "Rendering changes may be detected by anti-cheat.",
})

GameSection:CreateButton({
    Label    = "Rejoin",
    Variant  = "secondary",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end,
})

GameSection:CreateButton({
    Label    = "Server Hop",
    Variant  = "primary",
    Callback = function() end,
})

-- ── Settings Tab ──────────────────────────────────────
local SettingsTab = Window:CreateTab("Settings", "sliders-horizontal")

local UI = SettingsTab:CreateSection("Interface")

UI:CreateColorPicker({
    Label    = "Accent Color",
    Default  = Color3.fromRGB(76, 201, 240),
    Callback = function(c) end,
})

UI:CreateSlider({
    Label    = "Transparency",
    Min      = 0, Max = 100, Default = 5,
    Suffix   = "%",
    Callback = function(v) end,
})

UI:CreateToggle({ Label = "Blur Background", Default = true, Callback = function() end })

local Config = SettingsTab:CreateSection("Config")

Config:CreateButton({
    Label    = "Save",
    Variant  = "primary",
    Callback = function()
        Library:Notify({ Title = "Config", Content = "Saved.", Duration = 2 })
    end,
})

Config:CreateButton({
    Label    = "Load",
    Variant  = "secondary",
    Callback = function()
        Library:Notify({ Title = "Config", Content = "Loaded.", Duration = 2 })
    end,
})

Config:CreateButton({
    Label    = "Reset",
    Variant  = "danger",
    Callback = function()
        Library:Notify({ Title = "Config", Content = "Reset to defaults.", Duration = 2 })
    end,
})

-- ── Startup ───────────────────────────────────────────
task.wait(0.5)
Library:Notify({ Title = "Friendship.Lua", Content = "Loaded ✓", Duration = 3 })
