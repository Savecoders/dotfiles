-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local helpers = require("helpers")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Weather
------------

local weather_text = wibox.widget({
    font = beautiful.font_screen .. "11",
    markup = helpers.colorize_text("Unavailable", beautiful.bg),
    align = "left",
    valign = "center",
    widget = wibox.widget.textbox
})

local weather_temp = wibox.widget({
    font = beautiful.font_screen .. "11",
    markup = "##°C",
    align = "left",
    valign = "top",
    widget = wibox.widget.textbox
})

local weather_icon = wibox.widget({
    font = "icomoon 34",
    markup = helpers.colorize_text("", beautiful.bg),
    align = "bottom",
    valign = "bottom",
    widget = wibox.widget.textbox
})

local city = wibox.widget({
    font = beautiful.font_screen .. "11",
    markup = mycity,
    align = "left",
    valign = "center",
    widget = wibox.widget.textbox
})

local weather = wibox.widget({
    {
        weather_text,
        city,
        weather_temp,
        spacing = dpi(6),
        widget = wibox.container.margin,
        layout = wibox.layout.fixed.vertical,
    },
    {
        left = dpi(10),
        helpers.vertical_pad(dpi(60)),
        weather_icon,
        layout = wibox.layout.fixed.vertical,
        widget = wibox.container.margin,
    },
    layout = wibox.layout.align.horizontal
})

awesome.connect_signal("signals::weather", function(temperature, description, icon_widget)
    local weather_temp_symbol = "°C"
    weather_icon.markup = icon_widget
    weather_text.markup = helpers.colorize_text(description, beautiful.grey)
    weather_temp.markup = temperature .. weather_temp_symbol
    city = mycity
end)

return weather
