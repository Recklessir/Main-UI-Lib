-- Helper builders consumed by Core/Library.lua's `Library:CreateLoading` to give the on-screen
-- boot UI a terminal-style log panel and a glowing leading edge on the progress fill, instead of
-- a plain spinner + flat bar. `NewFn` is the library's private instance builder so scheme alias
-- strings (e.g. "AccentColor") keep resolving live across theme swaps.

local BootScreen = {}

---Pins a small glow image to the right edge of `FillFrame` (parented as its child, so it tracks
---the bar's width automatically as the fill tweens - no extra connections needed).
function BootScreen.AddGlowingLeadingEdge(NewFn, FillFrame, GlowAssetId, opts)
	if not GlowAssetId then
		return
	end
	opts = opts or {}

	return NewFn("ImageLabel", {
		Name = "LeadingGlow",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = opts.Size or UDim2.fromOffset(24, 24),
		Image = GlowAssetId,
		ImageColor3 = opts.AccentAlias or "AccentColor",
		ImageTransparency = opts.Transparency or 0.35,
		ZIndex = 5,
		Parent = FillFrame,
	})
end

---Builds a small auto-scrolling, monospace "terminal" log panel. Returns a Terminal table with
---an `:Append(text)` method that adds a line (prefixed "> "), auto-scrolls to bottom, and caps
---to `MaxLines` (dropping the oldest) so it never grows unbounded during a long boot sequence.
---`opts.TextColor` may be a scheme alias string or a `() -> Color3` function (e.g. one that
---derives from AccentColor) so the log keeps following theme swaps like the rest of the UI.
function BootScreen.CreateTerminalLog(NewFn, Parent, opts)
	opts = opts or {}
	local MaxLines = opts.MaxLines or 6
	local TextColor = opts.TextColor or "FontColor"

	local LogFrame = NewFn("ScrollingFrame", {
		Name = "BootTerminal",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = opts.Size or UDim2.fromScale(1, 1),
		Position = opts.Position or UDim2.fromScale(0, 0),
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = Parent,
	})

	NewFn("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = LogFrame,
	})

	local Terminal = { Frame = LogFrame, Lines = {} }

	function Terminal:Append(Text)
		local Line = NewFn("TextLabel", {
			Name = "LogLine",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 14),
			Text = "> " .. Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 12,
			FontFace = "MonoFont",
			TextColor3 = TextColor,
			LayoutOrder = #self.Lines + 1,
			Parent = LogFrame,
		})

		table.insert(self.Lines, Line)

		if #self.Lines > MaxLines then
			local Oldest = table.remove(self.Lines, 1)
			Oldest:Destroy()
		end

		task.defer(function()
			LogFrame.CanvasPosition = Vector2.new(0, math.huge)
		end)
	end

	return Terminal
end

return BootScreen
