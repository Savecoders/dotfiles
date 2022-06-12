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
local utils = require("config.apps").utils


-- cr_btn

local cr_btn = require("widgets.button").create

-- icons

local icons = {
    blocked         = "",
    blue_light      = "",
    bluetooth       = "",
    microphone      = "",
    recorded        = "",
    themes          = "",
    screenshot      = "",
    shot_area       = "",
    wifi            = "",
}

-- blocked

local blocked_cmd = function()
    require("layout.others.exit-screen") 
        awesome.emit_signal('module::exit_screen:show')
end

local blocked = cr_btn(icons.blocked, dpi(50), dpi(5),beautiful.bg_widget, beautiful.icon_normal, beautiful.red, blocked_cmd)

-- blue_light

local blue_light_cmd = function()
    awful.spawn.easy_async_with_shell(utils.blue_light, function() end)
end

local blue_light = cr_btn(icons.blue_light, dpi(50), dpi(5),beautiful.bg_widget, beautiful.icon_normal, beautiful.red, blue_light_cmd)

-- bluetooth

local bluetooth_cmd = function() 
    awful.spawn.easy_async_with_shell(utils.area_screenshot, function() end)
end

local bluetooth = cr_btn(icons.bluetooth, dpi(50), dpi(5), beautiful.bg_widget, beautiful.icon_normal, beautiful.red, bluetooth_cmd)

-- microphone

local microphone_cmd = function() 
    awful.spawn.easy_async_with_shell(utils.area_screenshot, function() end)
end

local microphone = cr_btn(icons.microphone, dpi(50), dpi(5), beautiful.bg_widget, beautiful.icon_normal, beautiful.red, microphone_cmd)

-- recorded

local recorded_cmd = function() 
    awful.spawn.easy_async_with_shell(utils.recorded, function() end)
end

local recorded = cr_btn(icons.recorded, dpi(50), dpi(5), beautiful.bg_widget, beautiful.icon_normal, beautiful.red, recorded_cmd)

-- themes

local themes_cmd = function()
    require("theme.selection_theme") 
        theme_toogle()
end

local themes = cr_btn(icons.themes, dpi(50), dpi(5),beautiful.bg_widget, beautiful.icon_normal, beautiful.red, themes_cmd)

-- screenshot

local screenshot_cmd = function()
    awful.spawn.easy_async_with_shell(utils.full_screenshot, function() end)
end

local screenshot = cr_btn(icons.screenshot, dpi(50), dpi(5), beautiful.bg_widget, beautiful.icon_normal, beautiful.red, screenshot_cmd)

-- shot_area

local shot_area_cmd = function()
    awful.spawn.easy_async_with_shell(utils.area_screenshot, function() end)
end

local shot_area = cr_btn(icons.shot_area, dpi(50), dpi(5), beautiful.bg_widget, beautiful.icon_normal, beautiful.red, shot_area_cmd)

-- wifi

local wifi_cmd = function()
    awful.spawn.easy_async_with_shell(utils.area_screenshot, function() end)
end

local wifi = cr_btn(icons.wifi, dpi(50), dpi(5), beautiful.bg_widget, beautiful.icon_normal, beautiful.red, wifi_cmd)



-- ~~~~~~~~~~~~
-- slider
-- ~~~~~~~~~~~~


local slider_options = wibox({
    height = dpi(230),
    width = dpi(230),
    bg = "#00000000",
    fg = beautiful.fg_normal,
    visible = false,
    ontop = true,
})

local slider_timed = rubato.timed {
    intro = 0.2,
    duration = 0.4,
    easing = rubato.bouncy,
    subscribed = function(pos)
        slider_options.x = pos
    end
}

slider_how = function()
    if slider_options.visible == false then
        slider_options.visible = not slider_options.visible
        slider_timed.target = dpi(130)
    else
        slider_timed.target = -dpi(130)
        slider_options.visible = false
    end
end

awful.placement.bottom(slider_options, {
    margins = {
        bottom = beautiful.useless_gap * 2.4
    }
})

slider_options:setup{
    {
        {
            {
                recorded,
                screenshot,
                shot_area,
                spacing = dpi(20),
                layout = wibox.layout.fixed.horizontal,
            },
            expand = "none",
            spacing = dpi(20),
            layout = wibox.layout.fixed.vertical,
            {
                blue_light,
                themes,
                microphone,
                spacing = dpi(20),
                layout = wibox.layout.fixed.horizontal,
            },
            {
                wifi,
                bluetooth,
                blocked,                                 
                spacing = dpi(20),
                layout = wibox.layout.fixed.horizontal,
            },
        },
        margins = dpi(20),
        widget = wibox.container.margin,
    },
    bg = beautiful.bg_sidebar,
    expand = "none",
    shape = helpers.rrect(beautiful.dock_radius - 2),
    widget = wibox.container.background
}