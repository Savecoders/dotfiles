local gfs = require("gears.filesystem")
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local rubato = require("modules.rubato")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local bling = require("modules.bling")

require("awful.autofocus")

local function format_progress_bar(bar)
    local w = wibox.widget {
        nil,
        {
            bar,
            layout = wibox.layout.fixed.horizontal
        },
        expand = "none",
        layout = wibox.layout.align.horizontal
    }
    return w
end

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

local clock = wibox.widget{
    {
        widget = wibox.widget.textclock,
        format = helpers.colorize_text("%I",beautiful.icon_normal),
        font = beautiful.font_screen .. "14",
        valign = "center",
        align = "center"
    },
    {
        widget = wibox.widget.textclock,
        format = helpers.colorize_text("%M",beautiful.icon_normal),
        font = beautiful.font_screen .. "14",
        valign = "center",
        align = "center"
    },
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(4),
    margins = dpi(18)
}


awful.screen.connect_for_each_screen(function(s)

    -- Wallpaper

    set_wallpaper(s)

    -- Taglist

    -- buttons

    local taglist_buttons = gears.table.join(awful.button({}, 1, function(t)
        t:view_only()
    end), awful.button({modkey}, 1, function(t)

        if client.focus then
            client.focus:move_to_tag(t)
        end
    end), awful.button({}, 3, awful.tag.viewtoggle), awful.button({modkey}, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end), awful.button({}, 4, function(t)
        awful.tag.viewnext(t.screen)
    end), awful.button({}, 5, function(t)
        awful.tag.viewprev(t.screen)
    end))

    -- Tags

    local tag_home = awful.tag.add("Web", {
        icon = colorize_icon(beautiful.home_selected, beautiful.icon_normal),
        screen = s,
        layout = awful.layout.suit.tile,
        selected = true
    })

    local tag_dashboard = awful.tag.add("Code", {
        icon = colorize_icon(beautiful.dashboard, beautiful.icon_normal),
        screen = s,
        layout = awful.layout.suit.tile,
        selected = true
    })

    local tag_folder = awful.tag.add("Terminal", {
        icon = colorize_icon(beautiful.folder, beautiful.icon_normal),
        screen = s,
        layout = awful.layout.suit.tile,
        selected = true
    })

    local tag_report = awful.tag.add("Music", {
        icon = colorize_icon(beautiful.report, beautiful.icon_normal),
        screen = s,
        layout = awful.layout.suit.tile,
        selected = true
    })

    local tag_cal = awful.tag.add("Calendar", {
        icon = colorize_icon(beautiful.cal, beautiful.icon_normal),
        screen = s,
        layout = awful.layout.suit.tile,
        selected = true
    })

    local tag_document = awful.tag.add("Documents", {
        icon = colorize_icon(beautiful.document, beautiful.icon_normal),
        screen = s,
        layout = awful.layout.suit.tile,
        selected = true
    })

    local tag_setting = awful.tag.add("Settings", {
        icon = colorize_icon(beautiful.settings, beautiful.icon_normal),
        screen = s,
        layout = awful.layout.suit.tile,
        selected = true
    })

    -- Update tags(suck)

    local update_tags = function(self, c3)

        local update_home = function(self, c3)
            if c3.selected then
                tag_home.icon = colorize_icon(beautiful.home_selected, beautiful.icon_selected)
            elseif #c3:clients() == 0 then
                tag_home.icon = colorize_icon(beautiful.home, beautiful.icon_normal)
            else
                tag_home.icon = colorize_icon(beautiful.home_selected, beautiful.icon_normal)
            end
        end

        local update_dashboard = function(self, c3)
            if c3.selected then
                tag_dashboard.icon = colorize_icon(beautiful.dashboard_selected, beautiful.icon_selected)
            elseif #c3:clients() == 0 then
                tag_dashboard.icon = colorize_icon(beautiful.dashboard, beautiful.icon_normal)
            else
                tag_dashboard.icon = colorize_icon(beautiful.dashboard_selected, beautiful.icon_normal)
            end
        end

        local update_folder = function(self, c3)
            if c3.selected then
                tag_folder.icon = colorize_icon(beautiful.folder_selected, beautiful.icon_selected)
            elseif #c3:clients() == 0 then
                tag_folder.icon = colorize_icon(beautiful.folder, beautiful.icon_normal)
            else
                tag_folder.icon = colorize_icon(beautiful.folder_selected, beautiful.icon_normal)
            end
        end

        local update_report = function(self, c3)
            if c3.selected then
                tag_report.icon = colorize_icon(beautiful.report_selected, beautiful.icon_selected)
            elseif #c3:clients() == 0 then
                tag_report.icon = colorize_icon(beautiful.report, beautiful.icon_normal)
            else
                tag_report.icon = colorize_icon(beautiful.report_selected, beautiful.icon_normal)
            end
        end

        local update_cal = function(self, c3)
            if c3.selected then
                tag_cal.icon = colorize_icon(beautiful.cal_selected, beautiful.icon_selected)
            elseif #c3:clients() == 0 then
                tag_cal.icon = colorize_icon(beautiful.cal, beautiful.icon_normal)
            else
                tag_cal.icon = colorize_icon(beautiful.cal_selected, beautiful.icon_normal)
            end
        end

        local update_document = function(self, c3)
            if c3.selected then
                tag_document.icon = colorize_icon(beautiful.document_selected, beautiful.icon_selected)
            elseif #c3:clients() == 0 then
                tag_document.icon = colorize_icon(beautiful.document, beautiful.icon_normal)
            else
                tag_document.icon = colorize_icon(beautiful.document_selected, beautiful.icon_normal)
            end
        end

        local update_setting = function(self, c3)
            if c3.selected then
                tag_setting.icon = colorize_icon(beautiful.settings_selected, beautiful.icon_selected)
            elseif #c3:clients() == 0 then
                tag_setting.icon = colorize_icon(beautiful.settings, beautiful.icon_normal)
            else
                tag_setting.icon = colorize_icon(beautiful.settings_selected, beautiful.icon_normal)
            end
        end

        update_home(self, c3)
        update_dashboard(self, c3)
        update_folder(self, c3)
        update_report(self, c3)
        update_cal(self, c3)
        update_document(self, c3)
        update_setting(self, c3)
    end

    -- Make Widget

    local active_timed = rubato.timed {
        intro = 0.075,
        duration = 0.2
    }

    -- Taglist

    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        style = {
            shape = helpers.rrect(beautiful.border_radius - 5),
        },
        layout = {
            spacing = dpi(16),
            layout = wibox.layout.fixed.vertical
        },
        widget_template = {
            {
                {
                    {
                        {
                            id = 'icon_role',
                            resize = true,
                            valign = "center",
                            halign = "center",
                            widget = wibox.widget.imagebox
                        },
                        width = dpi(40),
                        widget = wibox.container.constraint
                    },
                    spacing = dpi(25),
                    layout = wibox.layout.fixed.horizontal
                },
                margins = dpi(3.6),
                widget = wibox.container.margin
            },
            id = 'background_role',
            widget = wibox.container.background,
            update_callback = function(self, c3, index, objects)
                update_tags(self, c3)
            end
        },
        buttons = taglist_buttons
    }

    -- logo

    local logo_icon = wibox.widget {
        image = beautiful.logo_normal,
        widget = wibox.widget.imagebox
    }

    local logo = wibox.widget {
        {
            logo_icon,
            widget = wibox.container.margin
        },
        forced_height = dpi(30),
        widget = wibox.container.background
    }

    logo:connect_signal("mouse::enter", function()
        logo_icon.image = beautiful.logo_selected
    end)

    logo:connect_signal("mouse::leave", function()
        logo_icon.image = beautiful.logo_normal
    end)

    sidebar_toggle = function()
        if s.mywibox.visible == true then
            sidebar_normal()
        else
            sidebar_wide()
        end
    end

    -- icon for profile
    local sidebar_icon = wibox.widget {
        {
            {
                image = beautiful.profile,
                widget = wibox.widget.imagebox,
                resize = true
            },
            forced_height = dpi(50),
            widget = wibox.container.constraint
        },
        margins = dpi(18),
        widget = wibox.container.margin
    }

    sidebar_icon:buttons(gears.table.join(awful.button({}, 1, function()
        sidebar_toggle()
    end)))

    -- Wrap

    local wrap_widget = function(w)
        return {
            w,
            left = dpi(17),
            right = dpi(17),
            widget = wibox.container.margin
        }
    end

    -- themes

    -- Bar
    s.mywibox = awful.wibar({
        bg = "#0000000",
        type = "dock",
        position = "left",
        screen = s,
        ontop = true,
        height = s.geometry.height - dpi(93),
        width = dpi(65),
        visible = true
    })

    -- Add widgets
    s.mywibox.widget = wibox.widget {
        layout = wibox.layout.align.vertical,
        expand = "none",
        { -- top
            wrap_widget({
                logo,
                top = dpi(25),
                left = dpi(5),
                widget = wibox.container.margin
            }),
            layout = wibox.layout.fixed.vertical
        },
        {
            wrap_widget(s.mytaglist),
            layout = wibox.layout.fixed.vertical
        },
        { 
            --[[ wrap_widget({
                dark_toggle,
                margins = dpi(0),
                widget = wibox.container.margin
            }), ]]
            sidebar_icon,
            {
                clock,
                bottom = dpi(25),
                widget = wibox.container.margin
            },
            spacing = dpi(10),
            layout = wibox.layout.fixed.vertical

        }
    }

    -- setup for layout

    s.mywibox:setup{
        {
            layout = wibox.layout.align.horizontal,
            expand = "none",
            nil,
            { -- middle
                s.mywibox.widget,
                layout = wibox.layout.fixed.horizontal
            },
            nil
        },
        bg = beautiful.bg,
        -- border radius for bar
        shape = helpers.rrect(beautiful.border_radius),
        widget = wibox.container.background

    }

    logo:connect_signal("button::press", function()
        sidebar_toggle()
    end)

    -- rubato timed

    local widebox_timed = rubato.timed {
        intro = 0.1,
        duration = 0.3,
        easing = rubato.bouncy,
        subscribed = function(pos)
            s.mywibox.x = pos - dpi(95)
        end
    }

    -- screen padding
    s.padding = {
        left = dpi(24),
        right = dpi(7),
        top = dpi(7),
        bottom = dpi(7)
    }

    s.mywibox.x = dpi(30)

    awful.placement.left(s.mywibox, {
        margins = beautiful.useless_gap * 1.5
    })

end)

-- Remove wibar on full screen
local function remove_wibar(c)
    if c.fullscreen or c.maximized then
        c.screen.mywibox.visible = false
    else
        c.screen.mywibox.visible = true
    end
end

-- Remove wibar on full screen
local function add_wibar(c)
    if c.fullscreen or c.maximized then
        c.screen.mywibox.visible = true
    end
end

client.connect_signal("property::fullscreen", remove_wibar)

client.connect_signal("request::unmanage", add_wibar)

function systray_toggle()
    local s = awful.screen.focused()
    s.traybox.visible = not s.traybox.visible
end
