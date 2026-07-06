// Bundles UILIB/src/**/*.lua into the single distributable UILIB/Library.lua.
//
// Why: the library ships to Roblox via loadstring(game:HttpGet(repo.."Library.lua"))() (see
// Example.lua) - one HTTP fetch, one chunk. Luau has no `require` across HttpGet'd strings, so
// splitting the *source* into readable modules only works if we stitch them back into one file
// at build time. Each module in MODULE_ORDER is wrapped as `local <Name> = (function() ... end)()`
// so it's just an upvalue by the time Core/Library.lua's body (appended verbatim, unwrapped,
// since it ends with `return Library`) runs.
//
// Usage: node build/bundle.js

const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const SRC = path.join(ROOT, "src");
const OUT = path.join(ROOT, "Library.lua");

// Order matters only in that later modules could reference earlier ones - none currently do,
// but keep Theme/Animation before Intro/Core for readability of the generated file.
const MODULE_ORDER = [
	{ name: "ThemePalette", file: "Theme/Palette.lua" },
	{ name: "ThemeNeon", file: "Theme/Neon.lua" },
	{ name: "ThemeMatrixGrid", file: "Theme/MatrixGrid.lua" },
	{ name: "AnimationPresets", file: "Animation/Presets.lua" },
	{ name: "AnimationJuice", file: "Animation/Juice.lua" },
	{ name: "IntroBootConsole", file: "Intro/BootConsole.lua" },
	{ name: "IntroBootScreen", file: "Intro/BootScreen.lua" },
];

const CORE_FILE = "Core/Library.lua";

function readSrc(relativePath) {
	const fullPath = path.join(SRC, relativePath);
	return fs.readFileSync(fullPath, "utf8").replace(/\r\n/g, "\n");
}

function buildModuleBlock(moduleName, source) {
	return [
		`-- ==== module: ${moduleName} ====`,
		`local ${moduleName} = (function()`,
		source.replace(/\s+$/, ""),
		"end)()",
		"",
	].join("\n");
}

function build() {
	const parts = [];

	parts.push(
		"-- GENERATED FILE - do not edit directly.",
		"-- Source lives in UILIB/src/. Regenerate with: node build/bundle.js",
		""
	);

	for (const mod of MODULE_ORDER) {
		const source = readSrc(mod.file);
		parts.push(buildModuleBlock(mod.name, source));
	}

	parts.push("-- ==== Core/Library.lua ====");
	parts.push(readSrc(CORE_FILE).replace(/\s+$/, ""));
	parts.push("");

	const output = parts.join("\n");
	fs.writeFileSync(OUT, output, "utf8");

	console.log(`Wrote ${OUT} (${output.length} bytes, ${MODULE_ORDER.length} modules + Core).`);
}

build();
