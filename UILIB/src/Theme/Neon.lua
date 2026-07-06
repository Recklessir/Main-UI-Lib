-- Real "neon outline" recipe: a thin bright UIStroke plus a soft glow image behind the frame,
-- with a slow opacity "breathe" so it reads as alive instead of a flat colored border.
--
-- `NewFn` must be the library's private instance builder (`New(ClassName, Properties)`) so
-- string scheme aliases ("AccentColor", "OutlineColor", ...) keep resolving live when the user
-- swaps themes at runtime via ThemeManager - see Core/Library.lua's FillInstance/GetSchemeValue.

local Neon = {}

Neon.Defaults = {
	Thickness = 1,
	OutlineTransparency = 0.25,
	ShadowThickness = 2,
	ShadowTransparency = 0.4,
	GlowPadding = 28,
	GlowTransparency = 0.8,
	BreatheAmplitude = 0.12,
	BreatheTime = 2.4,
}

---Adds a neon-style outline to `Frame`. Returns (OutlineStroke, ShadowStroke) to stay
---source-compatible with the legacy `Library:AddOutline(Frame)` contract.
---@param NewFn (ClassName: string, Properties: table) -> Instance
---@param Frame GuiObject
---@param GlowAssetId string? -- pass nil to skip the glow image (stroke-only outline)
---@param TweenService TweenService?
function Neon.Apply(NewFn, Frame, GlowAssetId, TweenService, opts)
	opts = opts or {}
	-- `StrokeAlias` colors the thin border (defaults to AccentColor for standalone use).
	-- `GlowAlias` colors the backglow image - kept separate so a call site can have a subdued
	-- border (e.g. OutlineColor) while still popping a bright AccentColor glow behind it.
	local StrokeAlias = opts.StrokeAlias or opts.AccentAlias or "AccentColor"
	local GlowAlias = opts.GlowAlias or opts.AccentAlias or "AccentColor"

	local OutlineStroke = NewFn("UIStroke", {
		Color = StrokeAlias,
		Transparency = opts.OutlineTransparency or Neon.Defaults.OutlineTransparency,
		Thickness = opts.Thickness or Neon.Defaults.Thickness,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		ZIndex = 2,
		Parent = Frame,
	})

	local ShadowStroke = NewFn("UIStroke", {
		Color = "DarkColor",
		Transparency = opts.ShadowTransparency or Neon.Defaults.ShadowTransparency,
		Thickness = opts.ShadowThickness or Neon.Defaults.ShadowThickness,
		ZIndex = 1,
		Parent = Frame,
	})

	if GlowAssetId then
		local Padding = opts.GlowPadding or Neon.Defaults.GlowPadding
		local BaseTransparency = opts.GlowTransparency or Neon.Defaults.GlowTransparency

		local Glow = NewFn("ImageLabel", {
			Name = "NeonGlow",
			BackgroundTransparency = 1,
			Image = GlowAssetId,
			ImageColor3 = GlowAlias,
			ImageTransparency = BaseTransparency,
			Position = UDim2.fromOffset(-Padding / 2, -Padding / 2),
			Size = UDim2.new(1, Padding, 1, Padding),
			ZIndex = 0,
			Parent = Frame,
		})

		if TweenService and opts.Animate ~= false then
			local Amplitude = opts.BreatheAmplitude or Neon.Defaults.BreatheAmplitude
			local BreatheInfo = TweenInfo.new(
				opts.BreatheTime or Neon.Defaults.BreatheTime,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut,
				-1,
				true
			)
			TweenService:Create(Glow, BreatheInfo, {
				ImageTransparency = math.clamp(BaseTransparency + Amplitude, 0, 1),
			}):Play()
		end
	end

	return OutlineStroke, ShadowStroke
end

return Neon
