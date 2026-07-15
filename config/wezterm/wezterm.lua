local wezterm = require("wezterm")
local so = require("utils.platform")

-- This will hold the configuration.
local config = wezterm.config_builder()

local font_family = "DankMono Nerd Font"

local font_size = so.is_win and 14 or 12

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- matugen generate color_scheme
config.color_scheme = "matugen_theme"

-- disable wayland from Xwayland
config.enable_wayland = false

-- config fonts
config.font = wezterm.font({ family = font_family, weight = "Medium" })
config.font_size = font_size
config.adjust_window_size_when_changing_font_size = false
config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"
config.anti_alias_custom_block_glyphs = true
config.underline_position = -2.5
config.underline_thickness = "2px"
config.warn_about_missing_glyphs = false

--ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
config.freetype_load_target = "Normal" ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
config.freetype_render_target = "Normal" ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'

-- Appearance
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 8,
	right = 8,
	top = 8,
	bottom = 8,
}

config.window_background_opacity = 0.75

--  blur apply
if so.is_linux then
	config.macos_window_background_blur = 8
end

return config
