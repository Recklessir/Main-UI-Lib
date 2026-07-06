-- "Juicy" interaction helpers - press-scale feedback, an activation pulse burst for toggles/
-- checkboxes, and a scale-based open/close for the main window and keybind panel. These operate
-- on plain Instances via injected TweenService/TweenInfo so this module has no dependency on
-- the library's internals.

local Juice = {}

---Wires press-down/release-back scale feedback onto `Instance` via a dedicated, uniquely-named
---UIScale (kept separate from any DPI-scaling UIScale already on the instance). Returns the
---RBXScriptConnections created so the caller can register them with `Library:GiveSignal` for
---proper cleanup on Unload.
function Juice.PressScale(Instance, TweenService, PressInfo, ReleaseInfo, opts)
	opts = opts or {}
	local ScaleDown = opts.Scale or 0.97

	local Scale = Instance:FindFirstChild("PressScale")
	if not Scale then
		Scale = Instance.new("UIScale")
		Scale.Name = "PressScale"
		Scale.Parent = Instance
	end

	local function Press()
		TweenService:Create(Scale, PressInfo, { Scale = ScaleDown }):Play()
	end

	local function Release()
		TweenService:Create(Scale, ReleaseInfo, { Scale = 1 }):Play()
	end

	local Connections = {}

	table.insert(
		Connections,
		Instance.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Press()
			end
		end)
	)

	table.insert(
		Connections,
		Instance.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Release()
			end
		end)
	)

	table.insert(Connections, Instance.MouseLeave:Connect(Release))

	return Connections
end

---Fires a one-shot radial glow burst centered on `Parent` - the "rewarding click" feedback for
---toggles/checkboxes. Self-destroys once the tween completes.
function Juice.ActivationPulse(Parent, TweenService, GlowAssetId, AccentColor, opts)
	if not GlowAssetId then
		return
	end

	opts = opts or {}

	local Burst = Instance.new("ImageLabel")
	Burst.Name = "ActivationPulse"
	Burst.BackgroundTransparency = 1
	Burst.Image = GlowAssetId
	Burst.ImageColor3 = AccentColor
	Burst.ImageTransparency = 0.2
	Burst.AnchorPoint = opts.AnchorPoint or Vector2.new(0.5, 0.5)
	Burst.Position = opts.Position or UDim2.fromScale(0.5, 0.5)
	Burst.Size = opts.StartSize or UDim2.fromScale(0.6, 0.6)
	Burst.ZIndex = opts.ZIndex or 5
	Burst.Parent = Parent

	local PulseInfo = opts.TweenInfo or TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local Tween = TweenService:Create(Burst, PulseInfo, {
		Size = opts.EndSize or UDim2.fromScale(1.6, 1.6),
		ImageTransparency = 1,
	})

	Tween.Completed:Connect(function()
		Burst:Destroy()
	end)
	Tween:Play()
end

---Layout-safe click feedback: briefly intensifies a UIStroke's color/thickness then eases back.
---Unlike PressScale this never touches Size/UIScale, so it's safe on buttons that share a row
---with siblings under a `HorizontalFlex = Fill` UIListLayout, where a scale change would nudge
---AbsoluteSize and cause the whole row to jitter/reflow.
function Juice.ClickFlash(Stroke, TweenService, TweenInfoPreset, FlashColor, opts)
	opts = opts or {}
	local FlashThickness = opts.Thickness or (Stroke.Thickness + 1)
	local RestThickness = Stroke.Thickness
	local RestColor = opts.RestColor or Stroke.Color

	TweenService:Create(Stroke, opts.FlashInfo or TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Color = FlashColor,
		Thickness = FlashThickness,
	}):Play()

	task.delay((opts.FlashInfo and opts.FlashInfo.Time) or 0.06, function()
		TweenService:Create(Stroke, TweenInfoPreset, {
			Color = RestColor,
			Thickness = RestThickness,
		}):Play()
	end)
end

---Scale-based open/close, used for the main window's Visible flip and the keybind panel instead
---of an instant cut. Uses a dedicated, uniquely-named UIScale so it never fights with the
---library's DPI-scaling UIScale on the same frame.
function Juice.OpenClose(Frame, Opening, TweenService, TweenInfoPreset, opts)
	opts = opts or {}
	local ClosedScale = opts.ClosedScale or 0.9

	local Scale = Frame:FindFirstChild("OpenCloseScale")
	if not Scale then
		Scale = Instance.new("UIScale")
		Scale.Name = "OpenCloseScale"
		Scale.Parent = Frame
	end

	if Opening then
		Scale.Scale = ClosedScale
		Frame.Visible = true
		TweenService:Create(Scale, TweenInfoPreset, { Scale = 1 }):Play()
	else
		local Tween = TweenService:Create(Scale, TweenInfoPreset, { Scale = ClosedScale })
		Tween.Completed:Connect(function()
			Frame.Visible = false
			Scale.Scale = 1
		end)
		Tween:Play()
	end
end

return Juice
