-- KOkos Hub | Premium Script
-- Полная копия Orion Lib UI без CoreGui с автоинжекцией скриптов

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

-- Создаем Orion Lib таблицу
local OrionLib = {
    Elements = {},
    ThemeObjects = {},
    Connections = {},
    Flags = {},
    Themes = {
        Default = {
            Main = Color3.fromRGB(25, 25, 25),
            Second = Color3.fromRGB(32, 32, 32),
            Stroke = Color3.fromRGB(60, 60, 60),
            Divider = Color3.fromRGB(60, 60, 60),
            Text = Color3.fromRGB(240, 240, 240),
            TextDark = Color3.fromRGB(150, 150, 150)
        }
    },
    SelectedTheme = "Default",
    Folder = nil,
    SaveCfg = false
}

-- Создаем ScreenGui
local Orion = Instance.new("ScreenGui")
Orion.Name = "KOkosHubPremium"
Orion.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Orion.ResetOnSpawn = false

-- Защита GUI
if syn and syn.protect_gui then
    syn.protect_gui(Orion)
    Orion.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
elseif gethui then
    Orion.Parent = gethui()
else
    Orion.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Удаляем старые интерфейсы
for _, Interface in ipairs(Orion.Parent:GetChildren()) do
    if Interface.Name == Orion.Name and Interface ~= Orion then
        Interface:Destroy()
    end
end

function OrionLib:IsRunning()
    return Orion.Parent ~= nil
end

local function AddConnection(Signal, Function)
    if (not OrionLib:IsRunning()) then
        return
    end
    local SignalConnect = Signal:Connect(Function)
    table.insert(OrionLib.Connections, SignalConnect)
    return SignalConnect
end

task.spawn(function()
    while (OrionLib:IsRunning()) do
        wait()
    end
    for _, Connection in next, OrionLib.Connections do
        Connection:Disconnect()
    end
end)

local function AddDraggingFunctionality(DragPoint, Main)
    pcall(function()
        local Dragging, DragInput, MousePos, FramePos = false
        DragPoint.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                MousePos = Input.Position
                FramePos = Main.Position
                Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)
        DragPoint.InputChanged:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                DragInput = Input
            end
        end)
        UserInputService.InputChanged:Connect(function(Input)
            if Input == DragInput and Dragging then
                local Delta = Input.Position - MousePos
                TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
            end
        end)
    end)
end

local function Create(Name, Properties, Children)
    local Object = Instance.new(Name)
    for i, v in next, Properties or {} do
        Object[i] = v
    end
    for i, v in next, Children or {} do
        v.Parent = Object
    end
    return Object
end

local function CreateElement(ElementName, ElementFunction)
    OrionLib.Elements[ElementName] = function(...)
        return ElementFunction(...)
    end
end

local function MakeElement(ElementName, ...)
    local NewElement = OrionLib.Elements[ElementName](...)
    return NewElement
end

local function SetProps(Element, Props)
    for Property, Value in pairs(Props) do
        Element[Property] = Value
    end
    return Element
end

local function SetChildren(Element, Children)
    for _, Child in pairs(Children) do
        Child.Parent = Element
    end
    return Element
end

local function Round(Number, Factor)
    local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
    if Result < 0 then Result = Result + Factor end
    return Result
end

local function ReturnProperty(Object)
    if Object:IsA("Frame") or Object:IsA("TextButton") then
        return "BackgroundColor3"
    end 
    if Object:IsA("ScrollingFrame") then
        return "ScrollBarImageColor3"
    end 
    if Object:IsA("UIStroke") then
        return "Color"
    end 
    if Object:IsA("TextLabel") or Object:IsA("TextBox") then
        return "TextColor3"
    end   
    if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
        return "ImageColor3"
    end   
end

local function AddThemeObject(Object, Type)
    if not OrionLib.ThemeObjects[Type] then
        OrionLib.ThemeObjects[Type] = {}
    end    
    table.insert(OrionLib.ThemeObjects[Type], Object)
    Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Type]
    return Object
end

-- Создаем элементы UI как в оригинале
CreateElement("Corner", function(Scale, Offset)
    local Corner = Create("UICorner", {
        CornerRadius = UDim.new(Scale or 0, Offset or 10)
    })
    return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
    local Stroke = Create("UIStroke", {
        Color = Color or Color3.fromRGB(255, 255, 255),
        Thickness = Thickness or 1
    })
    return Stroke
end)

CreateElement("List", function(Scale, Offset)
    local List = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(Scale or 0, Offset or 0)
    })
    return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
    local Padding = Create("UIPadding", {
        PaddingBottom = UDim.new(0, Bottom or 4),
        PaddingLeft = UDim.new(0, Left or 4),
        PaddingRight = UDim.new(0, Right or 4),
        PaddingTop = UDim.new(0, Top or 4)
    })
    return Padding
end)

CreateElement("TFrame", function()
    local TFrame = Create("Frame", {
        BackgroundTransparency = 1
    })
    return TFrame
end)

CreateElement("Frame", function(Color)
    local Frame = Create("Frame", {
        BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
    return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
    local Frame = Create("Frame", {
        BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(Scale, Offset)
        })
    })
    return Frame
end)

CreateElement("Button", function()
    local Button = Create("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    return Button
end)

CreateElement("ScrollFrame", function(Color, Width)
    local ScrollFrame = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        MidImage = "rbxassetid://7445543667",
        BottomImage = "rbxassetid://7445543667",
        TopImage = "rbxassetid://7445543667",
        ScrollBarImageColor3 = Color,
        BorderSizePixel = 0,
        ScrollBarThickness = Width,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    return ScrollFrame
end)

CreateElement("Image", function(ImageID)
    local ImageNew = Create("ImageLabel", {
        Image = ImageID,
        BackgroundTransparency = 1
    })
    return ImageNew
end)

CreateElement("Label", function(Text, TextSize, Transparency)
    local Label = Create("TextLabel", {
        Text = Text or "",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextTransparency = Transparency or 0,
        TextSize = TextSize or 15,
        Font = Enum.Font.Gotham,
        RichText = true,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    return Label
end)

-- Функция MakeWindow как в оригинале
function OrionLib:MakeWindow(WindowConfig)
    local FirstTab = true
    local Minimized = false
    local Loaded = false
    local UIHidden = false

    WindowConfig = WindowConfig or {}
    WindowConfig.Name = WindowConfig.Name or "KOkos Hub"
    WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
    WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
    WindowConfig.HidePremium = WindowConfig.HidePremium or false
    if WindowConfig.IntroEnabled == nil then
        WindowConfig.IntroEnabled = true
    end
    WindowConfig.IntroText = WindowConfig.IntroText or "KOkos Hub"
    WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
    WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
    WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://7734068321"
    WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://7734068321"
    OrionLib.Folder = WindowConfig.ConfigFolder
    OrionLib.SaveCfg = WindowConfig.SaveConfig

    local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
        Size = UDim2.new(1, 0, 1, -50)
    }), {
        MakeElement("List"),
        MakeElement("Padding", 8, 0, 0, 8)
    }), "Divider")

    AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
    end)

    local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1
    }), {
        AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
            Position = UDim2.new(0, 9, 0, 6),
            Size = UDim2.new(0, 18, 0, 18)
        }), "Text")
    })

    local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1
    }), {
        AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
            Position = UDim2.new(0, 9, 0, 6),
            Size = UDim2.new(0, 18, 0, 18),
            Name = "Ico"
        }), "Text")
    })

    local DragPoint = SetProps(MakeElement("TFrame"), {
        Size = UDim2.new(1, 0, 0, 50)
    })

    local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
        Size = UDim2.new(0, 150, 1, -50),
        Position = UDim2.new(0, 0, 0, 50)
    }), {
        AddThemeObject(SetProps(MakeElement("Frame"), {
            Size = UDim2.new(1, 0, 0, 10),
            Position = UDim2.new(0, 0, 0, 0)
        }), "Second"), 
        AddThemeObject(SetProps(MakeElement("Frame"), {
            Size = UDim2.new(0, 10, 1, 0),
            Position = UDim2.new(1, -10, 0, 0)
        }), "Second"), 
        AddThemeObject(SetProps(MakeElement("Frame"), {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, -1, 0, 0)
        }), "Stroke"), 
        TabHolder,
        SetChildren(SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 1, -50)
        }), {
            AddThemeObject(SetProps(MakeElement("Frame"), {
                Size = UDim2.new(1, 0, 0, 1)
            }), "Stroke"), 
            AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(0, 10, 0.5, 0)
            }), {
                SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=".. LocalPlayer.UserId .."&width=420&height=420&format=png"), {
                    Size = UDim2.new(1, 0, 1, 0)
                }),
                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {
                    Size = UDim2.new(1, 0, 1, 0),
                }), "Second"),
                MakeElement("Corner", 1)
            }), "Divider"),
            SetChildren(SetProps(MakeElement("TFrame"), {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(0, 10, 0.5, 0)
            }), {
                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                MakeElement("Corner", 1)
            }),
            AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, WindowConfig.HidePremium and 14 or 13), {
                Size = UDim2.new(1, -60, 0, 13),
                Position = WindowConfig.HidePremium and UDim2.new(0, 50, 0, 19) or UDim2.new(0, 50, 0, 12),
                Font = Enum.Font.GothamBold,
                ClipsDescendants = true
            }), "Text"),
            AddThemeObject(SetProps(MakeElement("Label", "", 12), {
                Size = UDim2.new(1, -60, 0, 12),
                Position = UDim2.new(0, 50, 1, -25),
                Visible = not WindowConfig.HidePremium
            }), "TextDark")
        }),
    }), "Second")

    local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
        Size = UDim2.new(1, -30, 2, 0),
        Position = UDim2.new(0, 25, 0, -24),
        Font = Enum.Font.GothamBlack,
        TextSize = 20
    }), "Text")

    local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1)
    }), "Stroke")

    local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
        Parent = Orion,
        Position = UDim2.new(0.5, -307, 0.5, -172),
        Size = UDim2.new(0, 615, 0, 344),
        ClipsDescendants = true
    }), {
        SetChildren(SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 50),
            Name = "TopBar"
        }), {
            WindowName,
            WindowTopBarLine,
            AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 7), {
                Size = UDim2.new(0, 70, 0, 30),
                Position = UDim2.new(1, -90, 0, 10)
            }), {
                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                AddThemeObject(SetProps(MakeElement("Frame"), {
                    Size = UDim2.new(0, 1, 1, 0),
                    Position = UDim2.new(0.5, 0, 0, 0)
                }), "Stroke"), 
                CloseBtn,
                MinimizeBtn
            }), "Second"), 
        }),
        DragPoint,
        WindowStuff
    }), "Main")

    if WindowConfig.ShowIcon then
        WindowName.Position = UDim2.new(0, 50, 0, -24)
        local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 25, 0, 15)
        })
        WindowIcon.Parent = MainWindow.TopBar
    end

    AddDraggingFunctionality(DragPoint, MainWindow)

    AddConnection(CloseBtn.MouseButton1Up, function()
        MainWindow.Visible = false
        UIHidden = true
        OrionLib:MakeNotification({
            Name = "Interface Hidden",
            Content = "Tap RightShift to reopen the interface",
            Time = 5
        })
        WindowConfig.CloseCallback()
    end)

    AddConnection(UserInputService.InputBegan, function(Input)
        if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
            MainWindow.Visible = true
        end
    end)

    AddConnection(MinimizeBtn.MouseButton1Up, function()
        if Minimized then
            TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 615, 0, 344)}):Play()
            MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
            wait(.02)
            MainWindow.ClipsDescendants = false
            WindowStuff.Visible = true
            WindowTopBarLine.Visible = true
        else
            MainWindow.ClipsDescendants = true
            WindowTopBarLine.Visible = false
            MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
            TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play()
            wait(0.1)
            WindowStuff.Visible = false
        end
        Minimized = not Minimized
    end)

    local function LoadSequence()
        MainWindow.Visible = false
        local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
            Parent = Orion,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.4, 0),
            Size = UDim2.new(0, 28, 0, 28),
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ImageTransparency = 1
        })

        local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {
            Parent = Orion,
            Size = UDim2.new(1, 0, 1, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 19, 0.5, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            Font = Enum.Font.GothamBold,
            TextTransparency = 1
        })

        TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        wait(0.8)
        TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
        wait(0.3)
        TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        wait(2)
        TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
        MainWindow.Visible = true
        LoadSequenceLogo:Destroy()
        LoadSequenceText:Destroy()
    end

    if WindowConfig.IntroEnabled then
        LoadSequence()
    end

    local TabFunction = {}
    function TabFunction:MakeTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""
        TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

        local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
            Size = UDim2.new(1, 0, 0, 30),
            Parent = TabHolder
        }), {
            AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 10, 0.5, 0),
                ImageTransparency = 0.4,
                Name = "Ico"
            }), "Text"),
            AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
                Size = UDim2.new(1, -35, 1, 0),
                Position = UDim2.new(0, 35, 0, 0),
                Font = Enum.Font.GothamSemibold,
                TextTransparency = 0.4,
                Name = "Title"
            }), "Text")
        })

        local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {
            Size = UDim2.new(1, -150, 1, -50),
            Position = UDim2.new(0, 150, 0, 50),
            Parent = MainWindow,
            Visible = false,
            Name = "ItemContainer"
        }), {
            MakeElement("List", 0, 6),
            MakeElement("Padding", 15, 10, 10, 15)
        }), "Divider")

        AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
        end)

        if FirstTab then
            FirstTab = false
            TabFrame.Ico.ImageTransparency = 0
            TabFrame.Title.TextTransparency = 0
            TabFrame.Title.Font = Enum.Font.GothamBlack
            Container.Visible = true
        end

        AddConnection(TabFrame.MouseButton1Click, function()
            for _, Tab in next, TabHolder:GetChildren() do
                if Tab:IsA("TextButton") then
                    Tab.Title.Font = Enum.Font.GothamSemibold
                    TweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
                    TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
                end
            end
            for _, ItemContainer in next, MainWindow:GetChildren() do
                if ItemContainer.Name == "ItemContainer" then
                    ItemContainer.Visible = false
                end
            end
            TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
            TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
            TabFrame.Title.Font = Enum.Font.GothamBlack
            Container.Visible = true
        end)

        local function GetElements(ItemParent)
            local ElementFunction = {}
            
            function ElementFunction:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Name = ButtonConfig.Name or "Button"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end

                local Button = {}

                local Click = SetProps(MakeElement("Button"), {
                    Size = UDim2.new(1, 0, 1, 0)
                })

                local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
                    Size = UDim2.new(1, 0, 0, 33),
                    Parent = ItemParent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
                        Size = UDim2.new(1, -12, 1, 0),
                        Position = UDim2.new(0, 12, 0, 0),
                        Font = Enum.Font.GothamBold,
                        Name = "Content"
                    }), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"),
                    Click
                }), "Second")

                AddConnection(Click.MouseEnter, function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
                end)

                AddConnection(Click.MouseLeave, function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
                end)

                AddConnection(Click.MouseButton1Up, function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
                    spawn(function()
                        ButtonConfig.Callback()
                    end)
                end)

                AddConnection(Click.MouseButton1Down, function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
                end)

                function Button:Set(ButtonText)
                    ButtonFrame.Content.Text = ButtonText
                end

                return Button
            end

            function ElementFunction:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Name = ToggleConfig.Name or "Toggle"
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end
                ToggleConfig.Flag = ToggleConfig.Flag or nil

                local Toggle = {Value = ToggleConfig.Default}

                local Click = SetProps(MakeElement("Button"), {
                    Size = UDim2.new(1, 0, 1, 0)
                })

                local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(9, 99, 195), 0, 4), {
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(1, -24, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5)
                }), {
                    SetProps(MakeElement("Stroke"), {
                        Color = Color3.fromRGB(9, 99, 195),
                        Name = "Stroke",
                        Transparency = 0.5
                    }),
                    SetProps(MakeElement("Image", "rbxassetid://3944680095"), {
                        Size = UDim2.new(0, 20, 0, 20),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        ImageColor3 = Color3.fromRGB(255, 255, 255),
                        Name = "Ico"
                    }),
                })

                local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
                    Size = UDim2.new(1, 0, 0, 38),
                    Parent = ItemParent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
                        Size = UDim2.new(1, -12, 1, 0),
                        Position = UDim2.new(0, 12, 0, 0),
                        Font = Enum.Font.GothamBold,
                        Name = "Content"
                    }), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"),
                    ToggleBox,
                    Click
                }), "Second")

                function Toggle:Set(Value)
                    Toggle.Value = Value
                    TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Toggle.Value and Color3.fromRGB(9, 99, 195) or OrionLib.Themes.Default.Divider}):Play()
                    TweenService:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Toggle.Value and Color3.fromRGB(9, 99, 195) or OrionLib.Themes.Default.Stroke}):Play()
                    TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = Toggle.Value and 0 or 1, Size = Toggle.Value and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8)}):Play()
                    ToggleConfig.Callback(Toggle.Value)
                end

                Toggle:Set(Toggle.Value)

                AddConnection(Click.MouseEnter, function()
                    TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
                end)

                AddConnection(Click.MouseLeave, function()
                    TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
                end)

                AddConnection(Click.MouseButton1Up, function()
                    TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
                    Toggle:Set(not Toggle.Value)
                end)

                AddConnection(Click.MouseButton1Down, function()
                    TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
                end)

                if ToggleConfig.Flag then
                    OrionLib.Flags[ToggleConfig.Flag] = Toggle
                end
                return Toggle
            end

            function ElementFunction:AddSlider(SliderConfig)
                SliderConfig = SliderConfig or {}
                SliderConfig.Name = SliderConfig.Name or "Slider"
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Increment = SliderConfig.Increment or 1
                SliderConfig.Default = SliderConfig.Default or 50
                SliderConfig.Callback = SliderConfig.Callback or function() end
                SliderConfig.ValueName = SliderConfig.ValueName or ""
                SliderConfig.Flag = SliderConfig.Flag or nil

                local Slider = {Value = SliderConfig.Default}
                local Dragging = false

                local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(9, 149, 98), 0, 5), {
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundTransparency = 0.3,
                    ClipsDescendants = true
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
                        Size = UDim2.new(1, -12, 0, 14),
                        Position = UDim2.new(0, 12, 0, 6),
                        Font = Enum.Font.GothamBold,
                        Name = "Value",
                        TextTransparency = 0
                    }), "Text")
                })

                local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(9, 149, 98), 0, 5), {
                    Size = UDim2.new(1, -24, 0, 26),
                    Position = UDim2.new(0, 12, 0, 30),
                    BackgroundTransparency = 0.9
                }), {
                    SetProps(MakeElement("Stroke"), {
                        Color = Color3.fromRGB(9, 149, 98)
                    }),
                    AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
                        Size = UDim2.new(1, -12, 0, 14),
                        Position = UDim2.new(0, 12, 0, 6),
                        Font = Enum.Font.GothamBold,
                        Name = "Value",
                        TextTransparency = 0.8
                    }), "Text"),
                    SliderDrag
                })

                local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
                    Size = UDim2.new(1, 0, 0, 65),
                    Parent = ItemParent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {
                        Size = UDim2.new(1, -12, 0, 14),
                        Position = UDim2.new(0, 12, 0, 10),
                        Font = Enum.Font.GothamBold,
                        Name = "Content"
                    }), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"),
                    SliderBar
                }), "Second")

                SliderBar.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then 
                        Dragging = true 
                    end 
                end)
                SliderBar.InputEnded:Connect(function(Input) 
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then 
                        Dragging = false 
                    end 
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then 
                        local SizeScale = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                        Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale)) 
                    end
                end)

                function Slider:Set(Value)
                    self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
                    TweenService:Create(SliderDrag,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = UDim2.fromScale((self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1)}):Play()
                    SliderBar.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
                    SliderDrag.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
                    SliderConfig.Callback(self.Value)
                end

                Slider:Set(Slider.Value)
                if SliderConfig.Flag then
                    OrionLib.Flags[SliderConfig.Flag] = Slider
                end
                return Slider
            end

            function ElementFunction:AddSection(SectionConfig)
                SectionConfig.Name = SectionConfig.Name or "Section"

                local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
                    Size = UDim2.new(1, 0, 0, 26),
                    Parent = ItemParent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
                        Size = UDim2.new(1, -12, 0, 16),
                        Position = UDim2.new(0, 0, 0, 3),
                        Font = Enum.Font.GothamSemibold
                    }), "TextDark"),
                    SetChildren(SetProps(MakeElement("TFrame"), {
                        AnchorPoint = Vector2.new(0, 0),
                        Size = UDim2.new(1, 0, 1, -24),
                        Position = UDim2.new(0, 0, 0, 23),
                        Name = "Holder"
                    }), {
                        MakeElement("List", 0, 6)
                    }),
                })

                AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                    SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
                    SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
                end)

                local SectionFunction = {}
                for i, v in next, GetElements(SectionFrame.Holder) do
                    SectionFunction[i] = v 
                end
                return SectionFunction
            end

            function ElementFunction:AddParagraph(ParagraphConfig)
                ParagraphConfig.Name = ParagraphConfig.Name or "Paragraph"
                ParagraphConfig.Content = ParagraphConfig.Content or "Content"

                local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 0.7,
                    Parent = ItemParent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", ParagraphConfig.Name, 15), {
                        Size = UDim2.new(1, -12, 0, 14),
                        Position = UDim2.new(0, 12, 0, 10),
                        Font = Enum.Font.GothamBold,
                        Name = "Title"
                    }), "Text"),
                    AddThemeObject(SetProps(MakeElement("Label", "", 13), {
                        Size = UDim2.new(1, -24, 0, 0),
                        Position = UDim2.new(0, 12, 0, 26),
                        Font = Enum.Font.GothamSemibold,
                        Name = "Content",
                        TextWrapped = true
                    }), "TextDark"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke")
                }), "Second")

                AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
                    ParagraphFrame.Content.Size = UDim2.new(1, -24, 0, ParagraphFrame.Content.TextBounds.Y)
                    ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 35)
                end)

                ParagraphFrame.Content.Text = ParagraphConfig.Content

                local ParagraphFunction = {}
                function ParagraphFunction:Set(ToChange)
                    ParagraphFrame.Content.Text = ToChange
                end
                return ParagraphFunction
            end

            return ElementFunction
        end

        local ElementFunction = {}
        for i, v in next, GetElements(Container) do
            ElementFunction[i] = v 
        end

        return ElementFunction
    end

    return TabFunction
end

-- Функция MakeNotification
function OrionLib:MakeNotification(NotificationConfig)
    spawn(function()
        NotificationConfig.Name = NotificationConfig.Name or "Notification"
        NotificationConfig.Content = NotificationConfig.Content or "Test"
        NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
        NotificationConfig.Time = NotificationConfig.Time or 15

        local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
            SetProps(MakeElement("List"), {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 5)
            })
        }), {
            Position = UDim2.new(1, -25, 1, -25),
            Size = UDim2.new(0, 300, 1, -25),
            AnchorPoint = Vector2.new(1, 1),
            Parent = Orion
        })

        local NotificationParent = SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = NotificationHolder
        })

        local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
            Parent = NotificationParent, 
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(1, -55, 0, 0),
            BackgroundTransparency = 0,
            AutomaticSize = Enum.AutomaticSize.Y
        }), {
            MakeElement("Stroke", Color3.fromRGB(93, 93, 93), 1.2),
            MakeElement("Padding", 12, 12, 12, 12),
            SetProps(MakeElement("Image", NotificationConfig.Image), {
                Size = UDim2.new(0, 20, 0, 20),
                ImageColor3 = Color3.fromRGB(240, 240, 240),
                Name = "Icon"
            }),
            SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
                Size = UDim2.new(1, -30, 0, 20),
                Position = UDim2.new(0, 30, 0, 0),
                Font = Enum.Font.GothamBold,
                Name = "Title"
            }),
            SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 25),
                Font = Enum.Font.GothamSemibold,
                Name = "Content",
                AutomaticSize = Enum.AutomaticSize.Y,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextWrapped = true
            })
        })

        TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()

        wait(NotificationConfig.Time - 0.88)
        TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
        wait(0.3)
        TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
        TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
        TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
        wait(0.05)

        NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0),'In','Quint',0.8,true)
        wait(1.35)
        NotificationFrame:Destroy()
    end)
end

function OrionLib:Init()
    -- Инициализация
end

function OrionLib:Destroy()
    Orion:Destroy()
end

-- Функции читов KOkos Hub
local flyEnabled = false
local flySpeed = 50
local bodyVelocity

local function enableFly()
    if flyEnabled then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    flyEnabled = true
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
    bodyVelocity.Parent = character.HumanoidRootPart
    
    local flyConnection
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled or not character or not character:FindFirstChild("HumanoidRootPart") then
            if flyConnection then flyConnection:Disconnect() end
            return
        end
        
        local root = character.HumanoidRootPart
        local newVelocity = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            newVelocity = newVelocity + (root.CFrame.LookVector * flySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            newVelocity = newVelocity + (root.CFrame.LookVector * -flySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            newVelocity = newVelocity + (root.CFrame.RightVector * -flySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            newVelocity = newVelocity + (root.CFrame.RightVector * flySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            newVelocity = newVelocity + Vector3.new(0, flySpeed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            newVelocity = newVelocity + Vector3.new(0, -flySpeed, 0)
        end
        
        bodyVelocity.Velocity = newVelocity
    end)
end

local function disableFly()
    flyEnabled = false
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
end

-- NOCLIP
local noclipEnabled = false
local noclipConnection

local function enableNoclip()
    if noclipEnabled then return end
    
    noclipEnabled = true
    local character = LocalPlayer.Character
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if not noclipEnabled or not character then
            if noclipConnection then noclipConnection:Disconnect() end
            return
        end
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function disableNoclip()
    noclipEnabled = false
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

-- SPEED HACK
local speedHackEnabled = false
local originalWalkSpeed = 16

local function enableSpeedHack(speed)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        originalWalkSpeed = character.Humanoid.WalkSpeed
        character.Humanoid.WalkSpeed = speed
        speedHackEnabled = true
    end
end

local function disableSpeedHack()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = originalWalkSpeed
        speedHackEnabled = false
    end
end

-- JUMP HACK
local jumpHackEnabled = false
local originalJumpPower = 50

local function enableJumpHack(power)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        originalJumpPower = character.Humanoid.JumpPower
        character.Humanoid.JumpPower = power
        jumpHackEnabled = true
    end
end

local function disableJumpHack()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.JumpPower = originalJumpPower
        jumpHackEnabled = false
    end
end

-- ESP
local espEnabled = false
local espObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    if not Workspace:FindFirstChild(player.Name) then return end
    
    local character = Workspace[player.Name]
    if not character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "KOkosESP"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    
    espObjects[player] = highlight
end

local function removeESP(player)
    if espObjects[player] then
        espObjects[player]:Destroy()
        espObjects[player] = nil
    end
end

local function toggleESP(enable)
    espEnabled = enable
    
    if enable then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                spawn(function()
                    createESP(player)
                end)
            end
        end
    else
        for player, _ in pairs(espObjects) do
            removeESP(player)
        end
        table.clear(espObjects)
    end
end

-- Функция для автоматической инжекции скриптов
local function safeExecute(scriptCode, scriptName)
    local success, result = pcall(function()
        loadstring(scriptCode)()
    end)
    
    if success then
        OrionLib:MakeNotification({
            Name = "Успех! 🎉",
            Content = scriptName .. " успешно загружен!",
            Image = "rbxassetid://7734068321",
            Time = 5
        })
        print("✅ " .. scriptName .. " успешно загружен!")
    else
        OrionLib:MakeNotification({
            Name = "Ошибка! ❌",
            Content = "Ошибка загрузки " .. scriptName .. ": " .. tostring(result),
            Image = "rbxassetid://4483345998",
            Time = 5
        })
        warn("❌ Ошибка загрузки " .. scriptName .. ": " .. tostring(result))
    end
end

local function loadGameScript(scriptCode, scriptName)
    OrionLib:MakeNotification({
        Name = "Загрузка... ⏳",
        Content = "Загружаем " .. scriptName,
        Image = "rbxassetid://4483346026",
        Time = 3
    })
    
    wait(1)
    
    spawn(function()
        safeExecute(scriptCode, scriptName)
    end)
end

-- Создаем окно KOkos Hub
local Window = OrionLib:MakeWindow({
    Name = "KOkos Hub | 🚀 Premium", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "KOkosConfig",
    IntroEnabled = true,
    IntroText = "KOkos Hub Premium",
    IntroIcon = "rbxassetid://7734068321"
})

-- Вкладка основных функций
local MainTab = Window:MakeTab({
    Name = "Основные функции 🛠️",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddSection({
    Name = "Движение"
})

local FlyToggle = MainTab:AddToggle({
    Name = "Fly 🦅",
    Default = false,
    Callback = function(value)
        if value then
            enableFly()
            OrionLib:MakeNotification({
                Name = "Fly включен",
                Content = "Используйте WASD, Space(вверх), Ctrl(вниз)",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        else
            disableFly()
        end
    end
})

local NoclipToggle = MainTab:AddToggle({
    Name = "Noclip 🚷",
    Default = false,
    Callback = function(value)
        if value then
            enableNoclip()
        else
            disableNoclip()
        end
    end
})

local SpeedSlider = MainTab:AddSlider({
    Name = "Скорость 🏃",
    Min = 16,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "speed",
    Callback = function(value)
        if speedHackEnabled then
            enableSpeedHack(value)
        end
    end
})

local SpeedToggle = MainTab:AddToggle({
    Name = "Включить Speed Hack",
    Default = false,
    Callback = function(value)
        if value then
            enableSpeedHack(SpeedSlider.Value)
        else
            disableSpeedHack()
        end
    end
})

local JumpSlider = MainTab:AddSlider({
    Name = "Сила прыжка 🦘",
    Min = 50,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 10,
    ValueName = "power",
    Callback = function(value)
        if jumpHackEnabled then
            enableJumpHack(value)
        end
    end
})

local JumpToggle = MainTab:AddToggle({
    Name = "Включить Jump Hack",
    Default = false,
    Callback = function(value)
        if value then
            enableJumpHack(JumpSlider.Value)
        else
            disableJumpHack()
        end
    end
})

-- Вкладка ESP
local ESPTab = Window:MakeTab({
    Name = "ESP 👁️",
    Icon = "rbxassetid://4483345950",
    PremiumOnly = false
})

ESPTab:AddSection({
    Name = "Настройки ESP"
})

local ESPToggle = ESPTab:AddToggle({
    Name = "Включить ESP",
    Default = false,
    Callback = function(value)
        toggleESP(value)
    end
})

-- Вкладка популярных скриптов с автоинжекцией
local ScriptsTab = Window:MakeTab({
    Name = "Скрипты 📜",
    Icon = "rbxassetid://4483346026",
    PremiumOnly = false
})

ScriptsTab:AddSection({
    Name = "Универсальные скрипты"
})

local popularScripts = {
    {"Infinite Yield 🎯", "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()"},
    {"Dark Hub ⚡", "loadstring(game:HttpGet('https://raw.githubusercontent.com/RandomAdamYT/DarkHub/master/Init'))()"},
    {"Hydrogen 💧", "loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Loader.lua'))()"},
    {"Fluxus ⚡", "loadstring(game:HttpGet('https://raw.githubusercontent.com/FluxusCE/Fluxus/master/Fluxus.lua'))()"},
    {"Owl Hub 🦉", "loadstring(game:HttpGet('https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt'))()"},
    {"CMD-X 🖥️", "loadstring(game:HttpGet('https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source'))()"},
    {"V.G. Hub 🎮", "loadstring(game:HttpGet('https://raw.githubusercontent.com/1201for/V.G-Hub/main/V.Ghub'))()"},
    {"Zen Hub 🪷", "loadstring(game:HttpGet('https://raw.githubusercontent.com/KaizerSöze/zenx/main/zenx'))()"}
}

for _, scriptInfo in ipairs(popularScripts) do
    ScriptsTab:AddButton({
        Name = scriptInfo[1],
        Callback = function()
            loadGameScript(scriptInfo[2], scriptInfo[1])
        end
    })
end

-- Вкладка игр с автоинжекцией
local GamesTab = Window:MakeTab({
    Name = "Игры 🎮",
    Icon = "rbxassetid://7734068321",
    PremiumOnly = false
})

GamesTab:AddSection({
    Name = "🗡️ Боевые/РПГ"
})

local combatGames = {
    {"Blox Fruits 🍇", "loadstring(game:HttpGet('https://raw.githubusercontent.com/xQuartyx/DonateMe/main/ScriptLoader'))()"},
    {"King Legacy 👑", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/KingLegacy.lua'))()"},
    {"Shindo Life 🌊", "loadstring(game:HttpGet('https://pastebin.com/raw/ZYd0H8n0'))()"},
    {"Anime Fighting Simulator 💥", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/AnimeFightingSimulator.lua'))()"},
    {"Project Slayers 🗡️", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/ProjectSlayers.lua'))()"},
    {"Grand Piece Online ⛵", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/GrandPieceOnline.lua'))()"},
    {"Hollow Knight 🦇", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/HollowKnight.lua'))()"}
}

for _, gameScript in ipairs(combatGames) do
    GamesTab:AddButton({
        Name = gameScript[1],
        Callback = function()
            loadGameScript(gameScript[2], gameScript[1])
        end
    })
end

GamesTab:AddSection({
    Name = "🏃‍♂️ Симуляторы"
})

local simulatorGames = {
    {"Pet Simulator X 🐾", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/PetSimulatorX.lua'))()"},
    {"Pet Simulator 99 🎯", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/PetSimulator99.lua'))()"},
    {"Vehicle Legends 🚗", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/VehicleLegends.lua'))()"},
    {"Tower of Hell 🗼", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/TOH.lua'))()"},
    {"Natural Disaster Survival 🌪️", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/NDS.lua'))()"},
    {"Adopt Me 🐶", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/AdoptMe.lua'))()"},
    {"Bee Swarm Simulator 🐝", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/BeeSwarm.lua'))()"},
    {"Mining Simulator 2 ⛏️", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/MiningSimulator2.lua'))()"},
    {"Fishing Simulator 🎣", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/FishingSimulator.lua'))()"},
    {"Weight Lifting Simulator 💪", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/WeightLifting.lua'))()"},
    {"Restaurant Tycoon 2 🍕", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/RestaurantTycoon.lua'))()"},
    {"Jailbreak 🚔", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/Jailbreak.lua'))()"}
}

for _, gameScript in ipairs(simulatorGames) do
    GamesTab:AddButton({
        Name = gameScript[1],
        Callback = function()
            loadGameScript(gameScript[2], gameScript[1])
        end
    })
end

GamesTab:AddSection({
    Name = "🎭 Другие жанры"
})

local otherGames = {
    {"Doors 🚪", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/Doors.lua'))()"},
    {"Brookhaven 🏠", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/Brookhaven.lua'))()"},
    {"Arsenal 🔫", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/Arsenal.lua'))()"},
    {"Murder Mystery 2 🔪", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/MM2.lua'))()"},
    {"BedWars 🛏️", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/BedWars.lua'))()"},
    {"Slap Battles 👋", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/SlapBattles.lua'))()"},
    {"Prison Life ⛓️", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/PrisonLife.lua'))()"},
    {"MeepCity 🏙️", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/MeepCity.lua'))()"},
    {"99 Nights in the Forest 🌙", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/99Nights.lua'))()"},
    {"Steal A Brainrot 🧠", 'loadstring(game:HttpGet("https://pastefy.app/MJw2J4T6/raw"))()'},
    {"Evade 🏃‍♂️", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/Evade.lua'))()"},
    {"Ro-Ghoul 🦠", "loadstring(game:HttpGet('https://raw.githubusercontent.com/x2q6/Script/main/RoGhoul.lua'))()"}
}

for _, gameScript in ipairs(otherGames) do
    GamesTab:AddButton({
        Name = gameScript[1],
        Callback = function()
            loadGameScript(gameScript[2], gameScript[1])
        end
    })
end

-- Вкладка информации
local InfoTab = Window:MakeTab({
    Name = "Информация ℹ️",
    Icon = "rbxassetid://4483345901",
    PremiumOnly = false
})

InfoTab:AddSection({
    Name = "О скрипте"
})

InfoTab:AddParagraph("KOkos Hub Premium", "🎮 Премиум скрипт для Roblox\n\n✨ Возможности:\n• Fly режим\n• Noclip\n• Увеличение скорости\n• Увеличение прыжка\n• Красивый ESP\n• Хаб скриптов для популярных игр\n• Автоматическая инжекция скриптов\n\n⚠️ Используйте на свой риск!")

InfoTab:AddButton({
    Name = "Обновить персонажа 🔄",
    Callback = function()
        if LocalPlayer.Character then
            LocalPlayer.Character:BreakJoints()
        end
    end
})

InfoTab:AddButton({
    Name = "Отключить все функции 🚫",
    Callback = function()
        disableFly()
        disableNoclip()
        disableSpeedHack()
        disableJumpHack()
        toggleESP(false)
        
        if FlyToggle then FlyToggle:Set(false) end
        if NoclipToggle then NoclipToggle:Set(false) end
        if SpeedToggle then SpeedToggle:Set(false) end
        if JumpToggle then JumpToggle:Set(false) end
        if ESPToggle then ESPToggle:Set(false) end
        
        OrionLib:MakeNotification({
            Name = "Все функции отключены",
            Content = "Все читы были выключены",
            Image = "rbxassetid://4483345901",
            Time = 3
        })
    end
})

-- Автоматическое отключение при выходе
LocalPlayer.CharacterRemoving:Connect(function()
    disableFly()
    disableNoclip()
end)

Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        disableFly()
        disableNoclip()
        toggleESP(false)
    end
end)

-- Инициализация
OrionLib:Init()

OrionLib:MakeNotification({
    Name = "KOkos Hub загружен!",
    Content = "Добро пожаловать в премиум скрипт! 🚀",
    Image = "rbxassetid://7734068321",
    Time = 5
})

-- Защита от ошибок
spawn(function()
    while true do
        wait(10)
        if not LocalPlayer.Character and (flyEnabled or noclipEnabled) then
            disableFly()
            disableNoclip()
        end
    end
end)
