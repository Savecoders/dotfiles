-- requirements
-- ~~~~~~~~~~~~
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local container = {}

container.progress_bar =  function (bar, icon, size)

    local textIcon = wibox.widget {
        font = beautiful.icon_font .. size,
        align = "center",
        valign = "center",
        markup = icon,
        widget = wibox.widget.textbox,
    }

    return wibox.widget {
        {
            textIcon,
            widget = wibox.container.margin
        },
        bar,
        layout = wibox.layout.stack
    }
end

container.details = function (bar)
    return wibox.widget {
        {
            bar,
            left = dpi(23),
            bottom = dpi(23),
            right = dpi(23),
            top = dpi(23),
            widget = wibox.container.margin
        },
        layout = wibox.layout.fixed.vertical
    }
end

container.create_boxed_widget = function (widget_to_be_boxed, width, height, radius, margins, bg_color)
    local box_container = wibox.container.background()
    box_container.bg = bg_color
    box_container.forced_height = height
    box_container.forced_width = width
    box_container.shape = helpers.rrect(beautiful.dock_radius - 6)
    box_container.border_width = beautiful.widget_border_width
    box_container.border_color = beautiful.widget_border_color

    local boxed_widget = wibox.widget {
        {
            {
                widget_to_be_boxed,
                margins = dpi(margins),
                widget = wibox.container.margin,
                expand = "none"
            },
            widget = box_container
        },
        margins = box_gap,
        color = "#FF000000",
        widget = wibox.container.margin
    }
    return boxed_widget

end

return container