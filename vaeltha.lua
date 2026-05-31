-- ██╗   ██╗ █████╗ ███████╗██╗  ████████╗██╗  ██╗ █████╗
-- ██║   ██║██╔══██╗██╔════╝██║  ╚══██╔══╝██║  ██║██╔══██╗
-- ██║   ██║███████║█████╗  ██║     ██║   ███████║███████║
-- ╚██╗ ██╔╝██╔══██║██╔══╝  ██║     ██║   ██╔══██║██╔══██║
--  ╚████╔╝ ██║  ██║███████╗███████╗██║   ██║  ██║██║  ██║
--   ╚═══╝  ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝
-- Premium Roblox UI Library · v2.0

local Vaeltha = {flags = {}, tabs = {}, open = true}

local Players     = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS         = game:GetService("UserInputService")
local CoreGui     = game:GetService("CoreGui")
local Lighting    = game:GetService("Lighting")
local Debris      = game:GetService("Debris")

local LP = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
-- THEME · premium gri-siyah, minimal ama derin
-- ═══════════════════════════════════════════════════════════
local T = {
	bg         = Color3.fromRGB(8,   8,   10),
	bg2        = Color3.fromRGB(12,  12,  15),
	surface    = Color3.fromRGB(16,  16,  20),
	surface2   = Color3.fromRGB(22,  22,  28),
	surface3   = Color3.fromRGB(30,  30,  38),
	surface4   = Color3.fromRGB(38,  38,  48),
	border     = Color3.fromRGB(48,  48,  62),
	borderHi   = Color3.fromRGB(80,  80, 100),
	accent     = Color3.fromRGB(180, 160, 255),
	accentDim  = Color3.fromRGB(100,  80, 200),
	accentDeep = Color3.fromRGB( 60,  45, 140),
	accentGlow = Color3.fromRGB(210, 195, 255),
	text       = Color3.fromRGB(235, 235, 245),
	textDim    = Color3.fromRGB(150, 150, 170),
	textMuted  = Color3.fromRGB( 80,  80,  98),
	white      = Color3.fromRGB(255, 255, 255),
	red        = Color3.fromRGB(220,  70,  70),
	green      = Color3.fromRGB( 80, 200, 120),
}

-- ═══════════════════════════════════════════════════════════
-- SOUNDS
-- ═══════════════════════════════════════════════════════════
local SFX = {
	click   = {id = "rbxassetid://6895079853",  pitch = 1.2,  vol = 0.35},
	toggle  = {id = "rbxassetid://9119713951",  pitch = 1.15, vol = 0.3 },
	open    = {id = "rbxassetid://9119713951",  pitch = 0.85, vol = 0.45},
	close   = {id = "rbxassetid://9119713951",  pitch = 0.7,  vol = 0.4 },
	shrink  = {id = "rbxassetid://6895079853",  pitch = 0.8,  vol = 0.3 },
	tab     = {id = "rbxassetid://6895079853",  pitch = 1.35, vol = 0.28},
	hover   = {id = "rbxassetid://6895079853",  pitch = 1.6,  vol = 0.18},
	notify  = {id = "rbxassetid://9119713951",  pitch = 1.4,  vol = 0.38},
	slider  = {id = "rbxassetid://6895079853",  pitch = 1.5,  vol = 0.12},
	dropdown= {id = "rbxassetid://6895079853",  pitch = 1.1,  vol = 0.25},
	bind    = {id = "rbxassetid://9119713951",  pitch = 1.3,  vol = 0.3 },
}

local function sfx(key)
	local s = SFX[key]
	if not s then return end
	local snd = Instance.new("Sound")
	snd.SoundId = s.id
	snd.Volume = s.vol
	snd.PlaybackSpeed = s.pitch
	snd.Parent = CoreGui
	snd:Play()
	Debris:AddItem(snd, 3)
end

-- ═══════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════
local function tw(obj, props, t, style, dir)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		props
	):Play()
end

local function mk(cls, props, par)
	local o = Instance.new(cls)
	for k, v in props or {} do o[k] = v end
	if par then o.Parent = par end
	return o
end

local function corner(par, r)
	return mk("UICorner", {CornerRadius = UDim.new(0, r or 6)}, par)
end

local function stroke(par, col, thick, trans)
	return mk("UIStroke", {Color = col or T.border, Thickness = thick or 1, Transparency = trans or 0}, par)
end

local function pad(par, t, b, l, r)
	return mk("UIPadding", {
		PaddingTop = UDim.new(0, t or 0),
		PaddingBottom = UDim.new(0, b or 0),
		PaddingLeft = UDim.new(0, l or 0),
		PaddingRight = UDim.new(0, r or 0),
	}, par)
end

local function lst(par, sp, dir)
	return mk("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = dir or Enum.FillDirection.Vertical,
		Padding = UDim.new(0, sp or 0),
	}, par)
end

local function grad(par, c0, c1, rot)
	return mk("UIGradient", {
		Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c0), ColorSequenceKeypoint.new(1, c1)}),
		Rotation = rot or 90,
	}, par)
end

-- ═══════════════════════════════════════════════════════════
-- DRAG
-- ═══════════════════════════════════════════════════════════
local dragObj, dragStart, startPos, dragging = nil, nil, nil, false

local function makeDraggable(handle, target)
	handle.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1
		and i.UserInputType ~= Enum.UserInputType.Touch then return end
		dragging = true
		dragObj = target
		dragStart = i.Position
		startPos = target.Position
	end)
	handle.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

UIS.InputChanged:Connect(function(i)
	if not dragging or not dragObj then return end
	if i.UserInputType ~= Enum.UserInputType.MouseMovement
	and i.UserInputType ~= Enum.UserInputType.Touch then return end
	local d = i.Position - dragStart
	dragObj:TweenPosition(
		UDim2.new(
			startPos.X.Scale, startPos.X.Offset + d.X,
			startPos.Y.Scale, startPos.Y.Offset + d.Y
		),
		Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.06, true
	)
end)

-- ═══════════════════════════════════════════════════════════
-- VAELTHA LOGO · rbxassetid://84166263757664
-- ═══════════════════════════════════════════════════════════
local LOGO = "rbxassetid://84166263757664"

-- ═══════════════════════════════════════════════════════════
-- TAB ICONS · material / custom unicode
-- ═══════════════════════════════════════════════════════════
local DEFAULT_ICONS = {
	["Main"]     = "⚡",
	["Legit"]    = "🎯",
	["Rage"]     = "💢",
	["Visuals"]  = "👁",
	["Anti Aim"] = "🔄",
	["Settings"] = "⚙",
	["ESP"]      = "📡",
	["Movement"] = "🏃",
	["Misc"]     = "🔧",
	["Player"]   = "👤",
}

-- ═══════════════════════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════════════════════
function Vaeltha:Init(title)
	-- ── ScreenGui
	self.gui = mk("ScreenGui", {
		Name = "VaelthaUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(function()
		if gethui then
			self.gui.Parent = gethui()
		else
			self.gui.Parent = CoreGui
		end
	end)
	if not self.gui.Parent then self.gui.Parent = CoreGui end

	-- ── Ambient cinematic vignette
	local ambient = mk("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.55,
		ZIndex = 0,
	}, self.gui)

	-- Subtle radial glow blobs (premium depth feel)
	local function blob(x, y, sz, col, trans)
		local f = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(x, 0, y, 0),
			Size = UDim2.new(0, sz, 0, sz),
			BackgroundColor3 = col,
			BackgroundTransparency = trans,
			ZIndex = 0,
		}, ambient)
		corner(f, sz // 2)
		return f
	end
	blob(0.28, 0.35, 600, Color3.fromRGB(55, 35, 160), 0.91)
	blob(0.72, 0.65, 480, Color3.fromRGB(30, 20, 100), 0.93)
	blob(0.5,  0.5,  320, Color3.fromRGB(80, 60, 190), 0.95)

	-- ── BlurEffect for depth
	local blur = mk("BlurEffect", {Size = 10}, Lighting)

	-- ── Main Window
	self.window = mk("Frame", {
		Name = "VaelthaWindow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 720, 0, 460),
		BackgroundColor3 = T.bg,
		BorderSizePixel = 0,
		ZIndex = 2,
		ClipsDescendants = false,
	}, self.gui)
	corner(self.window, 12)

	-- window border glow
	local winStroke = stroke(self.window, T.border, 1, 0.2)

	-- drop shadow
	mk("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 12),
		Size = UDim2.new(1, 80, 1, 80),
		BackgroundTransparency = 1,
		Image = "rbxassetid://5028857084",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.55,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(24, 24, 276, 276),
		ZIndex = 1,
	}, self.window)

	-- top chromatic line
	local topLine = mk("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = T.accent,
		BackgroundTransparency = 0.2,
		ZIndex = 10,
	}, self.window)
	grad(topLine, T.accentGlow, T.accentDeep, 0)

	-- ── TITLEBAR
	local titlebar = mk("Frame", {
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = T.bg2,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, self.window)
	corner(titlebar, 12)
	mk("Frame", {
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = T.bg2,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, titlebar)

	makeDraggable(titlebar, self.window)

	-- separator under titlebar
	mk("Frame", {
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = T.border,
		BackgroundTransparency = 0.4,
		ZIndex = 6,
	}, titlebar)

	-- ── LOGO IMAGE
	local logoImg = mk("ImageLabel", {
		Position = UDim2.new(0, 14, 0, 10),
		Size = UDim2.new(0, 32, 0, 32),
		BackgroundTransparency = 1,
		Image = LOGO,
		ImageColor3 = T.accentGlow,
		ZIndex = 8,
	}, titlebar)

	-- logo glow halo
	local logoHalo = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(2.2, 0, 2.2, 0),
		BackgroundColor3 = T.accent,
		BackgroundTransparency = 0.82,
		ZIndex = 7,
	}, logoImg)
	corner(logoHalo, 30)

	-- pulse animation on logo
	task.spawn(function()
		while logoImg.Parent do
			tw(logoHalo, {BackgroundTransparency = 0.72}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(1.25)
			tw(logoHalo, {BackgroundTransparency = 0.88}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(1.25)
		end
	end)

	-- title text
	mk("TextLabel", {
		Position = UDim2.new(0, 54, 0, 0),
		Size = UDim2.new(0, 160, 1, 0),
		BackgroundTransparency = 1,
		Text = title or "Vaeltha",
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextColor3 = T.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 8,
	}, titlebar)

	-- version chip
	local chip = mk("Frame", {
		Position = UDim2.new(0, 54, 0, 33),
		Size = UDim2.new(0, 44, 0, 14),
		BackgroundColor3 = T.surface3,
		ZIndex = 8,
	}, titlebar)
	corner(chip, 4)
	stroke(chip, T.accentDeep, 1, 0.5)
	mk("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "v2.0",
		TextSize = 10,
		Font = Enum.Font.GothamBold,
		TextColor3 = T.accentDim,
		ZIndex = 9,
	}, chip)

	-- ── CLOSE button
	local closeBtn = mk("ImageButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, 26, 0, 26),
		BackgroundColor3 = T.red,
		BackgroundTransparency = 0.35,
		Image = "",
		ZIndex = 8,
	}, titlebar)
	corner(closeBtn, 7)
	mk("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "×",
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextColor3 = T.white,
		ZIndex = 9,
	}, closeBtn)
	closeBtn.MouseEnter:Connect(function() sfx("hover") tw(closeBtn, {BackgroundTransparency = 0}, 0.1) end)
	closeBtn.MouseLeave:Connect(function() tw(closeBtn, {BackgroundTransparency = 0.35}, 0.1) end)
	closeBtn.MouseButton1Click:Connect(function()
		sfx("close")
		self:Toggle()
	end)

	-- ── MINIMIZE button
	local minBtn = mk("ImageButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -46, 0.5, 0),
		Size = UDim2.new(0, 26, 0, 26),
		BackgroundColor3 = T.surface4,
		BackgroundTransparency = 0.4,
		Image = "",
		ZIndex = 8,
	}, titlebar)
	corner(minBtn, 7)
	mk("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "−",
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextColor3 = T.textDim,
		ZIndex = 9,
	}, minBtn)
	minBtn.MouseEnter:Connect(function() sfx("hover") tw(minBtn, {BackgroundTransparency = 0, BackgroundColor3 = T.accentDeep}, 0.1) end)
	minBtn.MouseLeave:Connect(function() tw(minBtn, {BackgroundTransparency = 0.4, BackgroundColor3 = T.surface4}, 0.1) end)
	minBtn.MouseButton1Click:Connect(function()
		sfx("shrink")
		self:Shrink()
	end)

	-- ── LEFT SIDEBAR
	local sidebar = mk("Frame", {
		Position = UDim2.new(0, 0, 0, 52),
		Size = UDim2.new(0, 58, 1, -52),
		BackgroundColor3 = T.bg2,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, self.window)

	-- right separator
	mk("Frame", {
		Position = UDim2.new(1, -1, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = T.border,
		BackgroundTransparency = 0.4,
		ZIndex = 5,
	}, sidebar)

	-- bottom left fill (square off corner)
	mk("Frame", {
		Position = UDim2.new(0, 0, 1, -12),
		Size = UDim2.new(1, 0, 0, 12),
		BackgroundColor3 = T.bg2,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, sidebar)

	self.tabList = mk("Frame", {
		Position = UDim2.new(0, 0, 0, 10),
		Size = UDim2.new(1, 0, 1, -20),
		BackgroundTransparency = 1,
		ZIndex = 5,
	}, sidebar)
	lst(self.tabList, 3)

	-- ── CONTENT AREA
	self.contentHolder = mk("Frame", {
		Position = UDim2.new(0, 58, 0, 52),
		Size = UDim2.new(1, -58, 1, -52),
		BackgroundTransparency = 1,
		ZIndex = 3,
		ClipsDescendants = true,
	}, self.window)

	-- subtle noise overlay for premium texture
	mk("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://9126418972",
		ImageTransparency = 0.96,
		ZIndex = 3,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.new(0, 64, 0, 64),
	}, self.contentHolder)

	-- open animation
	self.window.Size = UDim2.new(0, 720, 0, 0)
	self.window.BackgroundTransparency = 1
	tw(self.window, {Size = UDim2.new(0, 720, 0, 460), BackgroundTransparency = 0}, 0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	sfx("open")

	self.shrunk = false
	return self
end

-- ═══════════════════════════════════════════════════════════
-- TOGGLE & SHRINK
-- ═══════════════════════════════════════════════════════════
function Vaeltha:Toggle()
	self.open = not self.open
	if self.open then
		sfx("open")
		self.window.Visible = true
		tw(self.window, {Size = UDim2.new(0, 720, 0, 460), BackgroundTransparency = 0}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	else
		sfx("close")
		tw(self.window, {Size = UDim2.new(0, 720, 0, 0), BackgroundTransparency = 0.6}, 0.2, Enum.EasingStyle.Quint)
		task.delay(0.21, function() if not self.open then self.window.Visible = false end end)
	end
end

function Vaeltha:Shrink()
	self.shrunk = not self.shrunk
	if self.shrunk then
		sfx("shrink")
		tw(self.window, {Size = UDim2.new(0, 720, 0, 52)}, 0.22, Enum.EasingStyle.Quint)
		self.contentHolder.Visible = false
	else
		sfx("open")
		self.contentHolder.Visible = true
		tw(self.window, {Size = UDim2.new(0, 720, 0, 460)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end
end

-- ═══════════════════════════════════════════════════════════
-- ADD TAB
-- ═══════════════════════════════════════════════════════════
function Vaeltha:AddTab(name, icon)
	local tabData = {name = name, sections = {}, active = false}
	table.insert(self.tabs, tabData)

	icon = icon or DEFAULT_ICONS[name] or "•"

	-- ── sidebar button
	local btn = mk("ImageButton", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = T.surface,
		BackgroundTransparency = 1,
		Image = "",
		ZIndex = 6,
		LayoutOrder = #self.tabs,
		Parent = self.tabList,
	})
	corner(btn, 8)
	pad(btn, 0, 0, 4, 4)

	-- left active bar
	local bar = mk("Frame", {
		Position = UDim2.new(0, 3, 0.15, 0),
		Size = UDim2.new(0, 3, 0.7, 0),
		BackgroundColor3 = T.accent,
		BackgroundTransparency = 1,
		ZIndex = 7,
		Parent = btn,
	})
	corner(bar, 2)

	-- active fill
	local fill = mk("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = T.accent,
		BackgroundTransparency = 1,
		ZIndex = 6,
		Parent = btn,
	})
	corner(fill, 8)

	-- icon
	local ico = mk("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.4),
		Position = UDim2.new(0.5, 0, 0.4, 0),
		Size = UDim2.new(0, 24, 0, 24),
		BackgroundTransparency = 1,
		Text = icon,
		TextSize = 17,
		Font = Enum.Font.GothamBold,
		TextColor3 = T.textMuted,
		ZIndex = 7,
		Parent = btn,
	})

	-- label under icon
	local lbl = mk("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -5),
		Size = UDim2.new(1, -4, 0, 11),
		BackgroundTransparency = 1,
		Text = name,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextColor3 = T.textMuted,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 7,
		Parent = btn,
	})

	-- ── scroll page
	local page = mk("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.accentDeep,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		ZIndex = 4,
		Parent = self.contentHolder,
	})
	pad(page, 14, 14, 12, 12)
	lst(page, 8)

	tabData.btn  = btn
	tabData.bar  = bar
	tabData.fill = fill
	tabData.ico  = ico
	tabData.lbl  = lbl
	tabData.page = page

	local function activate()
		for _, t in self.tabs do
			if t ~= tabData then
				t.page.Visible = false
				tw(t.btn,  {BackgroundTransparency = 1}, 0.18)
				tw(t.bar,  {BackgroundTransparency = 1}, 0.18)
				tw(t.fill, {BackgroundTransparency = 1}, 0.18)
				tw(t.ico,  {TextColor3 = T.textMuted}, 0.18)
				tw(t.lbl,  {TextColor3 = T.textMuted}, 0.18)
				t.active = false
			end
		end
		tabData.active = true
		page.Visible = true
		tw(btn,  {BackgroundTransparency = 0.92}, 0.18)
		tw(fill, {BackgroundTransparency = 0.91, BackgroundColor3 = T.accentDeep}, 0.18)
		tw(bar,  {BackgroundTransparency = 0}, 0.18)
		tw(ico,  {TextColor3 = T.accentGlow}, 0.18)
		tw(lbl,  {TextColor3 = T.textDim}, 0.18)
	end

	btn.MouseButton1Click:Connect(function()
		if tabData.active then return end
		sfx("tab")
		-- ripple click effect
		local ripple = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = T.accent,
			BackgroundTransparency = 0.7,
			ZIndex = 9,
			Parent = btn,
		})
		corner(ripple, 30)
		tw(ripple, {Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Quint)
		task.delay(0.41, function() ripple:Destroy() end)
		activate()
	end)
	btn.MouseEnter:Connect(function()
		if tabData.active then return end
		sfx("hover")
		tw(btn, {BackgroundTransparency = 0.95}, 0.12)
		tw(ico, {TextColor3 = T.textDim}, 0.12)
	end)
	btn.MouseLeave:Connect(function()
		if tabData.active then return end
		tw(btn, {BackgroundTransparency = 1}, 0.12)
		tw(ico, {TextColor3 = T.textMuted}, 0.12)
	end)

	if #self.tabs == 1 then activate() end

	-- ═══════════════════════════════════════════════════════
	-- ADD SECTION
	-- ═══════════════════════════════════════════════════════
	function tabData:AddSection(sName)
		local sd = {}

		local container = mk("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = T.surface,
			BorderSizePixel = 0,
			ZIndex = 5,
			LayoutOrder = #page:GetChildren() + 1,
			Parent = page,
		})
		corner(container, 8)
		stroke(container, T.border, 1, 0.55)

		-- section header
		local hdr = mk("Frame", {
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundTransparency = 1,
			ZIndex = 6,
			Parent = container,
		})

		-- accent pill left
		local pill = mk("Frame", {
			Position = UDim2.new(0, 0, 0.18, 0),
			Size = UDim2.new(0, 3, 0.64, 0),
			BackgroundColor3 = T.accent,
			ZIndex = 7,
			Parent = hdr,
		})
		corner(pill, 2)
		grad(pill, T.accentGlow, T.accentDim, 90)

		mk("TextLabel", {
			Position = UDim2.new(0, 14, 0, 0),
			Size = UDim2.new(1, -14, 1, 0),
			BackgroundTransparency = 1,
			Text = sName,
			TextSize = 11,
			Font = Enum.Font.GothamBold,
			TextColor3 = T.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 7,
			Parent = hdr,
		})

		mk("Frame", {
			Position = UDim2.new(0, 14, 1, -1),
			Size = UDim2.new(1, -14, 0, 1),
			BackgroundColor3 = T.border,
			BackgroundTransparency = 0.55,
			ZIndex = 6,
			Parent = hdr,
		})

		-- content
		local content = mk("Frame", {
			Position = UDim2.new(0, 0, 0, 34),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			ZIndex = 6,
			Parent = container,
		})
		pad(content, 4, 8, 12, 12)
		lst(content, 3)

		local function lo() return #content:GetChildren() + 1 end

		-- ─────────────────────────────────────────────────
		-- LABEL
		-- ─────────────────────────────────────────────────
		function sd:AddLabel(text)
			mk("TextLabel", {
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundTransparency = 1,
				Text = text,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				TextColor3 = T.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 7,
				LayoutOrder = lo(),
				Parent = content,
			})
		end

		-- ─────────────────────────────────────────────────
		-- SEPARATOR
		-- ─────────────────────────────────────────────────
		function sd:AddSeparator()
			local w = mk("Frame", {
				Size = UDim2.new(1, 0, 0, 9),
				BackgroundTransparency = 1,
				ZIndex = 7,
				LayoutOrder = lo(),
				Parent = content,
			})
			mk("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = T.border,
				BackgroundTransparency = 0.4,
				ZIndex = 8,
				Parent = w,
			})
		end

		-- ─────────────────────────────────────────────────
		-- TOGGLE
		-- ─────────────────────────────────────────────────
		function sd:AddToggle(opt)
			opt = opt or {}
			opt.flag     = opt.flag or opt.text
			opt.state    = opt.state or false
			opt.callback = opt.callback or function() end
			Vaeltha.flags[opt.flag] = opt.state

			local h = opt.desc and 42 or 34
			local row = mk("Frame", {
				Size = UDim2.new(1, 0, 0, h),
				BackgroundTransparency = 1,
				ZIndex = 7,
				LayoutOrder = lo(),
				Parent = content,
			})

			mk("TextLabel", {
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, -54, 0, 18),
				BackgroundTransparency = 1,
				Text = opt.text or "",
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextColor3 = T.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 8,
				Parent = row,
			})

			if opt.desc then
				mk("TextLabel", {
					Position = UDim2.new(0, 0, 0, 19),
					Size = UDim2.new(1, -54, 0, 13),
					BackgroundTransparency = 1,
					Text = opt.desc,
					TextSize = 10,
					Font = Enum.Font.Gotham,
					TextColor3 = T.textMuted,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 8,
					Parent = row,
				})
			end

			-- pill track
			local pillBg = mk("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 44, 0, 22),
				BackgroundColor3 = opt.state and T.accentDeep or T.surface3,
				ZIndex = 8,
				Parent = row,
			})
			corner(pillBg, 11)
			local pillStroke = stroke(pillBg, opt.state and T.accent or T.border, 1, 0.4)

			-- inner gradient fill
			local pillFill = mk("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = T.accent,
				BackgroundTransparency = opt.state and 0.5 or 1,
				ZIndex = 8,
				Parent = pillBg,
			})
			corner(pillFill, 11)
			grad(pillFill, T.accentGlow, T.accentDim, 0)

			local knob = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = opt.state and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16),
				BackgroundColor3 = T.white,
				ZIndex = 9,
				Parent = pillBg,
			})
			corner(knob, 8)

			local function setState(s, noCb)
				opt.state = s
				Vaeltha.flags[opt.flag] = s
				if s then
					tw(pillBg,    {BackgroundColor3 = T.accentDeep}, 0.18)
					tw(pillFill,  {BackgroundTransparency = 0.5}, 0.18)
					tw(knob,      {Position = UDim2.new(1, -11, 0.5, 0), BackgroundColor3 = T.white}, 0.18)
					pillStroke.Color = T.accent
				else
					tw(pillBg,    {BackgroundColor3 = T.surface3}, 0.18)
					tw(pillFill,  {BackgroundTransparency = 1}, 0.18)
					tw(knob,      {Position = UDim2.new(0, 11, 0.5, 0), BackgroundColor3 = T.white}, 0.18)
					pillStroke.Color = T.border
				end
				if not noCb then opt.callback(s) end
			end

			row.InputBegan:Connect(function(i)
				if i.UserInputType ~= Enum.UserInputType.MouseButton1
				and i.UserInputType ~= Enum.UserInputType.Touch then return end
				sfx("toggle")
				-- knob pop
				tw(knob, {Size = UDim2.new(0, 20, 0, 20)}, 0.08)
				task.delay(0.09, function() tw(knob, {Size = UDim2.new(0, 16, 0, 16)}, 0.12) end)
				setState(not opt.state)
			end)

			row.MouseEnter:Connect(function()
				tw(pillBg, {BackgroundColor3 = opt.state and T.accentDeep or T.surface4}, 0.1)
			end)
			row.MouseLeave:Connect(function()
				tw(pillBg, {BackgroundColor3 = opt.state and T.accentDeep or T.surface3}, 0.1)
			end)

			function opt:SetState(s) setState(s, false) end
			if opt.state then task.defer(function() opt.callback(true) end) end
			return opt
		end

		-- ─────────────────────────────────────────────────
		-- SLIDER
		-- ─────────────────────────────────────────────────
		function sd:AddSlider(opt)
			opt = opt or {}
			opt.flag     = opt.flag or opt.text
			opt.min      = opt.min   or 0
			opt.max      = opt.max   or 100
			opt.value    = math.clamp(opt.value or opt.min, opt.min, opt.max)
			opt.float    = opt.float or 1
			opt.callback = opt.callback or function() end
			Vaeltha.flags[opt.flag] = opt.value

			local row = mk("Frame", {
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundTransparency = 1,
				ZIndex = 7,
				LayoutOrder = lo(),
				Parent = content,
			})

			mk("TextLabel", {
				Size = UDim2.new(1, -52, 0, 16),
				BackgroundTransparency = 1,
				Text = opt.text or "",
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextColor3 = T.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 8,
				Parent = row,
			})

			local valLbl = mk("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0, 52, 0, 16),
				BackgroundTransparency = 1,
				Text = tostring(opt.value),
				TextSize = 12,
				Font = Enum.Font.GothamBold,
				TextColor3 = T.accent,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 8,
				Parent = row,
			})

			-- track bg
			local track = mk("Frame", {
				Position = UDim2.new(0, 0, 0, 26),
				Size = UDim2.new(1, 0, 0, 6),
				BackgroundColor3 = T.surface3,
				ZIndex = 8,
				Parent = row,
			})
			corner(track, 3)
			stroke(track, T.border, 1, 0.6)

			local fill2 = mk("Frame", {
				Size = UDim2.new((opt.value - opt.min) / (opt.max - opt.min), 0, 1, 0),
				BackgroundColor3 = T.accent,
				ZIndex = 9,
				Parent = track,
			})
			corner(fill2, 3)
			grad(fill2, T.accentGlow, T.accentDim, 0)

			local hdl = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new((opt.value - opt.min) / (opt.max - opt.min), 0, 0.5, 0),
				Size = UDim2.new(0, 12, 0, 12),
				BackgroundColor3 = T.white,
				ZIndex = 10,
				Parent = track,
			})
			corner(hdl, 6)

			-- glow ring on handle
			local hdlGlow = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(2.4, 0, 2.4, 0),
				BackgroundColor3 = T.accent,
				BackgroundTransparency = 1,
				ZIndex = 9,
				Parent = hdl,
			})
			corner(hdlGlow, 20)

			local sliding = false

			local function setVal(v)
				v = math.floor(v / opt.float + 0.5) * opt.float
				v = math.clamp(v, opt.min, opt.max)
				opt.value = v
				Vaeltha.flags[opt.flag] = v
				valLbl.Text = tostring(v)
				local pct = (v - opt.min) / (opt.max - opt.min)
				fill2:TweenSize(UDim2.new(pct, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.05, true)
				hdl:TweenPosition(UDim2.new(pct, 0, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.05, true)
				opt.callback(v)
			end

			track.InputBegan:Connect(function(i)
				if i.UserInputType ~= Enum.UserInputType.MouseButton1
				and i.UserInputType ~= Enum.UserInputType.Touch then return end
				sliding = true
				sfx("slider")
				tw(hdl,     {Size = UDim2.new(0, 16, 0, 16)}, 0.1)
				tw(hdlGlow, {BackgroundTransparency = 0.75}, 0.1)
				local pct = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				setVal(opt.min + pct * (opt.max - opt.min))
			end)
			UIS.InputChanged:Connect(function(i)
				if not sliding then return end
				if i.UserInputType ~= Enum.UserInputType.MouseMovement
				and i.UserInputType ~= Enum.UserInputType.Touch then return end
				local pct = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				setVal(opt.min + pct * (opt.max - opt.min))
			end)
			UIS.InputEnded:Connect(function(i)
				if not sliding then return end
				if i.UserInputType ~= Enum.UserInputType.MouseButton1
				and i.UserInputType ~= Enum.UserInputType.Touch then return end
				sliding = false
				tw(hdl,     {Size = UDim2.new(0, 12, 0, 12)}, 0.12)
				tw(hdlGlow, {BackgroundTransparency = 1}, 0.12)
			end)

			function opt:SetValue(v) setVal(v) end
			return opt
		end

		-- ─────────────────────────────────────────────────
		-- BUTTON
		-- ─────────────────────────────────────────────────
		function sd:AddButton(opt)
			opt = opt or {}
			opt.callback = opt.callback or function() end

			local b = mk("ImageButton", {
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = T.surface3,
				Image = "",
				ZIndex = 7,
				LayoutOrder = lo(),
				Parent = content,
			})
			corner(b, 7)
			stroke(b, T.border, 1, 0.5)

			local bg2 = mk("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ZIndex = 7,
				Parent = b,
			})
			corner(bg2, 7)
			grad(bg2, T.surface4, T.surface2, 90)

			mk("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = opt.text or "",
				TextSize = 13,
				Font = Enum.Font.GothamBold,
				TextColor3 = T.text,
				ZIndex = 8,
				Parent = b,
			})

			b.MouseEnter:Connect(function()
				sfx("hover")
				tw(b, {BackgroundColor3 = T.surface4}, 0.12)
				grad(bg2, T.accentDeep, T.surface3, 90)
			end)
			b.MouseLeave:Connect(function()
				tw(b, {BackgroundColor3 = T.surface3}, 0.12)
				grad(bg2, T.surface4, T.surface2, 90)
			end)
			b.MouseButton1Down:Connect(function()
				tw(b, {BackgroundColor3 = T.accentDeep}, 0.06)
				tw(b, {Size = UDim2.new(1, -2, 0, 30)}, 0.06)
			end)
			b.MouseButton1Up:Connect(function()
				tw(b, {BackgroundColor3 = T.surface3, Size = UDim2.new(1, 0, 0, 32)}, 0.1)
			end)
			b.MouseButton1Click:Connect(function()
				sfx("click")
				opt.callback()
			end)
			return opt
		end

		-- ─────────────────────────────────────────────────
		-- DROPDOWN
		-- ─────────────────────────────────────────────────
		function sd:AddDropdown(opt)
			opt = opt or {}
			opt.flag     = opt.flag or opt.text
			opt.values   = opt.values or {}
			opt.value    = opt.value  or opt.values[1] or ""
			opt.callback = opt.callback or function() end
			Vaeltha.flags[opt.flag] = opt.value

			local wrap = mk("Frame", {
				Size = UDim2.new(1, 0, 0, 52),
				BackgroundTransparency = 1,
				ZIndex = 7,
				LayoutOrder = lo(),
				ClipsDescendants = false,
				Parent = content,
			})

			mk("TextLabel", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1,
				Text = opt.text or "",
				TextSize = 11,
				Font = Enum.Font.Gotham,
				TextColor3 = T.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 8,
				Parent = wrap,
			})

			local dBtn = mk("ImageButton", {
				Position = UDim2.new(0, 0, 0, 18),
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = T.surface3,
				Image = "",
				ZIndex = 8,
				Parent = wrap,
			})
			corner(dBtn, 7)
			stroke(dBtn, T.border, 1, 0.5)

			local selLbl = mk("TextLabel", {
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -32, 1, 0),
				BackgroundTransparency = 1,
				Text = tostring(opt.value),
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextColor3 = T.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 9,
				Parent = dBtn,
			})

			local chevron = mk("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16),
				BackgroundTransparency = 1,
				Text = "▾",
				TextSize = 11,
				Font = Enum.Font.GothamBold,
				TextColor3 = T.textMuted,
				ZIndex = 9,
				Parent = dBtn,
			})

			local popup = mk("Frame", {
				Position = UDim2.new(0, 0, 1, 3),
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundColor3 = T.surface2,
				ClipsDescendants = true,
				ZIndex = 30,
				Visible = false,
				Parent = dBtn,
			})
			corner(popup, 7)
			stroke(popup, T.border, 1, 0.3)
			pad(popup, 4, 4, 0, 0)
			lst(popup, 0)

			local ITEM_H = 28
			local dOpen = false

			local function close()
				dOpen = false
				tw(popup, {Size = UDim2.new(1, 0, 0, 0)}, 0.14)
				tw(chevron, {Rotation = 0}, 0.14)
				task.delay(0.15, function() popup.Visible = false end)
			end

			local function open()
				dOpen = true
				popup.Visible = true
				local cnt = math.min(#opt.values, 5)
				tw(popup, {Size = UDim2.new(1, 0, 0, cnt * ITEM_H + 8)}, 0.18)
				tw(chevron, {Rotation = 180}, 0.18)
			end

			for _, val in opt.values do
				local it = mk("ImageButton", {
					Size = UDim2.new(1, 0, 0, ITEM_H),
					BackgroundColor3 = T.surface2,
					BackgroundTransparency = 1,
					Image = "",
					ZIndex = 31,
					Parent = popup,
				})
				mk("TextLabel", {
					Position = UDim2.new(0, 10, 0, 0),
					Size = UDim2.new(1, -10, 1, 0),
					BackgroundTransparency = 1,
					Text = tostring(val),
					TextSize = 12,
					Font = Enum.Font.Gotham,
					TextColor3 = T.text,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 32,
					Parent = it,
				})
				it.MouseEnter:Connect(function() tw(it, {BackgroundTransparency = 0.75, BackgroundColor3 = T.accentDeep}, 0.1) end)
				it.MouseLeave:Connect(function() tw(it, {BackgroundTransparency = 1}, 0.1) end)
				it.MouseButton1Click:Connect(function()
					sfx("dropdown")
					opt.value = tostring(val)
					Vaeltha.flags[opt.flag] = opt.value
					selLbl.Text = opt.value
					opt.callback(val)
					close()
				end)
			end

			dBtn.MouseButton1Click:Connect(function()
				sfx("click")
				if dOpen then close() else open() end
			end)

			function opt:SetValue(v)
				opt.value = tostring(v)
				Vaeltha.flags[opt.flag] = opt.value
				selLbl.Text = opt.value
				opt.callback(v)
			end
			return opt
		end

		-- ─────────────────────────────────────────────────
		-- TEXTBOX
		-- ─────────────────────────────────────────────────
		function sd:AddTextBox(opt)
			opt = opt or {}
			opt.flag     = opt.flag or opt.text
			opt.value    = opt.value or ""
			opt.callback = opt.callback or function() end
			Vaeltha.flags[opt.flag] = opt.value

			local row = mk("Frame", {
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundTransparency = 1,
				ZIndex = 7,
				LayoutOrder = lo(),
				Parent = content,
			})

			mk("TextLabel", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1,
				Text = opt.text or "",
				TextSize = 11,
				Font = Enum.Font.Gotham,
				TextColor3 = T.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 8,
				Parent = row,
			})

			local boxBg = mk("Frame", {
				Position = UDim2.new(0, 0, 0, 20),
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundColor3 = T.surface3,
				ZIndex = 8,
				Parent = row,
			})
			corner(boxBg, 7)
			local bsStroke = stroke(boxBg, T.border, 1, 0.35)

			local box = mk("TextBox", {
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -10, 1, 0),
				BackgroundTransparency = 1,
				Text = opt.value,
				PlaceholderText = opt.placeholder or "...",
				PlaceholderColor3 = T.textMuted,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextColor3 = T.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false,
				ZIndex = 9,
				Parent = boxBg,
			})

			box.Focused:Connect(function()
				sfx("click")
				tw(boxBg, {BackgroundColor3 = T.surface4}, 0.14)
				bsStroke.Color = T.accent
				bsStroke.Transparency = 0
			end)
			box.FocusLost:Connect(function(enter)
				tw(boxBg, {BackgroundColor3 = T.surface3}, 0.14)
				bsStroke.Color = T.border
				bsStroke.Transparency = 0.35
				opt.value = box.Text
				Vaeltha.flags[opt.flag] = opt.value
				opt.callback(opt.value, enter)
			end)

			function opt:SetValue(v)
				opt.value = tostring(v)
				box.Text = opt.value
				Vaeltha.flags[opt.flag] = opt.value
			end
			return opt
		end

		-- ─────────────────────────────────────────────────
		-- KEYBIND
		-- ─────────────────────────────────────────────────
		function sd:AddBind(opt)
			opt = opt or {}
			opt.flag     = opt.flag or opt.text
			opt.key      = type(opt.key) == "string" and opt.key or (opt.key and opt.key.Name or "F")
			opt.callback = opt.callback or function() end
			Vaeltha.flags[opt.flag] = opt.key

			local BLACKLIST: {EnumItem} = {
				Enum.KeyCode.Unknown, Enum.KeyCode.Return, Enum.KeyCode.Tab,
				Enum.KeyCode.Escape,  Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift,
				Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl,
			}

			local row = mk("Frame", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				ZIndex = 7,
				LayoutOrder = lo(),
				Parent = content,
			})

			mk("TextLabel", {
				Size = UDim2.new(1, -72, 1, 0),
				BackgroundTransparency = 1,
				Text = opt.text or "",
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextColor3 = T.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 8,
				Parent = row,
			})

			local bBtn = mk("ImageButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 62, 0, 22),
				BackgroundColor3 = T.surface3,
				Image = "",
				ZIndex = 8,
				Parent = row,
			})
			corner(bBtn, 5)
			stroke(bBtn, T.border, 1, 0.5)

			local bLbl = mk("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = opt.key,
				TextSize = 11,
				Font = Enum.Font.GothamBold,
				TextColor3 = T.text,
				ZIndex = 9,
				Parent = bBtn,
			})

			local binding = false

			bBtn.MouseButton1Click:Connect(function()
				if binding then return end
				binding = true
				sfx("bind")
				bLbl.Text = "..."
				tw(bBtn, {BackgroundColor3 = T.accentDeep}, 0.12)
				tw(bLbl, {TextColor3 = T.accentGlow}, 0.12)
			end)

			UIS.InputBegan:Connect(function(i, gp)
				if gp then return end
				if binding then
					local blocked = false
					for _, bk in BLACKLIST do
						if i.KeyCode == bk then blocked = true break end
					end
					if not blocked and i.KeyCode ~= Enum.KeyCode.Unknown then
						opt.key = i.KeyCode.Name
						Vaeltha.flags[opt.flag] = opt.key
						bLbl.Text = opt.key
						tw(bBtn, {BackgroundColor3 = T.surface3}, 0.12)
						tw(bLbl, {TextColor3 = T.text}, 0.12)
						binding = false
					end
				elseif i.KeyCode.Name == opt.key then
					opt.callback()
				end
			end)

			function opt:SetKey(k)
				opt.key = k
				Vaeltha.flags[opt.flag] = k
				bLbl.Text = k
			end
			return opt
		end

		-- ─────────────────────────────────────────────────
		-- COLORPICKER
		-- ─────────────────────────────────────────────────
		function sd:AddColorPicker(opt)
			opt = opt or {}
			opt.flag     = opt.flag or opt.text
			opt.color    = opt.color or Color3.fromRGB(180, 100, 255)
			opt.callback = opt.callback or function() end
			Vaeltha.flags[opt.flag] = opt.color

			local row = mk("Frame", {
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundTransparency = 1,
				ZIndex = 7,
				LayoutOrder = lo(),
				Parent = content,
			})

			mk("TextLabel", {
				Size = UDim2.new(1, -42, 1, 0),
				BackgroundTransparency = 1,
				Text = opt.text or "",
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextColor3 = T.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 8,
				Parent = row,
			})

			local swatch = mk("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 30, 0, 26),
				BackgroundColor3 = opt.color,
				ZIndex = 8,
				Parent = row,
			})
			corner(swatch, 7)
			stroke(swatch, T.border, 1, 0.3)

			local H, S, V = Color3.toHSV(opt.color)
			local pickerOpen = false

			local pickerPopup = mk("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 1, 4),
				Size = UDim2.new(0, 200, 0, 0),
				BackgroundColor3 = T.surface2,
				ClipsDescendants = false,
				ZIndex = 35,
				Visible = false,
				Parent = row,
			})
			corner(pickerPopup, 9)
			stroke(pickerPopup, T.border, 1, 0.2)

			local inner = mk("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				ZIndex = 36,
				Parent = pickerPopup,
			})
			pad(inner, 8, 8, 8, 8)

			-- SV canvas
			local svBox = mk("ImageLabel", {
				Size = UDim2.new(1, 0, 0, 110),
				BackgroundColor3 = Color3.fromHSV(H, 1, 1),
				Image = "rbxassetid://4155801252",
				ZIndex = 37,
				Parent = inner,
			})
			corner(svBox, 5)

			local svHdl = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(S, 0, 1 - V, 0),
				Size = UDim2.new(0, 10, 0, 10),
				BackgroundColor3 = T.white,
				ZIndex = 38,
				Parent = svBox,
			})
			corner(svHdl, 5)
			stroke(svHdl, T.bg, 1.5, 0)

			-- hue bar
			local hueBar = mk("Frame", {
				Position = UDim2.new(0, 0, 0, 118),
				Size = UDim2.new(1, 0, 0, 10),
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),
				ZIndex = 37,
				Parent = inner,
			})
			corner(hueBar, 5)
			mk("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0,     Color3.fromRGB(255, 0,   0)),
					ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,   255, 0)),
					ColorSequenceKeypoint.new(0.5,   Color3.fromRGB(0,   255, 255)),
					ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,   0,   255)),
					ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0,   255)),
					ColorSequenceKeypoint.new(1,     Color3.fromRGB(255, 0,   0)),
				}),
			}, hueBar)

			local hueHdl = mk("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(H == 1 and 0 or H, 0, 0.5, 0),
				Size = UDim2.new(0, 8, 0, 14),
				BackgroundColor3 = T.white,
				ZIndex = 38,
				Parent = hueBar,
			})
			corner(hueHdl, 3)
			stroke(hueHdl, T.bg, 1.5, 0)

			local function upd()
				local c = Color3.fromHSV(H, S, V)
				opt.color = c
				Vaeltha.flags[opt.flag] = c
				swatch.BackgroundColor3 = c
				svBox.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
				opt.callback(c)
			end

			local svDrag = false
			svBox.InputBegan:Connect(function(i)
				if i.UserInputType ~= Enum.UserInputType.MouseButton1
				and i.UserInputType ~= Enum.UserInputType.Touch then return end
				svDrag = true
				S = math.clamp((i.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
				V = 1 - math.clamp((i.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
				svHdl.Position = UDim2.new(S, 0, 1 - V, 0)
				upd()
			end)
			UIS.InputChanged:Connect(function(i)
				if not svDrag then return end
				if i.UserInputType ~= Enum.UserInputType.MouseMovement
				and i.UserInputType ~= Enum.UserInputType.Touch then return end
				S = math.clamp((i.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
				V = 1 - math.clamp((i.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
				svHdl.Position = UDim2.new(S, 0, 1 - V, 0)
				upd()
			end)
			UIS.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1
				or i.UserInputType == Enum.UserInputType.Touch then svDrag = false end
			end)

			local hueDrag = false
			hueBar.InputBegan:Connect(function(i)
				if i.UserInputType ~= Enum.UserInputType.MouseButton1
				and i.UserInputType ~= Enum.UserInputType.Touch then return end
				hueDrag = true
				H = math.clamp((i.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
				hueHdl.Position = UDim2.new(H, 0, 0.5, 0)
				upd()
			end)
			UIS.InputChanged:Connect(function(i)
				if not hueDrag then return end
				if i.UserInputType ~= Enum.UserInputType.MouseMovement
				and i.UserInputType ~= Enum.UserInputType.Touch then return end
				H = math.clamp((i.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
				hueHdl.Position = UDim2.new(H, 0, 0.5, 0)
				upd()
			end)
			UIS.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1
				or i.UserInputType == Enum.UserInputType.Touch then hueDrag = false end
			end)

			swatch.InputBegan:Connect(function(i)
				if i.UserInputType ~= Enum.UserInputType.MouseButton1
				and i.UserInputType ~= Enum.UserInputType.Touch then return end
				sfx("click")
				pickerOpen = not pickerOpen
				pickerPopup.Visible = pickerOpen
				if pickerOpen then
					tw(pickerPopup, {Size = UDim2.new(0, 200, 0, 142)}, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				else
					tw(pickerPopup, {Size = UDim2.new(0, 200, 0, 0)}, 0.14)
					task.delay(0.15, function() if not pickerOpen then pickerPopup.Visible = false end end)
				end
			end)

			function opt:SetColor(c)
				opt.color = c
				swatch.BackgroundColor3 = c
				Vaeltha.flags[opt.flag] = c
				H, S, V = Color3.toHSV(c)
				upd()
			end
			return opt
		end

		table.insert(tabData.sections, sd)
		return sd
	end

	return tabData
end

-- ═══════════════════════════════════════════════════════════
-- NOTIFICATION
-- ═══════════════════════════════════════════════════════════
function Vaeltha:Notify(title, text, duration)
	duration = duration or 3.5
	if not self.notifHolder then
		self.notifHolder = mk("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -20, 1, -20),
			Size = UDim2.new(0, 290, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 60,
			Parent = self.gui,
		})
		mk("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 8),
			Parent = self.notifHolder,
		})
	end

	local n = mk("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = T.surface,
		ClipsDescendants = true,
		ZIndex = 61,
		BackgroundTransparency = 0.05,
		Parent = self.notifHolder,
	})
	corner(n, 9)
	stroke(n, T.border, 1, 0.25)

	-- accent top strip
	local nt = mk("Frame", {Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = T.accent, ZIndex = 62, Parent = n})
	corner(nt, 2)
	grad(nt, T.accentGlow, T.accentDim, 0)

	-- progress bar
	local prog = mk("Frame", {
		Position = UDim2.new(0, 0, 1, -2),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = T.accentDeep,
		ZIndex = 62,
		Parent = n,
	})
	grad(prog, T.accentDim, T.accent, 0)

	local inner = mk("Frame", {
		Position = UDim2.new(0, 0, 0, 2),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 62,
		Parent = n,
	})
	pad(inner, 9, 10, 12, 12)

	mk("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = title,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextColor3 = T.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 63,
		Parent = inner,
	})

	mk("TextLabel", {
		Position = UDim2.new(0, 0, 0, 18),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = text,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextColor3 = T.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		ZIndex = 63,
		Parent = inner,
	})

	sfx("notify")

	-- slide in
	n.Position = UDim2.new(1.1, 0, 0, 0)
	tw(n, {Position = UDim2.new(0, 0, 0, 0)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	-- progress shrink
	tw(prog, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)

	task.delay(duration, function()
		tw(n, {BackgroundTransparency = 1}, 0.28)
		task.delay(0.3, function() n:Destroy() end)
	end)
end

-- ═══════════════════════════════════════════════════════════
-- DESTROY
-- ═══════════════════════════════════════════════════════════
function Vaeltha:Destroy()
	if self.gui then self.gui:Destroy() end
end

return Vaeltha
