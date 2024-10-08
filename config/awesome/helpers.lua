-- Thanks For JavaCafe01
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local naughty = require("naughty")

local helpers = {}

function helpers.volume_control(step)
    local cmd
    if step == 0 then
        cmd = "pactl set-sink-mute @DEFAULT_SINK@ toggle"
    else
        sign = step > 0 and "+" or ""
        cmd =
            "pactl set-sink-mute @DEFAULT_SINK@ 0 && pactl set-sink-volume @DEFAULT_SINK@ " .. sign .. tostring(step) ..
            "%"
    end
    awful.spawn.with_shell(cmd)
end

function helpers.colorize_text(txt, fg)
    return "<span foreground='" .. fg .. "'>" .. txt .. "</span>"
end

function helpers.colorize_text2(txt, fg)
    if fg == "" then
        fg = "#ffffff"
    end

    return "<span foreground='" .. fg .. "'>" .. txt .. "</span>"
end

helpers.rrect = function(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end

helpers.rbar = function(width, height)
    return function(cr)
        gears.shape.rounded_bar(cr, width, height)
    end
end

helpers.prrect = function(radius, tl, tr, br, bl)
    return function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, tl, tr, br, bl, radius)
    end
end

helpers.squircle = function(width, height, rate)
    return function(cr, width, height)
        gears.shape.squircle(cr, width, height, rate)
    end
end

helpers.psquircle = function(tl, tr, br, bl, rate)
    return function(cr, width, height)
        gears.shape.partial_squircle(cr, width, height, tl, tr, br, bl, rate, delta)
    end
end

function helpers.add_hover_cursor(w, hover_cursor)
    local original_cursor = "left_ptr"

    w:connect_signal("mouse::enter", function()
        local w = _G.mouse.current_wibox
        if w then
            w.cursor = hover_cursor
        end
    end)

    w:connect_signal("mouse::leave", function()
        local w = _G.mouse.current_wibox
        if w then
            w.cursor = original_cursor
        end
    end)
end

function helpers.vertical_pad(height)
    return wibox.widget {
        forced_height = height,
        layout = wibox.layout.fixed.vertical
    }
end

function helpers.horizontal_pad(width)
    return wibox.widget {
        forced_width = width,
        layout = wibox.layout.fixed.horizontal
    }
end

function helpers.prompt(action, textbox, prompt, callback)
    if action == "web_search" then
        awful.prompt.run {
            prompt = prompt,
            bg_cursor = beautiful.search_bar,
            textbox = textbox,
            font = beautiful.font,
            done_callback = callback,
            exe_callback = function(input)
                if not input or #input == 0 then return end
                -- awful.spawn.with_shell('brave https://www.google.com/search?q='..input ..' &')
                --naughty.notify{ text = 'The input was: '..input }
            end
        }
    end
end

function helpers.remote_watch(command, interval, output_file, callback)
    local run_the_thing = function()
        -- Pass output to callback AND write it to file
        awful.spawn.easy_async_with_shell(command .. " | tee " .. output_file, function(out)
            callback(out)
        end)
    end

    local timer
    timer = gears.timer({
        timeout = interval,
        call_now = true,
        autostart = true,
        single_shot = false,
        callback = function()
            awful.spawn.easy_async_with_shell("date -r " .. output_file .. " +%s",
                function(last_update, _, __, exitcode)
                    -- Probably the file does not exist yet (first time
                    -- running after reboot)
                    if exitcode == 1 then
                        run_the_thing()
                        return
                    end

                    local diff = os.time() - tonumber(last_update)
                    if diff >= interval then
                        run_the_thing()
                    else
                        -- Pass the date saved in the file since it is fresh enough
                        awful.spawn.easy_async_with_shell("cat " .. output_file, function(out)
                            callback(out)
                        end)

                        -- Schedule an update for when the remaining time to complete the interval passes
                        timer:stop()
                        gears.timer.start_new(interval - diff, function()
                            run_the_thing()
                            timer:again()
                        end)
                    end
                end)
        end
    })
end

function colorize_icon(icon, color)
    local tags = gears.color.recolor_image(icon, color)
    return tags
end

return helpers
