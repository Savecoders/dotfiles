local wibox = require('wibox')
local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local helpers = require("helpers")
local rubato = require("modules.rubato")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local button = require("widgets.button")

-- Info

local userprofile = require("widgets.userprofile")
local user_box = button.create_boxed_widget(userprofile, dpi(280), dpi(130), dpi(14), dpi(15), beautiful.bg_widget)


-- Cpu

local cpu_bar = require("widgets.cpu_arc")
local cpu = button.progress_bar(cpu_bar, helpers.colorize_text("ﲟ", beautiful.fg_sidebar),"24")
local cpu_details = button.details(cpu)
local cpu_box = button.create_boxed_widget(cpu_details, dpi(130), dpi(130), dpi(14), dpi(0), beautiful.bg_widget)

-- Ram

local ram_bar = require("widgets.ram_arc")
local ram = button.progress_bar(ram_bar, helpers.colorize_text("", beautiful.fg_sidebar),"24")
local ram_details = button.details(ram)
local ram_box = button.create_boxed_widget(ram_details, dpi(130), dpi(130), dpi(14), dpi(0), beautiful.bg_widget)

-- Tmp 

local temp_bar = require("widgets.temp_arc")
local temp = button.progress_bar(temp_bar, helpers.colorize_text("", beautiful.fg_sidebar),"24")
local temp_details = button.details(temp)
local temp_box = button.create_boxed_widget(temp_details, dpi(130), dpi(130), dpi(14), dpi(0), beautiful.bg_widget)

-- weather

local weather_bar = require("widgets.weather")
local weather_box = button.create_boxed_widget(weather_bar, dpi(130), dpi(130), dpi(14), dpi(14), beautiful.bg_selected)

-- notif

local notif = require("notifs.notif-center")
local notif_center = wibox.widget {
    {
        {
            notif,
            margins = dpi(20),
            widget = wibox.container.margin
        },
        bg = beautiful.bg_widget,
        shape = helpers.rrect(beautiful.dock_radius - 6),
        forced_width = dpi(300),
        forced_height = dpi(500),
        widget = wibox.widget.background
    },
    bottom = dpi(30),
    widget = wibox.container.margin
}

local playerctl = require("widgets.playerctl")
local playercomand_box = button.create_boxed_widget(playerctl.playercomand, dpi(364), dpi(130), dpi(14), dpi(3),
    beautiful.bg_widget)
local controlpanel_box = button.create_boxed_widget(playerctl.controlpanel, dpi(44), dpi(130), dpi(14), dpi(0),
    beautiful.bg_widget)

-- Search

local search_text = wibox.widget {
    font = beautiful.font,
    markup = helpers.colorize_text("", beautiful.fg_focus),
    align = "center",
    valign = "center",
    visible = true,
    widget = wibox.widget.textbox()
}

local search = wibox.widget {
    {
        {
            {
                {
                    image = beautiful.search_bar_icon,
                    widget = wibox.widget.imagebox
                },
                margins = dpi(15),
                left = dpi(0),
                widget = wibox.container.margin
            },
            {
                search_text,
                bottom = dpi(2),
                widget = wibox.container.margin
            },
            layout = wibox.layout.fixed.horizontal
        },
        left = dpi(15),
        widget = wibox.container.margin
    },
    forced_height = dpi(50),
    forced_width = dpi(434),
    shape = helpers.rrect(dpi(10)),
    bg = beautiful.search_bar,
    widget = wibox.container.background()
}

function sidebar_activate_prompt(action)
    helpers.prompt(action, search_text, prompt, function()
    end)
end

search:buttons(gears.table.join(awful.button({}, 1, function()
    sidebar_activate_prompt("web_search")
end)))

-- Sidebar

local sidebar = wibox({
    ontop = true,
    height = screen_height - dpi(99),
    width = dpi(480),
    bg = "#00000000",
    fg = beautiful.fg_normal,
    y = dpi(50),
})

local sidebar_timed = rubato.timed {
    intro = 0.2,
    duration = 0.4,
    easing = rubato.bouncy,
    subscribed = function(pos)
        sidebar.x = pos
    end
}

sidebar_normal = function()
    if sidebar.visible == false then
        sidebar.visible = not sidebar.visible
        sidebar_timed.target = dpi(130)
    else
        sidebar_timed.target = -dpi(140)
        sidebar.visible = false
    end
end

sidebar_wide = function()
    if sidebar.visible == false then
        sidebar.visible = not sidebar.visible
        sidebar_timed.target = dpi(300) -- 370
    else
        sidebar_timed.target = -dpi(400)
        sidebar.visible = false
    end
end

sidebar:setup{
    {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        nil,
        {
            {
                {
                    helpers.vertical_pad(dpi(22)),
                    search,
                    helpers.vertical_pad(dpi(22)),
                    {
                        {
                            user_box,
                            layout = wibox.layout.fixed.vertical
                        },
                        weather_box,
                        spacing = dpi(22),
                        layout = wibox.layout.fixed.horizontal
                    },
                    layout = wibox.layout.fixed.vertical
                },
                {
                    helpers.vertical_pad(dpi(22)),
                    {
                        cpu_box,
                        ram_box,
                        temp_box,
                        spacing = dpi(22),
                        layout = wibox.layout.fixed.horizontal
                    },
                    layout = wibox.layout.fixed.vertical
                },
                {
                    helpers.vertical_pad(dpi(22)),
                    {
                        playercomand_box,
                        controlpanel_box,
                        spacing = dpi(22),
                        layout = wibox.layout.fixed.horizontal
                    },
                    layout = wibox.layout.fixed.vertical
                },
                helpers.vertical_pad(dpi(22)),
                notif_center,
                helpers.vertical_pad(dpi(22)),
                layout = wibox.layout.fixed.vertical
            },
            layout = wibox.layout.fixed.vertical
        },
        nil
    },
    bg = beautiful.bg_sidebar,
    shape = helpers.rrect(beautiful.dock_radius - 2),
    widget = wibox.container.background
}
