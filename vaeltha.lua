-- Vaeltha UI Library
-- Premium dark UI for Roblox executors

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local PLAYER = Players.LocalPlayer
local MOUSE = PLAYER:GetMouse()

local Vaeltha = {}
Vaeltha.__index = Vaeltha

-- Palette
local C = {
	BG        = Color3.fromRGB(10, 10, 11),
	PANEL     = Color3.fromRGB(16, 16, 18),
	SIDEBAR   = Color3.fromRGB(13, 13, 15),
	SURFACE   = Color3.fromRGB(22, 22, 25),
	ELEVATED  = Color3.fromRGB(28, 28, 32),
	BORDER    = Color3.fromRGB(38, 38, 44),
	BORDER2   = Color3.fromRGB(52, 52, 60),
	TEXT      = Color3.fromRGB(230, 230, 235),
	SUBTEXT   = Color3.fromRGB(130, 130, 140),
	MUTED     = Color3.fromRGB(72, 72, 82),
	ACCENT    = Color3.fromRGB(210, 210, 220),
	GLOW      = Color3.fromRGB(180, 180, 195),
	TOGGLE_ON = Color3.fromRGB(190, 190, 205),
	WHITE     = Color3.fromRGB(255, 255, 255),
}

-- Easing
local FAST  = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local MED   = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SLOW  = TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SPRING = TweenInfo.new(0.35, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)

-- Sound IDs (free Roblox audio)
local SFX = {
	CLICK      = 6042053273,
	TOGGLE_ON  = 6042053148,
	TOGGLE_OFF = 6042053148,
	NOTIF      = 5153644335,
	OPEN       = 5153644335,
	CLOSE      = 6042053273,
	DROPDOWN   = 6042053148,
	SLIDER     = 0,
}

local function tween(obj, props, info)
	TweenService:Create(obj, info or MED, props):Play()
end

local function sound(id)
	if id == 0 then return end
	local s = Instance.new("Sound")
	s.SoundId = `rbxassetid://{id}`
	s.Volume = 0.18
	s.Parent = workspace
	s:Play()
	game:GetService("Debris"):AddItem(s, 3)
end

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or C.BORDER
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function padding(parent, px)
	local p = Instance.new("UIPadding")
	p.PaddingLeft   = UDim.new(0, px)
	p.PaddingRight  = UDim.new(0, px)
	p.PaddingTop    = UDim.new(0, px)
	p.PaddingBottom = UDim.new(0, px)
	p.Parent = parent
	return p
end

local function label(parent, text, size, color, font)
	local l = Instance.new("TextLabel")
	l.Text = text
	l.TextSize = size or 13
	l.TextColor3 = color or C.TEXT
	l.Font = font or Enum.Font.GothamMedium
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Size = UDim2.new(1, 0, 0, size and size + 4 or 18)
	l.Parent = parent
	return l
end

local function frame(parent, size, pos, color, transp)
	local f = Instance.new("Frame")
	f.Size = size or UDim2.new(1, 0, 0, 36)
	f.Position = pos or UDim2.new(0, 0, 0, 0)
	f.BackgroundColor3 = color or C.SURFACE
	f.BackgroundTransparency = transp or 0
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end

-- Drag support
local function makeDraggable(handle, target)
	local dragging, dragStart, startPos = false, nil, nil

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		dragging = true
		dragStart = input.Position
		startPos = target.Position
	end)

	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		local delta = input.Position - dragStart
		target.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end)
end

-- Ambient shimmer on background
local function addShimmer(parent)
	local shimmer = Instance.new("Frame")
	shimmer.Size = UDim2.new(0, 220, 0, 220)
	shimmer.Position = UDim2.new(0, -40, 0, -60)
	shimmer.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	shimmer.BackgroundTransparency = 0.94
	shimmer.BorderSizePixel = 0
	shimmer.ZIndex = 0
	shimmer.Parent = parent
	corner(shimmer, 110)

	local shimmer2 = shimmer:Clone()
	shimmer2.Position = UDim2.new(1, -160, 1, -140)
	shimmer2.BackgroundTransparency = 0.96
	shimmer2.Parent = parent

	RunService.Heartbeat:Connect(function(dt)
		local t = tick() * 0.4
		shimmer.Position = UDim2.new(
			0, -40 + math.sin(t) * 12,
			0, -60 + math.cos(t * 0.7) * 10
		)
		shimmer2.Position = UDim2.new(
			1, -160 + math.sin(t + 2) * 10,
			1, -140 + math.cos(t * 0.8 + 1) * 8
		)
	end)
end

-- ─────────────────────────────────────────────
-- Window
-- ─────────────────────────────────────────────

function Vaeltha.new(config)
	config = config or {}
	local self = setmetatable({}, Vaeltha)

	self.Tabs = {}
	self.ActiveTab = nil
	self.Minimized = false

	-- Screen
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Vaeltha"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 999
	pcall(function() screenGui.Parent = gethui() end)
	if not screenGui.Parent then screenGui.Parent = PLAYER.PlayerGui end

	self.ScreenGui = screenGui

	-- Main window
	local WIN_W, WIN_H = config.Width or 660, config.Height or 440
	local SIDEBAR_W = 56

	local win = frame(screenGui,
		UDim2.new(0, WIN_W, 0, WIN_H),
		UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
		C.BG
	)
	win.Name = "Window"
	win.ZIndex = 2
	corner(win, 10)
	stroke(win, C.BORDER, 1)
	self.Window = win

	addShimmer(win)

	-- Outer glow
	local glow = Instance.new("ImageLabel")
	glow.Size = UDim2.new(1, 60, 1, 60)
	glow.Position = UDim2.new(0, -30, 0, -30)
	glow.BackgroundTransparency = 1
	glow.Image = "rbxassetid://5028857084"
	glow.ImageColor3 = Color3.fromRGB(120, 120, 140)
	glow.ImageTransparency = 0.88
	glow.ScaleType = Enum.ScaleType.Slice
	glow.SliceCenter = Rect.new(24, 24, 276, 276)
	glow.ZIndex = 1
	glow.Parent = win

	-- Titlebar
	local titlebar = frame(win,
		UDim2.new(1, 0, 0, 44),
		UDim2.new(0, 0, 0, 0),
		C.PANEL
	)
	titlebar.ZIndex = 5
	corner(titlebar, 10)
	self.Titlebar = titlebar

	-- Fix bottom corners of titlebar
	local tbfix = frame(titlebar,
		UDim2.new(1, 0, 0, 12),
		UDim2.new(0, 0, 1, -12),
		C.PANEL
	)
	tbfix.ZIndex = 5

	-- Logo
	local logo = Instance.new("ImageLabel")
	logo.Size = UDim2.new(0, 22, 0, 22)
	logo.Position = UDim2.new(0, 12, 0.5, -11)
	logo.BackgroundTransparency = 1
	logo.Image = "rbxassetid://84166263757664"
	logo.ZIndex = 6
	logo.Parent = titlebar

	-- Brand name
	local brandLabel = Instance.new("TextLabel")
	brandLabel.Size = UDim2.new(0, 100, 0, 22)
	brandLabel.Position = UDim2.new(0, 40, 0.5, -11)
	brandLabel.BackgroundTransparency = 1
	brandLabel.Text = "Vaeltha"
	brandLabel.TextColor3 = C.TEXT
	brandLabel.Font = Enum.Font.GothamBold
	brandLabel.TextSize = 15
	brandLabel.TextXAlignment = Enum.TextXAlignment.Left
	brandLabel.ZIndex = 6
	brandLabel.Parent = titlebar

	-- Subtitle/version
	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(0, 100, 0, 14)
	sub.Position = UDim2.new(0, 40, 0.5, 0)
	sub.BackgroundTransparency = 1
	sub.Text = config.Subtitle or "Premium UI"
	sub.TextColor3 = C.SUBTEXT
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 10
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.ZIndex = 6
	sub.Parent = titlebar

	-- Separator line under brand
	local brandSep = Instance.new("Frame")
	brandSep.Size = UDim2.new(0, 1, 0, 16)
	brandSep.Position = UDim2.new(0, 148, 0.5, -8)
	brandSep.BackgroundColor3 = C.BORDER
	brandSep.BorderSizePixel = 0
	brandSep.ZIndex = 6
	brandSep.Parent = titlebar

	-- Control buttons (close / minimize)
	local function makeCtrl(xOffset, icon, cb)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 28, 0, 28)
		btn.Position = UDim2.new(1, xOffset, 0.5, -14)
		btn.BackgroundColor3 = C.ELEVATED
		btn.BackgroundTransparency = 0.4
		btn.Text = icon
		btn.TextColor3 = C.SUBTEXT
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 11
		btn.ZIndex = 6
		btn.BorderSizePixel = 0
		btn.Parent = titlebar
		corner(btn, 7)

		btn.MouseEnter:Connect(function()
			tween(btn, {BackgroundTransparency = 0, TextColor3 = C.TEXT}, FAST)
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, {BackgroundTransparency = 0.4, TextColor3 = C.SUBTEXT}, FAST)
		end)
		btn.MouseButton1Click:Connect(function()
			sound(SFX.CLICK)
			cb()
		end)
		return btn
	end

	makeCtrl(-14, "✕", function()
		sound(SFX.CLOSE)
		tween(win, {Size = UDim2.new(0, WIN_W, 0, 0), Position = UDim2.new(0.5, -WIN_W/2, 0.5, 0)}, MED)
		task.delay(0.3, function() screenGui:Destroy() end)
	end)

	makeCtrl(-48, "—", function()
		sound(SFX.CLICK)
		if self.Minimized then
			self.Minimized = false
			tween(win, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, SPRING)
		else
			self.Minimized = true
			tween(win, {Size = UDim2.new(0, WIN_W, 0, 44)}, MED)
		end
	end)

	-- Drag
	makeDraggable(titlebar, win)

	-- Sidebar
	local sidebar = frame(win,
		UDim2.new(0, SIDEBAR_W, 1, -44),
		UDim2.new(0, 0, 0, 44),
		C.SIDEBAR
	)
	sidebar.ZIndex = 3
	self.Sidebar = sidebar

	-- Fix sidebar right-side corners
	local sbfix = frame(sidebar,
		UDim2.new(0, 10, 1, 0),
		UDim2.new(1, -10, 0, 0),
		C.SIDEBAR
	)
	sbfix.ZIndex = 3

	-- Fix sidebar bottom-left corner
	local sbbfix = frame(sidebar,
		UDim2.new(0, 10, 0, 10),
		UDim2.new(0, 0, 1, -10),
		C.SIDEBAR
	)
	sbbfix.ZIndex = 3

	-- Sidebar border
	local sborder = frame(sidebar,
		UDim2.new(0, 1, 1, 0),
		UDim2.new(1, -1, 0, 0),
		C.BORDER
	)
	sborder.ZIndex = 4

	-- Sidebar tab list
	local tabList = Instance.new("Frame")
	tabList.Size = UDim2.new(1, 0, 1, -16)
	tabList.Position = UDim2.new(0, 0, 0, 8)
	tabList.BackgroundTransparency = 1
	tabList.ZIndex = 4
	tabList.Parent = sidebar

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.FillDirection = Enum.FillDirection.Vertical
	tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabListLayout.Padding = UDim.new(0, 4)
	tabListLayout.Parent = tabList

	self.TabList = tabList

	-- Content area
	local content = frame(win,
		UDim2.new(1, -SIDEBAR_W, 1, -44),
		UDim2.new(0, SIDEBAR_W, 0, 44),
		C.PANEL
	)
	content.ZIndex = 3
	self.ContentArea = content

	-- Fix content left corners
	local cfixL = frame(content,
		UDim2.new(0, 10, 1, 0),
		UDim2.new(0, 0, 0, 0),
		C.PANEL
	)
	cfixL.ZIndex = 3

	-- Titlebar bottom fix for sidebar+content split
	local cfix = frame(win,
		UDim2.new(1, 0, 0, 6),
		UDim2.new(0, 0, 0, 38),
		C.PANEL
	)
	cfix.ZIndex = 3

	-- Sidebar titlebar fix
	local sfixTop = frame(win,
		UDim2.new(0, SIDEBAR_W, 0, 6),
		UDim2.new(0, 0, 0, 38),
		C.SIDEBAR
	)
	sfixTop.ZIndex = 4

	-- Notifications container
	local notifContainer = Instance.new("Frame")
	notifContainer.Size = UDim2.new(0, 280, 1, 0)
	notifContainer.Position = UDim2.new(1, 16, 0, 0)
	notifContainer.BackgroundTransparency = 1
	notifContainer.ZIndex = 20
	notifContainer.Parent = win
	self.NotifContainer = notifContainer

	local notifLayout = Instance.new("UIListLayout")
	notifLayout.FillDirection = Enum.FillDirection.Vertical
	notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
	notifLayout.Padding = UDim.new(0, 6)
	notifLayout.Parent = notifContainer

	-- Open animation
	win.Size = UDim2.new(0, WIN_W, 0, 0)
	win.BackgroundTransparency = 0.3
	sound(SFX.OPEN)
	tween(win, {Size = UDim2.new(0, WIN_W, 0, WIN_H), BackgroundTransparency = 0}, SPRING)

	self.WIN_W = WIN_W
	self.WIN_H = WIN_H

	return self
end

-- ─────────────────────────────────────────────
-- Tab
-- ─────────────────────────────────────────────

function Vaeltha:AddTab(name, icon)
	local TAB = {}
	TAB.Name = name
	TAB.Sections = {}

	-- Tab button
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 40)
	btn.BackgroundColor3 = C.SURFACE
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.ZIndex = 5
	btn.BorderSizePixel = 0
	btn.LayoutOrder = #self.Tabs + 1
	btn.Parent = self.TabList
	corner(btn, 8)

	-- Icon
	local ico = label(btn, icon or "•", 15, C.MUTED, Enum.Font.GothamBold)
	ico.Size = UDim2.new(1, 0, 1, 0)
	ico.TextXAlignment = Enum.TextXAlignment.Center
	ico.TextYAlignment = Enum.TextYAlignment.Center
	ico.ZIndex = 6

	-- Active indicator bar
	local indicator = frame(btn, UDim2.new(0, 3, 0, 22), UDim2.new(0, -2, 0.5, -11), C.ACCENT)
	indicator.BackgroundTransparency = 1
	indicator.ZIndex = 6
	corner(indicator, 2)

	-- Tab tooltip
	local tooltip = Instance.new("TextLabel")
	tooltip.Size = UDim2.new(0, 80, 0, 26)
	tooltip.Position = UDim2.new(1, 8, 0.5, -13)
	tooltip.BackgroundColor3 = C.ELEVATED
	tooltip.Text = name
	tooltip.TextColor3 = C.TEXT
	tooltip.Font = Enum.Font.GothamMedium
	tooltip.TextSize = 11
	tooltip.BackgroundTransparency = 1
	tooltip.ZIndex = 10
	tooltip.BorderSizePixel = 0
	tooltip.Parent = btn
	corner(tooltip, 5)
	stroke(tooltip, C.BORDER, 1)

	btn.MouseEnter:Connect(function()
		if self.ActiveTab == TAB then return end
		tween(btn, {BackgroundTransparency = 0.7}, FAST)
		tween(ico, {TextColor3 = C.ACCENT}, FAST)
		tween(tooltip, {BackgroundTransparency = 0}, FAST)
	end)
	btn.MouseLeave:Connect(function()
		if self.ActiveTab == TAB then return end
		tween(btn, {BackgroundTransparency = 1}, FAST)
		tween(ico, {TextColor3 = C.MUTED}, FAST)
		tween(tooltip, {BackgroundTransparency = 1}, FAST)
	end)

	-- Content page
	local page = frame(self.ContentArea,
		UDim2.new(1, 0, 1, 0),
		UDim2.new(0, 0, 0, 0),
		C.PANEL
	)
	page.Visible = false
	page.ZIndex = 4

	local pageScroll = Instance.new("ScrollingFrame")
	pageScroll.Size = UDim2.new(1, -20, 1, -16)
	pageScroll.Position = UDim2.new(0, 12, 0, 8)
	pageScroll.BackgroundTransparency = 1
	pageScroll.ScrollBarThickness = 3
	pageScroll.ScrollBarImageColor3 = C.BORDER2
	pageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	pageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	pageScroll.BorderSizePixel = 0
	pageScroll.ZIndex = 4
	pageScroll.Parent = page
	self.PageScroll = pageScroll

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.FillDirection = Enum.FillDirection.Vertical
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Padding = UDim.new(0, 8)
	pageLayout.Parent = pageScroll

	TAB.Page = page
	TAB.PageScroll = pageScroll
	TAB.PageLayout = pageLayout
	TAB.Btn = btn
	TAB.Ico = ico
	TAB.Indicator = indicator
	TAB.Order = #self.Tabs + 1

	btn.MouseButton1Click:Connect(function()
		if self.ActiveTab == TAB then return end
		self:SelectTab(TAB)
	end)

	self.Tabs[#self.Tabs + 1] = TAB

	if #self.Tabs == 1 then
		self:SelectTab(TAB)
	end

	-- Section builder
	function TAB:AddSection(sectionName)
		local SEC = {}

		local sectionFrame = frame(TAB.PageScroll,
			UDim2.new(1, -4, 0, 0),
			UDim2.new(0, 0, 0, 0),
			C.SURFACE
		)
		sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
		sectionFrame.LayoutOrder = #TAB.Sections + 1
		sectionFrame.ZIndex = 5
		corner(sectionFrame, 8)
		stroke(sectionFrame, C.BORDER, 1)

		local secPad = Instance.new("UIPadding")
		secPad.PaddingLeft   = UDim.new(0, 12)
		secPad.PaddingRight  = UDim.new(0, 12)
		secPad.PaddingTop    = UDim.new(0, 10)
		secPad.PaddingBottom = UDim.new(0, 12)
		secPad.Parent = sectionFrame

		local secLayout = Instance.new("UIListLayout")
		secLayout.FillDirection = Enum.FillDirection.Vertical
		secLayout.SortOrder = Enum.SortOrder.LayoutOrder
		secLayout.Padding = UDim.new(0, 8)
		secLayout.Parent = sectionFrame

		-- Section header
		local headerRow = frame(sectionFrame, UDim2.new(1, 0, 0, 20), nil, C.SURFACE)
		headerRow.LayoutOrder = 0
		headerRow.ZIndex = 5

		local secTitle = label(headerRow, sectionName, 11, C.SUBTEXT, Enum.Font.GothamBold)
		secTitle.TextXAlignment = Enum.TextXAlignment.Left
		secTitle.TextTransparency = 0
		secTitle.ZIndex = 5
		secTitle.Text = string.upper(sectionName)

		local headerLine = frame(headerRow, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1), C.BORDER)
		headerLine.ZIndex = 5

		SEC.Frame = sectionFrame
		SEC.Layout = secLayout
		SEC.Order = #TAB.Sections + 1
		TAB.Sections[#TAB.Sections + 1] = SEC

		-- ──────────────────────
		-- Button
		-- ──────────────────────
		function SEC:AddButton(text, desc, callback)
			local row = frame(sectionFrame, UDim2.new(1, 0, 0, 34), nil, C.ELEVATED)
			row.LayoutOrder = #sectionFrame:GetChildren()
			row.ZIndex = 6
			corner(row, 6)
			stroke(row, C.BORDER, 1)

			local l = label(row, text, 12, C.TEXT, Enum.Font.GothamMedium)
			l.Position = UDim2.new(0, 10, 0, 0)
			l.Size = UDim2.new(1, -60, 1, 0)
			l.TextYAlignment = Enum.TextYAlignment.Center
			l.ZIndex = 7

			if desc then
				l.Text = text
				l.Size = UDim2.new(1, -60, 0, 18)
				l.Position = UDim2.new(0, 10, 0, 5)
				local d = label(row, desc, 10, C.SUBTEXT, Enum.Font.Gotham)
				d.Position = UDim2.new(0, 10, 0, 21)
				d.Size = UDim2.new(1, -60, 0, 12)
				d.ZIndex = 7
			end

			local arrow = label(row, "›", 14, C.MUTED, Enum.Font.GothamBold)
			arrow.Size = UDim2.new(0, 20, 1, 0)
			arrow.Position = UDim2.new(1, -28, 0, 0)
			arrow.TextXAlignment = Enum.TextXAlignment.Center
			arrow.TextYAlignment = Enum.TextYAlignment.Center
			arrow.ZIndex = 7

			local btn2 = Instance.new("TextButton")
			btn2.Size = UDim2.new(1, 0, 1, 0)
			btn2.BackgroundTransparency = 1
			btn2.Text = ""
			btn2.ZIndex = 8
			btn2.Parent = row

			btn2.MouseEnter:Connect(function()
				tween(row, {BackgroundColor3 = C.BORDER2}, FAST)
				tween(arrow, {TextColor3 = C.ACCENT}, FAST)
			end)
			btn2.MouseLeave:Connect(function()
				tween(row, {BackgroundColor3 = C.ELEVATED}, FAST)
				tween(arrow, {TextColor3 = C.MUTED}, FAST)
			end)
			btn2.MouseButton1Down:Connect(function()
				tween(row, {Size = UDim2.new(1, 0, 0, 32)}, FAST)
			end)
			btn2.MouseButton1Up:Connect(function()
				tween(row, {Size = UDim2.new(1, 0, 0, 34)}, FAST)
			end)
			btn2.MouseButton1Click:Connect(function()
				sound(SFX.CLICK)
				if callback then pcall(callback) end
			end)
		end

		-- ──────────────────────
		-- Toggle
		-- ──────────────────────
		function SEC:AddToggle(text, default, callback)
			local state = default or false
			local row = frame(sectionFrame, UDim2.new(1, 0, 0, 34), nil, C.ELEVATED)
			row.LayoutOrder = #sectionFrame:GetChildren()
			row.ZIndex = 6
			corner(row, 6)
			stroke(row, C.BORDER, 1)

			local l = label(row, text, 12, C.TEXT, Enum.Font.GothamMedium)
			l.Position = UDim2.new(0, 10, 0, 0)
			l.Size = UDim2.new(1, -60, 1, 0)
			l.TextYAlignment = Enum.TextYAlignment.Center
			l.ZIndex = 7

			-- Track
			local track = frame(row, UDim2.new(0, 32, 0, 18), UDim2.new(1, -42, 0.5, -9), C.MUTED)
			track.ZIndex = 7
			corner(track, 9)

			-- Knob
			local knob = frame(track, UDim2.new(0, 14, 0, 14), UDim2.new(0, 2, 0.5, -7), C.TEXT)
			knob.ZIndex = 8
			corner(knob, 7)

			local function setState(val, silent)
				state = val
				if val then
					tween(track, {BackgroundColor3 = C.TOGGLE_ON}, MED)
					tween(knob, {Position = UDim2.new(0, 16, 0.5, -7), BackgroundColor3 = C.WHITE}, MED)
					if not silent then sound(SFX.TOGGLE_ON) end
				else
					tween(track, {BackgroundColor3 = C.MUTED}, MED)
					tween(knob, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = C.TEXT}, MED)
					if not silent then sound(SFX.TOGGLE_OFF) end
				end
				if callback and not silent then pcall(callback, val) end
			end

			setState(state, true)

			local btn2 = Instance.new("TextButton")
			btn2.Size = UDim2.new(1, 0, 1, 0)
			btn2.BackgroundTransparency = 1
			btn2.Text = ""
			btn2.ZIndex = 9
			btn2.Parent = row

			btn2.MouseEnter:Connect(function()
				tween(row, {BackgroundColor3 = C.BORDER2}, FAST)
			end)
			btn2.MouseLeave:Connect(function()
				tween(row, {BackgroundColor3 = C.ELEVATED}, FAST)
			end)
			btn2.MouseButton1Click:Connect(function()
				setState(not state)
			end)

			local API = {}
			function API:Set(val) setState(val, false) end
			function API:Get() return state end
			return API
		end

		-- ──────────────────────
		-- Slider
		-- ──────────────────────
		function SEC:AddSlider(text, min, max, default, callback)
			min = min or 0
			max = max or 100
			default = default or min
			local value = default

			local row = frame(sectionFrame, UDim2.new(1, 0, 0, 48), nil, C.ELEVATED)
			row.LayoutOrder = #sectionFrame:GetChildren()
			row.ZIndex = 6
			corner(row, 6)
			stroke(row, C.BORDER, 1)

			local l = label(row, text, 12, C.TEXT, Enum.Font.GothamMedium)
			l.Position = UDim2.new(0, 10, 0, 6)
			l.Size = UDim2.new(1, -70, 0, 16)
			l.ZIndex = 7

			local valLabel = label(row, tostring(value), 11, C.SUBTEXT, Enum.Font.GothamMedium)
			valLabel.Position = UDim2.new(1, -54, 0, 6)
			valLabel.Size = UDim2.new(0, 44, 0, 16)
			valLabel.TextXAlignment = Enum.TextXAlignment.Right
			valLabel.ZIndex = 7

			-- Track
			local track = frame(row, UDim2.new(1, -20, 0, 4), UDim2.new(0, 10, 0, 33), C.BORDER2)
			track.ZIndex = 7
			corner(track, 2)

			-- Fill
			local fill = frame(track, UDim2.new(0, 0, 1, 0), nil, C.ACCENT)
			fill.ZIndex = 8
			corner(fill, 2)

			-- Handle
			local handle = frame(track, UDim2.new(0, 12, 0, 12), UDim2.new(0, 0, 0.5, -6), C.TEXT)
			handle.ZIndex = 9
			corner(handle, 6)

			local function setSlider(val)
				val = math.clamp(val, min, max)
				val = math.round(val * 10) / 10
				value = val
				local pct = (val - min) / (max - min)
				tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, FAST)
				tween(handle, {Position = UDim2.new(pct, -6, 0.5, -6)}, FAST)
				valLabel.Text = tostring(val)
				if callback then pcall(callback, val) end
			end

			setSlider(default)

			local dragging = false

			local hitbox = Instance.new("TextButton")
			hitbox.Size = UDim2.new(1, 0, 0, 30)
			hitbox.Position = UDim2.new(0, 0, 0, 18)
			hitbox.BackgroundTransparency = 1
			hitbox.Text = ""
			hitbox.ZIndex = 10
			hitbox.Parent = row

			hitbox.MouseButton1Down:Connect(function()
				dragging = true
				sound(SFX.SLIDER)
			end)

			UserInputService.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(inp)
				if not dragging or inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
				local absPos = track.AbsolutePosition.X
				local absSize = track.AbsoluteSize.X
				local pct = math.clamp((inp.Position.X - absPos) / absSize, 0, 1)
				setSlider(min + pct * (max - min))
			end)

			row.MouseEnter:Connect(function()
				tween(row, {BackgroundColor3 = C.BORDER2}, FAST)
			end)
			row.MouseLeave:Connect(function()
				tween(row, {BackgroundColor3 = C.ELEVATED}, FAST)
			end)

			local API = {}
			function API:Set(val) setSlider(val) end
			function API:Get() return value end
			return API
		end

		-- ──────────────────────
		-- Dropdown
		-- ──────────────────────
		function SEC:AddDropdown(text, options, callback)
			local selected = options[1]
			local open = false

			local wrapper = Instance.new("Frame")
			wrapper.Size = UDim2.new(1, 0, 0, 34)
			wrapper.BackgroundTransparency = 1
			wrapper.LayoutOrder = #sectionFrame:GetChildren()
			wrapper.AutomaticSize = Enum.AutomaticSize.Y
			wrapper.ZIndex = 15
			wrapper.ClipsDescendants = false
			wrapper.Parent = sectionFrame

			local row = frame(wrapper, UDim2.new(1, 0, 0, 34), nil, C.ELEVATED)
			row.ZIndex = 6
			corner(row, 6)
			stroke(row, C.BORDER, 1)

			local l = label(row, text, 12, C.TEXT, Enum.Font.GothamMedium)
			l.Position = UDim2.new(0, 10, 0, 0)
			l.Size = UDim2.new(0.5, 0, 1, 0)
			l.TextYAlignment = Enum.TextYAlignment.Center
			l.ZIndex = 7

			local selLabel = label(row, selected, 11, C.SUBTEXT, Enum.Font.Gotham)
			selLabel.Size = UDim2.new(0.45, 0, 1, 0)
			selLabel.Position = UDim2.new(0.5, 0, 0, 0)
			selLabel.TextXAlignment = Enum.TextXAlignment.Right
			selLabel.TextYAlignment = Enum.TextYAlignment.Center
			selLabel.ZIndex = 7

			local chevron = label(row, "⌄", 13, C.MUTED, Enum.Font.GothamBold)
			chevron.Size = UDim2.new(0, 24, 1, 0)
			chevron.Position = UDim2.new(1, -28, 0, 0)
			chevron.TextXAlignment = Enum.TextXAlignment.Center
			chevron.TextYAlignment = Enum.TextYAlignment.Center
			chevron.ZIndex = 7

			-- Dropdown panel
			local dropPanel = frame(wrapper,
				UDim2.new(1, 0, 0, 0),
				UDim2.new(0, 0, 0, 36),
				C.ELEVATED
			)
			dropPanel.ClipsDescendants = true
			dropPanel.ZIndex = 16
			dropPanel.Visible = false
			corner(dropPanel, 6)
			stroke(dropPanel, C.BORDER, 1)

			local dropLayout = Instance.new("UIListLayout")
			dropLayout.FillDirection = Enum.FillDirection.Vertical
			dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
			dropLayout.Parent = dropPanel

			local function buildOptions()
				for _, child in dropPanel:GetChildren() do
					if child:IsA("TextButton") then child:Destroy() end
				end
				for i, opt in options do
					local optBtn = Instance.new("TextButton")
					optBtn.Size = UDim2.new(1, 0, 0, 28)
					optBtn.BackgroundColor3 = C.ELEVATED
					optBtn.BackgroundTransparency = 1
					optBtn.Text = ""
					optBtn.BorderSizePixel = 0
					optBtn.LayoutOrder = i
					optBtn.ZIndex = 17
					optBtn.Parent = dropPanel

					local optLabel = label(optBtn, opt, 11, if opt == selected then C.TEXT else C.SUBTEXT, Enum.Font.GothamMedium)
					optLabel.Position = UDim2.new(0, 10, 0, 0)
					optLabel.Size = UDim2.new(1, -10, 1, 0)
					optLabel.TextYAlignment = Enum.TextYAlignment.Center
					optLabel.ZIndex = 18

					optBtn.MouseEnter:Connect(function()
						tween(optBtn, {BackgroundTransparency = 0.7}, FAST)
						tween(optLabel, {TextColor3 = C.TEXT}, FAST)
					end)
					optBtn.MouseLeave:Connect(function()
						tween(optBtn, {BackgroundTransparency = 1}, FAST)
						tween(optLabel, {TextColor3 = if opt == selected then C.TEXT else C.SUBTEXT}, FAST)
					end)
					optBtn.MouseButton1Click:Connect(function()
						selected = opt
						selLabel.Text = opt
						sound(SFX.CLICK)
						open = false
						tween(dropPanel, {Size = UDim2.new(1, 0, 0, 0)}, MED)
						tween(chevron, {Rotation = 0}, MED)
						task.delay(0.3, function() dropPanel.Visible = false end)
						buildOptions()
						if callback then pcall(callback, opt) end
					end)
				end
			end

			buildOptions()

			local hitbox = Instance.new("TextButton")
			hitbox.Size = UDim2.new(1, 0, 1, 0)
			hitbox.BackgroundTransparency = 1
			hitbox.Text = ""
			hitbox.ZIndex = 8
			hitbox.Parent = row

			hitbox.MouseEnter:Connect(function()
				tween(row, {BackgroundColor3 = C.BORDER2}, FAST)
			end)
			hitbox.MouseLeave:Connect(function()
				tween(row, {BackgroundColor3 = C.ELEVATED}, FAST)
			end)

			hitbox.MouseButton1Click:Connect(function()
				open = not open
				if open then
					sound(SFX.DROPDOWN)
					dropPanel.Visible = true
					local targetH = math.min(#options * 28, 140)
					tween(dropPanel, {Size = UDim2.new(1, 0, 0, targetH)}, MED)
					tween(chevron, {Rotation = 180}, MED)
				else
					sound(SFX.CLICK)
					tween(dropPanel, {Size = UDim2.new(1, 0, 0, 0)}, MED)
					tween(chevron, {Rotation = 0}, MED)
					task.delay(0.3, function() dropPanel.Visible = false end)
				end
			end)

			local API = {}
			function API:Set(val)
				if table.find(options, val) then
					selected = val
					selLabel.Text = val
					buildOptions()
					if callback then pcall(callback, val) end
				end
			end
			function API:Get() return selected end
			return API
		end

		-- ──────────────────────
		-- TextBox
		-- ──────────────────────
		function SEC:AddTextbox(text, placeholder, callback)
			local row = frame(sectionFrame, UDim2.new(1, 0, 0, 48), nil, C.ELEVATED)
			row.LayoutOrder = #sectionFrame:GetChildren()
			row.ZIndex = 6
			corner(row, 6)
			local outlineStroke = stroke(row, C.BORDER, 1)

			local l = label(row, text, 11, C.SUBTEXT, Enum.Font.GothamBold)
			l.Position = UDim2.new(0, 10, 0, 6)
			l.Size = UDim2.new(1, -20, 0, 14)
			l.Text = string.upper(text)
			l.ZIndex = 7

			local box = Instance.new("TextBox")
			box.Size = UDim2.new(1, -20, 0, 22)
			box.Position = UDim2.new(0, 10, 0, 22)
			box.BackgroundTransparency = 1
			box.Text = ""
			box.PlaceholderText = placeholder or "Type here..."
			box.PlaceholderColor3 = C.MUTED
			box.TextColor3 = C.TEXT
			box.Font = Enum.Font.GothamMedium
			box.TextSize = 12
			box.TextXAlignment = Enum.TextXAlignment.Left
			box.BorderSizePixel = 0
			box.ZIndex = 7
			box.ClearTextOnFocus = false
			box.Parent = row

			box.Focused:Connect(function()
				tween(outlineStroke, {Color = C.ACCENT}, FAST)
				tween(row, {BackgroundColor3 = C.BORDER2}, FAST)
			end)
			box.FocusLost:Connect(function(enterPressed)
				tween(outlineStroke, {Color = C.BORDER}, FAST)
				tween(row, {BackgroundColor3 = C.ELEVATED}, FAST)
				if callback then pcall(callback, box.Text, enterPressed) end
			end)

			local API = {}
			function API:Get() return box.Text end
			function API:Set(v) box.Text = v end
			return API
		end

		-- ──────────────────────
		-- Label
		-- ──────────────────────
		function SEC:AddLabel(text)
			local l = label(sectionFrame, text, 11, C.SUBTEXT, Enum.Font.Gotham)
			l.LayoutOrder = #sectionFrame:GetChildren()
			l.Size = UDim2.new(1, 0, 0, 16)
			l.ZIndex = 6
			return l
		end

		-- ──────────────────────
		-- Separator
		-- ──────────────────────
		function SEC:AddSeparator()
			local sep = frame(sectionFrame, UDim2.new(1, 0, 0, 1), nil, C.BORDER)
			sep.LayoutOrder = #sectionFrame:GetChildren()
			sep.ZIndex = 6
		end

		return SEC
	end

	return TAB
end

-- ─────────────────────────────────────────────
-- Tab switching
-- ─────────────────────────────────────────────

function Vaeltha:SelectTab(tab)
	if self.ActiveTab then
		local old = self.ActiveTab
		tween(old.Page, {BackgroundTransparency = 0.3}, FAST)
		tween(old.Ico, {TextColor3 = C.MUTED}, FAST)
		tween(old.Btn, {BackgroundTransparency = 1}, FAST)
		tween(old.Indicator, {BackgroundTransparency = 1}, FAST)
		task.delay(0.15, function()
			if old.Page then old.Page.Visible = false end
		end)
	end

	self.ActiveTab = tab
	sound(SFX.CLICK)

	tab.Page.BackgroundTransparency = 0.3
	tab.Page.Visible = true
	tween(tab.Page, {BackgroundTransparency = 0}, MED)
	tween(tab.Ico, {TextColor3 = C.ACCENT}, MED)
	tween(tab.Btn, {BackgroundTransparency = 0.55}, MED)
	tween(tab.Indicator, {BackgroundTransparency = 0}, MED)
end

-- ─────────────────────────────────────────────
-- Notification
-- ─────────────────────────────────────────────

function Vaeltha:Notify(title, message, duration)
	duration = duration or 4

	local notif = frame(self.NotifContainer,
		UDim2.new(1, 0, 0, 68),
		nil,
		C.SURFACE
	)
	notif.LayoutOrder = tick()
	notif.Position = UDim2.new(1, 0, 0, 0)
	notif.BackgroundTransparency = 0.1
	notif.ZIndex = 25
	corner(notif, 8)
	stroke(notif, C.BORDER, 1)
	padding(notif, 10)

	local accentBar = frame(notif, UDim2.new(0, 3, 1, -20), UDim2.new(0, -10, 0, 10), C.ACCENT)
	accentBar.ZIndex = 26
	corner(accentBar, 2)

	local t = label(notif, title, 12, C.TEXT, Enum.Font.GothamBold)
	t.Position = UDim2.new(0, 6, 0, 0)
	t.Size = UDim2.new(1, -6, 0, 18)
	t.ZIndex = 26

	local m = label(notif, message, 11, C.SUBTEXT, Enum.Font.Gotham)
	m.Position = UDim2.new(0, 6, 0, 22)
	m.Size = UDim2.new(1, -6, 0, 30)
	m.TextWrapped = true
	m.ZIndex = 26

	-- Progress bar
	local progressTrack = frame(notif, UDim2.new(1, -16, 0, 2), UDim2.new(0, 6, 1, -4), C.BORDER)
	progressTrack.ZIndex = 26
	corner(progressTrack, 1)

	local progress = frame(progressTrack, UDim2.new(1, 0, 1, 0), nil, C.GLOW)
	progress.ZIndex = 27
	corner(progress, 1)

	sound(SFX.NOTIF)

	tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, SPRING)
	tween(progress, {Size = UDim2.new(0, 0, 1, 0)}, TweenInfo.new(duration, Enum.EasingStyle.Linear))

	task.delay(duration, function()
		tween(notif, {Position = UDim2.new(1, 16, 0, 0), BackgroundTransparency = 1}, MED)
		task.delay(0.32, function() notif:Destroy() end)
	end)
end

-- ─────────────────────────────────────────────
-- Destroy
-- ─────────────────────────────────────────────

function Vaeltha:Destroy()
	sound(SFX.CLOSE)
	tween(self.Window, {Size = UDim2.new(0, self.WIN_W, 0, 0), BackgroundTransparency = 1}, MED)
	task.delay(0.32, function() self.ScreenGui:Destroy() end)
end

return Vaeltha
