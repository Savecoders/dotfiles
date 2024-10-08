local naughty = require("naughty")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")


-- Default notification theme

naughty.config.defaults.ontop = true
naughty.config.defaults.icon_size = dpi(22)
naughty.config.defaults.screen = awful.screen.focused()
naughty.config.defaults.timeout = 5
naughty.config.defaults.title = "System Notification"
naughty.config.defaults.position = "top_right"


-- icons for notifications

naughty.config.icon_dirs = {
    "$HOME/.icons/01-WhiteSur/WhiteSur-dark/",
}
naughty.config.icon_formats = { "png", "svg", "jpg" }

naughty.config.presets.critical.timeout = 0
naughty.config.presets.ok = naughty.config.presets.normal
naughty.config.presets.info = naughty.config.presets.normal
naughty.config.presets.warn = naughty.config.presets.critical

naughty.connect_signal("request::display", function(notify)
    local time = os.date("%H:%M %p")

    notify.timeout = 8

    local appicon = notify.app_icon or notify.icon
    if not appicon then appicon = beautiful.notification_icon end

    local action_widget = {
        {
            {
                id = 'text_role',
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox
            },
            left = dpi(6),
            right = dpi(6),
            widget = wibox.container.margin
        },
        widget = wibox.container.background
    }

    local actions = wibox.widget {
        notification = notify,
        base_layout = wibox.widget {
            --Space for notification
            spacing = dpi(12),
            layout = wibox.layout.flex.horizontal
        },
        widget_template = action_widget,
        style = { underline_normal = false, underline_selected = true },
        widget = naughty.list.actions
    }
    helpers.add_hover_cursor(actions, "hand1")

    naughty.layout.box {
        notification = notify,
        type = "notification",
        bg = "#00000000",
        fg = beautiful.fg_normal,
        ontop = true,
        cursor = "hand2",
        maximum_width = dpi(350),
        maximum_height = dpi(180),
        shape = gears.shape.rectangle,
        margins = dpi(20),
        padding = dpi(20),
        --container for notification

        widget_template = {
            {
                {
                    {
                        {
                            {
                                {
                                    {
                                        -- image for appicon
                                        {
                                            image = appicon,
                                            resize = true,
                                            clip_shape = helpers.rrect(beautiful.border_radius - 5),
                                            widget = wibox.widget.imagebox
                                        },
                                        strategy = "max",
                                        height = dpi(18),
                                        widget = wibox.container.constraint
                                    },
                                    right = dpi(10),
                                    widget = wibox.container.margin
                                },
                                -- ttile for notification
                                {
                                    markup = notify.app_name,
                                    align = "left",
                                    font = beautiful.font,
                                    widget = wibox.widget.textbox
                                },
                                {
                                    markup = time,
                                    align = "right",
                                    font = beautiful.font,
                                    widget = wibox.widget.textbox
                                },
                                layout = wibox.layout.align.horizontal
                            },
                            top = dpi(18),
                            left = dpi(18),
                            right = dpi(18),
                            bottom = dpi(10),
                            widget = wibox.container.margin
                        },
                        widget = wibox.container.background
                    },
                    {
                        {
                            {
                                helpers.vertical_pad(5),
                                {
                                    -- title for aplication
                                    {
                                        step_function = wibox.container.scroll
                                            .step_functions
                                            .waiting_nonlinear_back_and_forth,
                                        speed = 50,
                                        {
                                            markup = "<span weight='bold'>" .. notify.title .. "</span>",
                                            font = beautiful.font,
                                            align = "left",
                                            widget = wibox.widget.textbox
                                        },
                                        forced_width = dpi(148),
                                        widget = wibox.container.scroll.horizontal
                                    },
                                    helpers.vertical_pad(0.5),
                                    --message  of textbox
                                    {
                                        {
                                            markup = (#notify.message > 20 and string.sub(notify.message, 0, 20) .. ".." or notify.message),
                                            align = "left",
                                            font = beautiful.font,
                                            widget = wibox.widget.textbox
                                        },
                                        right = 10,
                                        widget = wibox.container.margin
                                    },
                                    spacing = 0,
                                    layout = wibox.layout.flex.vertical
                                },
                                helpers.vertical_pad(10),
                                layout = wibox.layout.align.vertical
                            },
                            left = dpi(18),
                            right = dpi(18),
                            widget = wibox.container.margin
                        },
                        {
                            {
                                nil,
                                {
                                    -- image of notification
                                    {
                                        image = appicon,
                                        resize = true,
                                        clip_shape = helpers.rrect(beautiful.border_radius - 5),
                                        widget = wibox.widget.imagebox
                                    },
                                    strategy = "max",
                                    height = dpi(30),
                                    widget = wibox.container.constraint
                                },
                                nil,
                                expand = "none",
                                layout = wibox.layout.align.vertical
                            },
                            top = dpi(2),
                            left = dpi(10),
                            right = dpi(18),
                            bottom = dpi(2),
                            widget = wibox.container.margin
                        },
                        layout = wibox.layout.fixed.horizontal
                    },
                    {
                        { actions, layout = wibox.layout.fixed.vertical },
                        margins = dpi(12),
                        visible = notify.actions and #notify.actions > 0,
                        widget = wibox.container.margin
                    },
                    layout = wibox.layout.fixed.vertical
                },
                top = dpi(2),
                bottom = dpi(5),
                widget = wibox.container.margin
            },
            bg = beautiful.bg,
            shape = helpers.rrect(beautiful.border_radius - 2),
            widget = wibox.container.background
        }
    }
end)
