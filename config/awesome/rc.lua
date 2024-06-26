pcall(require, "luarocks.loader")

-- 📚 Library

local gears = require("gears")
local gfs = require("gears.filesystem")
local awful = require("awful")
local beautiful = require("beautiful")

-- ✨ Modules

local bling = require("modules.bling")
local machi = require("modules.layout-machi")

-- 🎵 Playerctl

Playerctl = bling.signal.playerctl.lib({})

-- 🖥 Screen

screen_width = awful.screen.focused().geometry.width
screen_height = awful.screen.focused().geometry.height

-- 🎨 Theme

themes = {
	"gruvbox",
	"light",
	"dark",
}

theme = themes[1]

beautiful.init(gfs.get_configuration_dir() .. "theme/" .. theme .. "/theme.lua")

-- temperature

-- enter your city here
mycity = "guayaquil"

-- Require

require("awful.autofocus")
require("awful.hotkeys_popup.keys")
require("config")
require("layout")
require("notifs")
require("modules")

-- 🚀 Launch Script

local autostart = require("autostart")

screen.connect_signal("request::desktop_decoration", function(s)
	if s.index == 1 then
		awful.tag({}, s, awful.layout.layouts[1])
	end
	s.tags[1]:view_only()
end)

-- Signals And Rules

awesome.register_xproperty("WM_NAME", "string")

awful.rules.rules = {
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			honor_workarea = true,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			size_hints_honor = false,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Viewnior",
				"Sxiv",
				"feh",
			},
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"zoom",
			},
		},
		properties = {
			floating = true,
		},
	},
	-- Add titlebars to normal clients and dialogs
	{
		rule_any = {
			type = { "normal", "dialog" },
		},
		properties = {
			titlebars_enabled = true,
		},
	},
	{
		rule_any = {
			class = { "Thunar" },
			instance = { "Thunar" },
		},
		properties = {
			floating = true,
			placement = awful.placement.centered,
		},
	},
	{
		rule_any = {
			class = { "warp", "warp-terminal" },
			instance = { "warp", "warp-terminal" },
		},
		properties = {
			titlebars_enabled = false,
			placement = awful.placement.centered,
		},
	},
}

if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Error occured",
		text = awesome.startup_errors,
	})
end

client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", {
		raise = false,
	})
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

-- globalkeys
root.keys(globalkeys)

require("signals")
