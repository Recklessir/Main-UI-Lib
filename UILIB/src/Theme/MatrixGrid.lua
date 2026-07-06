-- Restrained wireframe grid + a single slow top-to-bottom scanline, parented behind the main
-- window's content. This is the "techy/matrixy" background texture - deliberately subtle
-- (near-90% transparent lines) so it reads as professional texture, not a flashy overlay.

local MatrixGrid = {}

MatrixGrid.Defaults = {
	Columns = 14,
	Rows = 10,
	LineTransparency = 0.92,
	ScanTransparency = 0.55,
	ScanThickness = 2,
	ScanTime = 5,
}

---Builds the grid + scanline inside `Parent`. `NewFn` is the library's private instance builder
---so "OutlineColor"/"AccentColor" scheme aliases keep resolving live across theme swaps.
---Returns the container Frame so callers can Destroy/reparent it (e.g. on Unload).
function MatrixGrid.Build(NewFn, Parent, TweenService, opts)
	opts = opts or {}
	local Columns = opts.Columns or MatrixGrid.Defaults.Columns
	local Rows = opts.Rows or MatrixGrid.Defaults.Rows
	local LineTransparency = opts.LineTransparency or MatrixGrid.Defaults.LineTransparency

	local Container = NewFn("Frame", {
		Name = "MatrixGrid",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		ZIndex = 0,
		Parent = Parent,
	})

	for Index = 1, Columns - 1 do
		NewFn("Frame", {
			Name = "GridColumn",
			BackgroundColor3 = opts.LineAlias or "OutlineColor",
			BackgroundTransparency = LineTransparency,
			BorderSizePixel = 0,
			Position = UDim2.new(Index / Columns, 0, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			ZIndex = 0,
			Parent = Container,
		})
	end

	for Index = 1, Rows - 1 do
		NewFn("Frame", {
			Name = "GridRow",
			BackgroundColor3 = opts.LineAlias or "OutlineColor",
			BackgroundTransparency = LineTransparency,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, Index / Rows, 0),
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = 0,
			Parent = Container,
		})
	end

	local Scanline = NewFn("Frame", {
		Name = "Scanline",
		BackgroundColor3 = opts.ScanAlias or "AccentColor",
		BackgroundTransparency = opts.ScanTransparency or MatrixGrid.Defaults.ScanTransparency,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, -0.05, 0),
		Size = UDim2.new(1, 0, 0, opts.ScanThickness or MatrixGrid.Defaults.ScanThickness),
		ZIndex = 0,
		Parent = Container,
	})

	if TweenService then
		local ScanInfo = TweenInfo.new(
			opts.ScanTime or MatrixGrid.Defaults.ScanTime,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.InOut,
			-1,
			false
		)
		TweenService:Create(Scanline, ScanInfo, {
			Position = UDim2.new(0, 0, 1.05, 0),
		}):Play()
	end

	return Container
end

return MatrixGrid
