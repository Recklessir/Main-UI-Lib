-- Black/Yellow "techy" default palette for the library.
-- Consumed by Core/Library.lua to seed `Library.Scheme` and the default fonts.
-- Keep the key set identical to the legacy scheme (ThemeManager/SaveManager depend on the
-- exact names: FontColor, MainColor, AccentColor, BackgroundColor, OutlineColor, RedColor,
-- DestructiveColor, DarkColor, WhiteColor) plus the new MonoFont alias.

local Palette = {}

Palette.Scheme = {
	BackgroundColor = Color3.fromRGB(8, 8, 10),
	MainColor = Color3.fromRGB(18, 18, 20),
	AccentColor = Color3.fromRGB(255, 214, 10),
	OutlineColor = Color3.fromRGB(58, 50, 10),
	FontColor = Color3.fromRGB(232, 232, 226),

	RedColor = Color3.fromRGB(255, 70, 70),
	DestructiveColor = Color3.fromRGB(220, 38, 38),
	DarkColor = Color3.new(0, 0, 0),
	WhiteColor = Color3.new(1, 1, 1),

	Font = Font.fromEnum(Enum.Font.GothamMedium),
	MonoFont = Font.fromEnum(Enum.Font.Code),
	TitleFont = Font.fromEnum(Enum.Font.GothamBold),

	BackgroundImageEnabled = false,
	BackgroundImage = "",
	WindowGlow = true,
}

return Palette
