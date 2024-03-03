local awful = require("awful")
local wibox = require("wibox")
local gears = require('gears')
local helpers = require("helpers")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local imguser = wibox.widget {
    image = beautiful.profile,
    resize = true,
    clip_shape = helpers.squircle(w, h, 9),
    halign = "center",
    widget = wibox.widget.imagebox
}

local date_day = wibox.widget({
    font = beautiful.font,
    format = "⚖️ %a, %d %b",
    valign = "center",
    widget = wibox.widget.textclock
})

local clock = wibox.widget({
    font = beautiful.font,
    format = "🕑 %I:%M %p",
    valign = "center",
    widget = wibox.widget.textclock
})

local text = wibox.widget {
    markup = helpers.colorize_text("👋 Hi, " .. os.getenv('USER') .. "!", beautiful.fg_sidebar),
    font = beautiful.font,
    valign = "center",
    widget = wibox.widget.textbox
}

local info = wibox.widget({
    {
        {
            text,
            date_day,
            clock,
            spacing = dpi(7),
            expand = "none",
            widget = wibox.container.margin,
            layout = wibox.layout.fixed.vertical
        },
        layout = wibox.layout.fixed.horizontal
    },
    layout = wibox.layout.fixed.horizontal
})

local userprofile = wibox.widget {
    {
        imguser,
        margins = dpi(13),
        widget = wibox.container.margin
    },
    {
        layout = wibox.layout.fixed.vertical,
        expand = "none",
        helpers.vertical_pad(dpi(15)),
        info
    },

    layout = wibox.layout.align.horizontal
}

return userprofile
