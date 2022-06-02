local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local helpers       = require("helpers")
local button = {}

button.create = function(icon_cc, size, margin, bg, bg_hover, bg_press, command)

    local button_icon = wibox.widget {
        align = "center",
        valign = "center",
        font = beautiful.icon_font .. "28",
        markup = helpers.colorize_text(icon_cc, bg_hover),
        widget = wibox.widget.textbox()
    }
    
    local button = wibox.widget {
        {
            button_icon, 
            spacing = dpi(8),
            widget = wibox.container.margin
        },
        forced_height = size,
        forced_width = size,
        bg = bg,
        shape = helpers.rrect(beautiful.bar_radius),
        widget = wibox.container.background
    }

    button:connect_signal("button::press", function()
        button.bg = bg_press
        command()
    end)

    button:connect_signal("button::leave", function() 
        button_icon.markup = helpers.colorize_text(icon_cc, bg_hover)
        button.bg = bg
    end)

    button:connect_signal("mouse::enter", function() 
        button_icon.markup = helpers.colorize_text(icon_cc, bg)
        button.bg = bg_hover 
    end)

    button:connect_signal("mouse::leave", function() 
        button_icon.markup = helpers.colorize_text(icon_cc, bg_hover)
        button.bg = bg
    end)


    helpers.add_hover_cursor(button, "hand1")

    return button
end


button.create_widget = function(widget, command)
    local button = wibox.widget {
        {widget, margins = dpi(10), widget = wibox.container.margin},
        bg = beautiful.bg_normal,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(10))
        end,
        widget = wibox.container.background
    }

    button:connect_signal("button::press", function()
        button.bg = beautiful.bg_very_light
        command()
    end)

    button:connect_signal("button::leave",
                          function() button.bg = beautiful.bg_normal end)
    button:connect_signal("mouse::enter",
                          function() button.bg = beautiful.bg_light end)
    button:connect_signal("mouse::leave",
                          function() button.bg = beautiful.bg_normal end)

    return button
end

button.create_image = function(image, image_hover)
    local image_widget = wibox.widget {
        image = image,
        widget = wibox.widget.imagebox
    }

    image_widget:connect_signal("mouse::enter",
                                function() image_widget.image = image_hover end)
    image_widget:connect_signal("mouse::leave",
                                function() image_widget.image = image end)

    return image_widget
end

button.create_image_onclick = function(image, image_hover, onclick)
    local image = button.create_image(image, image_hover)

    local container = wibox.widget {image, widget = wibox.container.background}

    container:connect_signal("button::press", onclick)

    return container
end

button.create_text = function(color, color_hover, text, font)
    local textWidget = wibox.widget {
        font = font,
        markup = "<span foreground='" .. color .. "'>" .. text .. "</span>",
        widget = wibox.widget.textbox
    }

    textWidget:connect_signal("mouse::enter", function()
        textWidget.markup =
            "<span foreground='" .. color_hover .. "'>" .. text .. "</span>"
    end)
    textWidget:connect_signal("mouse::leave", function()
        textWidget.markup = "<span foreground='" .. color .. "'>" .. text ..
                                "</span>"
    end)

    return textWidget
end

return button