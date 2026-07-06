-- Animated boot bar for the executor console (rconsole), matching the requested
-- `0%[====      ]100% | message` shape and actually animating frame-by-frame instead of a
-- single static print. Falls back to a handful of stepped `print()` lines when rconsole isn't
-- available (e.g. running in Roblox Studio), since the default output can't overwrite a line.

local BootConsole = {}

local BAR_WIDTH = 24

local DEFAULT_STEPS = {
	{ Percent = 0, Message = "Initializing..." },
	{ Percent = 20, Message = "Loading modules..." },
	{ Percent = 45, Message = "Applying theme..." },
	{ Percent = 70, Message = "Building interface..." },
	{ Percent = 90, Message = "Finalizing..." },
	{ Percent = 100, Message = "Now executing..." },
}

local function BuildBar(Percent)
	local Filled = math.floor((Percent / 100) * BAR_WIDTH)
	return string.rep("=", Filled) .. string.rep(" ", BAR_WIDTH - Filled)
end

local function MessageFor(Steps, Percent)
	local Message = Steps[1] and Steps[1].Message or ""
	for _, Step in Steps do
		if Percent >= Step.Percent then
			Message = Step.Message
		end
	end
	return Message
end

---Runs the animated boot bar. `Steps` is an optional list of `{ Percent, Message }` checkpoints
---(ascending, last one should be 100) - defaults to a generic sweep.
function BootConsole.Run(Steps, opts)
	opts = opts or {}
	Steps = Steps or DEFAULT_STEPS

	local HasRConsole = typeof(rconsolecreate) == "function" and typeof(rconsoleprint) == "function"
	local HasClear = typeof(rconsoleclear) == "function"

	if HasRConsole then
		pcall(rconsolecreate)
		if typeof(rconsolesettitle) == "function" then
			pcall(rconsolesettitle, opts.Title or "Booting")
		end
	end

	local TotalTime = opts.TotalTime or 1.6
	local FrameTime = opts.FrameTime or 0.05
	local Frames = math.max(1, math.floor(TotalTime / FrameTime))

	local LastPrintedTenth = -1
	for Frame = 0, Frames do
		local Percent = math.floor((Frame / Frames) * 100)
		local Message = MessageFor(Steps, Percent)
		local Line = ("%d%%[%s]100%% | %s"):format(Percent, BuildBar(Percent), Message)

		if HasRConsole then
			if HasClear then
				pcall(rconsoleclear)
			end
			pcall(rconsoleprint, Line .. "\n")
		else
			local Tenth = math.floor(Percent / 10)
			if Tenth ~= LastPrintedTenth then
				LastPrintedTenth = Tenth
				print(Line)
			end
		end

		task.wait(FrameTime)
	end

	local FinalMessage = Steps[#Steps] and Steps[#Steps].Message or "Now executing..."
	local FinalLine = ("100%%[%s]100%% | %s"):format(BuildBar(100), FinalMessage)

	if HasRConsole then
		if HasClear then
			pcall(rconsoleclear)
		end
		pcall(rconsoleprint, FinalLine .. "\n")
	else
		print(FinalLine)
	end
end

return BootConsole
