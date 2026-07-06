-- Tiered TweenInfo presets, replacing the single flat `Library.TweenInfo` that used to drive
-- every animation in the library (hover colors, toggle switches, tab changes, window open/close,
-- notifications) with one identical 0.1s Quad-Out curve. Different interactions now get curves
-- that actually match their weight.

local Presets = {}

-- Fast, snappy - hover/press color changes, small UI feedback.
Presets.Micro = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Toggles, checkboxes, tab switches, sliders - a slight overshoot for a "satisfying" feel.
Presets.Standard = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Window/dialog/keybind-panel open-close - slower, same overshoot family as Standard.
Presets.Macro = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Notification slide-in/out.
Presets.Notify = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Linear fills - progress bars, timers.
Presets.Boot = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

-- Press-down / release-back for the per-element press-scale effect.
Presets.Press = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
Presets.Release = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

return Presets
