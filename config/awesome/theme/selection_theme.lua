-- requirements
-- ~~~~~~~~~~~~
local awful         = require("awful")
local gears         = require("gears")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local xresources	= require("beautiful.xresources")
local dpi           = xresources.apply_dpi
local helpers       = require("helpers")


-- icons
local icons = {
    dark = {
		outline = "",
		glyph = ""
	},
    light = {
		outline = "",
		glyph = "盛"
	},
}

local change_dark_theme = function ()
    awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "scripts/themes/dark")
    awesome.emit_signal('module::theme_screen:hide')
    awesome.restart()
end

local change_light_theme = function ()    
    awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "scripts/themes/light")
    awesome.emit_signal('module::theme_screen:hide')
    awesome.restart()
end

local cr_btn = require("widgets.button").create
local dark  = cr_btn(icons.dark.outline, dpi(100), dpi(0), beautiful.bg, beautiful.icon_normal, beautiful.red, change_dark_theme)
local light = cr_btn(icons.light.outline, dpi(100), dpi(0), beautiful.bg, beautiful.icon_normal, beautiful.red, change_light_theme)

local theme_list = function(s)
	s.theme_screen = wibox{
		screen 	= s,
		type 	= 'splash',
		visible = false,
		ontop 	= true,
		bg 		= beautiful.transparent .. "80",
		fg 		= beautiful.foreground,
		height 	= s.geometry.height,
		width 	= s.geometry.width,
		x 		= s.geometry.x,
		y 		= s.geometry.y
	}

    s.theme_screen:buttons(gears.table.join(awful.button(
				{}, 2, function()
					awesome.emit_signal('module::theme_screen:hide')
				end),

			awful.button(
				{}, 3, function()
					awesome.emit_signal('module::theme_screen:hide')
				end
			)
		)
	)


-- a


    s.theme_screen:setup {
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

end


screen.connect_signal('request::desktop_decoration',
	function(s)
		theme_list(s)
	end
)

screen.connect_signal('removed',
	function(s)
		theme_list(s)
	end
)

local exit_screen_grabber = awful.keygrabber {
	auto_start = true,
	stop_event = 'release',
	keypressed_callback = function(self, mod, key, command)
		if key == 's' then
			suspend_command()

		elseif key == 'e' then
			exit_command()

		elseif key == 'p' then
			poweroff_command()

		elseif key == 'r' then
			reboot_command()

		elseif key == 'Escape' or key == 'q' or key == 'v' then
			awesome.emit_signal('module::theme_screen:hide')
		end
	end
}

awesome.connect_signal(
	'module::theme_screen:show',
	function()
		for s in screen do
			s.theme_screen.visible = false
		end
		awful.screen.focused().theme_screen.visible = true
		exit_screen_grabber:start()
	end
)

awesome.connect_signal(
	'module::theme_screen:hide',
	function()
		exit_screen_grabber:stop()
		for s in screen do
			s.theme_screen.visible = false
		end
	end
)