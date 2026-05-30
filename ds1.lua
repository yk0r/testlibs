--!strict
--[[
    DEADCELL // ImGui UI Library for Roblox Client/Exploits
    Developed in Strict typed Luau. Inspired by DEADCELL's PC client.
    
    API Architecture:
        Library -> Window -> Tab -> Section -> Element
        
    Usage:
        local Library = require(path.to.DeadcellLibrary)
        local Window = Library:CreateWindow({ Title = "DEADCELL", Version = "SYS_v2.1.4" })
        local Tab = Window:CreateTab("Visuals")
        local Section = Tab:CreateSection("Overlay")
        Section:CreateToggle({
            Name = "Enable",
            Default = true,
            Callback = function(state) print("Enable State:", state) end
        })
--]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Custom Types for Strict Type Checking
export type WindowConfig = {
    Title: string,
    Version: string?,
}

export type ToggleConfig = {
    Name: string,
    Default: boolean?,
    Color: Color3?,
    Callback: (boolean, Color3?) -> (),
}

export type SliderConfig = {
    Name: string,
    Min: number,
    Max: number,
    Default: number,
    Suffix: string?,
    Callback: (number) -> (),
}

export type DropdownConfig = {
    Name: string,
    Options: {string},
    Default: string?,
    Callback: (string) -> (),
}

export type KeybindConfig = {
    Name: string,
    Default: Enum.KeyCode?,
    Callback: (Enum.KeyCode) -> (),
}

export type ToggleElement = {
    Set: (self: ToggleElement, state: boolean, color: Color3?) -> (),
    Get: (self: ToggleElement) -> (boolean, Color3?),
}

export type SliderElement = {
    Set: (self: SliderElement, value: number) -> (),
    Get: (self: SliderElement) -> number,
}

export type DropdownElement = {
    Set: (self: DropdownElement, option: string) -> (),
    Get: (self: DropdownElement) -> string,
    Refresh: (self: DropdownElement, options: {string}, default: string?) -> (),
}

export type KeybindElement = {
    Set: (self: KeybindElement, key: Enum.KeyCode) -> (),
    Get: (self: KeybindElement) -> Enum.KeyCode,
}

-- Theme Palette Colors matching the DEADCELL Screenshot exactly
local Theme = {
    BG_Base = Color3.fromRGB(18, 21, 28),         -- #12151c
    BG_Window = Color3.fromRGB(29, 34, 43),       -- #1d222b
    BG_Sidebar = Color3.fromRGB(22, 26, 33),      -- #161a21
    BG_Panel = Color3.fromRGB(22, 26, 33),        -- #161a21
    BG_Element = Color3.fromRGB(17, 20, 26),      -- #11141a
    BG_Hover = Color3.fromRGB(35, 42, 54),        -- Elements hover state
    
    Accent = Color3.fromRGB(226, 88, 107),        -- DEADCELL Pink-Red checked accent (#e2586b)
    BlueAccent = Color3.fromRGB(59, 130, 246),    -- Blue trigger text (#3b82f6)
    StatusGreen = Color3.fromRGB(46, 204, 113),   -- Active Status Green (#2ecc71)
    
    Text_Main = Color3.fromRGB(209, 216, 224),    -- #d1d8e0
    Text_Muted = Color3.fromRGB(106, 118, 140),   -- #6a768c
    Text_White = Color3.fromRGB(255, 255, 255),
    
    Border_Light = Color3.fromRGB(40, 47, 60),    -- #282f3c
    Border_Focus = Color3.fromRGB(62, 72, 92),    -- #3e485c
}

-- Helper function to parent GUI safely in exploits or local environments
local function getGuiParent(): Instance
    local success, localPlayer = pcall(function() return Players.LocalPlayer end)
    if success and localPlayer then
        local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
        if playerGui then return playerGui end
    end
    
    -- Exploit environment fallback
    local getHui = (window or getgenv or _G).gethui
    if getHui then
        return getHui()
    end
    
    return CoreGui
end

-- Fast UI Construction Helper
local function create(className: string, properties: {[string]: any}, children: {Instance}?): any
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    return inst
end

-- Handle Window Dragging with Inertia
local function makeDraggable(windowFrame: Frame, dragHeader: Frame)
    local dragInput: InputObject?
    local dragStart: Vector3?
    local startPos: UDim2?

    local function update(input: InputObject)
        if not dragStart or not startPos then return end
        local delta = input.Position - dragStart
        windowFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    dragHeader.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = windowFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStart = nil
                    startPos = nil
                end
            end)
        end
    end)

    dragHeader.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragStart then
            update(input)
        end
    end)
end

-- Core Library Exporter
local DeadcellLibrary = {}

function DeadcellLibrary:CreateWindow(config: WindowConfig)
    local ScreenGui = create("ScreenGui", {
        Name = "DeadcellImGui",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
    })
    
    -- Attempt to hide/protect GUI in exploit envs
    local success, protect = pcall(function() return (syn and syn.protect_gui) or (rprotectgui) end)
    if success and protect then
        protect(ScreenGui)
    end
    ScreenGui.Parent = getGuiParent()

    -- Main Frame Outer Shell
    local MainFrame = create("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(0, 850, 0, 610),
        Position = UDim2.new(0.5, -425, 0.5, -305),
        BackgroundColor3 = Theme.BG_Window,
        BorderSizePixel = 1,
        BorderColor3 = Theme.Border_Light,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 4) })
    })
    MainFrame.Parent = ScreenGui

    -- Window Header Faceplate
    local Header = create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = Theme.BG_Sidebar,
        BorderSizePixel = 0,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        -- Conceal lower corners to keep sidebar look
        create("Frame", {
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 1, -4),
            BackgroundColor3 = Theme.BG_Sidebar,
            BorderSizePixel = 0,
        })
    })
    Header.Parent = MainFrame

    -- DEADCELL Title Text (Exactly matching the bold uppercase font)
    local Title = create("TextLabel", {
        Text = config.Title:upper(),
        Size = UDim2.new(0, 150, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text_White,
        TextSize = 16,
        Font = Enum.Font.SourceSansBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    Title.Parent = Header

    -- Main Tabs Row container (Top Right aligned)
    local TabsContainer = create("Frame", {
        Name = "TabsRow",
        Size = UDim2.new(1, -180, 1, 0),
        Position = UDim2.new(0, 160, 0, 0),
        BackgroundTransparency = 1,
    }, {
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
        })
    })
    TabsContainer.Parent = Header

    -- Sub Header (Welcome banner & sub-tabs)
    local SubHeader = create("Frame", {
        Name = "SubHeader",
        Size = UDim2.new(1, 0, 0, 38),
        Position = UDim2.new(0, 0, 0, 52),
        BackgroundColor3 = Color3.fromRGB(26, 31, 38),
        BorderSizePixel = 0,
    })
    SubHeader.Parent = MainFrame
    
    -- SubHeader bottom border line
    create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border_Light,
        BorderSizePixel = 0,
    }).Parent = SubHeader

    -- Welcome label
    local WelcomeLabel = create("TextLabel", {
        Text = "Welcome admin!",
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text_Muted,
        TextSize = 11,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    WelcomeLabel.Parent = SubHeader

    -- Sub-Tabs and Attached Status indicators grouped
    local SubTabsRow = create("Frame", {
        Name = "SubTabsRow",
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 130, 0, 0),
        BackgroundTransparency = 1,
    }, {
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 16),
        })
    })
    SubTabsRow.Parent = SubHeader

    -- Create Status Attached pill exactly like the screen
    local AttachedPill = create("Frame", {
        Size = UDim2.new(0, 80, 0, 20),
        BackgroundTransparency = 1,
        LayoutOrder = 999,
    }, {
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
        }),
        -- Green Status Dot
        create("Frame", {
            Size = UDim2.new(0, 6, 0, 6),
            BackgroundColor3 = Theme.StatusGreen,
            BorderSizePixel = 0,
        }, {
            create("UICorner", { CornerRadius = UDim.new(1, 0) })
        }),
        -- Attached Text
        create("TextLabel", {
            Text = "Attached",
            Size = UDim2.new(0, 50, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text_Muted,
            TextSize = 11,
            Font = Enum.Font.SourceSansBold,
        })
    })
    AttachedPill.Parent = SubTabsRow

    -- Viewport Workspace Container
    local Viewport = create("Frame", {
        Name = "Viewport",
        Size = UDim2.new(1, 0, 1, -90),
        Position = UDim2.new(0, 0, 0, 90),
        BackgroundTransparency = 1,
    })
    Viewport.Parent = MainFrame

    -- Watermark link overlay bottom right
    local Watermark = create("TextButton", {
        Name = "Watermark",
        Text = "https://github.com/KingsleydotDev/ImGuiHub/",
        Size = UDim2.new(0, 230, 0, 20),
        Position = UDim2.new(1, -242, 1, -32),
        BackgroundColor3 = Theme.BG_Element,
        BorderColor3 = Color3.fromRGB(46, 134, 222), -- Vivid blue border
        BorderSizePixel = 1,
        TextColor3 = Color3.fromRGB(52, 152, 219), -- Light blue text
        TextSize = 10,
        Font = Enum.Font.Code,
        AutoButtonColor = false,
        ZIndex = 9999,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 4) })
    })
    Watermark.Parent = MainFrame
    Watermark.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard("https://github.com/KingsleydotDev/ImGuiHub/")
        end
    end)

    -- Draggable Binding
    makeDraggable(MainFrame, Header)

    -- Window Class Instance definition
    local Window = {
        Frame = MainFrame,
        Tabs = {},
        ActiveTab = nil,
    }

    function Window:CreateTab(name: string)
        local TabFrame = create("Frame", {
            Name = "TabContent_" .. name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
        })
        TabFrame.Parent = Viewport

        -- Scrolling Container within the tab for sections
        local Scroll = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Border_Light,
        })
        Scroll.Parent = TabFrame

        -- Dual-column structure inside the ScrollFrame
        local SplitColumns = create("Frame", {
            Size = UDim2.new(1, -32, 1, -32),
            Position = UDim2.new(0, 16, 0, 16),
            BackgroundTransparency = 1,
        }, {
            -- Left Column
            create("Frame", {
                Name = "LeftColumn",
                Size = UDim2.new(0.5, -7, 1, 0),
                BackgroundTransparency = 1,
            }, {
                create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    Padding = UDim.new(0, 14),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
            }),
            -- Right Column
            create("Frame", {
                Name = "RightColumn",
                Size = UDim2.new(0.5, -7, 1, 0),
                Position = UDim2.new(0.5, 7, 0, 0),
                BackgroundTransparency = 1,
            }, {
                create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    Padding = UDim.new(0, 14),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
            })
        })
        SplitColumns.Parent = Scroll

        -- Automatically manage scroll canvas height to encapsulate dual columns
        local leftLayout = SplitColumns.LeftColumn.UIListLayout
        local rightLayout = SplitColumns.RightColumn.UIListLayout
        local function updateCanvas()
            local height = math.max(leftLayout.AbsoluteContentSize.Y, rightLayout.AbsoluteContentSize.Y) + 40
            Scroll.CanvasSize = UDim2.new(0, 0, 0, height)
        end
        leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

        -- Create navigation button top right
        local TabButton = create("TextButton", {
            Name = "TabBtn_" .. name,
            Text = name,
            Size = UDim2.new(0, 80, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text_Muted,
            TextSize = 12.5,
            Font = Enum.Font.SourceSansBold,
            AutoButtonColor = false,
        })
        TabButton.Parent = TabsContainer

        local Tab = {
            Frame = TabFrame,
            LeftCol = SplitColumns.LeftColumn,
            RightCol = SplitColumns.RightColumn,
            SectionCount = 0,
        }

        local function activate()
            if Window.ActiveTab then
                Window.ActiveTab.Frame.Visible = false
                Window.ActiveTab.Button.TextColor3 = Theme.Text_Muted
                Window.ActiveTab.Button.BackgroundTransparency = 1
            end
            TabFrame.Visible = true
            TabButton.TextColor3 = Theme.Text_White
            TabButton.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = Theme.BG_Window
            Window.ActiveTab = Tab
        end

        TabButton.MouseButton1Click:Connect(activate)
        Tab.Button = TabButton

        -- Default activate first tab
        if not Window.ActiveTab then
            activate()
        end

        -- Section Factory Within Tab
        function Tab:CreateSection(sectionName: string)
            Tab.SectionCount += 1
            -- Decide column placement based on balancing count
            local targetColumn = (Tab.SectionCount % 2 == 1) and Tab.LeftCol or Tab.RightCol

            local SectionFrame = create("Frame", {
                Name = "Section_" .. sectionName,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.BG_Panel,
                BorderColor3 = Theme.Border_Light,
                BorderSizePixel = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
            }, {
                create("UICorner", { CornerRadius = UDim.new(0, 3) })
            })
            SectionFrame.Parent = targetColumn

            local SectionHeader = create("Frame", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Color3.fromRGB(22, 26, 33), -- Muted title block
                BorderSizePixel = 0,
            }, {
                create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                create("TextLabel", {
                    Text = sectionName,
                    Size = UDim2.new(1, -12, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.Text_White,
                    TextSize = 11.5,
                    Font = Enum.Font.SourceSansBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
            })
            SectionHeader.Parent = SectionFrame

            local Body = create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 26),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
            }, {
                create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10),
                }),
                create("UIPadding", {
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                    PaddingTop = UDim.new(0, 12),
                    PaddingBottom = UDim.new(0, 12),
                })
            })
            Body.Parent = SectionFrame

            local Section = {}

            -- 1. Create Checkbox/Toggle Widget (Includes optional color picker & details trigger)
            function Section:CreateToggle(elementConfig: ToggleConfig)
                local valueState = elementConfig.Default or false
                local activeColor = elementConfig.Color or Theme.Accent

                local ToggleRow = create("Frame", {
                    Name = "Toggle_" .. elementConfig.Name,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                })
                ToggleRow.Parent = Body

                -- Left group: Checkbox + Label Text
                local TriggerButton = create("TextButton", {
                    Size = UDim2.new(1, -40, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                })
                TriggerButton.Parent = ToggleRow

                -- The flat checkmark box itself
                local CheckboxBox = create("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 0, 0.5, -7),
                    BackgroundColor3 = Theme.BG_Element,
                    BorderColor3 = Theme.Border_Light,
                    BorderSizePixel = 1,
                }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 2) })
                })
                CheckboxBox.Parent = TriggerButton

                local Checkmark = create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Visible = valueState,
                }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 2) }),
                    create("TextLabel", {
                        Text = "✓",
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        TextColor3 = Theme.Text_White,
                        TextSize = 10,
                        Font = Enum.Font.SourceSansBold,
                    })
                })
                Checkmark.Parent = CheckboxBox

                local LabelText = create("TextLabel", {
                    Text = elementConfig.Name,
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 24, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.Text_Main,
                    TextSize = 11.5,
                    Font = Enum.Font.SourceSans,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                LabelText.Parent = TriggerButton

                -- Inline Color Picker rectangular block if requested
                local ColorPickerBtn
                if elementConfig.Color then
                    ColorPickerBtn = create("TextButton", {
                        Size = UDim2.new(0, 16, 0, 9),
                        Position = UDim2.new(1, -16, 0.5, -4),
                        BackgroundColor3 = activeColor,
                        BorderSizePixel = 1,
                        BorderColor3 = Color3.fromRGB(0,0,0),
                        Text = "",
                    })
                    ColorPickerBtn.Parent = ToggleRow
                    
                    -- Let user tap block to cycle through 6 preset ImGui colors
                    local presets = {
                        Color3.fromRGB(226, 88, 107), -- DEADCELL Pink/Red
                        Color3.fromRGB(159, 239, 0),   -- Lime Green
                        Color3.fromRGB(84, 160, 255),  -- Sky Blue
                        Color3.fromRGB(255, 255, 255), -- White
                        Color3.fromRGB(255, 118, 117), -- Coral Red
                        Color3.fromRGB(162, 155, 254)  -- Purple
                    }
                    local currentIdx = 1
                    ColorPickerBtn.MouseButton1Click:Connect(function()
                        currentIdx = (currentIdx % #presets) + 1
                        activeColor = presets[currentIdx]
                        ColorPickerBtn.BackgroundColor3 = activeColor
                        elementConfig.Callback(valueState, activeColor)
                    end)
                end

                local function toggleValue()
                    valueState = not valueState
                    Checkmark.Visible = valueState
                    elementConfig.Callback(valueState, activeColor)
                end

                TriggerButton.MouseButton1Click:Connect(toggleValue)

                return {
                    Set = function(self, state: boolean, color: Color3?)
                        valueState = state
                        Checkmark.Visible = state
                        if color and ColorPickerBtn then
                            activeColor = color
                            ColorPickerBtn.BackgroundColor3 = color
                        end
                        elementConfig.Callback(valueState, activeColor)
                    end,
                    Get = function(self)
                        return valueState, activeColor
                    end
                }
            end

            -- 2. Create Precision Custom ImGui Slider
            function Section:CreateSlider(elementConfig: SliderConfig)
                local currentVal = elementConfig.Default
                local suffix = elementConfig.Suffix or ""

                local SliderFrame = create("Frame", {
                    Name = "Slider_" .. elementConfig.Name,
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                })
                SliderFrame.Parent = Body

                -- Slider parameter label and dynamic counter text
                local HeaderRow = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                })
                HeaderRow.Parent = SliderFrame

                local Label = create("TextLabel", {
                    Text = elementConfig.Name,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.Text_Main,
                    TextSize = 11,
                    Font = Enum.Font.SourceSans,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                Label.Parent = HeaderRow

                local ValueDisplay = create("TextLabel", {
                    Text = tostring(currentVal) .. suffix,
                    Size = UDim2.new(0.3, 0, 1, 0),
                    Position = UDim2.new(0.7, 0, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.Accent,
                    TextSize = 11,
                    Font = Enum.Font.Code,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })
                ValueDisplay.Parent = HeaderRow

                -- The flat, razor-thin slider track
                local Track = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 2),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = Theme.Border_Light,
                    BorderSizePixel = 0,
                })
                Track.Parent = SliderFrame

                -- Single vertical tick pin indicator
                local Pin = create("Frame", {
                    Size = UDim2.new(0, 6, 0, 12),
                    Position = UDim2.new(0, 0, 0.5, -6),
                    BackgroundColor3 = Theme.Text_White,
                    BorderSizePixel = 1,
                    BorderColor3 = Theme.Border_Focus,
                })
                Pin.Parent = Track

                local function updateSlider(input: InputObject)
                    local relativeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local rawVal = elementConfig.Min + (relativeX * (elementConfig.Max - elementConfig.Min))
                    -- Format clean precision strings
                    currentVal = math.round(rawVal * 10) / 10
                    
                    Pin.Position = UDim2.new(relativeX, -3, 0.5, -6)
                    ValueDisplay.Text = tostring(currentVal) .. suffix
                    elementConfig.Callback(currentVal)
                end

                local activeDragging = false
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        activeDragging = true
                        updateSlider(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        activeDragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if activeDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)

                -- Initialize default slider placement
                local initialRatio = math.clamp((currentVal - elementConfig.Min) / (elementConfig.Max - elementConfig.Min), 0, 1)
                Pin.Position = UDim2.new(initialRatio, -3, 0.5, -6)

                return {
                    Set = function(self, value: number)
                        currentVal = math.clamp(value, elementConfig.Min, elementConfig.Max)
                        local ratio = (currentVal - elementConfig.Min) / (elementConfig.Max - elementConfig.Min)
                        Pin.Position = UDim2.new(ratio, -3, 0.5, -6)
                        ValueDisplay.Text = tostring(currentVal) .. suffix
                        elementConfig.Callback(currentVal)
                    end,
                    Get = function(self)
                        return currentVal
                    end
                }
            end

            -- 3. Create Droplist Selector
            function Section:CreateDropdown(elementConfig: DropdownConfig)
                local currentSelected = elementConfig.Default or elementConfig.Options[1] or ""

                local DropdownFrame = create("Frame", {
                    Name = "Dropdown_" .. elementConfig.Name,
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                })
                DropdownFrame.Parent = Body

                local Label = create("TextLabel", {
                    Text = elementConfig.Name,
                    Size = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.Text_Main,
                    TextSize = 11,
                    Font = Enum.Font.SourceSans,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                Label.Parent = DropdownFrame

                local Btn = create("TextButton", {
                    Text = currentSelected,
                    Size = UDim2.new(1, 0, 0, 24),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = Theme.BG_Element,
                    BorderColor3 = Theme.Border_Light,
                    BorderSizePixel = 1,
                    TextColor3 = Theme.Text_Main,
                    TextSize = 11.5,
                    Font = Enum.Font.SourceSans,
                    AutoButtonColor = false,
                }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 2) }),
                    create("TextLabel", {
                        Text = "▼",
                        Size = UDim2.new(0, 20, 1, 0),
                        Position = UDim2.new(1, -20, 0, 0),
                        BackgroundTransparency = 1,
                        TextColor3 = Theme.Text_Muted,
                        TextSize = 8,
                        Font = Enum.Font.SourceSansBold,
                    })
                })
                Btn.Parent = DropdownFrame

                local Menu = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 2),
                    BackgroundColor3 = Theme.BG_Element,
                    BorderColor3 = Theme.Border_Focus,
                    BorderSizePixel = 1,
                    Visible = false,
                    ZIndex = 100,
                }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 2) }),
                    create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical })
                })
                Menu.Parent = Btn

                local function toggleMenu()
                    Menu.Visible = not Menu.Visible
                    if Menu.Visible then
                        -- Auto adjust menu height to wrap list values
                        Menu.Size = UDim2.new(1, 0, 0, #Menu:GetChildren() * 22)
                    end
                end
                Btn.MouseButton1Click:Connect(toggleMenu)

                local function drawOptions()
                    for _, child in ipairs(Menu:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end

                    for _, option in ipairs(elementConfig.Options) do
                        local OptBtn = create("TextButton", {
                            Text = option,
                            Size = UDim2.new(1, 0, 0, 22),
                            BackgroundTransparency = 1,
                            TextColor3 = (option == currentSelected) and Theme.Accent or Theme.Text_Main,
                            TextSize = 11,
                            Font = Enum.Font.SourceSans,
                            ZIndex = 101,
                        })
                        OptBtn.Parent = Menu

                        OptBtn.MouseButton1Click:Connect(function()
                            currentSelected = option
                            Btn.Text = option
                            Menu.Visible = false
                            elementConfig.Callback(option)
                            drawOptions()
                        end)
                    end
                end
                drawOptions()

                return {
                    Set = function(self, option: string)
                        currentSelected = option
                        Btn.Text = option
                        elementConfig.Callback(option)
                        drawOptions()
                    end,
                    Get = function(self)
                        return currentSelected
                    end,
                    Refresh = function(self, options: {string}, default: string?)
                        elementConfig.Options = options
                        currentSelected = default or options[1] or ""
                        Btn.Text = currentSelected
                        drawOptions()
                    end
                }
            end

            -- 4. Create Keybind Widget
            function Section:CreateKeybind(elementConfig: KeybindConfig)
                local currentKey = elementConfig.Default or Enum.KeyCode.Insert
                local capturing = false

                local BindFrame = create("Frame", {
                    Name = "Keybind_" .. elementConfig.Name,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                })
                BindFrame.Parent = Body

                local Label = create("TextLabel", {
                    Text = elementConfig.Name,
                    Size = UDim2.new(0.6, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.Text_Main,
                    TextSize = 11.5,
                    Font = Enum.Font.SourceSans,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                Label.Parent = BindFrame

                local Btn = create("TextButton", {
                    Text = currentKey.Name:upper(),
                    Size = UDim2.new(0.35, 0, 1, 0),
                    Position = UDim2.new(0.65, 0, 0, 0),
                    BackgroundColor3 = Theme.BG_Element,
                    BorderColor3 = Theme.Border_Light,
                    BorderSizePixel = 1,
                    TextColor3 = Theme.Text_Main,
                    TextSize = 10.5,
                    Font = Enum.Font.Code,
                    AutoButtonColor = false,
                }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 2) })
                })
                Btn.Parent = BindFrame

                Btn.MouseButton1Click:Connect(function()
                    capturing = true
                    Btn.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(input)
                    if capturing and input.UserInputType == Enum.UserInputType.Keyboard then
                        capturing = false
                        currentKey = input.KeyCode
                        Btn.Text = currentKey.Name:upper()
                        elementConfig.Callback(currentKey)
                    end
                end)

                return {
                    Set = function(self, key: Enum.KeyCode)
                        currentKey = key
                        Btn.Text = key.Name:upper()
                        elementConfig.Callback(key)
                    end,
                    Get = function(self)
                        return currentKey
                    end
                }
            end

            -- 5. Create Paragraph Widget (Technical Advisory Box)
            function Section:CreateParagraph(elementConfig: { Title: string, Content: string })
                local ParaBox = create("Frame", {
                    Name = "AdvisoryBox",
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, {
                    create("Frame", {
                        Size = UDim2.new(1, 0, 0, 1),
                        BackgroundColor3 = Theme.Border_Light,
                        BorderSizePixel = 0,
                    }),
                    create("TextLabel", {
                        Text = elementConfig.Title:upper(),
                        Size = UDim2.new(1, 0, 0, 14),
                        Position = UDim2.new(0, 0, 0, 4),
                        BackgroundTransparency = 1,
                        TextColor3 = Theme.Accent,
                        TextSize = 10,
                        Font = Enum.Font.SourceSansBold,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    }),
                    create("TextLabel", {
                        Text = elementConfig.Content,
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.new(0, 0, 0, 18),
                        BackgroundTransparency = 1,
                        TextColor3 = Theme.Text_Muted,
                        TextSize = 10,
                        Font = Enum.Font.SourceSans,
                        TextWrapped = true,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                })
                ParaBox.Parent = Body
            end

            return Section
        end

        Window.Tabs[name] = Tab
        return Tab
    end

    return Window
end

return DeadcellLibrary
