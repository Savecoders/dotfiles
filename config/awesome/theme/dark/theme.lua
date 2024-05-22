local awful              = require("awful")
local gears              = require("gears")
local theme_assets       = require("beautiful.theme_assets")
local xresources         = require("beautiful.xresources")
local dpi                = xresources.apply_dpi
local gfs                = require('gears.filesystem')
local themes_path        = gfs.get_themes_dir()
local beautiful          = require("beautiful")
local helpers            = require("helpers")

local theme              = {}

-- themes

theme.font               = "SF Pro Display Medium 11"

theme.icon_var           = "Font Awesome 6 Free "

theme.font_screen        = "SF Pro Display Medium  "

-- wallpaper scripts

theme.dir                = string.format('%s/.config/awesome/theme', os.getenv('HOME'))

theme.wallpaper          = "~/Pictures/Wallpapers/dark/programming.png"

theme.useless_gap        = 6
theme.useless_less       = 8

-- colors
-- #18181A - #theme.bg = "#131417" #18191D

theme.bg                 = "#131417"
theme.bg_sidebar         = "#131417"
theme.bg_selected        = "#18191D" --
theme.bg_widget          = "#18191D"
theme.border_color       = "#252628"
theme.accent             = "#d6E7fc"
theme.transparent        = "#000000"
theme.fg_normal          = "#8A8E97"
theme.fg_focus           = "#FFFFFF"
theme.fg_urgent          = "#8A8E97"
theme.fg_minimize        = "#8A8E97"
theme.fg_sidebar         = "#FFFFFF"

theme.taglist_bg_focus   = {
  type = "linear",
  from = { 00, 00, 10 },
  to = { 100, 100, 30 },
  stops = { { 0, "#3F8CFF" }, { 1, "#5197FF" } }
}

theme.active             = "#FFFFFF"

theme.icon_bg            = "#FFFFFF"
theme.icon_normal        = "#8A8E97"
theme.icon_selected      = "#6A6E78"

theme.red                = "#db7272"

theme.grey               = "#8B8B8B"

theme.titlebar_unfocused = "#252628"

theme.fg_contrast        = "#FFFFFF"

theme.search_bar         = "#18191D"

theme.dark_slider_bg     = "#3F8CFF"

theme.arc_bg             = "#131417"
theme.arc_color          = "#6192FB"

-- wibar

theme.wibar_height       = 1080
theme.popup_left         = 150

-- radius

theme.bar_radius         = dpi(6)
theme.border_radius      = dpi(9)
theme.client_radius      = dpi(8)
theme.sidebar_radius     = dpi(10)
theme.dock_radius        = dpi(12)

theme.snap_bg            = theme.border_color
theme.snap_border_width  = dpi(2)

-- icons

theme.profile            = gfs.get_configuration_dir() .. "icons/bar/profile.png"

theme.home               = gfs.get_configuration_dir() .. "icons/tag/home.png"
theme.home_selected      = gfs.get_configuration_dir() .. "icons/tag/home_selected.png"

theme.terminal           = gfs.get_configuration_dir() .. "icons/tag/terminal-outline.svg"
theme.terminal_selected  = gfs.get_configuration_dir() .. "icons/tag/terminal.svg"

theme.dashboard          = gfs.get_configuration_dir() .. "icons/tag/dashboard.png"
theme.dashboard_selected = gfs.get_configuration_dir() .. "icons/tag/dashboard_selected.png"

theme.folder             = gfs.get_configuration_dir() .. "icons/tag/folder.png"
theme.folder_selected    = gfs.get_configuration_dir() .. "icons/tag/folder_selected.png"

theme.report             = gfs.get_configuration_dir() .. "icons/tag/headset-outline.svg"
theme.report_selected    = gfs.get_configuration_dir() .. "icons/tag/headset.svg"

theme.cal                = gfs.get_configuration_dir() .. "icons/tag/cal.png"
theme.cal_selected       = gfs.get_configuration_dir() .. "icons/tag/cal_selected.png"

theme.document           = gfs.get_configuration_dir() .. "icons/tag/document.png"
theme.document_selected  = gfs.get_configuration_dir() .. "icons/tag/document_selected.png"

theme.settings           = gfs.get_configuration_dir() .. "icons/tag/settings.png"
theme.settings_selected  = gfs.get_configuration_dir() .. "icons/tag/settings_selected.png"

-- icons

theme.notif_icon         = gfs.get_configuration_dir() .. "icons/notif-center/notif.png"
theme.darkmode           = gfs.get_configuration_dir() .. "icons/bar/darkmode.png"

theme.clear_icon         = gfs.get_configuration_dir() .. "icons/notif-center/clear.png"
theme.clear_filled       = gfs.get_configuration_dir() .. "icons/notif-center/clear_filled.png"
theme.delete_icon        = gfs.get_configuration_dir() .. "icons/notif-center/delete.png"

theme.wide_icon          = gfs.get_configuration_dir() .. "icons/bar/wide.png"

theme.music_icon         = gfs.get_configuration_dir() .. "icons/bar/music.png"

theme.vol                = gfs.get_configuration_dir() .. "icons/bar/vol.png"

theme.search_icon        = gfs.get_configuration_dir() .. "icons/bar/search.png"
theme.search_bar_icon    = colorize_icon(theme.search_icon, theme.icon_normal)

theme.logo               = gfs.get_configuration_dir() .. "icons/bar/align.png"
theme.logo_normal        = colorize_icon(theme.logo, theme.icon_normal)
theme.logo_selected      = colorize_icon(theme.logo, theme.icon_selected)

theme.icon_change_theme  = gfs.get_configuration_dir() .. "icons/ichange_theme.png"

-- notif

theme.notification_icon  = colorize_icon(theme.notif_icon, theme.icon_normal)
theme.delete             = colorize_icon(theme.delete_icon, theme.red)
theme.delete_hover       = colorize_icon(theme.delete_icon, theme.red .. "80")
theme.clear              = colorize_icon(theme.clear_icon, theme.grey)
theme.clear_hover        = colorize_icon(theme.clear_filled, theme.grey)

theme.icon_theme         = nil

return theme
