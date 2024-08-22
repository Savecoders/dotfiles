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

local clock = wibox.widget {
    {
        widget = wibox.widget.textclock,
        format = helpers.colorize_text("%H", beautiful.icon_normal),
        font = beautiful.font_screen .. "14",
        valign = "center",
        align = "center"
    },
    {
        widget = wibox.widget.textclock,
        format = helpers.colorize_text("%M", beautiful.icon_normal),
        font = beautiful.font_screen .. "14",
        valign = "center",
        align = "center"
    },
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(0),
    margins = dpi(0)
}


awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper

    set_wallpaper(s)

    -- buttons

    local taglist_buttons = gears.table.join(awful.button({}, 1, function(t)
        t:view_only()
    end), awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end), awful.button({}, 3, awful.tag.viewtoggle), awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end), awful.button({}, 4, function(t)
        awful.tag.viewnext(t.screen)
    end), awful.button({}, 5, function(t)
        awful.tag.viewprev(t.screen)
    end))

    -- Tags

    local create_tag = function(name, icon, color)
        return awful.tag.add(name, {
            icon = colorize_icon(icon, color),
            screen = s,
            layout = awful.layout.suit.tile,
            selected = true
        })
    end

    local tag_home = create_tag("Web", beautiful.home_selected, beautiful.icon_normal)

    local tag_terminal = create_tag("Terminal", beautiful.terminal, beautiful.icon_normal)

    local tag_dashboard = create_tag("Code", beautiful.dashboard, beautiful.icon_normal)

    local tag_folder = create_tag("Terminal", beautiful.folder, beautiful.icon_normal)

    local tag_report = create_tag("Music", beautiful.report, beautiful.icon_normal)

    local tag_cal = create_tag("Calendar", beautiful.cal, beautiful.icon_normal)

    local tag_document = create_tag("Documents", beautiful.document, beautiful.icon_normal)

    local tag_setting = create_tag("Settings", beautiful.settings, beautiful.icon_normal)

    -- Update tags(suck)


    local update_tags = function(self, c3)
        -- update tags(suck)
        local update_icon_tag = function(tag, icon, icon_select, self, c3)
            return function(self, c3)
                if c3.selected then
                    tag.icon = colorize_icon(icon_select, beautiful.active)
                elseif #c3:clients() == 0 then
                    tag.icon = colorize_icon(icon, beautiful.icon_normal)
                else
                    tag.icon = colorize_icon(icon_select, beautiful.icon_normal)
                end
            end
        end

        local update_home = update_icon_tag(tag_home, beautiful.home, beautiful.home_selected, self, c3)

        local update_terminal = update_icon_tag(tag_terminal, beautiful.terminal, beautiful.terminal_selected, self, c3)

        local update_dashboard = update_icon_tag(tag_dashboard, beautiful.dashboard, beautiful.dashboard_selected, self,
            c3)

        local update_folder = update_icon_tag(tag_folder, beautiful.folder, beautiful.folder_selected, self, c3)

        local update_report = update_icon_tag(tag_report, beautiful.report, beautiful.report_selected, self, c3)

        local update_cal = update_icon_tag(tag_cal, beautiful.cal, beautiful.cal_selected, self, c3)

        local update_document = update_icon_tag(tag_document, beautiful.document, beautiful.document_selected, self, c3)

        local update_setting = update_icon_tag(tag_setting, beautiful.settings, beautiful.settings_selected, self, c3)

        update_home(self, c3)
        update_terminal(self, c3)
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
            shape = helpers.rrect(beautiful.bar_radius),
        },
        layout = {
            spacing = dpi(24),
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
                        width = dpi(50),
                        widget = wibox.container.constraint
                    },
                    spacing = dpi(20),
                    layout = wibox.layout.fixed.horizontal
                },
                margins = dpi(4),
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

    helpers.add_hover_cursor(s.mytaglist, "hand1")

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
        forced_height = dpi(50),
        widget = wibox.container.background
    }

    logo:connect_signal("mouse::enter", function()
        logo_icon.image = beautiful.logo_selected
    end)

    logo:connect_signal("mouse::leave", function()
        logo_icon.image = beautiful.logo_normal
    end)

    helpers.add_hover_cursor(logo, "hand1")

    sidebar_toggle = function()
        if s.mywibox.visible == true then
            sidebar_normal()
        else
            sidebar_wide()
        end
    end

    -- icon for profile
    local sidebar_icon = wibox.widget{
        markup = "",
        font = beautiful.icon_var .. "14",
        valign = "center",
        align = "center",
        widget = wibox.widget.textbox,
        margin = dpi(10),
    }

    sidebar_icon:buttons(gears.table.join(awful.button({}, 1, function()
        require("layout.panel.panel")
        slider_how()
    end)))

    helpers.add_hover_cursor(sidebar_icon, "hand1")
    -- Wrapaaa

    local wrap_widget = function(w)
        return {
            w,
            margins = dpi(12),
            widget = wibox.container.margin
        }
    end

    local mysystray = wibox.widget.systray()
    mysystray:set_base_size(dpi(30))
    mysystray:set_horizontal(false)

    -- Bar
    s.mywibox = awful.wibar({
        bg = "#0000000",
        type = "dock",
        position = "left",
        screen = s,
        ontop = true,
        height = s.geometry.height - dpi(beautiful.useless_gap * 4),
        width = dpi(50),
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
            wrap_widget(
                {
                    mysystray,
                    top = dpi(25),
                    widget = wibox.container.margin
                }
            ),
            sidebar_icon,
            {
                top = dpi(25),
                clock,
                bottom = dpi(25),
                widget = wibox.container.margin
            },
            layout = wibox.layout.fixed.vertical
        }
    }

    -- setup for layout

    s.mywibox:setup {
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
        left = dpi(beautiful.useless_gap * 1.5),
        right = dpi(beautiful.useless_gap),
    }

    awful.placement.left(s.mywibox, {
        margins = beautiful.useless_gap * 1.5,
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
