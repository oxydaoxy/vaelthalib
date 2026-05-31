--[[
    Vaeltha UI Library v2.0.0
    Premium Roblox UI Library
    Usage: local Vaeltha = loadstring(...)()
--]]

local Vaeltha = {}
Vaeltha.__index = Vaeltha

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PLAYER = Players.LocalPlayer
local MOUSE = PLAYER:GetMouse()

local THEME = {
    Base        = Color3.fromRGB(10, 10, 11),
    Surface     = Color3.fromRGB(17, 17, 19),
    Elevated    = Color3.fromRGB(22, 22, 24),
    Panel       = Color3.fromRGB(26, 26, 29),
    Hover       = Color3.fromRGB(32, 32, 36),
    Active      = Color3.fromRGB(37, 37, 41),
    BorderSubtle= Color3.fromRGB(38, 38, 42),
    BorderMid   = Color3.fromRGB(52, 52, 58),
    BorderBright= Color3.fromRGB(68, 68, 76),
    TextPrimary = Color3.fromRGB(240, 240, 242),
    TextSecondary=Color3.fromRGB(138, 138, 150),
    TextMuted   = Color3.fromRGB(82, 82, 92),
    AccentOn    = Color3.fromRGB(200, 200, 220),
    Success     = Color3.fromRGB(74, 222, 128),
    Warning     = Color3.fromRGB(245, 158, 11),
    Danger      = Color3.fromRGB(220, 80, 80),
}

local SOUNDS = {
    Click   = { Pitch = 1.8,  Volume = 0.12, Duration = 0.06 },
    Toggle  = { Pitch = 1.4,  Volume = 0.10, Duration = 0.08 },
    Open    = { Pitch = 1.2,  Volume = 0.14, Duration = 0.12 },
    Close   = { Pitch = 0.8,  Volume = 0.10, Duration = 0.10 },
    Notif   = { Pitch = 1.6,  Volume = 0.13, Duration = 0.09 },
    Hover   = { Pitch = 2.0,  Volume = 0.05, Duration = 0.04 },
}

local TWEEN_FAST   = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_MED    = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_SLOW   = TweenInfo.new(0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_SPRING = TweenInfo.new(0.35, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)

local function tween(obj, props, info)
    TweenService:Create(obj, info or TWEEN_FAST, props):Play()
end

local function playSound(cfg)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxasset://sounds/uiclick.wav"
    sound.Pitch = cfg.Pitch or 1
    sound.Volume = cfg.Volume or 0.1
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 1)
end

local function makeInstance(class, props)
    local inst = Instance.new(class)
    for k, v in props do
        inst[k] = v
    end
    return inst
end

local function corner(parent, radius)
    return makeInstance("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function stroke(parent, color, thickness)
    return makeInstance("UIStroke", {
        Color = color or THEME.BorderSubtle,
        Thickness = thickness or 1,
        Parent = parent,
    })
end

local function padding(parent, top, right, bottom, left)
    return makeInstance("UIPadding", {
        PaddingTop    = UDim.new(0, top    or 8),
        PaddingRight  = UDim.new(0, right  or 10),
        PaddingBottom = UDim.new(0, bottom or 8),
        PaddingLeft   = UDim.new(0, left   or 10),
        Parent = parent,
    })
end

local function listLayout(parent, dir, spacing, align)
    return makeInstance("UIListLayout", {
        FillDirection       = dir or Enum.FillDirection.Vertical,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, spacing or 4),
        HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
        Parent = parent,
    })
end

local GUI = Instance.new("ScreenGui")
GUI.Name = "VaelthaUI"
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn = false
GUI.DisplayOrder = 999
GUI.Parent = gethui and gethui() or Players.LocalPlayer.PlayerGui

local NOTIF_HOLDER = makeInstance("Frame", {
    Name = "Notifications",
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -16, 1, -16),
    Size = UDim2.new(0, 260, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    ZIndex = 50,
    Parent = GUI,
})
makeInstance("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding = UDim.new(0, 6),
    Parent = NOTIF_HOLDER,
})

local function notify(title, body, ntype)
    playSound(SOUNDS.Notif)

    local dotColor = ntype == "success" and THEME.Success
        or ntype == "warning" and THEME.Warning
        or ntype == "error"   and THEME.Danger
        or THEME.TextSecondary

    local frame = makeInstance("Frame", {
        Name = "Notif",
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = THEME.Panel,
        BackgroundTransparency = 0.1,
        ClipsDescendants = true,
        Parent = NOTIF_HOLDER,
    })
    corner(frame, 10)
    stroke(frame, THEME.BorderMid)

    local dot = makeInstance("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = dotColor,
        Parent = frame,
    })
    corner(dot, 99)

    makeInstance("TextLabel", {
        Position = UDim2.new(0, 26, 0, 10),
        Size = UDim2.new(1, -30, 0, 16),
        Text = title,
        TextColor3 = THEME.TextPrimary,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = frame,
    })

    makeInstance("TextLabel", {
        Position = UDim2.new(0, 26, 0, 28),
        Size = UDim2.new(1, -30, 0, 14),
        Text = body or "",
        TextColor3 = THEME.TextMuted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = frame,
    })

    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.BackgroundTransparency = 1
    tween(frame, { Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 0.1 }, TWEEN_SPRING)

    task.delay(3, function()
        tween(frame, { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1 }, TWEEN_MED)
        task.delay(0.3, function() frame:Destroy() end)
    end)
end

function Vaeltha.new(config)
    config = config or {}
    local self = setmetatable({}, Vaeltha)

    self.Title      = config.Title    or "Vaeltha"
    self.Subtitle   = config.Subtitle or "v2.0.0"
    self.ToggleKey  = config.ToggleKey or Enum.KeyCode.RightShift
    self.Tabs       = {}
    self.ActiveTab  = nil
    self.Dragging   = false
    self.Minimized  = false
    self.Connections= {}

    self:_buildWindow()
    return self
end

function Vaeltha:_buildWindow()
    local WINDOW = makeInstance("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 620, 0, 440),
        BackgroundColor3 = THEME.Base,
        ClipsDescendants = true,
        Parent = GUI,
    })
    corner(WINDOW, 16)
    stroke(WINDOW, THEME.BorderSubtle, 1)
    self.Window = WINDOW

    local TITLEBAR = makeInstance("Frame", {
        Name = "Titlebar",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = THEME.Surface,
        Parent = WINDOW,
    })
    corner(TITLEBAR, 16)
    makeInstance("Frame", {
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = THEME.Surface,
        BorderSizePixel = 0,
        Parent = TITLEBAR,
    })
    makeInstance("Frame", {
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = THEME.BorderSubtle,
        BorderSizePixel = 0,
        Parent = TITLEBAR,
    })

    local LOGO = makeInstance("ImageLabel", {
        Position = UDim2.new(0, 12, 0.5, -11),
        Size = UDim2.new(0, 22, 0, 22),
        Image = "rbxassetid://84166263757664",
        BackgroundTransparency = 1,
        Parent = TITLEBAR,
    })

    makeInstance("TextLabel", {
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Text = self.Title,
        TextColor3 = THEME.TextPrimary,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = TITLEBAR,
    })

    makeInstance("TextLabel", {
        Position = UDim2.new(0, 96, 0, 0),
        Size = UDim2.new(0, 80, 1, 0),
        Text = self.Subtitle,
        TextColor3 = THEME.TextMuted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = TITLEBAR,
    })

    local ACTIONS = makeInstance("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 56, 0, 24),
        BackgroundTransparency = 1,
        Parent = TITLEBAR,
    })
    makeInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Parent = ACTIONS,
    })

    local function makeActionBtn(symbol, order, hoverColor, onClick)
        local btn = makeInstance("TextButton", {
            Size = UDim2.new(0, 24, 0, 24),
            Text = symbol,
            TextColor3 = THEME.TextMuted,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            BackgroundColor3 = THEME.Elevated,
            LayoutOrder = order,
            Parent = ACTIONS,
        })
        corner(btn, 6)
        stroke(btn, THEME.BorderSubtle)

        btn.MouseEnter:Connect(function()
            tween(btn, { BackgroundColor3 = hoverColor or THEME.Hover, TextColor3 = THEME.TextPrimary })
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, { BackgroundColor3 = THEME.Elevated, TextColor3 = THEME.TextMuted })
        end)
        btn.MouseButton1Click:Connect(onClick)
        return btn
    end

    makeActionBtn("−", 1, THEME.Hover, function()
        self:Minimize()
    end)
    makeActionBtn("×", 2, Color3.fromRGB(80, 30, 30), function()
        self:Close()
    end)

    self:_enableDrag(TITLEBAR)

    local BODY = makeInstance("Frame", {
        Position = UDim2.new(0, 0, 0, 48),
        Size = UDim2.new(1, 0, 1, -48),
        BackgroundTransparency = 1,
        Parent = WINDOW,
    })

    local SIDEBAR = makeInstance("Frame", {
        Size = UDim2.new(0, 50, 1, 0),
        BackgroundColor3 = THEME.Surface,
        Parent = BODY,
    })
    makeInstance("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = THEME.BorderSubtle,
        BorderSizePixel = 0,
        Parent = SIDEBAR,
    })
    makeInstance("UICorner", {
        CornerRadius = UDim.new(0, 0),
        Parent = SIDEBAR,
    })

    self.NavHolder = makeInstance("Frame", {
        Position = UDim2.new(0, 0, 0, 8),
        Size = UDim2.new(1, 0, 1, -16),
        BackgroundTransparency = 1,
        Parent = SIDEBAR,
    })
    listLayout(self.NavHolder, nil, 3)

    local CONTENT = makeInstance("Frame", {
        Position = UDim2.new(0, 50, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundColor3 = THEME.Base,
        ClipsDescendants = true,
        Parent = BODY,
    })
    self.ContentHolder = CONTENT

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.ToggleKey then
            self:Toggle()
        end
    end)

    tween(WINDOW, { Size = UDim2.new(0, 620, 0, 440) }, TWEEN_SPRING)
    playSound(SOUNDS.Open)
    notify("Vaeltha", "UI loaded successfully.", "success")
end

function Vaeltha:_enableDrag(handle)
    local startPos, startMouse
    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        self.Dragging = true
        startPos  = self.Window.Position
        startMouse= Vector2.new(input.Position.X, input.Position.Y)
    end)
    handle.InputChanged:Connect(function(input)
        if not self.Dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - startMouse
        self.Window.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)
end

function Vaeltha:AddTab(config)
    config = config or {}
    local tab = {
        Name      = config.Name    or "Tab",
        Icon      = config.Icon    or "rbxassetid://0",
        Sections  = {},
        NavButton = nil,
        Frame     = nil,
    }

    local NAV_BTN = makeInstance("TextButton", {
        Size = UDim2.new(1, -8, 0, 36),
        BackgroundColor3 = THEME.Surface,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = self.NavHolder,
    })
    corner(NAV_BTN, 8)
    padding(NAV_BTN, 0, 0, 0, 0)

    local ICON = makeInstance("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        Image = tab.Icon,
        ImageColor3 = THEME.TextMuted,
        BackgroundTransparency = 1,
        Parent = NAV_BTN,
    })

    local INDICATOR = makeInstance("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 3, 0, 0),
        BackgroundColor3 = THEME.AccentOn,
        BorderSizePixel = 0,
        Parent = NAV_BTN,
    })
    corner(INDICATOR, 3)

    local TAB_FRAME = makeInstance("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = THEME.BorderMid,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Visible = false,
        Parent = self.ContentHolder,
    })
    padding(TAB_FRAME, 14, 14, 14, 14)
    listLayout(TAB_FRAME, nil, 0)

    tab.NavButton  = NAV_BTN
    tab.Frame      = TAB_FRAME
    tab.Icon_Label = ICON
    tab.Indicator  = INDICATOR

    NAV_BTN.MouseEnter:Connect(function()
        if self.ActiveTab == tab then return end
        tween(ICON, { ImageColor3 = THEME.TextSecondary })
        tween(NAV_BTN, { BackgroundTransparency = 0.7 })
    end)
    NAV_BTN.MouseLeave:Connect(function()
        if self.ActiveTab == tab then return end
        tween(ICON, { ImageColor3 = THEME.TextMuted })
        tween(NAV_BTN, { BackgroundTransparency = 1 })
    end)
    NAV_BTN.MouseButton1Click:Connect(function()
        self:_selectTab(tab)
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        self:_selectTab(tab)
    end

    local tabAPI = {}

    function tabAPI:AddSection(name)
        local sec = {}

        local HEADER = makeInstance("TextLabel", {
            Size = UDim2.new(1, 0, 0, 24),
            Text = (name or "Section"):upper(),
            TextColor3 = THEME.TextMuted,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Parent = TAB_FRAME,
        })
        padding(HEADER, 4, 0, 2, 2)

        local CONTAINER = makeInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = TAB_FRAME,
        })
        listLayout(CONTAINER, nil, 3)

        local SPACER = makeInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 10),
            BackgroundTransparency = 1,
            Parent = TAB_FRAME,
        })

        sec.Container = CONTAINER

        local function makeRow(labelText, desc)
            local ROW = makeInstance("Frame", {
                Size = UDim2.new(1, 0, 0, desc and 46 or 36),
                BackgroundColor3 = THEME.Surface,
                Parent = CONTAINER,
            })
            corner(ROW, 8)
            stroke(ROW, THEME.BorderSubtle)

            ROW.MouseEnter:Connect(function()
                tween(ROW, { BackgroundColor3 = THEME.Elevated })
            end)
            ROW.MouseLeave:Connect(function()
                tween(ROW, { BackgroundColor3 = THEME.Surface })
            end)

            makeInstance("TextLabel", {
                Position = UDim2.new(0, 12, 0, desc and 8 or 0),
                Size = UDim2.new(0.6, -12, 0, 18),
                Text = labelText or "",
                TextColor3 = THEME.TextSecondary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = ROW,
            })

            if desc then
                makeInstance("TextLabel", {
                    Position = UDim2.new(0, 12, 0, 26),
                    Size = UDim2.new(0.7, -12, 0, 14),
                    Text = desc,
                    TextColor3 = THEME.TextMuted,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Parent = ROW,
                })
            end

            return ROW
        end

        function sec:AddToggle(config)
            config = config or {}
            local state = config.Default or false
            local ROW = makeRow(config.Name, config.Description)

            local TRACK = makeInstance("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, 34, 0, 18),
                BackgroundColor3 = THEME.Active,
                Parent = ROW,
            })
            corner(TRACK, 99)
            stroke(TRACK, THEME.BorderMid)

            local THUMB = makeInstance("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 2, 0.5, 0),
                Size = UDim2.new(0, 13, 0, 13),
                BackgroundColor3 = THEME.TextMuted,
                Parent = TRACK,
            })
            corner(THUMB, 99)

            local function setState(val, silent)
                state = val
                if val then
                    tween(TRACK, { BackgroundColor3 = Color3.fromRGB(50, 50, 65) })
                    tween(THUMB, { Position = UDim2.new(0, 18, 0.5, 0), BackgroundColor3 = THEME.TextPrimary })
                else
                    tween(TRACK, { BackgroundColor3 = THEME.Active })
                    tween(THUMB, { Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = THEME.TextMuted })
                end
                if not silent then
                    playSound(SOUNDS.Toggle)
                    if config.Callback then config.Callback(val) end
                end
            end

            setState(state, true)

            TRACK.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    setState(not state)
                end
            end)
            ROW.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    setState(not state)
                end
            end)

            local api = {}
            function api:Set(val) setState(val) end
            function api:Get() return state end
            return api
        end

        function sec:AddSlider(config)
            config = config or {}
            local MIN = config.Min or 0
            local MAX = config.Max or 100
            local DEF = config.Default or MIN
            local STEP = config.Step or 1
            local val = DEF
            local suffix = config.Suffix or ""

            local ROW = makeInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = THEME.Surface,
                Parent = CONTAINER,
            })
            corner(ROW, 8)
            stroke(ROW, THEME.BorderSubtle)

            ROW.MouseEnter:Connect(function() tween(ROW, { BackgroundColor3 = THEME.Elevated }) end)
            ROW.MouseLeave:Connect(function() tween(ROW, { BackgroundColor3 = THEME.Surface }) end)

            makeInstance("TextLabel", {
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(0.7, -12, 0, 16),
                Text = config.Name or "",
                TextColor3 = THEME.TextSecondary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = ROW,
            })

            local VAL_LABEL = makeInstance("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 8),
                Size = UDim2.new(0, 60, 0, 16),
                Text = tostring(DEF) .. suffix,
                TextColor3 = THEME.TextMuted,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundTransparency = 1,
                Parent = ROW,
            })

            local TRACK_BG = makeInstance("Frame", {
                Position = UDim2.new(0, 12, 0, 32),
                Size = UDim2.new(1, -24, 0, 3),
                BackgroundColor3 = THEME.Active,
                Parent = ROW,
            })
            corner(TRACK_BG, 99)

            local TRACK_FILL = makeInstance("Frame", {
                Size = UDim2.new((DEF - MIN) / (MAX - MIN), 0, 1, 0),
                BackgroundColor3 = THEME.AccentOn,
                Parent = TRACK_BG,
            })
            corner(TRACK_FILL, 99)

            local THUMB = makeInstance("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new((DEF - MIN) / (MAX - MIN), 0, 0.5, 0),
                Size = UDim2.new(0, 13, 0, 13),
                BackgroundColor3 = THEME.TextPrimary,
                Parent = TRACK_BG,
                ZIndex = 2,
            })
            corner(THUMB, 99)

            local dragging = false

            local function updateSlider(x)
                local rel = math.clamp((x - TRACK_BG.AbsolutePosition.X) / TRACK_BG.AbsoluteSize.X, 0, 1)
                val = MIN + math.round((MAX - MIN) * rel / STEP) * STEP
                val = math.clamp(val, MIN, MAX)
                local pct = (val - MIN) / (MAX - MIN)
                TRACK_FILL.Size = UDim2.new(pct, 0, 1, 0)
                THUMB.Position = UDim2.new(pct, 0, 0.5, 0)
                VAL_LABEL.Text = tostring(val) .. suffix
                if config.Callback then config.Callback(val) end
            end

            TRACK_BG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    playSound(SOUNDS.Click)
                    updateSlider(input.Position.X)
                end
            end)
            THUMB.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            local api = {}
            function api:Set(v)
                val = math.clamp(v, MIN, MAX)
                local pct = (val - MIN) / (MAX - MIN)
                TRACK_FILL.Size = UDim2.new(pct, 0, 1, 0)
                THUMB.Position = UDim2.new(pct, 0, 0.5, 0)
                VAL_LABEL.Text = tostring(val) .. suffix
            end
            function api:Get() return val end
            return api
        end

        function sec:AddDropdown(config)
            config = config or {}
            local OPTIONS = config.Options or {}
            local selected = config.Default or OPTIONS[1] or ""
            local open = false

            local ROW = makeInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = THEME.Surface,
                ClipsDescendants = false,
                ZIndex = 5,
                Parent = CONTAINER,
            })
            corner(ROW, 8)
            stroke(ROW, THEME.BorderSubtle)

            makeInstance("TextLabel", {
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(0.4, 0, 1, 0),
                Text = config.Name or "",
                TextColor3 = THEME.TextSecondary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                ZIndex = 5,
                Parent = ROW,
            })

            local BTN = makeInstance("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, 140, 0, 24),
                BackgroundColor3 = THEME.Active,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 5,
                Parent = ROW,
            })
            corner(BTN, 6)
            stroke(BTN, THEME.BorderMid)

            local BTN_LABEL = makeInstance("TextLabel", {
                Position = UDim2.new(0, 8, 0, 0),
                Size = UDim2.new(1, -24, 1, 0),
                Text = selected,
                TextColor3 = THEME.TextSecondary,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                ZIndex = 5,
                Parent = BTN,
            })

            makeInstance("TextLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -6, 0.5, 0),
                Size = UDim2.new(0, 14, 0, 14),
                Text = "▾",
                TextColor3 = THEME.TextMuted,
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                BackgroundTransparency = 1,
                ZIndex = 5,
                Parent = BTN,
            })

            local MENU = makeInstance("Frame", {
                Position = UDim2.new(1, -150, 1, 4),
                Size = UDim2.new(0, 140, 0, 0),
                BackgroundColor3 = THEME.Panel,
                ClipsDescendants = true,
                ZIndex = 20,
                Visible = false,
                Parent = ROW,
            })
            corner(MENU, 10)
            stroke(MENU, THEME.BorderMid)

            local MENU_LIST = makeInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ZIndex = 20,
                Parent = MENU,
            })
            listLayout(MENU_LIST, nil, 1)

            for _, opt in OPTIONS do
                local OPT_BTN = makeInstance("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = opt == selected and THEME.Active or THEME.Panel,
                    BackgroundTransparency = opt == selected and 0 or 1,
                    Text = opt,
                    TextColor3 = opt == selected and THEME.TextPrimary or THEME.TextSecondary,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    AutoButtonColor = false,
                    ZIndex = 20,
                    Parent = MENU_LIST,
                })
                padding(OPT_BTN, 0, 0, 0, 10)

                OPT_BTN.MouseEnter:Connect(function()
                    tween(OPT_BTN, { BackgroundTransparency = 0, BackgroundColor3 = THEME.Hover, TextColor3 = THEME.TextPrimary })
                end)
                OPT_BTN.MouseLeave:Connect(function()
                    local isSelected = OPT_BTN.Text == selected
                    tween(OPT_BTN, {
                        BackgroundTransparency = isSelected and 0 or 1,
                        BackgroundColor3 = THEME.Active,
                        TextColor3 = isSelected and THEME.TextPrimary or THEME.TextSecondary,
                    })
                end)
                OPT_BTN.MouseButton1Click:Connect(function()
                    selected = opt
                    BTN_LABEL.Text = opt
                    for _, child in MENU_LIST:GetChildren() do
                        if child:IsA("TextButton") then
                            local isSel = child.Text == selected
                            tween(child, {
                                BackgroundTransparency = isSel and 0 or 1,
                                BackgroundColor3 = THEME.Active,
                                TextColor3 = isSel and THEME.TextPrimary or THEME.TextSecondary,
                            })
                        end
                    end
                    open = false
                    tween(MENU, { Size = UDim2.new(0, 140, 0, 0) }, TWEEN_FAST)
                    task.delay(0.18, function() MENU.Visible = false end)
                    playSound(SOUNDS.Click)
                    if config.Callback then config.Callback(opt) end
                end)
            end

            BTN.MouseButton1Click:Connect(function()
                open = not open
                playSound(SOUNDS.Click)
                if open then
                    MENU.Visible = true
                    local targetH = math.min(#OPTIONS * 29 + 4, 160)
                    tween(MENU, { Size = UDim2.new(0, 140, 0, targetH) }, TWEEN_SPRING)
                else
                    tween(MENU, { Size = UDim2.new(0, 140, 0, 0) }, TWEEN_FAST)
                    task.delay(0.18, function() MENU.Visible = false end)
                end
            end)

            local api = {}
            function api:Set(v)
                selected = v
                BTN_LABEL.Text = v
                if config.Callback then config.Callback(v) end
            end
            function api:Get() return selected end
            return api
        end

        function sec:AddButton(config)
            config = config or {}

            local ROW = makeInstance("TextButton", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = THEME.Surface,
                Text = "",
                AutoButtonColor = false,
                Parent = CONTAINER,
            })
            corner(ROW, 8)
            stroke(ROW, THEME.BorderSubtle)

            makeInstance("TextLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, -24, 1, 0),
                Text = config.Name or "Button",
                TextColor3 = THEME.TextSecondary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                BackgroundTransparency = 1,
                Parent = ROW,
            })

            ROW.MouseEnter:Connect(function()
                tween(ROW, { BackgroundColor3 = THEME.Elevated })
            end)
            ROW.MouseLeave:Connect(function()
                tween(ROW, { BackgroundColor3 = THEME.Surface })
            end)
            ROW.MouseButton1Down:Connect(function()
                tween(ROW, { BackgroundColor3 = THEME.Active })
            end)
            ROW.MouseButton1Click:Connect(function()
                tween(ROW, { BackgroundColor3 = THEME.Elevated })
                playSound(SOUNDS.Click)
                if config.Callback then config.Callback() end
            end)
        end

        function sec:AddTextbox(config)
            config = config or {}
            local ROW = makeRow(config.Name)

            local BOX = makeInstance("TextBox", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, 150, 0, 24),
                BackgroundColor3 = THEME.Active,
                Text = config.Default or "",
                PlaceholderText = config.Placeholder or "...",
                TextColor3 = THEME.TextSecondary,
                PlaceholderColor3 = THEME.TextMuted,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                ClearTextOnFocus = config.ClearOnFocus ~= false,
                Parent = ROW,
            })
            corner(BOX, 6)
            stroke(BOX, THEME.BorderSubtle)
            padding(BOX, 0, 8, 0, 8)

            BOX.Focused:Connect(function()
                tween(BOX, { BackgroundColor3 = THEME.Panel })
            end)
            BOX.FocusLost:Connect(function(enter)
                tween(BOX, { BackgroundColor3 = THEME.Active })
                if config.Callback then config.Callback(BOX.Text, enter) end
            end)

            local api = {}
            function api:Get() return BOX.Text end
            function api:Set(v) BOX.Text = v end
            return api
        end

        function sec:AddColorPicker(config)
            config = config or {}
            local colors = config.Colors or {
                Color3.fromRGB(200, 200, 212),
                Color3.fromRGB(74, 222, 128),
                Color3.fromRGB(96, 165, 250),
                Color3.fromRGB(248, 113, 113),
                Color3.fromRGB(251, 191, 36),
            }
            local selected = config.Default or colors[1]

            local ROW = makeInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = THEME.Surface,
                Parent = CONTAINER,
            })
            corner(ROW, 8)
            stroke(ROW, THEME.BorderSubtle)

            makeInstance("TextLabel", {
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(0.4, 0, 1, 0),
                Text = config.Name or "Color",
                TextColor3 = THEME.TextSecondary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = ROW,
            })

            local PICKER_HOLDER = makeInstance("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, (#colors * 26) + (#colors - 1) * 5, 0, 26),
                BackgroundTransparency = 1,
                Parent = ROW,
            })
            listLayout(PICKER_HOLDER, Enum.FillDirection.Horizontal, 5, Enum.HorizontalAlignment.Right)

            for _, c in colors do
                local SWATCH = makeInstance("TextButton", {
                    Size = UDim2.new(0, 26, 0, 26),
                    BackgroundColor3 = c,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = PICKER_HOLDER,
                })
                corner(SWATCH, 7)

                if c == selected then
                    stroke(SWATCH, THEME.TextPrimary, 2)
                else
                    stroke(SWATCH, THEME.BorderMid)
                end

                SWATCH.MouseButton1Click:Connect(function()
                    selected = c
                    for _, child in PICKER_HOLDER:GetChildren() do
                        if child:IsA("TextButton") then
                            local s = child:FindFirstChildOfClass("UIStroke")
                            if s then
                                s.Color = child.BackgroundColor3 == c and THEME.TextPrimary or THEME.BorderMid
                                s.Thickness = child.BackgroundColor3 == c and 2 or 1
                            end
                        end
                    end
                    playSound(SOUNDS.Click)
                    if config.Callback then config.Callback(c) end
                end)

                SWATCH.MouseEnter:Connect(function()
                    tween(SWATCH, { Size = UDim2.new(0, 28, 0, 28) })
                end)
                SWATCH.MouseLeave:Connect(function()
                    tween(SWATCH, { Size = UDim2.new(0, 26, 0, 26) })
                end)
            end

            local api = {}
            function api:Get() return selected end
            return api
        end

        function sec:AddLabel(text)
            makeInstance("TextLabel", {
                Size = UDim2.new(1, 0, 0, 28),
                Text = text or "",
                TextColor3 = THEME.TextMuted,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = CONTAINER,
            })
        end

        function sec:AddSeparator()
            local SEP = makeInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = THEME.BorderSubtle,
                BorderSizePixel = 0,
                Parent = CONTAINER,
            })
        end

        return sec
    end

    return tabAPI
end

function Vaeltha:_selectTab(tab)
    if self.ActiveTab == tab then return end
    playSound(SOUNDS.Click)

    if self.ActiveTab then
        local prev = self.ActiveTab
        tween(prev.NavButton, { BackgroundTransparency = 1 })
        tween(prev.Icon_Label, { ImageColor3 = THEME.TextMuted })
        tween(prev.Indicator, { Size = UDim2.new(0, 3, 0, 0) })
        prev.Frame.Visible = false
    end

    self.ActiveTab = tab
    tween(tab.NavButton, { BackgroundTransparency = 0.7 })
    tween(tab.Icon_Label, { ImageColor3 = THEME.TextPrimary })
    tween(tab.Indicator, { Size = UDim2.new(0, 3, 0, 16) })

    tab.Frame.Position = UDim2.new(0.05, 0, 0, 0)
    tab.Frame.Visible = true
    tween(tab.Frame, { Position = UDim2.new(0, 0, 0, 0) }, TWEEN_MED)
end

function Vaeltha:Notify(title, body, ntype)
    notify(title, body, ntype)
end

function Vaeltha:Toggle()
    if self.Minimized then
        self:Restore()
    else
        self.Window.Visible = not self.Window.Visible
        playSound(self.Window.Visible and SOUNDS.Open or SOUNDS.Close)
    end
end

function Vaeltha:Minimize()
    self.Minimized = true
    playSound(SOUNDS.Close)
    tween(self.Window, { Size = UDim2.new(0, 620, 0, 48) }, TWEEN_MED)
end

function Vaeltha:Restore()
    self.Minimized = false
    playSound(SOUNDS.Open)
    tween(self.Window, { Size = UDim2.new(0, 620, 0, 440) }, TWEEN_SPRING)
end

function Vaeltha:Close()
    playSound(SOUNDS.Close)
    tween(self.Window, { Size = UDim2.new(0, 620, 0, 0), BackgroundTransparency = 1 }, TWEEN_MED)
    task.delay(0.3, function()
        GUI:Destroy()
    end)
end

function Vaeltha:Destroy()
    GUI:Destroy()
end

return Vaeltha
