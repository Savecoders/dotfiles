-- ▗▖  ▗▖▗▖  ▗▖▗▄▄▄▖▗▄▄▄ ▗▄▄▄▖  ▗▄▖
-- ▐▛▚▖▐▌▐▌  ▐▌  █  ▐▌  █  █  ▐▌ ▐▌
-- ▐▌ ▝▜▌▐▌  ▐▌  █  ▐▌  █  █  ▐▛▀▜▌
-- ▐▌  ▐▌ ▝▚▞▘ ▗▄█▄▖▐▙▄▄▀▗▄█▄▖▐▌ ▐▌

-- Please See https://wiki.hyprland.org/Nvidia/

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia") -- Disable this if you have issues with screensharing
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("NVD_BACKEND", "direct")
