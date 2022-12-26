
-- requirements
-- ~~~~~~~~~~~~
local awful         = require("awful")
local gears         = require("gears")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local xresources	= require("beautiful.xresources")
local dpi           = xresources.apply_dpi
local helpers       = require("helpers")

-- misc/vars
-- ~~~~~~~~~

-- icons
local icons = {
    poweroff = "",
    suspend  = "",
    reboot   = "",
    exit     = ""
}

-- Commands
local poweroff_command = function()
	awful.spawn.with_shell("systemctl poweroff")
	awesome.emit_signal('module::exit_screen:hide')
end

local reboot_command = function() 
	awful.spawn.with_shell("systemctl reboot")
	awesome.emit_signal('module::exit_screen:hide')
end

local suspend_command = function()
	awesome.emit_signal('module::exit_screen:hide')
    awful.spawn("betterlockscreen -l")
end

local exit_command = function() awesome.quit() end


-- helper function for buttons
local cr_btn = require("widgets.button").create

-- Widgets themselves
-- ~~~~~~~~~~~~~~~~~~

-- Create the buttons
local poweroff  = cr_btn(icons.poweroff, dpi(100), dpi(0), beautiful.icon_var .. "22", beautiful.bg,beautiful.icon_normal, beautiful.red, poweroff_command)
local reboot    = cr_btn(icons.reboot, dpi(100), dpi(0), beautiful.icon_var .. "22", beautiful.bg,beautiful.icon_normal, beautiful.red, reboot_command)
local suspend   = cr_btn(icons.suspend,dpi(100), dpi(0), beautiful.icon_var .. "22", beautiful.bg,beautiful.icon_normal, beautiful.red, suspend_command)
local exit      = cr_btn(icons.exit, dpi(100), dpi(0), beautiful.icon_var .. "22", beautiful.bg,beautiful.icon_normal, beautiful.red, exit_command)

-- exit screen
local exit_screen_f = function(s)
	s.exit_screen = wibox{
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

    s.exit_screen:buttons(gears.table.join(awful.button(
				{}, 2, function()
					awesome.emit_signal('module::exit_screen:hide')
				end),

			awful.button(
				{}, 3, function()
					awesome.emit_signal('module::exit_screen:hide')
				end
			)
		)
	)





    s.exit_screen:setup {
		nil,
		{
			nil,
			{
				{
					{
						{
							exit,
							suspend,
							spacing = dpi(20),
							layout = wibox.layout.fixed.horizontal
						},
						{
							reboot,
							poweroff,
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
		exit_screen_f(s)
	end
)

screen.connect_signal('removed',
	function(s)
		exit_screen_f(s)
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
			awesome.emit_signal('module::exit_screen:hide')
		end
	end
}

awesome.connect_signal(
	'module::exit_screen:show',
	function()
		for s in screen do
			s.exit_screen.visible = false
		end
		awful.screen.focused().exit_screen.visible = true
		exit_screen_grabber:start()
	end
)

awesome.connect_signal(
	'module::exit_screen:hide',
	function()
		exit_screen_grabber:stop()
		for s in screen do
			s.exit_screen.visible = false
		end
	end
)