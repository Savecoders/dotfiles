--  ▗▄▖ ▗▖ ▗▖▗▄▄▄▖▗▄▖  ▗▄▄▖▗▄▄▄▖▗▄▖ ▗▄▄▖▗▄▄▄▖
-- ▐▌ ▐▌▐▌ ▐▌  █ ▐▌ ▐▌▐▌     █ ▐▌ ▐▌▐▌ ▐▌ █
-- ▐▛▀▜▌▐▌ ▐▌  █ ▐▌ ▐▌ ▝▀▚▖  █ ▐▛▀▜▌▐▛▀▚▖ █
-- ▐▌ ▐▌▝▚▄▞▘  █ ▝▚▄▞▘▗▄▄▞▘  █ ▐▌ ▐▌▐▌ ▐▌ █

-- See https://wiki.hypr.land/Configuring/Monitors/

hl.monitor({
  output = "eDP-1",
  mode = "1920x1080@60",
  position = "0x0",
  scale = 1
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "1920x1080@60",
  position = "1920x0",
  scale = 1
})

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
hl.on("hyprland.start", function()
  -- Vicinae
  hl.exec_cmd("vicinae server")

  -- Bar
  hl.exec_cmd("qs &")
end)
