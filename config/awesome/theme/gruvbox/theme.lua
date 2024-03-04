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

theme.wallpaper          = "~/Pictures/Wallpapers/gruvbox/waterfall2.jpg"

theme.useless_gap        = 6
theme.useless_less       = 8

-- colors
-- #131417

theme.bg                 = "#1d2021"
theme.bg_sidebar         = "#1d2021"
theme.bg_selected        = "#1b2021" --
theme.bg_widget          = "#1b2021"
theme.border_color       = "#252628"
theme.accent             = "#7daea3"
theme.transparent        = "#000000"
theme.fg_normal          = "#a89984"
theme.fg_focus           = "#d4be98"
theme.fg_urgent          = "#a89984"
theme.fg_minimize        = "#a89984"
theme.fg_sidebar         = "#d4be98"

theme.taglist_bg_focus   = {
  type = "linear",
  from = { 00, 00, 10 },
  to = { 100, 100, 30 },
  stops = { { 0, "#7daea3" }, { 1, "#7daea3" } }
}

theme.active             = "#1d2021"

theme.icon_bg            = "#d4be98"
theme.icon_normal        = "#a89984"
theme.icon_selected      = "#d4be98"

theme.red                = "#ea6962"

theme.grey               = "#928374"

theme.titlebar_unfocused = "#252628"

theme.fg_contrast        = "#d4be98"

theme.search_bar         = "#1b2021"

theme.dark_slider_bg     = "#7daea3"

theme.arc_bg             = "#1d2021"
theme.arc_color          = "#7daea3"


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

theme.profile            = gfs.get_configuration_dir() .. "icons/bar/elric.png"

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
