local filesystem = require("gears.filesystem")
local config_dir = filesystem.get_configuration_dir()
local utils_dir = config_dir .. "scripts/utils/"

return {
	-- List of binaries/shell scripts that will execute for a certain task
	utils = {
		-- Fullscreen screenshot
		full_screenshot = utils_dir .. "scrott full",
		-- Area screenshot
		area_screenshot = utils_dir .. "scrott area",
		-- screenrect
		recorded = utils_dir .. "recorded",
		-- blue light
		blue_light = utils_dir .. "bluelight",
		-- bluetooth
		bluetooth = utils_dir .. "bluetooth",
		-- unmute microphone
		unmute = utils_dir .. "unmute",
		-- pick_color
		color_pick = utils_dir .. "xcolor"
	},
}
