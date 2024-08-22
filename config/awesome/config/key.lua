local gears = require("gears")
local gfs = require('gears.filesystem')
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local helpers = require("helpers")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local apps = require("config.apps")
local keys = {}

-- awful keys

require("awful.hotkeys_popup.keys")
require("awful.autofocus")

terminal = "kitty"
browser = "brave"
music_player = "spotify"
vscode = "code"
discord = "discord-canary"
lockscreen = "betterlockscreen -l"
modkey = "Mod4"

clientbuttons = gears.table.join(awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),

    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),

    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)


mykeyboardlayout = awful.widget.keyboardlayout()

keys.desktopbuttons = gears.table.join(awful.button({}, 2, function()
    sidebar_toggle()
end))

-- keys

globalkeys = gears.table.join(

    awful.key({ modkey }, "Left", awful.tag.viewprev, {
        description = "view previous",
        group = "tag"
    }),

    awful.key({ modkey }, "Right", awful.tag.viewnext, {
        description = "view next",
        group = "tag"
    }),

    awful.key({ modkey }, "Escape", awful.tag.history.restore, {
        description = "go back",
        group = "tag"
    }),

    awful.key({ modkey }, "j", function()
        awful.client.focus.byidx(1)
    end, {
        description = "focus next by index",
        group = "client"
    }),

    awful.key({ modkey }, "k", function()
        awful.client.focus.byidx(-1)
    end, {
        description = "focus previous by index",
        group = "client"
    }),

    -- aplication

    awful.key({ modkey }, "e", function()
        awful.spawn(vscode)
    end, {
        description = "spawn code",
        group = "launcher"
    }),

    awful.key({ modkey }, "w", function()
        awful.spawn(browser)
    end, {
        description = "spawn browser",
        group = "launcher"
    }),

    awful.key({ modkey }, "g", function()
        awful.spawn(discord)
    end, {
        description = "discord social app",
        group = "launcher"
    }),

    awful.key({ modkey }, "s", function()
        awful.spawn(music_player)
    end, {
        description = "spawn music player",
        group = "launcher"
    }),

    awful.key({ modkey }, "z", function()
        awful.spawn.with_shell(apps.utils.color_pick)
    end, {
        description = "open color-picker",
        group = "launcher"
    }),

    awful.key({ modkey }, "p", function()
        awful.spawn(lockscreen)
    end, {
        description = "lock screen",
        group = "launcher"
    }),

    awful.key({ modkey, "Shift" }, "x", awesome.quit, {
        description = "quit awesome",
        group = "awesome"
    }),

    awful.key({ modkey }, "Tab", function()
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
    end, { description = "go back", group = "client" }),

    -- Audio

    awful.key({}, "XF86AudioRaiseVolume", function()
        awful.spawn.easy_async_with_shell(
            helpers.volume_control(5)
        )
    end, {
        description = "raise volume by 5%",
        group = "audio"
    }),

    awful.key({}, "XF86AudioLowerVolume", function()
        awful.spawn.easy_async_with_shell(
            helpers.volume_control(-5)
        )
    end, {
        description = "lower volume by 5%",
        group = "audio"
    }),

    awful.key({}, "XF86AudioMute", function()
        awful.spawn.easy_async_with_shell(
            helpers.volume_control(0)
        )
    end, {
        description = "mute audio",
        group = "audio"
    }),

    -- Dark toggle
    awful.key({ modkey }, "x", function()
        require("theme.selection_theme")
        theme_toogle()
    end, {
        description = "color theme change",
        group = "launcher"
    }),

    -- Standard program
    awful.key({ modkey }, "Return", function()
        awful.spawn.with_shell(terminal)
    end, {
        description = "open a terminal",
        group = "launcher"
    }),

    awful.key({ modkey, "Shift" }, "r", awesome.restart, {
        description = "reload awesome",
        group = "awesome"
    }),

    awful.key({ modkey, "Control" }, "r", awesome.quit, {
        description = "quit awesome",
        group = "awesome"
    }),

    -- Screenshot

    awful.key({}, "Print", function()
        awful.spawn.easy_async_with_shell(apps.utils.full_screenshot, function() end)
    end, { description = "take a full screenshot", group = "hotkeys" }),

    -- short screenshot

    awful.key({ modkey }, "Print", function()
        awful.spawn.easy_async_with_shell(apps.utils.area_screenshot, function() end)
    end, { description = "take a area screenshot", group = "hotkeys" }),

    -- Screenrect

    awful.key({ modkey, "Control" }, "Print", function()
        awful.spawn.easy_async_with_shell(apps.utils.recorded, function() end)
    end, { description = "take a area recorded", group = "hotkeys" }),

    -- mode for screen aplication

    awful.key({ modkey }, ";", function()
        awful.tag.incmwfact(0.05)
    end, {
        description = "increase master width factor",
        group = "layout"
    }),

    awful.key({ modkey }, "-", function()
        awful.tag.incmwfact(-0.05)
    end, {
        description = "decrease master width factor",
        group = "layout"
    }),

    awful.key({ modkey, "Shift" }, "-", function()
        awful.tag.incnmaster(1, nil, true)
    end, {
        description = "increase the number of master clients",
        group = "layout"
    }),

    awful.key({ modkey, "Shift" }, ";", function()
        awful.tag.incnmaster(-1, nil, true)
    end, {
        description = "decrease the number of master clients",
        group = "layout"
    }),

    awful.key({ modkey, "Control" }, "-", function()
        awful.tag.incncol(1, nil, true)
    end, {
        description = "increase the number of columns",
        group = "layout"
    }),

    awful.key({ modkey, "Control" }, ";", function()
        awful.tag.incncol(-1, nil, true)
    end, {
        description = "decrease the number of columns",
        group = "layout"
    }),

    awful.key({ modkey }, "space", function()
        awful.layout.inc(1)
    end, {
        description = "select next",
        group = "layout"
    }),

    awful.key({ modkey, "Shift" }, "space", function()
        awful.layout.inc(-1)
    end, {
        description = "select previous",
        group = "layout"
    }),

    -- sidebar screen

    awful.key({ modkey }, "q", function()
        sidebar_toggle()
    end, {
        description = "show or hide sidebar",
        group = "awesome"
    }),

    awful.key({ modkey }, "v", function()
        require("layout.others.exit-screen")
        awesome.emit_signal('module::exit_screen:show')
    end, {
        description = "show exit screen",
        group = "awesome"
    }),

    awful.key({ modkey }, "l", function()
        awful.spawn.easy_async_with_shell(apps.utils.blue_light, function() end)
    end, {
        description = "take a blue light",
        group = "hotkeys"
    }),


    awful.key({ modkey, "Control" }, "n", function()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            c:emit_signal("request::activate", "key.unminimize", {
                raise = true
            })
        end
    end, {
        description = "restore minimized",
        group = "client"
    }),

    -- Menubar

    awful.key({ modkey }, "r", function()
        if theme == themes[1] then
            awful.spawn.easy_async_with_shell(
                'rofi -show drun -theme ' .. '~/.config/rofi/gruvbox.rasi' .. ' -show-icons')
        elseif theme == themes[2] then
            awful.spawn.easy_async_with_shell(
                'rofi -show drun -theme ' .. '~/.config/rofi/light.rasi' .. ' -show-icons')
        elseif theme == themes[3] then
            awful.spawn.easy_async_with_shell(
                'rofi -show drun -theme ' .. '~/.config/rofi/dark.rasi' .. ' -show-icons')
        end
    end, {
        description = "show the menubar",
        group = "launcher"
    }),

    -- emoji

    awful.key({ modkey }, "i", function()
        awful.spawn.easy_async_with_shell("emoji-picker")
    end, {
        description = "emoji menu",
        group = "launcher"
    })

)

-- screen

clientkeys = gears.table.join(

    awful.key({ modkey }, "f", function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end, {
        description = "toggle fullscreen",
        group = "client"
    }),

    -- kill aplication

    awful.key({ modkey, "Shift" }, "c", function(c)
        c:kill()
    end, {
        description = "close",
        group = "client"
    }),

    -- kill all process

    awful.key({ modkey, "Control" }, "c", function(c)
        if c.pid then
            awful.spawn.with_shell("kill -9 " .. c.pid)
        end
    end, {
        description = "close",
        group = "client procces"
    }),

    -- application floating

    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle, {
        description = "toggle floating",
        group = "client"
    }),

    -- Resize windows
    awful.key({ modkey, "Control" }, "Left", function()
        awful.client.moveresize(0, 0, -20, 0)
    end, {description = "reduce window width", group = "client"}),

    awful.key({ modkey, "Control" }, "Right", function()
        awful.client.moveresize(0, 0, 20, 0)
    end, {description = "increase window width", group = "client"}),

    awful.key({ modkey, "Control" }, "Up", function()
        awful.client.moveresize(0, 0, 0, -20)
    end, {description = "reduce window height", group = "client"}),

    awful.key({ modkey, "Control" }, "Down", function()
        awful.client.moveresize(0, 0, 0, 20)
    end, {description = "increase window height", group = "client"}),

    -- tilling windown manager

    awful.key({ modkey, "Control" }, "Return", function(c)
        c:swap(awful.client.getmaster())
    end, {
        description = "move to master",
        group = "client"
    }),

    awful.key({ modkey }, "o", function(c)
        c:move_to_screen()
    end, {
        description = "move to screen",
        group = "client"
    }),

    awful.key({ modkey }, "t", function(c)
        c.ontop = not c.ontop
    end, {
        description = "toggle keep on top",
        group = "client"
    }),

    awful.key({ modkey }, "n", function(c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
        c.minimized = true
    end, {
        description = "minimize",
        group = "client"
    }),

    awful.key({ modkey }, "m", function(c)
        c.maximized = not c.maximized
        c:raise()
    end, {
        description = "(un)maximize",
        group = "client"
    }),

    awful.key({ modkey, "Control" }, "m", function(c)
        c.maximized_vertical = not c.maximized_vertical
        c:raise()
    end, {
        description = "(un)maximize vertically",
        group = "client"
    }),

    awful.key({ modkey, "Shift" }, "m", function(c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
    end, {
        description = "(un)maximize horizontally",
        group = "client"
    })
)

for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys, -- View tag only.

        awful.key({ modkey }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                tag:view_only()
            end
        end, {
            description = "view tag #" .. i,
            group = "tag"
        }),

        -- Toggle tag display.

        awful.key({ modkey, "Control" }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end, {
            description = "toggle tag #" .. i,
            group = "tag"
        }),

        -- Move client to tag.

        awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {
            description = "move focused client to tag #" .. i,
            group = "tag"
        }),

        -- Toggle tag on focused client.

        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end, {
            description = "toggle focused client on tag #" .. i,
            group = "tag"
        }))
end


root.buttons(keys.desktopbuttons)

for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys, -- View tag only.

        awful.key({ modkey }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                tag:view_only()
            end
        end, {
            description = "view tag #" .. i,
            group = "tag"
        }),

        -- Toggle tag display.

        awful.key({ modkey, "Control" }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end, {
            description = "toggle tag #" .. i,
            group = "tag"
        }),

        -- Move client to tag.

        awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {
            description = "move focused client to tag #" .. i,
            group = "tag"
        }),

        -- Toggle tag on focused client.

        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end, {
            description = "toggle focused client on tag #" .. i,
            group = "tag"
        }))
end

clientbuttons = gears.table.join(awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),

    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),

    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

return keys
