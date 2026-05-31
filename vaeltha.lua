-- Vaeltha UI Library
-- Premium Roblox UI Library

local Vaeltha = {flags = {}, windows = {}, tabs = {}, open = true}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ============================================================
-- THEME
-- ============================================================
local THEME = {
	bg          = Color3.fromRGB(10, 10, 12),
	surface     = Color3.fromRGB(16, 16, 20),
	surface2    = Color3.fromRGB(22, 22, 28),
	surface3    = Color3.fromRGB(28, 28, 36),
	border      = Color3.fromRGB(40, 40, 52),
	borderHover = Color3.fromRGB(70, 70, 90),
	accent      = Color3.fromRGB(110, 90, 255),
	accentDim   = Color3.fromRGB(70, 55, 180),
	accentGlow  = Color3.fromRGB(130, 110, 255),
	text        = Color3.fromRGB(230, 230, 240),
	textDim     = Color3.fromRGB(130, 130, 150),
	textMuted   = Color3.fromRGB(70, 70, 85),
	success     = Color3.fromRGB(80, 200, 120),
	danger      = Color3.fromRGB(220, 80, 80),
	white       = Color3.fromRGB(255, 255, 255),
}

-- ============================================================
-- SOUNDS
-- ============================================================
local SOUNDS = {
	click    = "rbxassetid://6895079853",
	tab      = "rbxassetid://6895079853",
	toggle   = "rbxassetid://9119713951",
	open     = "rbxassetid://9119713951",
	close    = "rbxassetid://9119713951",
	hover    = "rbxassetid://6895079853",
	notify   = "rbxassetid://9119713951",
}

local function playSound(id, pitch, vol)
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = vol or 0.4
	s.PlaybackSpeed = pitch or 1
	s.Parent = CoreGui
	s:Play()
	game:GetService("Debris"):AddItem(s, 2)
end

-- ============================================================
-- HELPERS
-- ============================================================
local function tween(inst, props, t, style, dir)
	TweenService:Create(inst, TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
end

local function new(class, props, parent)
	local inst = Instance.new(class)
	for k, v in props or {} do
		inst[k] = v
	end
	if parent then inst.Parent = parent end
	return inst
end

local function stroke(parent, color, thickness, trans)
	return new("UIStroke", {
		Color = color or THEME.border,
		Thickness = thickness or 1,
		Transparency = trans or 0,
	}, parent)
end

local function corner(parent, radius)
	return new("UICorner", {CornerRadius = UDim.new(0, radius or 6)}, parent)
end

local function pad(parent, t, b, l, r)
	return new("UIPadding", {
		PaddingTop    = UDim.new(0, t or 0),
		PaddingBottom = UDim.new(0, b or 0),
		PaddingLeft   = UDim.new(0, l or 0),
		PaddingRight  = UDim.new(0, r or 0),
	}, parent)
end

local function list(parent, spacing, dir)
	return new("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = dir or Enum.FillDirection.Vertical,
		Padding = UDim.new(0, spacing or 0),
	}, parent)
end

local function gradient(parent, from, to, rot)
	return new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, from),
			ColorSequenceKeypoint.new(1, to),
		}),
		Rotation = rot or 90,
	}, parent)
end

-- dragging
local DRAG_OBJ, DRAG_START, START_POS, IS_DRAG = nil, nil, nil, false

local function makeDraggable(handle, target)
	handle.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
		IS_DRAG, DRAG_OBJ = true, target
		DRAG_START = i.Position
		START_POS  = target.Position
	end)
	handle.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			IS_DRAG = false
		end
	end)
end

UIS.InputChanged:Connect(function(i)
	if IS_DRAG and DRAG_OBJ and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - DRAG_START
		DRAG_OBJ:TweenPosition(
			UDim2.new(START_POS.X.Scale, START_POS.X.Offset + d.X, START_POS.Y.Scale, START_POS.Y.Offset + d.Y),
			Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.07, true
		)
	end
end)

-- ============================================================
-- INIT GUI
-- ============================================================
function Vaeltha:Init(title)
	self.gui = new("ScreenGui", {
		Name = "Vaeltha",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	pcall(function()
		if syn and syn.protect_gui then syn.protect_gui(self.gui)
		elseif gethui then self.gui.Parent = gethui() return end
	end)
	self.gui.Parent = CoreGui

	-- ambient glow background
	local ambient = new("Frame", {
		Name = "Ambient",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.3,
		ZIndex = 0,
	}, self.gui)

	local glow1 = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.3, 0, 0.4, 0),
		Size = UDim2.new(0, 500, 0, 500),
		BackgroundColor3 = Color3.fromRGB(80, 60, 200),
		BackgroundTransparency = 0.93,
		ZIndex = 0,
	}, ambient)
	corner(glow1, 250)

	local glow2 = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.7, 0, 0.6, 0),
		Size = UDim2.new(0, 400, 0, 400),
		BackgroundColor3 = Color3.fromRGB(40, 30, 120),
		BackgroundTransparency = 0.94,
		ZIndex = 0,
	}, ambient)
	corner(glow2, 200)

	-- blur
	new("BlurEffect", {Size = 8}, game:GetService("Lighting"))

	-- ============================================================
	-- MAIN WINDOW
	-- ============================================================
	self.window = new("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 680, 0, 440),
		BackgroundColor3 = THEME.bg,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, self.gui)
	corner(self.window, 10)
	stroke(self.window, THEME.border, 1, 0.3)

	-- window shadow
	local shadow = new("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 8),
		Size = UDim2.new(1, 60, 1, 60),
		BackgroundTransparency = 1,
		Image = "rbxassetid://5028857084",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.6,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(24, 24, 276, 276),
		ZIndex = 1,
	}, self.window)

	-- window top glow line
	local topGlow = new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = THEME.accent,
		BackgroundTransparency = 0.5,
		ZIndex = 3,
	}, self.window)
	gradient(topGlow, THEME.accentGlow, THEME.accentDim)

	-- ============================================================
	-- TITLEBAR
	-- ============================================================
	local titlebar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = THEME.surface,
		BorderSizePixel = 0,
		ZIndex = 3,
	}, self.window)
	corner(titlebar, 10)

	-- bottom of titlebar fill (to remove bottom rounded corners)
	new("Frame", {
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = THEME.surface,
		BorderSizePixel = 0,
		ZIndex = 3,
	}, titlebar)

	makeDraggable(titlebar, self.window)

	-- logo / accent dot
	local accentDot = new("Frame", {
		Position = UDim2.new(0, 16, 0, 18),
		Size = UDim2.new(0, 14, 0, 14),
		BackgroundColor3 = THEME.accent,
		ZIndex = 4,
	}, titlebar)
	corner(accentDot, 4)
	gradient(accentDot, THEME.accentGlow, THEME.accentDim, 135)

	-- glow effect on dot
	local dotGlow = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(2.5, 0, 2.5, 0),
		BackgroundColor3 = THEME.accent,
		BackgroundTransparency = 0.7,
		ZIndex = 3,
	}, accentDot)
	corner(dotGlow, 20)

	-- title text
	new("TextLabel", {
		Position = UDim2.new(0, 38, 0, 0),
		Size = UDim2.new(0, 200, 1, 0),
		BackgroundTransparency = 1,
		Text = title or "Vaeltha",
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		TextColor3 = THEME.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
	}, titlebar)

	-- version badge
	local badge = new("Frame", {
		Position = UDim2.new(0, 38 + 6, 0, 14),
		Size = UDim2.new(0, 46, 0, 18),
		BackgroundColor3 = THEME.surface3,
		ZIndex = 4,
	}, titlebar)
	corner(badge, 4)
	stroke(badge, THEME.border, 1, 0.5)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "v1.0",
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		TextColor3 = THEME.textMuted,
		ZIndex = 5,
	}, badge)
	-- offset title to make room for badge
	-- (already placed correctly above)

	-- close button
	local closeBtn = new("ImageButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.new(0, 24, 0, 24),
		BackgroundColor3 = Color3.fromRGB(200, 60, 60),
		BackgroundTransparency = 0.3,
		Image = "",
		ZIndex = 4,
	}, titlebar)
	corner(closeBtn, 6)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "×",
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextColor3 = THEME.white,
		ZIndex = 5,
	}, closeBtn)

	closeBtn.MouseEnter:Connect(function()
		tween(closeBtn, {BackgroundTransparency = 0}, 0.12)
	end)
	closeBtn.MouseLeave:Connect(function()
		tween(closeBtn, {BackgroundTransparency = 0.3}, 0.12)
	end)
	closeBtn.MouseButton1Click:Connect(function()
		playSound(SOUNDS.close, 0.9, 0.5)
		Vaeltha:Toggle()
	end)

	-- minimize button
	local minBtn = new("ImageButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -46, 0.5, 0),
		Size = UDim2.new(0, 24, 0, 24),
		BackgroundColor3 = THEME.surface3,
		BackgroundTransparency = 0.3,
		Image = "",
		ZIndex = 4,
	}, titlebar)
	corner(minBtn, 6)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "−",
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextColor3 = THEME.textDim,
		ZIndex = 5,
	}, minBtn)

	minBtn.MouseEnter:Connect(function()
		tween(minBtn, {BackgroundColor3 = THEME.surface3, BackgroundTransparency = 0}, 0.12)
	end)
	minBtn.MouseLeave:Connect(function()
		tween(minBtn, {BackgroundTransparency = 0.3}, 0.12)
	end)

	-- border line under titlebar
	new("Frame", {
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = THEME.border,
		BackgroundTransparency = 0.5,
		ZIndex = 4,
	}, titlebar)

	-- ============================================================
	-- LEFT TAB BAR
	-- ============================================================
	local sidebar = new("Frame", {
		Position = UDim2.new(0, 0, 0, 50),
		Size = UDim2.new(0, 52, 1, -50),
		BackgroundColor3 = THEME.surface,
		BorderSizePixel = 0,
		ZIndex = 3,
	}, self.window)

	-- right border
	new("Frame", {
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = THEME.border,
		BackgroundTransparency = 0.5,
		ZIndex = 4,
	}, sidebar)

	-- bottom left corner fill
	local sideCornerFill = new("Frame", {
		Position = UDim2.new(0, 0, 1, -10),
		Size = UDim2.new(1, 0, 0, 10),
		BackgroundColor3 = THEME.surface,
		BorderSizePixel = 0,
		ZIndex = 3,
	}, sidebar)

	self.sidebarTabList = new("Frame", {
		Position = UDim2.new(0, 0, 0, 8),
		Size = UDim2.new(1, 0, 1, -16),
		BackgroundTransparency = 1,
		ZIndex = 4,
	}, sidebar)
	list(self.sidebarTabList, 4)

	-- ============================================================
	-- CONTENT AREA
	-- ============================================================
	self.contentHolder = new("Frame", {
		Position = UDim2.new(0, 52, 0, 50),
		Size = UDim2.new(1, -52, 1, -50),
		BackgroundTransparency = 1,
		ZIndex = 2,
	}, self.window)

	-- play open sound
	playSound(SOUNDS.open, 1.1, 0.5)

	return self
end

-- ============================================================
-- ADD TAB
-- ============================================================
function Vaeltha:AddTab(name, icon)
	local tabData = {
		name = name,
		options = {},
		sections = {},
		active = false,
	}
	table.insert(self.tabs, tabData)

	-- ---- sidebar button ----
	local btn = new("ImageButton", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = THEME.surface,
		BackgroundTransparency = 1,
		Image = "",
		ZIndex = 5,
		LayoutOrder = #self.tabs,
		Parent = self.sidebarTabList,
	})
	corner(btn, 6)
	new("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)}, btn)

	-- active indicator bar
	local indicator = new("Frame", {
		Position = UDim2.new(0, -4, 0.2, 0),
		Size = UDim2.new(0, 3, 0.6, 0),
		BackgroundColor3 = THEME.accent,
		BackgroundTransparency = 1,
		ZIndex = 6,
		Parent = btn,
	})
	corner(indicator, 2)

	-- icon label
	local iconLabel = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.42, 0),
		Size = UDim2.new(0, 22, 0, 22),
		BackgroundTransparency = 1,
		Text = icon or "•",
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextColor3 = THEME.textMuted,
		ZIndex = 6,
		Parent = btn,
	})

	-- name label (tiny, below icon)
	local nameLabel = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -5),
		Size = UDim2.new(1, 0, 0, 12),
		BackgroundTransparency = 1,
		Text = name,
		TextSize = 9,
		Font = Enum.Font.Gotham,
		TextColor3 = THEME.textMuted,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 6,
		Parent = btn,
	})

	-- ---- content page ----
	local page = new("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = THEME.border,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		ZIndex = 3,
		Parent = self.contentHolder,
	})
	pad(page, 14, 14, 14, 14)

	local pageLayout = list(page, 8)

	tabData.btn       = btn
	tabData.indicator = indicator
	tabData.iconLabel = iconLabel
	tabData.nameLabel = nameLabel
	tabData.page      = page

	local function activate()
		-- deactivate all
		for _, t in self.tabs do
			if t ~= tabData then
				t.page.Visible = false
				tween(t.btn,       {BackgroundTransparency = 1}, 0.2)
				tween(t.indicator, {BackgroundTransparency = 1}, 0.2)
				tween(t.iconLabel, {TextColor3 = THEME.textMuted}, 0.2)
				tween(t.nameLabel, {TextColor3 = THEME.textMuted}, 0.2)
				t.active = false
			end
		end
		tabData.active = true
		tabData.page.Visible = true
		tween(btn,       {BackgroundTransparency = 0.85, BackgroundColor3 = THEME.surface3}, 0.2)
		tween(indicator, {BackgroundTransparency = 0}, 0.2)
		tween(iconLabel, {TextColor3 = THEME.accentGlow}, 0.2)
		tween(nameLabel, {TextColor3 = THEME.textDim},    0.2)
	end

	btn.MouseButton1Click:Connect(function()
		if tabData.active then return end
		playSound(SOUNDS.tab, 1.2, 0.3)
		activate()
	end)

	btn.MouseEnter:Connect(function()
		if tabData.active then return end
		tween(btn, {BackgroundTransparency = 0.92}, 0.12)
		tween(iconLabel, {TextColor3 = THEME.textDim}, 0.12)
	end)
	btn.MouseLeave:Connect(function()
		if tabData.active then return end
		tween(btn, {BackgroundTransparency = 1}, 0.12)
		tween(iconLabel, {TextColor3 = THEME.textMuted}, 0.12)
	end)

	-- activate first tab by default
	if #self.tabs == 1 then activate() end

	-- ============================================================
	-- SECTION HELPER
	-- ============================================================
	function tabData:AddSection(sectionName)
		local sectionData = {options = {}}

		-- section container
		local container = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = THEME.surface,
			BorderSizePixel = 0,
			ZIndex = 4,
			LayoutOrder = #page:GetChildren(),
			Parent = page,
		})
		corner(container, 8)
		stroke(container, THEME.border, 1, 0.6)

		local sectionHeader = new("Frame", {
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundTransparency = 1,
			ZIndex = 5,
			Parent = container,
		})

		-- accent line left
		local accentLine = new("Frame", {
			Position = UDim2.new(0, 0, 0.15, 0),
			Size = UDim2.new(0, 3, 0.7, 0),
			BackgroundColor3 = THEME.accent,
			ZIndex = 6,
			Parent = sectionHeader,
		})
		corner(accentLine, 2)

		new("TextLabel", {
			Position = UDim2.new(0, 14, 0, 0),
			Size = UDim2.new(1, -14, 1, 0),
			BackgroundTransparency = 1,
			Text = sectionName,
			TextSize = 12,
			Font = Enum.Font.GothamBold,
			TextColor3 = THEME.textDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 6,
			Parent = sectionHeader,
		})

		-- divider
		new("Frame", {
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = THEME.border,
			BackgroundTransparency = 0.5,
			ZIndex = 5,
			Parent = sectionHeader,
		})

		-- options content
		local content = new("Frame", {
			Position = UDim2.new(0, 0, 0, 34),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			ZIndex = 5,
			Parent = container,
		})
		pad(content, 6, 8, 10, 10)
		list(content, 4)

		-- ============================================================
		-- COMPONENTS
		-- ============================================================

		-- ---- LABEL ----
		function sectionData:AddLabel(text)
			new("TextLabel", {
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				Text = text,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextColor3 = THEME.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 6,
				LayoutOrder = #content:GetChildren(),
				Parent = content,
			})
		end

		-- ---- SEPARATOR ----
		function sectionData:AddSeparator()
			local f = new("Frame", {
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = THEME.border,
				BackgroundTransparency = 0.5,
				ZIndex = 6,
				LayoutOrder = #content:GetChildren(),
				Parent = content,
			})
			new("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)}, f)
		end

		-- ---- TOGGLE ----
		function sectionData:AddToggle(option)
			option = option or {}
			option.flag = option.flag or option.text
			option.state = option.state or false
			option.callback = option.callback or function() end
			Vaeltha.flags[option.flag] = option.state

			local row = new("Frame", {
				Size = UDim2.new(1, 0, 0, 34),
				BackgroundTransparency = 1,
				ZIndex = 6,
				LayoutOrder = #content:GetChildren(),
				Parent = content,
			})

			new("TextLabel", {
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, -54, 1, 0),
				BackgroundTransparency = 1,
				Text = option.text or "",
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextColor3 = THEME.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 7,
				Parent = row,
			})

			if option.desc then
				new("TextLabel", {
					Position = UDim2.new(0, 0, 0, 18),
					Size = UDim2.new(1, -54, 0, 14),
					BackgroundTransparency = 1,
					Text = option.desc,
					TextSize = 11,
					Font = Enum.Font.Gotham,
					TextColor3 = THEME.textMuted,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 7,
					Parent = row,
				})
				row.Size = UDim2.new(1, 0, 0, 40)
			end

			-- toggle pill
			local pillBg = new("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 42, 0, 22),
				BackgroundColor3 = option.state and THEME.accent or THEME.surface3,
				ZIndex = 7,
				Parent = row,
			})
			corner(pillBg, 11)
			stroke(pillBg, option.state and THEME.accent or THEME.border, 1, 0.3)

			local knob = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = option.state and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16),
				BackgroundColor3 = THEME.white,
				ZIndex = 8,
				Parent = pillBg,
			})
			corner(knob, 8)

			local function setState(state, noCallback)
				option.state = state
				Vaeltha.flags[option.flag] = state
				if state then
					tween(pillBg, {BackgroundColor3 = THEME.accent}, 0.18)
					tween(knob,   {Position = UDim2.new(1, -11, 0.5, 0)}, 0.18)
				else
					tween(pillBg, {BackgroundColor3 = THEME.surface3}, 0.18)
					tween(knob,   {Position = UDim2.new(0, 11, 0.5, 0)}, 0.18)
				end
				if not noCallback then option.callback(state) end
			end

			row.InputBegan:Connect(function(i)
				if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
				playSound(SOUNDS.toggle, option.state and 0.9 or 1.1, 0.3)
				setState(not option.state)
			end)

			function option:SetState(s) setState(s, false) end

			if option.state then task.defer(function() option.callback(true) end) end
			return option
		end

		-- ---- SLIDER ----
		function sectionData:AddSlider(option)
			option = option or {}
			option.flag  = option.flag or option.text
			option.min   = option.min   or 0
			option.max   = option.max   or 100
			option.value = math.clamp(option.value or option.min, option.min, option.max)
			option.float = option.float or 1
			option.callback = option.callback or function() end
			Vaeltha.flags[option.flag] = option.value

			local row = new("Frame", {
				Size = UDim2.new(1, 0, 0, 46),
				BackgroundTransparency = 1,
				ZIndex = 6,
				LayoutOrder = #content:GetChildren(),
				Parent = content,
			})

			-- top row: label + value
			new("TextLabel", {
				Size = UDim2.new(1, -50, 0, 18),
				BackgroundTransparency = 1,
				Text = option.text or "",
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextColor3 = THEME.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 7,
				Parent = row,
			})

			local valueLabel = new("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0, 50, 0, 18),
				BackgroundTransparency = 1,
				Text = tostring(option.value),
				TextSize = 12,
				Font = Enum.Font.GothamBold,
				TextColor3 = THEME.accent,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 7,
				Parent = row,
			})

			-- track
			local track = new("Frame", {
				Position = UDim2.new(0, 0, 0, 26),
				Size = UDim2.new(1, 0, 0, 6),
				BackgroundColor3 = THEME.surface3,
				ZIndex = 7,
				Parent = row,
			})
			corner(track, 3)
			stroke(track, THEME.border, 1, 0.5)

			local fillBar = new("Frame", {
				Size = UDim2.new((option.value - option.min) / (option.max - option.min), 0, 1, 0),
				BackgroundColor3 = THEME.accent,
				ZIndex = 8,
				Parent = track,
			})
			corner(fillBar, 3)
			gradient(fillBar, THEME.accentGlow, THEME.accent, 0)

			local handle = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new((option.value - option.min) / (option.max - option.min), 0, 0.5, 0),
				Size = UDim2.new(0, 12, 0, 12),
				BackgroundColor3 = THEME.white,
				ZIndex = 9,
				Parent = track,
			})
			corner(handle, 6)

			local sliding = false

			local function setValue(v)
				v = math.floor(v / option.float + 0.5) * option.float
				v = math.clamp(v, option.min, option.max)
				option.value = v
				Vaeltha.flags[option.flag] = v
				valueLabel.Text = tostring(v)
				local pct = (v - option.min) / (option.max - option.min)
				fillBar:TweenSize(UDim2.new(pct, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.06, true)
				handle:TweenPosition(UDim2.new(pct, 0, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.06, true)
				option.callback(v)
			end

			track.InputBegan:Connect(function(i)
				if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
				sliding = true
				tween(handle, {Size = UDim2.new(0, 16, 0, 16)}, 0.12)
				tween(fillBar, {BackgroundColor3 = THEME.accentGlow}, 0.12)
				local pct = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				setValue(option.min + pct * (option.max - option.min))
			end)

			UIS.InputChanged:Connect(function(i)
				if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
					local pct = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					setValue(option.min + pct * (option.max - option.min))
				end
			end)

			UIS.InputEnded:Connect(function(i)
				if sliding and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
					sliding = false
					tween(handle,  {Size = UDim2.new(0, 12, 0, 12)}, 0.12)
					tween(fillBar, {BackgroundColor3 = THEME.accent},  0.12)
				end
			end)

			function option:SetValue(v) setValue(v) end
			return option
		end

		-- ---- BUTTON ----
		function sectionData:AddButton(option)
			option = option or {}
			option.callback = option.callback or function() end

			local btn2 = new("ImageButton", {
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = THEME.surface3,
				Image = "",
				ZIndex = 6,
				LayoutOrder = #content:GetChildren(),
				Parent = content,
			})
			corner(btn2, 6)
			stroke(btn2, THEME.border, 1, 0.5)

			local btnGrad = gradient(btn2, THEME.surface3, THEME.surface2, 180)

			new("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = option.text or "",
				TextSize = 13,
				Font = Enum.Font.GothamBold,
				TextColor3 = THEME.text,
				ZIndex = 7,
				Parent = btn2,
			})

			btn2.MouseEnter:Connect(function()
				tween(btn2, {BackgroundColor3 = THEME.surface3}, 0.12)
				btnGrad.Color = ColorSequence.new(THEME.accentDim, THEME.surface3)
			end)
			btn2.MouseLeave:Connect(function()
				tween(btn2, {BackgroundColor3 = THEME.surface3}, 0.12)
				btnGrad.Color = ColorSequence.new(THEME.surface3, THEME.surface2)
			end)
			btn2.MouseButton1Down:Connect(function()
				tween(btn2, {BackgroundColor3 = THEME.accentDim}, 0.08)
			end)
			btn2.MouseButton1Up:Connect(function()
				tween(btn2, {BackgroundColor3 = THEME.surface3}, 0.14)
			end)
			btn2.MouseButton1Click:Connect(function()
				playSound(SOUNDS.click, 1.0, 0.35)
				option.callback()
			end)

			return option
		end

		-- ---- DROPDOWN ----
		function sectionData:AddDropdown(option)
			option = option or {}
			option.flag   = option.flag or option.text
			option.values = option.values or {}
			option.value  = option.value  or option.values[1] or ""
			option.callback = option.callback or function() end
			Vaeltha.flags[option.flag] = option.value

			local dropFrame = new("Frame", {
				Size = UDim2.new(1, 0, 0, 52),
				BackgroundTransparency = 1,
				ZIndex = 6,
				LayoutOrder = #content:GetChildren(),
				ClipsDescendants = false,
				Parent = content,
			})

			new("TextLabel", {
				Size = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				Text = option.text or "",
				TextSize = 12,
				Font = Enum.Font.Gotham,
				TextColor3 = THEME.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 7,
				Parent = dropFrame,
			})

			local dropBtn = new("ImageButton", {
				Position = UDim2.new(0, 0, 0, 20),
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = THEME.surface3,
				Image = "",
				ZIndex = 7,
				Parent = dropFrame,
			})
			corner(dropBtn, 6)
			stroke(dropBtn, THEME.border, 1, 0.5)

			local selectedLabel = new("TextLabel", {
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -30, 1, 0),
				BackgroundTransparency = 1,
				Text = tostring(option.value),
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextColor3 = THEME.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 8,
				Parent = dropBtn,
			})

			-- chevron
			new("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.new(0, 14, 0, 14),
				BackgroundTransparency = 1,
				Text = "▾",
				TextSize = 12,
				Font = Enum.Font.GothamBold,
				TextColor3 = THEME.textMuted,
				ZIndex = 8,
				Parent = dropBtn,
			})

			-- popup
			local popupFrame = new("Frame", {
				Position = UDim2.new(0, 0, 1, 4),
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundColor3 = THEME.surface2,
				ClipsDescendants = true,
				ZIndex = 20,
				Visible = false,
				Parent = dropBtn,
			})
			corner(popupFrame, 6)
			stroke(popupFrame, THEME.border, 1, 0.3)

			local popupList = list(popupFrame, 0)
			pad(popupFrame, 4, 4, 0, 0)

			local ITEM_H = 28
			local dropOpen = false

			local function closePopup()
				dropOpen = false
				tween(popupFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
				task.delay(0.15, function() popupFrame.Visible = false end)
			end

			local function openPopup()
				dropOpen = true
				popupFrame.Visible = true
				local count = math.min(#option.values, 5)
				tween(popupFrame, {Size = UDim2.new(1, 0, 0, count * ITEM_H + 8)}, 0.18)
			end

			for _, val in option.values do
				local item = new("ImageButton", {
					Size = UDim2.new(1, 0, 0, ITEM_H),
					BackgroundColor3 = THEME.surface2,
					BackgroundTransparency = 1,
					Image = "",
					ZIndex = 21,
					Parent = popupFrame,
				})
				new("TextLabel", {
					Position = UDim2.new(0, 10, 0, 0),
					Size = UDim2.new(1, -10, 1, 0),
					BackgroundTransparency = 1,
					Text = tostring(val),
					TextSize = 13,
					Font = Enum.Font.Gotham,
					TextColor3 = THEME.text,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 22,
					Parent = item,
				})
				item.MouseEnter:Connect(function()
					tween(item, {BackgroundTransparency = 0.7}, 0.1)
				end)
				item.MouseLeave:Connect(function()
					tween(item, {BackgroundTransparency = 1}, 0.1)
				end)
				item.MouseButton1Click:Connect(function()
					playSound(SOUNDS.click, 1.1, 0.3)
					option.value = tostring(val)
					Vaeltha.flags[option.flag] = option.value
					selectedLabel.Text = option.value
					option.callback(val)
					closePopup()
				end)
			end

			dropBtn.MouseButton1Click:Connect(function()
				playSound(SOUNDS.click, 1.0, 0.3)
				if dropOpen then closePopup() else openPopup() end
			end)

			function option:SetValue(v)
				option.value = tostring(v)
				Vaeltha.flags[option.flag] = option.value
				selectedLabel.Text = option.value
				option.callback(v)
			end

			return option
		end

		-- ---- TEXTBOX ----
		function sectionData:AddTextBox(option)
			option = option or {}
			option.flag = option.flag or option.text
			option.value = option.value or ""
			option.callback = option.callback or function() end
			Vaeltha.flags[option.flag] = option.value

			local row = new("Frame", {
				Size = UDim2.new(1, 0, 0, 48),
				BackgroundTransparency = 1,
				ZIndex = 6,
				LayoutOrder = #content:GetChildren(),
				Parent = content,
			})

			new("TextLabel", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1,
				Text = option.text or "",
				TextSize = 12,
				Font = Enum.Font.Gotham,
				TextColor3 = THEME.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 7,
				Parent = row,
			})

			local boxBg = new("Frame", {
				Position = UDim2.new(0, 0, 0, 18),
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundColor3 = THEME.surface3,
				ZIndex = 7,
				Parent = row,
			})
			corner(boxBg, 6)
			local boxStroke = stroke(boxBg, THEME.border, 1, 0.3)

			local box = new("TextBox", {
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -10, 1, 0),
				BackgroundTransparency = 1,
				Text = option.value,
				PlaceholderText = option.placeholder or "...",
				PlaceholderColor3 = THEME.textMuted,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextColor3 = THEME.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false,
				ZIndex = 8,
				Parent = boxBg,
			})

			box.Focused:Connect(function()
				tween(boxBg, {BackgroundColor3 = THEME.surface2}, 0.15)
				boxStroke.Color = THEME.accent
				boxStroke.Transparency = 0
			end)
			box.FocusLost:Connect(function(enter)
				tween(boxBg, {BackgroundColor3 = THEME.surface3}, 0.15)
				boxStroke.Color = THEME.border
				boxStroke.Transparency = 0.3
				option.value = box.Text
				Vaeltha.flags[option.flag] = option.value
				option.callback(option.value, enter)
			end)

			function option:SetValue(v)
				option.value = tostring(v)
				box.Text = option.value
				Vaeltha.flags[option.flag] = option.value
			end

			return option
		end

		-- ---- KEYBIND ----
		function sectionData:AddBind(option)
			option = option or {}
			option.flag = option.flag or option.text
			option.key  = (option.key and option.key.Name) or option.key or "F"
			option.callback = option.callback or function() end
			Vaeltha.flags[option.flag] = option.key

			local BLACKLIST = {
				Enum.KeyCode.Unknown, Enum.KeyCode.Return, Enum.KeyCode.Tab,
				Enum.KeyCode.Escape, Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift,
				Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl,
			}

			local row = new("Frame", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				ZIndex = 6,
				LayoutOrder = #content:GetChildren(),
				Parent = content,
			})

			new("TextLabel", {
				Size = UDim2.new(1, -70, 1, 0),
				BackgroundTransparency = 1,
				Text = option.text or "",
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextColor3 = THEME.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 7,
				Parent = row,
			})

			local bindBtn = new("ImageButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 60, 0, 22),
				BackgroundColor3 = THEME.surface3,
				Image = "",
				ZIndex = 7,
				Parent = row,
			})
			corner(bindBtn, 5)
			stroke(bindBtn, THEME.border, 1, 0.5)

			local bindLabel = new("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = option.key,
				TextSize = 11,
				Font = Enum.Font.GothamBold,
				TextColor3 = THEME.text,
				ZIndex = 8,
				Parent = bindBtn,
			})

			local binding = false

			bindBtn.MouseButton1Click:Connect(function()
				if binding then return end
				binding = true
				bindLabel.Text = "..."
				tween(bindBtn, {BackgroundColor3 = THEME.accentDim}, 0.12)
			end)

			UIS.InputBegan:Connect(function(i, gp)
				if gp then return end
				if binding then
					local key = i.KeyCode
					local blocked = false
					for _, bk in BLACKLIST do
						if key == bk then blocked = true break end
					end
					if not blocked and key ~= Enum.KeyCode.Unknown then
						option.key = key.Name
						Vaeltha.flags[option.flag] = option.key
						bindLabel.Text = option.key
						tween(bindBtn, {BackgroundColor3 = THEME.surface3}, 0.12)
						binding = false
					end
				elseif not gp and (i.KeyCode.Name == option.key) then
					option.callback()
				end
			end)

			function option:SetKey(k) option.key = k Vaeltha.flags[option.flag] = k bindLabel.Text = k end
			return option
		end

		-- ---- COLORPICKER (simple swatch) ----
		function sectionData:AddColorPicker(option)
			option = option or {}
			option.flag  = option.flag or option.text
			option.color = option.color or Color3.fromRGB(255, 100, 100)
			option.callback = option.callback or function() end
			Vaeltha.flags[option.flag] = option.color

			local row = new("Frame", {
				Size = UDim2.new(1, 0, 0, 34),
				BackgroundTransparency = 1,
				ZIndex = 6,
				LayoutOrder = #content:GetChildren(),
				Parent = content,
			})

			new("TextLabel", {
				Size = UDim2.new(1, -40, 1, 0),
				BackgroundTransparency = 1,
				Text = option.text or "",
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextColor3 = THEME.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 7,
				Parent = row,
			})

			local swatch = new("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 28, 0, 28),
				BackgroundColor3 = option.color,
				ZIndex = 7,
				Parent = row,
			})
			corner(swatch, 6)
			stroke(swatch, THEME.border, 1, 0.3)

			-- HSV picker popup
			local pickerOpen = false
			local H, S, V = Color3.toHSV(option.color)

			local pickerPopup = new("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 1, 6),
				Size = UDim2.new(0, 200, 0, 0),
				BackgroundColor3 = THEME.surface2,
				ClipsDescendants = false,
				ZIndex = 30,
				Visible = false,
				Parent = row,
			})
			corner(pickerPopup, 8)
			stroke(pickerPopup, THEME.border, 1, 0.2)

			local pickerInner = new("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				ZIndex = 31,
				Parent = pickerPopup,
			})
			pad(pickerInner, 8, 8, 8, 8)

			-- SV square
			local svSquare = new("ImageLabel", {
				Size = UDim2.new(1, 0, 0, 120),
				BackgroundColor3 = Color3.fromHSV(H, 1, 1),
				Image = "rbxassetid://4155801252",
				ZIndex = 32,
				Parent = pickerInner,
			})
			corner(svSquare, 4)

			local svHandle = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(S, 0, 1 - V, 0),
				Size = UDim2.new(0, 10, 0, 10),
				BackgroundColor3 = THEME.white,
				ZIndex = 33,
				Parent = svSquare,
			})
			corner(svHandle, 5)
			stroke(svHandle, THEME.bg, 1.5, 0)

			-- Hue bar
			local hueBar = new("Frame", {
				Position = UDim2.new(0, 0, 0, 128),
				Size = UDim2.new(1, 0, 0, 10),
				BackgroundTransparency = 1,
				ZIndex = 32,
				Parent = pickerInner,
			})
			corner(hueBar, 5)

			local hueGrad = new("UIGradient", {
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
			-- hue bar bg
			hueBar.BackgroundColor3 = Color3.fromRGB(255,0,0)

			local hueHandle = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(H == 1 and 0 or H, 0, 0.5, 0),
				Size = UDim2.new(0, 8, 0, 14),
				BackgroundColor3 = THEME.white,
				ZIndex = 33,
				Parent = hueBar,
			})
			corner(hueHandle, 3)
			stroke(hueHandle, THEME.bg, 1.5, 0)

			local function updateColor()
				local c = Color3.fromHSV(H, S, V)
				option.color = c
				Vaeltha.flags[option.flag] = c
				swatch.BackgroundColor3 = c
				svSquare.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
				option.callback(c)
			end

			-- SV drag
			local svDrag = false
			svSquare.InputBegan:Connect(function(i)
				if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
				svDrag = true
				S = math.clamp((i.Position.X - svSquare.AbsolutePosition.X) / svSquare.AbsoluteSize.X, 0, 1)
				V = 1 - math.clamp((i.Position.Y - svSquare.AbsolutePosition.Y) / svSquare.AbsoluteSize.Y, 0, 1)
				svHandle.Position = UDim2.new(S, 0, 1 - V, 0)
				updateColor()
			end)
			UIS.InputChanged:Connect(function(i)
				if svDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
					S = math.clamp((i.Position.X - svSquare.AbsolutePosition.X) / svSquare.AbsoluteSize.X, 0, 1)
					V = 1 - math.clamp((i.Position.Y - svSquare.AbsolutePosition.Y) / svSquare.AbsoluteSize.Y, 0, 1)
					svHandle.Position = UDim2.new(S, 0, 1 - V, 0)
					updateColor()
				end
			end)
			UIS.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then svDrag = false end
			end)

			-- Hue drag
			local hueDrag = false
			hueBar.InputBegan:Connect(function(i)
				if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
				hueDrag = true
				H = math.clamp((i.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
				hueHandle.Position = UDim2.new(H, 0, 0.5, 0)
				updateColor()
			end)
			UIS.InputChanged:Connect(function(i)
				if hueDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
					H = math.clamp((i.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
					hueHandle.Position = UDim2.new(H, 0, 0.5, 0)
					updateColor()
				end
			end)
			UIS.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hueDrag = false end
			end)

			swatch.InputBegan:Connect(function(i)
				if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
				pickerOpen = not pickerOpen
				pickerPopup.Visible = pickerOpen
				if pickerOpen then
					tween(pickerPopup, {Size = UDim2.new(0, 200, 0, 152)}, 0.18)
				else
					tween(pickerPopup, {Size = UDim2.new(0, 200, 0, 0)}, 0.14)
					task.delay(0.14, function() if not pickerOpen then pickerPopup.Visible = false end end)
				end
			end)

			function option:SetColor(c)
				option.color = c
				swatch.BackgroundColor3 = c
				Vaeltha.flags[option.flag] = c
				H, S, V = Color3.toHSV(c)
				updateColor()
			end

			return option
		end

		table.insert(tabData.sections, sectionData)
		return sectionData
	end

	return tabData
end

-- ============================================================
-- TOGGLE VISIBILITY
-- ============================================================
function Vaeltha:Toggle()
	self.open = not self.open
	if self.open then
		playSound(SOUNDS.open, 1.1, 0.4)
		self.window.Visible = true
		tween(self.window, {Size = UDim2.new(0, 680, 0, 440)}, 0.22)
	else
		playSound(SOUNDS.close, 0.85, 0.4)
		tween(self.window, {Size = UDim2.new(0, 680, 0, 0)}, 0.18)
		task.delay(0.19, function() self.window.Visible = false end)
	end
end

-- ============================================================
-- NOTIFICATION
-- ============================================================
function Vaeltha:Notify(title, text, duration)
	duration = duration or 3
	if not self.notifHolder then
		self.notifHolder = new("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -18, 1, -18),
			Size = UDim2.new(0, 280, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 50,
			Parent = self.gui,
		})
		list(self.notifHolder, 8)
		new("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Parent = self.notifHolder,
		})
	end

	local notif = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = THEME.surface,
		ClipsDescendants = true,
		ZIndex = 51,
		Parent = self.notifHolder,
	})
	corner(notif, 8)
	stroke(notif, THEME.border, 1, 0.3)

	-- top accent
	local na = new("Frame", {Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = THEME.accent, ZIndex = 52, Parent = notif})
	corner(na, 2)
	gradient(na, THEME.accentGlow, THEME.accentDim)

	local inner = new("Frame", {
		Position = UDim2.new(0, 0, 0, 2),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 52,
		Parent = notif,
	})
	pad(inner, 10, 10, 12, 12)

	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = title,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextColor3 = THEME.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 53,
		Parent = inner,
	})
	new("TextLabel", {
		Position = UDim2.new(0, 0, 0, 18),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = text,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextColor3 = THEME.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		ZIndex = 53,
		Parent = inner,
	})

	playSound(SOUNDS.notify, 1.3, 0.4)

	task.delay(duration, function()
		tween(notif, {BackgroundTransparency = 1}, 0.3)
		task.delay(0.3, function() notif:Destroy() end)
	end)
end

return Vaeltha
