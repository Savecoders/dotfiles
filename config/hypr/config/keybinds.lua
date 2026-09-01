-- ▗▖ ▗▖▗▄▄▄▖▗▖  ▗▖▗▄▄▖ ▗▄▄▄▖▗▖  ▗▖▗▄▄▄ ▗▄▄▄▖▗▖  ▗▖ ▗▄▄▖ ▗▄▄▖
-- ▐▌▗▞▘▐▌    ▝▚▞▘ ▐▌ ▐▌  █  ▐▛▚▖▐▌▐▌  █  █  ▐▛▚▖▐▌▐▌   ▐▌
-- ▐▛▚▖ ▐▛▀▀▘  ▐▌  ▐▛▀▚▖  █  ▐▌ ▝▜▌▐▌  █  █  ▐▌ ▝▜▌▐▌▝▜▌ ▝▀▚▖
-- ▐▌ ▐▌▐▙▄▄▖  ▐▌  ▐▙▄▞▘▗▄█▄▖▐▌  ▐▌▐▙▄▄▀▗▄█▄▖▐▌  ▐▌▝▚▄▞▘▗▄▄▞▘

-- See https://wiki.hypr.land/Configuring/Keywords/
local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local apps = require("config.apps")

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(apps.terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(apps.fileManager))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(apps.code))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(apps.menu))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("qs ipc call dashboard toggle"))
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("qs ipc call settings toggle"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
for i = 1, 10 do
	local key = tostring(i % 10)
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
end
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "e+1" }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = tostring(i % 10)
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+ && qs ipc call global updateBrightness"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%- && qs ipc call global updateBrightness"),
	{ locked = true, repeating = true }
)

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- prints & ocr
hl.bind("Print", hl.dsp.exec_cmd(apps.screenshot))
hl.bind(mainMod .. "+ SHIFT + T", hl.dsp.exec_cmd(apps.ocr))

-- Gestures Config
hl.gesture({ fingers = 3, direction = "swipe", action = "move" })
hl.gesture({ fingers = 3, direction = "pinch", action = "float" })
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 2, direction = "pinch", action = "cursor_zoom", zoom_level = 2, mode = "live" })
