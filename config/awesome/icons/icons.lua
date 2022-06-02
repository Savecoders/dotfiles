local gfs = require('gears.filesystem')
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
-- icons

local icons = {}

icons.dark_toggle = gfs.get_configuration_dir() .. "icons/bar/light.png"
icons.darkmode = gfs.get_configuration_dir() .. "icons/bar/darkmode.png"

icons.clear_icon = gfs.get_configuration_dir() .. "icons/notif-center/clear.png"
icons.clear_filled = gfs.get_configuration_dir() .. "icons/notif-center/clear_filled.png"
icons.delete_icon = gfs.get_configuration_dir() .. "icons/notif-center/delete.png"

icons.profile = gfs.get_configuration_dir() .. "icons/bar/elric.png"

icons.home = gfs.get_configuration_dir() .. "icons/tag/terminal-outline.svg"
icons.home_selected = gfs.get_configuration_dir() .. "icons/tag/terminal.svg"

icons.dashboard = gfs.get_configuration_dir() .. "icons/tag/dashboard.png"
icons.dashboard_selected = gfs.get_configuration_dir() .. "icons/tag/dashboard_selected.png"

icons.folder = gfs.get_configuration_dir() .. "icons/tag/code-outline.svg"
icons.folder_selected = gfs.get_configuration_dir() .. "icons/tag/code.svg"

icons.report = gfs.get_configuration_dir() .. "icons/tag/headset-outline.svg"
icons.report_selected = gfs.get_configuration_dir() .. "icons/tag/headset.svg"

icons.cal = gfs.get_configuration_dir() .. "icons/tag/cal.png"
icons.cal_selected = gfs.get_configuration_dir() .. "icons/tag/cal_selected.png"

icons.document = gfs.get_configuration_dir() .. "icons/tag/document.png"
icons.document_selected = gfs.get_configuration_dir() .. "icons/tag/document_selected.png"

icons.settings = gfs.get_configuration_dir() .. "icons/tag/settings.png"
icons.settings_selected = gfs.get_configuration_dir() .. "icons/tag/settings_selected.png"

icons.wide_icon = gfs.get_configuration_dir() .. "icons/bar/wide.png"

icons.music_icon = gfs.get_configuration_dir() .. "icons/bar/music.png"

icons.vol = gfs.get_configuration_dir() .. "icons/bar/vol.png"

icons.temp = gfs.get_configuration_dir() .. "icons/bar/temp.png"
icons.cpu = gfs.get_configuration_dir() .. "icons/bar/cpu.png"
icons.ram = gfs.get_configuration_dir() .. "icons/bar/ram.png"

icons.notif_icon = gfs.get_configuration_dir() .. "icons/notif-center/notif.png"

icons.search_icon = gfs.get_configuration_dir() .. "icons/bar/search.png"
icons.search_bar_icon = colorize_icon(icons.search_icon, icons.icon_normal)

icons.logo = gfs.get_configuration_dir() .. "icons/bar/align.png"
icons.logo_normal = colorize_icon(icons.logo, icons.icon_normal) 
icons.logo_selected = colorize_icon(icons.logo, icons.icon_selected) 

icons.moon = gfs.get_configuration_dir() .. "icons/bar/moon.png"

icons.shutdown = gfs.get_configuration_dir() .. "icons/power/shutdown.png"
icons.restart = gfs.get_configuration_dir() .. "icons/power/restart.png"
icons.logout = gfs.get_configuration_dir() .. "icons/power/logout.png"

icons.dots = gfs.get_configuration_dir() .. "icons/bar/dots.png"


return icons