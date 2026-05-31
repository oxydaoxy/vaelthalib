-- Vaeltha UI Library
-- Fluent/Acrylic style, sidebar tabs, full component set

local Vaeltha = {}
Vaeltha.__index = Vaeltha

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local TWEEN = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_SLOW = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local THEME = {
	Background     = Color3.fromRGB(20, 20, 28),
	Sidebar        = Color3.fromRGB(15, 15, 22),
	Surface        = Color3.fromRGB(28, 28, 38),
	SurfaceHover   = Color3.fromRGB(35, 35, 48),
	Elevated       = Color3.fromRGB(32, 32, 44),
	Accent         = Color3.fromRGB(90, 120, 255),
	AccentHover    = Color3.fromRGB(110, 138, 255),
	AccentDim      = Color3.fromRGB(90, 120, 255),
	Text           = Color3.fromRGB(235, 235, 245),
	TextSecondary  = Color3.fromRGB(140, 140, 165),
	TextDisabled   = Color3.fromRGB(80, 80, 100),
	Border         = Color3.fromRGB(50, 50, 68),
	BorderAccent   = Color3.fromRGB(90, 120, 255),
	Toggle_On      = Color3.fromRGB(90, 120, 255),
	Toggle_Off     = Color3.fromRGB(55, 55, 72),
	Scrollbar      = Color3.fromRGB(60, 60, 82),
	Danger         = Color3.fromRGB(255, 80, 80),
}

local function tween(obj, props, info)
	TweenService:Create(obj, info or TWEEN, props):Play()
end

local function create(class, props, children)
	local obj = Instance.new(class)
	for k, v in props do obj[k] = v end
	if children then
		for _, c in children do c.Parent = obj end
	end
	return obj
end

local function stroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		Parent = parent,
		Color = color or THEME.Border,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function corner(parent, radius)
	return create("UICorner", { Parent = parent, CornerRadius = UDim.new(0, radius or 8) })
end

local function padding(parent, t, b, l, r)
	return create("UIPadding", {
		Parent = parent,
		PaddingTop = UDim.new(0, t or 6),
		PaddingBottom = UDim.new(0, b or 6),
		PaddingLeft = UDim.new(0, l or 10),
		PaddingRight = UDim.new(0, r or 10),
	})
end

local function icon(parent, text, size, color)
	return create("TextLabel", {
		Parent = parent,
		Text = text,
		TextColor3 = color or THEME.TextSecondary,
		TextSize = size or 16,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, size or 16, 0, size or 16),
		AutomaticSize = Enum.AutomaticSize.None,
	})
end

local function ripple(parent)
	local rip = create("Frame", {
		Parent = parent,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.85,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		ZIndex = parent.ZIndex + 5,
		ClipsDescendants = true,
	})
	corner(rip, 999)
	tween(rip, { Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 1 }, TweenInfo.new(0.4, Enum.EasingStyle.Quart))
	task.delay(0.4, function() rip:Destroy() end)
end

-- drag
local function makeDraggable(frame, handle)
	handle = handle or frame
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
end

-- ScreenGui
function Vaeltha.new(title, subtitle)
	local self = setmetatable({}, Vaeltha)
	self.Tabs = {}
	self.ActiveTab = nil
	self.Visible = true

	self.GUI = create("ScreenGui", {
		Name = "VaelthaLib",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
	})

	-- try gethui
	pcall(function() self.GUI.Parent = gethui() end)
	if not self.GUI.Parent then self.GUI.Parent = game:GetService("CoreGui") end

	-- main window
	self.Window = create("Frame", {
		Parent = self.GUI,
		Name = "Window",
		BackgroundColor3 = THEME.Background,
		Size = UDim2.new(0, 620, 0, 440),
		Position = UDim2.new(0.5, -310, 0.5, -220),
		ClipsDescendants = true,
	})
	corner(self.Window, 12)
	stroke(self.Window, THEME.Border, 1)

	-- acrylic noise overlay
	local noise = create("ImageLabel", {
		Parent = self.Window,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Image = "rbxassetid://6804124180",
		ImageTransparency = 0.97,
		ZIndex = 0,
	})

	-- titlebar
	self.Titlebar = create("Frame", {
		Parent = self.Window,
		Name = "Titlebar",
		BackgroundColor3 = THEME.Sidebar,
		Size = UDim2.new(1, 0, 0, 48),
		ZIndex = 2,
	})
	create("UICorner", { Parent = self.Titlebar, CornerRadius = UDim.new(0, 12) })
	create("Frame", {
		Parent = self.Titlebar,
		BackgroundColor3 = THEME.Sidebar,
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		ZIndex = 2,
	})

	-- window icon dot
	local dot = create("Frame", {
		Parent = self.Titlebar,
		BackgroundColor3 = THEME.Accent,
		Size = UDim2.new(0, 8, 0, 8),
		Position = UDim2.new(0, 16, 0.5, -4),
		ZIndex = 3,
	})
	corner(dot, 99)

	create("TextLabel", {
		Parent = self.Titlebar,
		Text = title or "Vaeltha",
		TextColor3 = THEME.Text,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 32, 0, 0),
		Size = UDim2.new(0, 200, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
	})

	if subtitle then
		create("TextLabel", {
			Parent = self.Titlebar,
			Text = subtitle,
			TextColor3 = THEME.TextSecondary,
			TextSize = 11,
			Font = Enum.Font.Gotham,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 32, 0, 26),
			Size = UDim2.new(0, 200, 0, 16),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3,
		})
	end

	-- close + minimize
	local BTNS = {
		{ color = Color3.fromRGB(255, 90, 90), pos = UDim2.new(1, -14, 0.5, -5), cb = function() self.GUI:Destroy() end },
		{ color = Color3.fromRGB(255, 190, 50), pos = UDim2.new(1, -32, 0.5, -5), cb = function() self:Toggle() end },
	}
	for _, b in BTNS do
		local btn = create("TextButton", {
			Parent = self.Titlebar,
			BackgroundColor3 = b.color,
			Size = UDim2.new(0, 10, 0, 10),
			Position = b.pos,
			Text = "",
			ZIndex = 4,
		})
		corner(btn, 99)
		btn.MouseButton1Click:Connect(b.cb)
	end

	makeDraggable(self.Window, self.Titlebar)

	-- sidebar
	self.Sidebar = create("Frame", {
		Parent = self.Window,
		Name = "Sidebar",
		BackgroundColor3 = THEME.Sidebar,
		Size = UDim2.new(0, 150, 1, -48),
		Position = UDim2.new(0, 0, 0, 48),
		ZIndex = 2,
	})

	local sideList = create("UIListLayout", {
		Parent = self.Sidebar,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
	})
	padding(self.Sidebar, 8, 8, 8, 8)

	-- content area
	self.Content = create("Frame", {
		Parent = self.Window,
		Name = "Content",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -150, 1, -48),
		Position = UDim2.new(0, 150, 0, 48),
		ClipsDescendants = true,
		ZIndex = 2,
	})

	-- divider line
	create("Frame", {
		Parent = self.Window,
		BackgroundColor3 = THEME.Border,
		Size = UDim2.new(0, 1, 1, -48),
		Position = UDim2.new(0, 150, 0, 48),
		ZIndex = 3,
	})

	-- keybind toggle (default INSERT)
	self.Keybind = Enum.KeyCode.Insert
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == self.Keybind then self:Toggle() end
	end)

	return self
end

function Vaeltha:Toggle()
	self.Visible = not self.Visible
	self.Window.Visible = self.Visible
end

function Vaeltha:SetKeybind(key)
	self.Keybind = key
end

function Vaeltha:AddTab(name, tabIcon)
	local Tab = {}
	Tab.Name = name
	Tab.Components = {}
	Tab.Active = false

	-- tab button
	Tab.Button = create("TextButton", {
		Parent = self.Sidebar,
		Name = name,
		BackgroundColor3 = THEME.Sidebar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
		Text = "",
		ZIndex = 4,
		AutoButtonColor = false,
	})
	corner(Tab.Button, 7)

	local btnPad = padding(Tab.Button, 0, 0, 8, 8)

	local btnRow = create("Frame", {
		Parent = Tab.Button,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
	})
	create("UIListLayout", {
		Parent = btnRow,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
	})

	if tabIcon then
		create("TextLabel", {
			Parent = btnRow,
			Text = tabIcon,
			TextColor3 = THEME.TextSecondary,
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 1, 0),
		})
	end

	Tab.Label = create("TextLabel", {
		Parent = btnRow,
		Text = name,
		TextColor3 = THEME.TextSecondary,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	-- indicator bar
	Tab.Indicator = create("Frame", {
		Parent = Tab.Button,
		BackgroundColor3 = THEME.Accent,
		Size = UDim2.new(0, 2, 0.5, 0),
		Position = UDim2.new(0, 0, 0.25, 0),
		AnchorPoint = Vector2.new(0, 0),
		ZIndex = 5,
	})
	corner(Tab.Indicator, 99)
	Tab.Indicator.Visible = false

	-- scroll container
	Tab.Frame = create("ScrollingFrame", {
		Parent = self.Content,
		Name = name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = THEME.Scrollbar,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		ZIndex = 3,
	})
	padding(Tab.Frame, 10, 10, 12, 12)
	create("UIListLayout", {
		Parent = Tab.Frame,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
	})

	Tab.Button.MouseEnter:Connect(function()
		if not Tab.Active then
			tween(Tab.Button, { BackgroundTransparency = 0.85, BackgroundColor3 = THEME.SurfaceHover })
		end
	end)
	Tab.Button.MouseLeave:Connect(function()
		if not Tab.Active then
			tween(Tab.Button, { BackgroundTransparency = 1 })
		end
	end)
	Tab.Button.MouseButton1Click:Connect(function()
		self:SelectTab(Tab)
	end)

	table.insert(self.Tabs, Tab)
	if #self.Tabs == 1 then self:SelectTab(Tab) end

	-- component methods
	local Methods = {}
	setmetatable(Methods, { __index = function(_, k) return Tab[k] end })

	function Methods:AddSection(name)
		local Section = {}

		local header = create("Frame", {
			Parent = Tab.Frame,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			ZIndex = 3,
		})
		create("TextLabel", {
			Parent = header,
			Text = (name or ""):upper(),
			TextColor3 = THEME.Accent,
			TextSize = 10,
			Font = Enum.Font.GothamBold,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			LetterSpacingInEm = 0.1,
		})
		create("Frame", {
			Parent = header,
			BackgroundColor3 = THEME.Border,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -1),
		})

		Section.Container = create("Frame", {
			Parent = Tab.Frame,
			BackgroundColor3 = THEME.Surface,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			ZIndex = 3,
			ClipsDescendants = true,
		})
		corner(Section.Container, 10)
		stroke(Section.Container, THEME.Border, 1)

		create("UIListLayout", {
			Parent = Section.Container,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 0),
		})

		local function divider(parent)
			create("Frame", {
				Parent = parent,
				BackgroundColor3 = THEME.Border,
				Size = UDim2.new(1, -20, 0, 1),
				Position = UDim2.new(0, 10, 0, 0),
				ZIndex = 3,
			})
		end

		local function rowBase(height)
			local row = create("Frame", {
				Parent = Section.Container,
				BackgroundColor3 = THEME.Surface,
				Size = UDim2.new(1, 0, 0, height or 42),
				ZIndex = 3,
				AutoButtonColor = false,
			})
			padding(row, 0, 0, 14, 14)
			return row
		end

		-- AddToggle
		function Section:AddToggle(opts)
			opts = opts or {}
			local state = opts.Default or false
			local cb = opts.Callback or function() end

			local row = rowBase(42)
			local btn = create("TextButton", {
				Parent = row,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Text = "",
				ZIndex = 4,
				AutoButtonColor = false,
			})

			create("TextLabel", {
				Parent = row,
				Text = opts.Name or "Toggle",
				TextColor3 = THEME.Text,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -52, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 4,
			})

			if opts.Description then
				create("TextLabel", {
					Parent = row,
					Text = opts.Description,
					TextColor3 = THEME.TextSecondary,
					TextSize = 11,
					Font = Enum.Font.Gotham,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -52, 0, 14),
					Position = UDim2.new(0, 0, 0.55, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 4,
				})
				row.Size = UDim2.new(1, 0, 0, 52)
			end

			local track = create("Frame", {
				Parent = row,
				BackgroundColor3 = state and THEME.Toggle_On or THEME.Toggle_Off,
				Size = UDim2.new(0, 36, 0, 20),
				Position = UDim2.new(1, -36, 0.5, -10),
				ZIndex = 4,
			})
			corner(track, 99)

			local knob = create("Frame", {
				Parent = track,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.new(0, 14, 0, 14),
				Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
				ZIndex = 5,
			})
			corner(knob, 99)

			local Component = { Value = state }
			local function set(val, silent)
				state = val
				Component.Value = val
				tween(track, { BackgroundColor3 = val and THEME.Toggle_On or THEME.Toggle_Off })
				tween(knob, { Position = val and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) })
				if not silent then cb(val) end
			end

			btn.MouseButton1Click:Connect(function()
				ripple(row)
				set(not state)
			end)

			function Component:Set(val) set(val) end
			return Component
		end

		-- AddSlider
		function Section:AddSlider(opts)
			opts = opts or {}
			local min = opts.Min or 0
			local max = opts.Max or 100
			local default = opts.Default or min
			local val = default
			local suffix = opts.Suffix or ""
			local cb = opts.Callback or function() end

			local row = create("Frame", {
				Parent = Section.Container,
				BackgroundColor3 = THEME.Surface,
				Size = UDim2.new(1, 0, 0, 58),
				ZIndex = 3,
			})
			padding(row, 8, 8, 14, 14)

			local top = create("Frame", {
				Parent = row,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18),
				ZIndex = 4,
			})
			create("TextLabel", {
				Parent = top,
				Text = opts.Name or "Slider",
				TextColor3 = THEME.Text,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.7, 0, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 4,
			})

			local ValLabel = create("TextLabel", {
				Parent = top,
				Text = tostring(val) .. suffix,
				TextColor3 = THEME.Accent,
				TextSize = 12,
				Font = Enum.Font.GothamBold,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.3, 0, 1, 0),
				Position = UDim2.new(0.7, 0, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 4,
			})

			local track = create("Frame", {
				Parent = row,
				BackgroundColor3 = THEME.Elevated,
				Size = UDim2.new(1, 0, 0, 6),
				Position = UDim2.new(0, 0, 0, 26),
				ZIndex = 4,
			})
			corner(track, 99)
			stroke(track, THEME.Border, 1)

			local fill = create("Frame", {
				Parent = track,
				BackgroundColor3 = THEME.Accent,
				Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
				ZIndex = 5,
			})
			corner(fill, 99)

			local knob = create("Frame", {
				Parent = track,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new((val - min) / (max - min), -7, 0.5, -7),
				ZIndex = 6,
			})
			corner(knob, 99)

			local dragging = false
			local function setVal(newVal, silent)
				newVal = math.clamp(math.round(newVal), min, max)
				val = newVal
				local pct = (val - min) / (max - min)
				tween(fill, { Size = UDim2.new(pct, 0, 1, 0) })
				tween(knob, { Position = UDim2.new(pct, -7, 0.5, -7) })
				ValLabel.Text = tostring(val) .. suffix
				if not silent then cb(val) end
			end

			local function fromMouse()
				local mx = UserInputService:GetMouseLocation().X
				local abs = track.AbsolutePosition.X
				local w = track.AbsoluteSize.X
				setVal(min + (mx - abs) / w * (max - min))
			end

			track.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true; fromMouse()
				end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then fromMouse() end
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
			end)

			local Component = { Value = val }
			function Component:Set(v) setVal(v) end
			return Component
		end

		-- AddButton
		function Section:AddButton(opts)
			opts = opts or {}
			local cb = opts.Callback or function() end

			local row = rowBase(42)
			local btn = create("TextButton", {
				Parent = row,
				BackgroundColor3 = THEME.Accent,
				Size = UDim2.new(1, 0, 0, 28),
				Position = UDim2.new(0, 0, 0.5, -14),
				Text = "",
				ZIndex = 4,
				AutoButtonColor = false,
			})
			corner(btn, 7)

			create("TextLabel", {
				Parent = btn,
				Text = opts.Name or "Button",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 13,
				Font = Enum.Font.GothamBold,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 5,
			})

			row.Size = UDim2.new(1, 0, 0, 50)

			btn.MouseEnter:Connect(function() tween(btn, { BackgroundColor3 = THEME.AccentHover }) end)
			btn.MouseLeave:Connect(function() tween(btn, { BackgroundColor3 = THEME.Accent }) end)
			btn.MouseButton1Click:Connect(function()
				ripple(btn)
				cb()
			end)

			return {}
		end

		-- AddDropdown
		function Section:AddDropdown(opts)
			opts = opts or {}
			local items = opts.Items or {}
			local selected = opts.Default or items[1]
			local multi = opts.Multi or false
			local cb = opts.Callback or function() end
			local open = false

			local wrapper = create("Frame", {
				Parent = Section.Container,
				BackgroundColor3 = THEME.Surface,
				Size = UDim2.new(1, 0, 0, 62),
				ZIndex = 3,
				ClipsDescendants = false,
			})
			padding(wrapper, 8, 8, 14, 14)

			create("TextLabel", {
				Parent = wrapper,
				Text = opts.Name or "Dropdown",
				TextColor3 = THEME.Text,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 16),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 4,
			})

			local box = create("TextButton", {
				Parent = wrapper,
				BackgroundColor3 = THEME.Elevated,
				Size = UDim2.new(1, 0, 0, 28),
				Position = UDim2.new(0, 0, 0, 22),
				Text = "",
				ZIndex = 5,
				AutoButtonColor = false,
			})
			corner(box, 7)
			stroke(box, THEME.Border, 1)

			local BoxLabel = create("TextLabel", {
				Parent = box,
				Text = multi and "Select..." or (selected or "Select..."),
				TextColor3 = THEME.Text,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -26, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 6,
			})

			create("TextLabel", {
				Parent = box,
				Text = "▾",
				TextColor3 = THEME.TextSecondary,
				TextSize = 12,
				Font = Enum.Font.GothamBold,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 18, 1, 0),
				Position = UDim2.new(1, -20, 0, 0),
				ZIndex = 6,
			})

			-- dropdown list
			local listFrame = create("Frame", {
				Parent = wrapper,
				BackgroundColor3 = THEME.Elevated,
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 52),
				ZIndex = 20,
				ClipsDescendants = true,
				Visible = false,
			})
			corner(listFrame, 7)
			stroke(listFrame, THEME.BorderAccent, 1)

			local listLayout = create("UIListLayout", {
				Parent = listFrame,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2),
			})
			padding(listFrame, 4, 4, 6, 6)

			local multiSelected = {}
			local itemBtns = {}

			local function updateLabel()
				if multi then
					local keys = {}
					for k in multiSelected do table.insert(keys, k) end
					BoxLabel.Text = #keys == 0 and "Select..." or table.concat(keys, ", ")
				else
					BoxLabel.Text = selected or "Select..."
				end
			end

			local function buildItems()
				for _, c in listFrame:GetChildren() do
					if c:IsA("TextButton") then c:Destroy() end
				end
				itemBtns = {}
				for _, item in items do
					local iBtn = create("TextButton", {
						Parent = listFrame,
						BackgroundColor3 = THEME.Elevated,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 26),
						Text = "",
						ZIndex = 21,
						AutoButtonColor = false,
					})
					corner(iBtn, 5)

					local activeIndicator = create("Frame", {
						Parent = iBtn,
						BackgroundColor3 = THEME.Accent,
						Size = UDim2.new(0, 3, 0.5, 0),
						Position = UDim2.new(0, 0, 0.25, 0),
						ZIndex = 22,
						Visible = multi and multiSelected[item] or (item == selected),
					})
					corner(activeIndicator, 99)

					create("TextLabel", {
						Parent = iBtn,
						Text = item,
						TextColor3 = (item == selected or (multi and multiSelected[item])) and THEME.Text or THEME.TextSecondary,
						TextSize = 12,
						Font = Enum.Font.Gotham,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -10, 1, 0),
						Position = UDim2.new(0, 10, 0, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 22,
					})

					iBtn.MouseEnter:Connect(function() tween(iBtn, { BackgroundTransparency = 0.7 }) end)
					iBtn.MouseLeave:Connect(function() tween(iBtn, { BackgroundTransparency = 1 }) end)
					iBtn.MouseButton1Click:Connect(function()
						if multi then
							multiSelected[item] = not multiSelected[item] or nil
							activeIndicator.Visible = multiSelected[item] ~= nil
							updateLabel()
							cb(multiSelected)
						else
							selected = item
							for _, b in itemBtns do
								local ind = b:FindFirstChildOfClass("Frame")
								local lbl = b:FindFirstChildOfClass("TextLabel")
								if ind then ind.Visible = false end
								if lbl then lbl.TextColor3 = THEME.TextSecondary end
							end
							activeIndicator.Visible = true
							iBtn:FindFirstChildOfClass("TextLabel").TextColor3 = THEME.Text
							updateLabel()
							cb(selected)
							open = false
							listFrame.Visible = false
							tween(wrapper, { Size = UDim2.new(1, 0, 0, 62) })
						end
					end)

					table.insert(itemBtns, iBtn)
				end

				local contentH = listLayout.AbsoluteContentSize.Y + 12
				local maxH = math.min(contentH, 160)
				return maxH
			end

			box.MouseButton1Click:Connect(function()
				open = not open
				if open then
					listFrame.Visible = true
					local h = buildItems()
					tween(listFrame, { Size = UDim2.new(1, 0, 0, h) })
					tween(wrapper, { Size = UDim2.new(1, 0, 0, 62 + h + 6) })
				else
					listFrame.Visible = false
					tween(wrapper, { Size = UDim2.new(1, 0, 0, 62) })
				end
			end)

			local Component = { Value = selected, MultiValue = multiSelected }
			function Component:Set(val)
				selected = val; updateLabel()
			end
			function Component:SetItems(newItems)
				items = newItems
			end
			return Component
		end

		-- AddTextBox
		function Section:AddTextBox(opts)
			opts = opts or {}
			local cb = opts.Callback or function() end

			local row = create("Frame", {
				Parent = Section.Container,
				BackgroundColor3 = THEME.Surface,
				Size = UDim2.new(1, 0, 0, 62),
				ZIndex = 3,
			})
			padding(row, 8, 8, 14, 14)

			create("TextLabel", {
				Parent = row,
				Text = opts.Name or "TextBox",
				TextColor3 = THEME.Text,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 16),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 4,
			})

			local box = create("Frame", {
				Parent = row,
				BackgroundColor3 = THEME.Elevated,
				Size = UDim2.new(1, 0, 0, 28),
				Position = UDim2.new(0, 0, 0, 22),
				ZIndex = 4,
			})
			corner(box, 7)
			local BoxStroke = stroke(box, THEME.Border, 1)

			local input = create("TextBox", {
				Parent = box,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -16, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				Text = opts.Default or "",
				PlaceholderText = opts.Placeholder or "Enter value...",
				PlaceholderColor3 = THEME.TextDisabled,
				TextColor3 = THEME.Text,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				ClearTextOnFocus = opts.ClearOnFocus ~= false,
				ZIndex = 5,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			input.Focused:Connect(function() tween(BoxStroke, { Color = THEME.BorderAccent }) end)
			input.FocusLost:Connect(function(enter)
				tween(BoxStroke, { Color = THEME.Border })
				if opts.Immediate or enter then cb(input.Text) end
			end)

			local Component = { Value = input.Text }
			function Component:Set(val) input.Text = val end
			return Component
		end

		-- AddColorPicker
		function Section:AddColorPicker(opts)
			opts = opts or {}
			local col = opts.Default or Color3.fromRGB(255, 255, 255)
			local cb = opts.Callback or function() end
			local open = false

			local row = create("Frame", {
				Parent = Section.Container,
				BackgroundColor3 = THEME.Surface,
				Size = UDim2.new(1, 0, 0, 42),
				ZIndex = 3,
				ClipsDescendants = false,
			})
			padding(row, 0, 0, 14, 14)

			create("TextLabel", {
				Parent = row,
				Text = opts.Name or "Color",
				TextColor3 = THEME.Text,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -44, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 4,
			})

			local preview = create("TextButton", {
				Parent = row,
				BackgroundColor3 = col,
				Size = UDim2.new(0, 30, 0, 22),
				Position = UDim2.new(1, -30, 0.5, -11),
				Text = "",
				ZIndex = 4,
				AutoButtonColor = false,
			})
			corner(preview, 6)
			stroke(preview, THEME.Border, 1)

			-- HSV picker panel
			local panel = create("Frame", {
				Parent = row,
				BackgroundColor3 = THEME.Elevated,
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 44),
				ZIndex = 15,
				Visible = false,
				ClipsDescendants = true,
			})
			corner(panel, 8)
			stroke(panel, THEME.BorderAccent, 1)
			padding(panel, 8, 8, 8, 8)

			-- sat/val gradient square
			local sv = create("ImageLabel", {
				Parent = panel,
				BackgroundColor3 = Color3.fromHSV(col:ToHSV()),
				Size = UDim2.new(1, 0, 0, 100),
				Image = "rbxassetid://6804517327",
				ZIndex = 16,
			})
			corner(sv, 6)

			local svDot = create("Frame", {
				Parent = sv,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.new(0, 10, 0, 10),
				ZIndex = 17,
			})
			corner(svDot, 99)
			stroke(svDot, Color3.fromRGB(0, 0, 0), 1.5, 0.3)

			-- hue bar
			local hueBar = create("ImageLabel", {
				Parent = panel,
				Size = UDim2.new(1, 0, 0, 14),
				Position = UDim2.new(0, 0, 0, 108),
				Image = "rbxassetid://6804516514",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 16,
			})
			corner(hueBar, 99)

			local hueDot = create("Frame", {
				Parent = hueBar,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.new(0, 12, 1, 2),
				Position = UDim2.new(0, 0, 0.5, -7),
				ZIndex = 17,
			})
			corner(hueDot, 4)
			stroke(hueDot, Color3.fromRGB(0, 0, 0), 1.5, 0.3)

			local HexInput = create("TextBox", {
				Parent = panel,
				BackgroundColor3 = THEME.Surface,
				Size = UDim2.new(1, 0, 0, 24),
				Position = UDim2.new(0, 0, 0, 130),
				Text = "",
				PlaceholderText = "#FFFFFF",
				PlaceholderColor3 = THEME.TextDisabled,
				TextColor3 = THEME.Text,
				TextSize = 12,
				Font = Enum.Font.Code,
				BackgroundTransparency = 0,
				ZIndex = 16,
				TextXAlignment = Enum.TextXAlignment.Center,
			})
			corner(HexInput, 6)
			stroke(HexInput, THEME.Border, 1)

			local H, S, V = col:ToHSV()

			local function toHex(c)
				return string.format("#%02X%02X%02X", math.round(c.R * 255), math.round(c.G * 255), math.round(c.B * 255))
			end

			local function applyColor()
				col = Color3.fromHSV(H, S, V)
				preview.BackgroundColor3 = col
				sv.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
				svDot.Position = UDim2.new(S, -5, 1 - V, -5)
				hueDot.Position = UDim2.new(H, -6, 0.5, -7)
				HexInput.Text = toHex(col)
				cb(col)
			end

			local svDrag, hueDrag = false, false

			sv.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = true end
			end)
			hueBar.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = true end
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = false; hueDrag = false end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
				local mx, my = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y
				if svDrag then
					S = math.clamp((mx - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
					V = 1 - math.clamp((my - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
					applyColor()
				elseif hueDrag then
					H = math.clamp((mx - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
					applyColor()
				end
			end)

			HexInput.FocusLost:Connect(function()
				local hex = HexInput.Text:gsub("#", "")
				if #hex == 6 then
					local r, g, b = tonumber(hex:sub(1,2), 16), tonumber(hex:sub(3,4), 16), tonumber(hex:sub(5,6), 16)
					if r and g and b then
						col = Color3.fromRGB(r, g, b)
						H, S, V = col:ToHSV()
						applyColor()
					end
				end
			end)

			applyColor()

			preview.MouseButton1Click:Connect(function()
				open = not open
				if open then
					panel.Visible = true
					tween(panel, { Size = UDim2.new(1, 0, 0, 162) }, TWEEN_SLOW)
					tween(row, { Size = UDim2.new(1, 0, 0, 42 + 168) }, TWEEN_SLOW)
				else
					tween(panel, { Size = UDim2.new(1, 0, 0, 0) }, TWEEN_SLOW)
					tween(row, { Size = UDim2.new(1, 0, 0, 42) }, TWEEN_SLOW)
					task.delay(0.3, function() panel.Visible = false end)
				end
			end)

			local Component = { Value = col }
			function Component:Set(c)
				col = c; H, S, V = c:ToHSV(); applyColor()
			end
			return Component
		end

		-- AddKeybind
		function Section:AddKeybind(opts)
			opts = opts or {}
			local key = opts.Default or Enum.KeyCode.Unknown
			local cb = opts.Callback or function() end
			local listening = false

			local row = rowBase(42)

			create("TextLabel", {
				Parent = row,
				Text = opts.Name or "Keybind",
				TextColor3 = THEME.Text,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -90, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 4,
			})

			local KeyBtn = create("TextButton", {
				Parent = row,
				BackgroundColor3 = THEME.Elevated,
				Size = UDim2.new(0, 80, 0, 24),
				Position = UDim2.new(1, -80, 0.5, -12),
				Text = key.Name,
				TextColor3 = THEME.Accent,
				TextSize = 11,
				Font = Enum.Font.GothamBold,
				ZIndex = 4,
				AutoButtonColor = false,
			})
			corner(KeyBtn, 6)
			stroke(KeyBtn, THEME.Border, 1)

			KeyBtn.MouseButton1Click:Connect(function()
				listening = true
				KeyBtn.Text = "..."
				KeyBtn.TextColor3 = THEME.TextSecondary
			end)

			UserInputService.InputBegan:Connect(function(i, gpe)
				if not listening then return end
				if i.UserInputType == Enum.UserInputType.Keyboard then
					listening = false
					key = i.KeyCode
					KeyBtn.Text = key.Name
					KeyBtn.TextColor3 = THEME.Accent
					cb(key)
				end
			end)

			local Component = { Value = key }
			function Component:Set(k)
				key = k; KeyBtn.Text = k.Name
			end
			return Component
		end

		-- AddLabel
		function Section:AddLabel(text)
			local row = rowBase(34)
			create("TextLabel", {
				Parent = row,
				Text = text or "",
				TextColor3 = THEME.TextSecondary,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				ZIndex = 4,
			})
			return {}
		end

		-- AddParagraph
		function Section:AddParagraph(title, body)
			local row = create("Frame", {
				Parent = Section.Container,
				BackgroundColor3 = THEME.Surface,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 3,
			})
			padding(row, 8, 8, 14, 14)
			create("UIListLayout", {
				Parent = row,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2),
			})
			create("TextLabel", {
				Parent = row,
				Text = title or "",
				TextColor3 = THEME.Text,
				TextSize = 13,
				Font = Enum.Font.GothamBold,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 4,
			})
			create("TextLabel", {
				Parent = row,
				Text = body or "",
				TextColor3 = THEME.TextSecondary,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				ZIndex = 4,
			})
			return {}
		end

		return Section
	end

	return Methods
end

function Vaeltha:SelectTab(Tab)
	if self.ActiveTab then
		self.ActiveTab.Frame.Visible = false
		self.ActiveTab.Active = false
		tween(self.ActiveTab.Button, { BackgroundTransparency = 1 })
		tween(self.ActiveTab.Label, { TextColor3 = THEME.TextSecondary, Font = Enum.Font.Gotham })
		self.ActiveTab.Indicator.Visible = false
	end
	self.ActiveTab = Tab
	Tab.Active = true
	Tab.Frame.Visible = true
	tween(Tab.Button, { BackgroundTransparency = 0.78, BackgroundColor3 = THEME.Surface })
	tween(Tab.Label, { TextColor3 = THEME.Text })
	Tab.Label.Font = Enum.Font.GothamBold
	Tab.Indicator.Visible = true
end

function Vaeltha:Notify(opts)
	opts = opts or {}
	local duration = opts.Duration or 4

	local GUI = self.GUI
	local notif = create("Frame", {
		Parent = GUI,
		BackgroundColor3 = THEME.Surface,
		Size = UDim2.new(0, 280, 0, 0),
		Position = UDim2.new(1, -295, 1, -10),
		AnchorPoint = Vector2.new(0, 1),
		ZIndex = 100,
		ClipsDescendants = true,
		AutomaticSize = Enum.AutomaticSize.None,
	})
	corner(notif, 10)
	stroke(notif, opts.Type == "Error" and THEME.Danger or THEME.BorderAccent, 1)

	local inner = create("Frame", {
		Parent = notif,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 70),
		ZIndex = 101,
	})
	padding(inner, 10, 10, 14, 14)
	create("UIListLayout", {
		Parent = inner,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 3),
	})

	create("TextLabel", {
		Parent = inner,
		Text = opts.Title or "Notification",
		TextColor3 = THEME.Text,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 102,
	})
	create("TextLabel", {
		Parent = inner,
		Text = opts.Content or "",
		TextColor3 = THEME.TextSecondary,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 30),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		ZIndex = 102,
	})

	-- progress bar
	local bar = create("Frame", {
		Parent = notif,
		BackgroundColor3 = opts.Type == "Error" and THEME.Danger or THEME.Accent,
		Size = UDim2.new(1, 0, 0, 3),
		Position = UDim2.new(0, 0, 1, -3),
		ZIndex = 103,
	})
	corner(bar, 99)

	tween(notif, { Size = UDim2.new(0, 280, 0, 76) }, TWEEN_SLOW)
	task.delay(0.3, function()
		tween(bar, { Size = UDim2.new(0, 0, 0, 3) }, TweenInfo.new(duration, Enum.EasingStyle.Linear))
	end)
	task.delay(duration + 0.3, function()
		tween(notif, { Size = UDim2.new(0, 280, 0, 0), BackgroundTransparency = 1 }, TWEEN_SLOW)
		task.delay(0.3, function() notif:Destroy() end)
	end)
end

function Vaeltha:SetTheme(custom)
	for k, v in custom do THEME[k] = v end
end

return Vaeltha
