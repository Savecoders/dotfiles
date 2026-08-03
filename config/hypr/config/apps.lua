-- ▗▄▖ ▗▄▄▖ ▗▄▄▖  ▗▄▄▖
-- ▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▌
-- ▐▛▀▜▌▐▛▀▘ ▐▛▀▘  ▝▀▚▖
-- ▐▌ ▐▌▐▌   ▐▌   ▗▄▄▞▘

-- Set programs that you use
local terminal = "kitty"
local fileManager = "thunar"
local menu = "vicinae open"
local screenshot = os.getenv("HOME") .. "/.config/hypr/scripts/screenshot.sh"
local ocr = os.getenv("HOME") .. "/.config/hypr/scripts/ocr-screenshot.sh"
local code = "zeditor"
local browser = "zen-browser"
local notes = "obsidian"

return {
	terminal = terminal,
	fileManager = fileManager,
	menu = menu,
	screenshot = screenshot,
	ocr = ocr,
	code = code,
	broswer = browser,
	notes = notes,
}
