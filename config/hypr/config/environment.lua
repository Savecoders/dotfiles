-- ▗▄▄▄▖▗▖  ▗▖▗▖  ▗▖
-- ▐▌   ▐▛▚▖▐▌▐▌  ▐▌
-- ▐▛▀▀▘▐▌ ▝▜▌▐▌  ▐▌
-- ▐▙▄▄▖▐▌  ▐▌ ▝▚▞▘

-- See https://wiki.hypr.land/Configuring/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("HYPRCURSOR_SIZE", "24")

-- Multi-GPU
-- Please checkout nvidia.lua when using nvidia card
-- This line defines using the Integrated Card
hl.env("AQ_DRM_DEVICES", "/dev/dri/card2:/dev/dri/card1")

-- Wayland
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Themes
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORMTHEME_QT6", "qt6ct")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
