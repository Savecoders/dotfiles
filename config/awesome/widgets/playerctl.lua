local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local helpers = require("helpers")
local beautiful = require("beautiful")
local bling = require("modules.bling")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local create_button = function(symbol, size_symbol, color, command, playpause)

    local icon = wibox.widget {
        markup = helpers.colorize_text(symbol, color),
        font = beautiful.icon_var .. size_symbol,
        align = "center",
        halign = "center",
        valign = "center",
        widget = wibox.widget.textbox()
    }

    local button = wibox.widget {
        icon,
        forced_height = dpi(36),
        forced_width = dpi(36),
        widget = wibox.container.background
    }

    awesome.connect_signal("bling::playerctl::status", function(playing)
        if playpause then
            if playing then
                icon.markup = helpers.colorize_text("", color)
            else
                icon.markup = helpers.colorize_text("", color)
            end
        end
    end)

    button:buttons(gears.table.join(
                       awful.button({}, 1, function() command() end)))

    button:connect_signal("mouse::enter", function()
        icon.markup = helpers.colorize_text(icon.text, beautiful.fg_sidebar)
    end)

    button:connect_signal("mouse::leave", function()
        icon.markup = helpers.colorize_text(icon.text, color)
    end)

    return button
end

local box = wibox.container.background()
box.bg = beautiful.bg_4
box.shape = helpers.rrect(dpi(6))
box.forced_height = dpi(30)
box.forced_width = dpi(80)

local spot = colorize_icon(beautiful.music_icon, beautiful.fg_sidebar)

local art = wibox.widget {
    image = spot,
    resize = true,
    clip_shape = helpers.squircle(w, h, 9),
    halign = "center",
    widget = wibox.widget.imagebox
}

local music_pos = wibox.widget({
	font = "Font Awesome 5 Free 11.2",
    align = 'left',
	valign = "center",
	widget = wibox.widget.textbox,
})

local title_widget = wibox.widget {
    markup = helpers.colorize_text('No Light?', beautiful.fg_sidebar),
    align = 'left',
    valign = 'center',
    forced_height = dpi(26),
    font = "Font Awesome 5 Free 12",
    widget = wibox.widget.textbox
}

local artist_widget = wibox.widget {
    markup = helpers.colorize_text('No Music?', beautiful.fg_sidebar),
    align = 'left',
    valign = 'center',
    font = "Font Awesome 5 Free 11.3",
    widget = wibox.widget.textbox
}

-- Get Song Info 

Playerctl:connect_signal("metadata",
                       function(_, title, artist, album_path, album, ___, player_name)
    -- Set art widget
    art:set_image(gears.surface.load_uncached(album_path))

    title_widget:set_markup_silently('<span foreground="' .. beautiful.fg_sidebar .. '">' .. ( #title > 23 and string.sub(title,0,23).. ".."  or title ) .. '</span>')
    artist_widget:set_markup_silently('<span foreground="' .. beautiful.fg_sidebar.. "90" .. '">' .. artist .. '</span>')
end)

Playerctl:connect_signal("position", 
                    function(_, interval_sec, length_sec, player_name)
	local pos_now = tostring(os.date("!%M:%S", math.floor(interval_sec)))
	local pos_length = tostring(os.date("!%M:%S", math.floor(length_sec)))
	local pos_markup = helpers.colorize_text(pos_now .. " / " .. pos_length, beautiful.fg_sidebar .. "66")

	music_pos:set_markup_silently(pos_markup)
end)


local play_command = function() Playerctl:play_pause() end
local prev_command = function() Playerctl:previous() end
local next_command = function() Playerctl:next() end

local playerctl_play_symbol = create_button("", "14", beautiful.fg_sidebar, play_command, true)
local playerctl_prev_symbol = create_button("", "12", beautiful.fg_sidebar, prev_command, false)-- 
local playerctl_next_symbol = create_button("", "12", beautiful.fg_sidebar, next_command, false)


local info = wibox.widget {
    helpers.vertical_pad(4),
    {
        title_widget,
        widget = wibox.container.margin
    },
    {
        artist_widget,
        top = dpi(4),
        widget = wibox.container.margin
    },
    {
        music_pos,
        top = dpi(4),
        widget = wibox.container.margin
    },
    layout = wibox.layout.fixed.vertical
}

local box_music_pos = wibox.widget{
    {
        {
            nil,
            music_pos,
            layout = wibox.layout.align.horizontal,
            expand = "none"
        },
        widget = box
        
    },
    layout = wibox.layout.fixed.vertical,   
    widget = wibox.container.margin,
    expand = "none"
}

local control = wibox.widget {
    helpers.vertical_pad(9),
    {
        playerctl_prev_symbol,
        margins = {
            left = dpi(4),
            right = dpi(4),
        },
        widget = wibox.container.margin
    },
    {
        playerctl_play_symbol,
        widget = wibox.container.margin
    },
    {
        playerctl_next_symbol,
        margins = {
            left = dpi(4),
            right = dpi(4),
        },
        widget = wibox.container.margin
    },
    widget = wibox.container.margin,
    layout = wibox.layout.fixed.vertical,
}

local playerctl = {
    playercomand = wibox.widget {
       {
           art,
           margins = dpi(26),
           widget = wibox.container.margin
       },
       {
           layout = wibox.layout.fixed.vertical,
           expand = "none",
           helpers.vertical_pad(dpi(18)),
           info,
       },

       layout = wibox.layout.align.horizontal
   },
   controlpanel = control

}

return playerctl