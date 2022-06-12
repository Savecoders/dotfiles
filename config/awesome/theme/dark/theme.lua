local awful = require("awful")
local gears = require("gears")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gfs = require('gears.filesystem')
local themes_path = gfs.get_themes_dir()
local beautiful = require("beautiful")
local helpers = require("helpers")

local theme = {}

-- wallpaper scripts


-- themes 

theme.font = "SF Pro Display Medium 11"

theme.icon_font = "JetBrainsMono Nerd Font "

theme.icon_var = "Font Awesome 6 Free 18 "


theme.dir = string.format('%s/.config/awesome/theme', os.getenv('HOME'))

theme.dir = string.format('%s/.config/awesome/theme', os.getenv('HOME'))

theme.wallpaper = gfs.get_configuration_dir() .. "wallpapers/japan.jpg"


theme.useless_gap = 20
theme.useless_less = 8
-- colors

theme.bg = "#131417"
theme.bg_sidebar = "#131417"
theme.bg_selected = "#1D1F22" --
theme.bg_widget = "#1D1F22"
theme.border_color = "#252628"

--the exit-scren

theme.accent = "#d6E7fc"
theme.accent_2       = theme.accent .. "66"
theme.bg_color         = "#101012"
theme.transparent = "#000000"
theme.ext_light_fg = "#170e14"
theme.rounded       = dpi(10)
theme.ext_light_bg = "#E1F0E3"
theme.rounded_wids  = dpi(16)
theme.font_screen = "SF Pro Display Medium  "
theme.bg_2 = "#1B1B1B"
theme.bg_3 = "#303030"
theme.bg_4 = "#1e1d22"

--theme.icon_var = "Material Icons Round "

------

theme.fg_normal = "#8A8E97"
theme.fg_focus      = "#FFFFFF"
theme.fg_urgent     = "#8A8E97"
theme.fg_minimize   = "#8A8E97"
theme.fg_sidebar = "#FFFFFF"

theme.taglist_bg_focus = {
  type = "linear",
  from = { 00, 00, 10 },
  to = { 100, 100, 30 },
  stops = { { 0, "#3F8CFF" }, { 1, "#5197FF" } }
} 

theme.active = "#6A6E78"

theme.icon_bg = "#FFFFFF"
theme.icon_normal = "#8A8E97"
theme.icon_selected = "#FFFFFF"

theme.red = "#db7272"

theme.grey = "#8B8B8B"

theme.titlebar_unfocused = "#252628"

theme.fg_contrast = "#FFFFFF"

theme.search_bar = "#1D1F22"

theme.dark_slider_bg = "#3F8CFF"

theme.arc_bg = "#131417"
theme.arc_color = "#6192FB"

-- radius

theme.bar_radius = dpi(6) -- 25
theme.border_radius = dpi(9)
theme.client_radius = dpi(8)
theme.sidebar_radius = dpi(12)
theme.dock_radius = dpi(14)

theme.snap_bg = theme.border_color
theme.snap_border_width = dpi(2)

-- icons

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

-- icons

theme.notif_icon = gfs.get_configuration_dir() .. "icons/notif-center/notif.png"
theme.darkmode = gfs.get_configuration_dir() .. "icons/bar/darkmode.png"

theme.clear_icon = gfs.get_configuration_dir() .. "icons/notif-center/clear.png"
theme.clear_filled = gfs.get_configuration_dir() .. "icons/notif-center/clear_filled.png"
theme.delete_icon = gfs.get_configuration_dir() .. "icons/notif-center/delete.png"

theme.wide_icon = gfs.get_configuration_dir() .. "icons/bar/wide.png"

theme.music_icon = gfs.get_configuration_dir() .. "icons/bar/music.png"

theme.vol = gfs.get_configuration_dir() .. "icons/bar/vol.png"

theme.search_icon = gfs.get_configuration_dir() .. "icons/bar/search.png"
theme.search_bar_icon = colorize_icon(theme.search_icon, theme.icon_normal)

theme.logo = gfs.get_configuration_dir() .. "icons/bar/align.png"
theme.logo_normal = colorize_icon(theme.logo, theme.icon_normal) 
theme.logo_selected = colorize_icon(theme.logo, theme.icon_selected) 

theme.icon_change_theme = gfs.get_configuration_dir() .. "icons/ichange_theme.png"

-- notif

theme.notification_icon = colorize_icon(theme.notif_icon, theme.icon_normal) 
theme.delete = colorize_icon(theme.delete_icon, theme.red)
theme.delete_hover = colorize_icon(theme.delete_icon, theme.red .. "80")
theme.clear = colorize_icon(theme.clear_icon, theme.grey)
theme.clear_hover = colorize_icon(theme.clear_filled, theme.grey)

theme.icon_theme = nil

return theme