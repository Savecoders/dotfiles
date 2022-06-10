-- requirements
-- ~~~~~~~~~~~~
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local rubato = require("modules.rubato")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")

-- icons
local icons = {
    dark = {
        outline = "",
        glyph = ""
    },
    light = {
        outline = "",
        glyph = "盛"
    }
}

local change_dark_theme = function()
    awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "scripts/themes/dark")
    awesome.restart()
end

local change_light_theme = function()
    awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "scripts/themes/light")
    awesome.restart()
end

local cr_btn = require("widgets.button").create
local dark = cr_btn(icons.dark.outline, dpi(100), dpi(0), beautiful.bg, beautiful.icon_normal, beautiful.red,
    change_dark_theme)
local light = cr_btn(icons.light.outline, dpi(100), dpi(0), beautiful.bg, beautiful.icon_normal, beautiful.red,
    change_light_theme)

local theme_screen = wibox({
    type = "popup_menu",
    height = dpi(120),
    width = dpi(280),
    shape = helpers.rrect(beautiful.border_radius),
    bg = beautiful.bg_sidebar, -- active
    halign  = "center",
	valign  = "center",
	ontop   = true,
	visible = false,
})

awful.placement.centered(theme_screen, {
    margins = {
        center = beautiful.useless_gap * 2
    }
})

theme_screen:setup {
	nil,
	{
		nil,
		{
			{
				{
					
					{
						dark,
						light,
						spacing = dpi(20),
						layout = wibox.layout.fixed.horizontal
					},
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(20)
				},
				widget = wibox.container.margin,
				margins = dpi(15)
			},
			widget = wibox.container.background,
			bg = beautiful.bg,
			shape = helpers.rrect(beautiful.bar_radius)
		},
		layout = wibox.layout.align.vertical,
		expand = "none"
	},
	expand = "none",
	layout = wibox.layout.align.horizontal
}

theme_toogle  = function()
    if theme_screen.visible == false then
        theme_screen.visible = not theme_screen.visible
        theme_screen.target = dpi(130)
    else
        theme_screen.target = -dpi(140)
        theme_screen.visible = false
    end
end