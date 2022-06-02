local gears = require("gears")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local xrdb = xresources.get_current_theme()
local gfs = require('gears.filesystem')
local themes_path = gfs.get_themes_dir()
local beautiful = require("beautiful")
local helpers = require("helpers")

local theme = {}

-- themes 

theme.font = "SF Pro Display Medium 12"
--theme.icon_font = "SFMono Nerd Font 12"

theme.icon_font = "JetBrainsMono Nerd Font "

theme.icon_var = "Font Awesome 5 Free 20 "

theme.dir = string.format('%s/.config/awesome/theme', os.getenv('HOME'))

theme.wallpaper = gfs.get_configuration_dir() .. "wallpapers/hands.jpg"

theme.useless_gap = 20
theme.useless_less = 8

-- colors

theme.bg = "#FFFFFF"
theme.bg_sidebar = "#FFFFFF"
theme.bg_selected = "#F7F8FC"
theme.bg_widget = "#F7F8FB"
theme.border_color = "#ECECEC"

--the exit-scren

theme.accent = "#d6E7fc"
theme.accent_2       = theme.accent .. "66"
theme.bg_color         = "#101012"
theme.transparent = "#000000"
theme.ext_light_fg = "#170e14"
theme.rounded       = dpi(10)
theme.rounded_wids  = dpi(16)
theme.ext_light_bg = "#E1F0E3"
theme.font_screen = "SF Pro Display Medium "
theme.bg_2 = "#1B1B1B"
theme.bg_3 = "#303030"
theme.bg_4 = "#fcfdff"
--theme.icon_var = "Material Icons Round "
------

theme.fg_normal = "#b0b2bf"
theme.fg_focus      = "#6192FB"
theme.fg_urgent     = "#b0b2bf"
theme.fg_minimize   = "#b0b2bf"
theme.fg_sidebar    = "#2A3256"

theme.taglist_bg_focus = "#F7F8FC"

theme.active = "#6A6E78"

theme.icon_bg = "#b0b2bf"
theme.icon_normal = "#b0b2bf"
theme.icon_selected = "#6192FB"

theme.red = "#db7272"

theme.grey = "#383D44"

theme.titlebar_unfocused = "#EFEFEF"

theme.fg_contrast = "#555B6E"

theme.search_bar = "#F7F8FA"

theme.dark_slider_bg = "#E6E9EB"

theme.arc_bg = "#D8E4FA"
theme.arc_color = "#6192FB"

-- radius

theme.bar_radius = dpi(6) -- 25
theme.border_radius = dpi(9)
theme.client_radius = dpi(8)
theme.sidebar_radius = dpi(10) -- 40
theme.dock_radius = dpi(14)


theme.snap_bg = theme.border_color
theme.snap_border_width = dpi(2)

-- wibar

theme.wibar_height = 1080 
theme.popup_left = 150

-- icons

theme.dark_toggle = gfs.get_configuration_dir() .. "icons/bar/light.png"
theme.darkmode = gfs.get_configuration_dir() .. "icons/bar/darkmode.png"

theme.clear_icon = gfs.get_configuration_dir() .. "icons/notif-center/clear.png"
theme.clear_filled = gfs.get_configuration_dir() .. "icons/notif-center/clear_filled.png"
theme.delete_icon = gfs.get_configuration_dir() .. "icons/notif-center/delete.png"

theme.profile = gfs.get_configuration_dir() .. "icons/bar/elric.png"

theme.home = gfs.get_configuration_dir() .. "icons/tag/terminal-outline.svg"
theme.home_selected = gfs.get_configuration_dir() .. "icons/tag/terminal.svg"

theme.dashboard = gfs.get_configuration_dir() .. "icons/tag/dashboard.png"
theme.dashboard_selected = gfs.get_configuration_dir() .. "icons/tag/dashboard_selected.png"

theme.folder = gfs.get_configuration_dir() .. "icons/tag/folder.png"
theme.folder_selected = gfs.get_configuration_dir() .. "icons/tag/folder_selected.png"

theme.report = gfs.get_configuration_dir() .. "icons/tag/headset-outline.svg"
theme.report_selected = gfs.get_configuration_dir() .. "icons/tag/headset.svg"

theme.cal = gfs.get_configuration_dir() .. "icons/tag/cal.png"
theme.cal_selected = gfs.get_configuration_dir() .. "icons/tag/cal_selected.png"

theme.document = gfs.get_configuration_dir() .. "icons/tag/document.png"
theme.document_selected = gfs.get_configuration_dir() .. "icons/tag/document_selected.png"

theme.settings = gfs.get_configuration_dir() .. "icons/tag/settings.png"
theme.settings_selected = gfs.get_configuration_dir() .. "icons/tag/settings_selected.png"

theme.wide_icon = gfs.get_configuration_dir() .. "icons/bar/wide.png"

theme.music_icon = gfs.get_configuration_dir() .. "icons/bar/music.png"

theme.vol = gfs.get_configuration_dir() .. "icons/bar/vol.png"

theme.temp = gfs.get_configuration_dir() .. "icons/bar/temp.png"
theme.cpu = gfs.get_configuration_dir() .. "icons/bar/cpu.png"
theme.ram = gfs.get_configuration_dir() .. "icons/bar/ram.png"

theme.notif_icon = gfs.get_configuration_dir() .. "icons/notif-center/notif.png"

theme.search_icon = gfs.get_configuration_dir() .. "icons/bar/search.png"
theme.search_bar_icon = colorize_icon(theme.search_icon, theme.icon_normal)

theme.logo = gfs.get_configuration_dir() .. "icons/bar/align.png"
theme.logo_normal = colorize_icon(theme.logo, theme.icon_normal) 
theme.logo_selected = colorize_icon(theme.logo, theme.icon_selected) 

theme.moon = gfs.get_configuration_dir() .. "icons/bar/moon.png"

theme.shutdown = gfs.get_configuration_dir() .. "icons/power/shutdown.png"
theme.restart = gfs.get_configuration_dir() .. "icons/power/restart.png"
theme.logout = gfs.get_configuration_dir() .. "icons/power/logout.png"

theme.dots = gfs.get_configuration_dir() .. "icons/bar/dots.png"

-- notif

theme.notification_icon = colorize_icon(theme.notif_icon, theme.icon_normal) 
theme.delete = colorize_icon(theme.delete_icon, theme.red)
theme.delete_hover = colorize_icon(theme.delete_icon, theme.red .."80")
theme.clear = colorize_icon(theme.clear_icon, theme.grey)
theme.clear_hover = colorize_icon(theme.clear_filled, theme.grey)

theme.icon_theme = nil

return theme
