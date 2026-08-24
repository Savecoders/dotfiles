--  ▗▄▖ ▗▖ ▗▖▗▄▄▄▖▗▄▖  ▗▄▄▖▗▄▄▄▖▗▄▖ ▗▄▄▖▗▄▄▄▖
-- ▐▌ ▐▌▐▌ ▐▌  █ ▐▌ ▐▌▐▌     █ ▐▌ ▐▌▐▌ ▐▌ █
-- ▐▛▀▜▌▐▌ ▐▌  █ ▐▌ ▐▌ ▝▀▚▖  █ ▐▛▀▜▌▐▛▀▚▖ █
-- ▐▌ ▐▌▝▚▄▞▘  █ ▝▚▄▞▘▗▄▄▞▘  █ ▐▌ ▐▌▐▌ ▐▌ █

-- See https://wiki.hypr.land/Configuring/Monitors/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
hl.on("hyprland.start", function()
	-- Vicinae
	hl.exec_cmd("vicinae server")

	-- Wallpaper Daemon (awww / swww)
	hl.exec_cmd("sh -c 'awww-daemon || swww-daemon' &")
	hl.exec_cmd("sh -c 'sleep 0.5 && if command -v awww >/dev/null 2>&1; then (awww restore || (if [ -f ~/.current.wall ]; then awww img ~/.current.wall; fi)); elif command -v swww >/dev/null 2>&1 && [ -f ~/.current.wall ]; then swww img ~/.current.wall; fi' &")

	-- Quickshell Desktop Shell
	hl.exec_cmd("qs &")
end)
