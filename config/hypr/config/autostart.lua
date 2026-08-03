--  ▗▄▖ ▗▖ ▗▖▗▄▄▄▖▗▄▖  ▗▄▄▖▗▄▄▄▖▗▄▖ ▗▄▄▖▗▄▄▄▖
-- ▐▌ ▐▌▐▌ ▐▌  █ ▐▌ ▐▌▐▌     █ ▐▌ ▐▌▐▌ ▐▌ █
-- ▐▛▀▜▌▐▌ ▐▌  █ ▐▌ ▐▌ ▝▀▚▖  █ ▐▛▀▜▌▐▛▀▚▖ █
-- ▐▌ ▐▌▝▚▄▞▘  █ ▝▚▄▞▘▗▄▄▞▘  █ ▐▌ ▐▌▐▌ ▐▌ █

-- See https://wiki.hypr.land/Configuring/Monitors/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
hl.on("hyprland.start", function()
	-- Vicinae
	hl.exec_cmd("vicinae server")

	-- Bar
	hl.exec_cmd("qs &")
end)
