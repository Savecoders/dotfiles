local gfs = require('gears.filesystem')
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
-- icons

local icon = {}

-- icons

icon.notif_icon = gfs.get_configuration_dir() .. "icons/notif-center/notif.png"
icon.darkmode = gfs.get_configuration_dir() .. "icons/bar/darkmode.png"

icon.clear_icon = gfs.get_configuration_dir() .. "icons/notif-center/clear.png"
icon.clear_filled = gfs.get_configuration_dir() .. "icons/notif-center/clear_filled.png"
icon.delete_icon = gfs.get_configuration_dir() .. "icons/notif-center/delete.png"

icon.wide_icon = gfs.get_configuration_dir() .. "icons/bar/wide.png"

icon.music_icon = gfs.get_configuration_dir() .. "icons/bar/music.png"

icon.vol = gfs.get_configuration_dir() .. "icons/bar/vol.png"

icon.search_icon = gfs.get_configuration_dir() .. "icons/bar/search.png"
icon.search_bar_icon = colorize_icon(icon.search_icon, icon.icon_normal)

icon.logo = gfs.get_configuration_dir() .. "icons/bar/align.png"
icon.logo_normal = colorize_icon(icon.logo, icon.icon_normal) 
icon.logo_selected = colorize_icon(theme.logo, icon.icon_selected) 

icon.icon_change_theme = gfs.get_configuration_dir() .. "icons/ichange_theme.png"



return icons