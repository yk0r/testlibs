--[[
    Friendship.Lua - Example Usage Script
    
    This script demonstrates how to use FriendshipLua UI Library.
    Paste the entire FriendshipLua.lua content above this, then use as shown.
    
    OR load via executor:
        local Library = loadstring(game:HttpGet("YOUR_RAWGIT_URL"))()
]]

-- ====================================================
--  LOAD LIBRARY
--  Method 1: loadstring (recommended for executors)
--    local Library = loadstring(game:HttpGet("YOUR_RAW_URL"))()
--  
--  Method 2: require (if placed as a LocalScript/ModuleScript)
--    local Library = require(script.Parent.FriendshipLua)
--
--  Method 3: Direct execution — after running FriendshipLua.lua,
--    the library is available as _G.FriendshipLib
-- ====================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/yk0r/testlibs/refs/heads/main/FriendshipLua.lua"))()
if not Library then
    -- Fallback: try to load via require if it's a sibling module
    local ok, lib = pcall(function()
        return require(script.Parent:FindFirstChild("FriendshipLua"))
    end)
    if ok and lib then
        Library = lib
    else
        warn("[Friendship.Lua] Failed to load library!")
        warn("Make sure FriendshipLua.lua is executed BEFORE this script,")
        warn("or change the loadstring URL below and use Method 1.")
        return
    end
end

-- ====================================================
--  CREATE WINDOW
-- ====================================================
local Window = Library:CreateWindow({
    Title      = "Friendship.Lua",    -- displayed as "Friendship" + ".Lua" in accent
    SubTitle   = "Premium Scripts",
    Size       = UDim2.fromOffset(700, 450),
    Position   = UDim2.new(0.5, -350, 0.5, -225),
    ToggleKey  = Enum.KeyCode.RightShift,  -- key to show/hide UI
})

-- ====================================================
--  TAB: COMBAT
-- ====================================================
local CombatTab = Window:CreateTab("Combat", "")   -- leave icon "" for default dot

-- Section: Aimbot Settings
local AimbotSection = CombatTab:CreateSection("Aimbot Settings")

local aimbotEnabled = false
local AimbotToggle = AimbotSection:CreateToggle({
    Label       = "Enabled",
    Description = "Automatically aim at targets",
    Default     = false,
    Callback    = function(value)
        aimbotEnabled = value
        -- your aimbot enable/disable logic here
    end
})

local AimbotKey = AimbotSection:CreateKeybind({
    Label    = "Aimbot Key",
    Default  = Enum.KeyCode.Q,
    Callback = function(key)
        print("Aimbot key set to:", key.Name)
    end
})

local FOVSlider = AimbotSection:CreateSlider({
    Label    = "FOV Size",
    Min      = 0,
    Max      = 360,
    Default  = 120,
    Suffix   = "°",
    Callback = function(value)
        -- update your FOV circle size
    end
})

local SmoothSlider = AimbotSection:CreateSlider({
    Label    = "Smoothing",
    Min      = 1,
    Max      = 20,
    Default  = 5,
    Callback = function(value)
        -- update aimbot smoothing
    end
})

local TargetDrop = AimbotSection:CreateDropdown({
    Label    = "Target Part",
    Options  = {"Head", "Torso", "Random", "Nearest"},
    Default  = "Head",
    Callback = function(value)
        print("Targeting:", value)
    end
})

-- Section: Trigger Bot
local TriggerSection = CombatTab:CreateSection("Trigger Bot")

TriggerSection:CreateToggle({
    Label    = "Enabled",
    Description = "Automatically shoot when target is in crosshair",
    Default  = false,
    Callback = function(value)
        -- trigger bot logic
    end
})

TriggerSection:CreateSlider({
    Label    = "Delay",
    Min      = 0,
    Max      = 1000,
    Default  = 0,
    Suffix   = "ms",
    Callback = function(value) end
})

TriggerSection:CreateToggle({
    Label   = "Team Check",
    Default = true,
    Callback = function(value) end
})

-- ====================================================
--  TAB: VISUALS
-- ====================================================
local VisualsTab = Window:CreateTab("Visuals", "")

local ESPSection = VisualsTab:CreateSection("ESP Main")

local espEnabled = true
ESPSection:CreateToggle({
    Label   = "ESP Enabled",
    Default = true,
    Callback = function(value)
        espEnabled = value
    end
})

ESPSection:CreateToggle({
    Label   = "Box ESP",
    Default = true,
    Callback = function(value) end
})

ESPSection:CreateColorPicker({
    Label    = "Box Color",
    Default  = Color3.fromRGB(76, 201, 240),
    Callback = function(color)
        -- update ESP box color
    end
})

ESPSection:CreateToggle({
    Label   = "Tracer Lines",
    Default = false,
    Callback = function(value) end
})

ESPSection:CreateDropdown({
    Label   = "Tracer Origin",
    Options = {"Bottom", "Center", "Mouse"},
    Default = "Bottom",
    Callback = function(value) end
})

local ESPExtras = VisualsTab:CreateSection("ESP Extras")

ESPExtras:CreateToggle({
    Label   = "Name ESP",
    Default = true,
    Callback = function(value) end
})

ESPExtras:CreateToggle({
    Label   = "Health Bar",
    Default = true,
    Callback = function(value) end
})

ESPExtras:CreateToggle({
    Label   = "Distance ESP",
    Default = false,
    Callback = function(value) end
})

ESPExtras:CreateSlider({
    Label   = "Max Distance",
    Min     = 100,
    Max     = 10000,
    Default = 2500,
    Suffix  = " studs",
    Callback = function(value) end
})

-- ====================================================
--  TAB: MOVEMENT
-- ====================================================
local MovementTab = Window:CreateTab("Movement", "")

local MoveSection = MovementTab:CreateSection("Movement Mods")

MoveSection:CreateToggle({
    Label   = "Speed Hack",
    Default = false,
    Callback = function(value)
        if value then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

MoveSection:CreateSlider({
    Label   = "Walk Speed",
    Min     = 16,
    Max     = 250,
    Default = 16,
    Callback = function(value)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        end)
    end
})

MoveSection:CreateToggle({
    Label   = "Infinite Jump",
    Default = false,
    Callback = function(value)
        game:GetService("UserInputService").JumpRequest:Connect(function()
            if value then
                pcall(function()
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
        end)
    end
})

MoveSection:CreateToggle({
    Label   = "No Clip",
    Default = false,
    Callback = function(value)
        -- noclip logic via RunService
    end
})

MoveSection:CreateKeybind({
    Label   = "Fly Keybind",
    Default = Enum.KeyCode.F,
    Callback = function(key) end
})

local TeleportSection = MovementTab:CreateSection("Teleportation")

TeleportSection:CreateTextField({
    Label       = "Coordinates",
    Placeholder = "0, 0, 0",
    Callback    = function(text)
        print("Input:", text)
    end
})

TeleportSection:CreateButton({
    Label   = "Teleport To Center",
    Variant = "secondary",
    Callback = function()
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            char:MoveTo(Vector3.new(0, 5, 0))
        end)
    end
})

TeleportSection:CreateButton({
    Label   = "Teleport To Target",
    Variant = "primary",
    Callback = function()
        -- your target teleport logic
        Library:Notify({
            Title    = "Teleport",
            Content  = "Teleporting to nearest player...",
            Duration = 2,
        })
    end
})

-- ====================================================
--  TAB: MISC
-- ====================================================
local MiscTab = Window:CreateTab("Misc", "")

local SelfSection = MiscTab:CreateSection("Self")

SelfSection:CreateToggle({
    Label   = "God Mode",
    Default = false,
    Callback = function(value) end
})

SelfSection:CreateToggle({
    Label   = "No Fall Damage",
    Default = true,
    Callback = function(value) end
})

SelfSection:CreateToggle({
    Label   = "Auto Respawn",
    Default = false,
    Callback = function(value) end
})

local GameSection = MiscTab:CreateSection("Game")

GameSection:CreateToggle({
    Label   = "Remove Fog",
    Default = false,
    Callback = function(value)
        pcall(function()
            game:GetService("Lighting").FogEnd = value and 1e9 or 1000
        end)
    end
})

GameSection:CreateToggle({
    Label   = "Full Bright",
    Default = false,
    Callback = function(value)
        pcall(function()
            game:GetService("Lighting").Brightness = value and 5 or 1
            game:GetService("Lighting").Ambient = value and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
        end)
    end
})

GameSection:CreateSeparator()

GameSection:CreateButton({
    Label   = "Rejoin Server",
    Variant = "secondary",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})

GameSection:CreateButton({
    Label   = "Hop Server",
    Variant = "primary",
    Callback = function()
        -- server hop logic
    end
})

-- ====================================================
--  TAB: SETTINGS
-- ====================================================
local SettingsTab = Window:CreateTab("Settings", "")

local UISection = SettingsTab:CreateSection("Interface")

UISection:CreateColorPicker({
    Label    = "Accent Color",
    Default  = Color3.fromRGB(76, 201, 240),
    Callback = function(color)
        -- dynamically update accent (advanced - would require re-theming)
    end
})

UISection:CreateSlider({
    Label   = "UI Transparency",
    Min     = 0,
    Max     = 100,
    Default = 5,
    Suffix  = "%",
    Callback = function(value) end
})

UISection:CreateToggle({
    Label   = "Blur Background",
    Default = true,
    Callback = function(value) end
})

local ConfigSection = SettingsTab:CreateSection("Configuration")

ConfigSection:CreateButton({
    Label   = "Save Config",
    Variant = "primary",
    Callback = function()
        -- save to writefile / config system
        Library:Notify({
            Title   = "Config",
            Content = "Configuration saved successfully.",
            Duration = 3,
        })
    end
})

ConfigSection:CreateButton({
    Label   = "Load Config",
    Variant = "secondary",
    Callback = function()
        Library:Notify({
            Title   = "Config",
            Content = "Configuration loaded.",
            Duration = 3,
        })
    end
})

ConfigSection:CreateButton({
    Label   = "Reset Defaults",
    Variant = "danger",
    Callback = function()
        Library:Notify({
            Title   = "Config",
            Content = "Settings reset to defaults.",
            Duration = 3,
        })
    end
})

-- ====================================================
--  STARTUP NOTIFICATIONS
-- ====================================================
task.wait(1)
Library:Notify({
    Title   = "System",
    Content = "Friendship.Lua Loaded Successfully",
    Duration = 4,
})

task.wait(0.5)
Library:Notify({
    Title   = "System",
    Content = "Welcome back, " .. game.Players.LocalPlayer.Name,
    Duration = 4,
})
