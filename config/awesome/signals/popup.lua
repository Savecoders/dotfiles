-- AAApopup notif
-- ~~~~~~~~~~~
-- uses rubato for smooth animations

-- requirements
-- ~~~~~~~~~~~~
local awful         = require("awful")
local gears         = require("gears")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local rubato		= require("modules.rubato")
local dpi           = beautiful.xresources.apply_dpi
local helpers       = require("helpers")
local volume_arc 	= require("widgets.volume_arc")


-- widgets themselves
-- ~~~~~~~~~~~~~~~~~~

local circle_animate = wibox.widget{
	widget = wibox.container.background,
	shape = helpers.rrect(beautiful.border_radius),
	bg = beautiful.accent,
	forced_width = 0,
	forced_height = 0,
}

-- actual popup
local pop = wibox({
	type    = "popup_menu",
	height  = dpi(160),
	width   = dpi(160),
	shape   = helpers.rrect(beautiful.border_radius),
	bg      = beautiful.bg_widget,--active
	halign  = "center",
	valign  = "center",
	ontop   = true,
	visible = false,
})

-- placement
awful.placement.centered(pop, {margins = {center = beautiful.useless_gap * 2}})

-- timeout
local timeout = gears.timer({
	autostart   = true,
	timeout     = 2,
	callback    = function()
		        pop.visible = false
	end,
})

local function toggle_pop()
	if pop.visible then
		timeout:again()
	else
		pop.visible = true
		timeout:start()
	end
end


-- volumen icons and progress_bar

-- icons
local vol_default = helpers.colorize_text("墳", beautiful.fg_sidebar)
local vol_high = helpers.colorize_text("", beautiful.fg_sidebar)
local vol_mid = helpers.colorize_text("墳", beautiful.fg_sidebar)
local vol_low = helpers.colorize_text("", beautiful.fg_sidebar)
local vol_off = helpers.colorize_text("",beautiful.fg_sidebar)
local vol_muted = helpers.colorize_text( "ﱝ", beautiful.fg_sidebar)

-- progress_bar
local textIcon = wibox.widget {
	font = beautiful.icon_font .. "34",
	align = "center",
	valign = "center",
	markup = vol_default,
	widget = wibox.widget.textbox,
}

local volumebar = wibox.widget {
	{
		{
			{
				textIcon,
				widget = wibox.container.margin
			},
			volume_arc,
			layout = wibox.layout.stack
		},
		left = dpi(23),
		bottom = dpi(23),
		right = dpi(23),
		top = dpi(23),
		widget = wibox.container.margin
	},
	layout = wibox.layout.fixed.vertical
}

pop:setup({
	{
		volumebar,
		margins = dpi(7),
		widget = wibox.container.margin
	},
	layout = wibox.layout.fixed.vertical,
})

  local animation = rubato.timed{
      pos = 25,
      rate = 60,
      intro = 0.02,
      duration = 0.08,
      awestore_compat = true,
  }

  local animation_button = rubato.timed{
      pos = 0,
      rate = 60,
      intro = 0.02,
      duration = 0.08,
      awestore_compat = true,
      subscribed = function(pos)
		circle_animate.forced_width = pos
		circle_animate.forced_height = pos
      end
  }

-- volume
-- signal::volume is the conexion for awesome

local popup_isActived = true
awesome.connect_signal("signals::volume", function(value, muted)
	
	if muted then
		textIcon.markup = vol_muted
	elseif value <= 0 then
		textIcon.markup = vol_off
	elseif value < 25 then
		textIcon.markup = vol_low
	elseif value < 60 then
		textIcon.markup = vol_mid
	else
		textIcon.markup = vol_high
	end
	
	if popup_isActived then
		popup_isActived = false
	else
		toggle_pop()
	end


end)