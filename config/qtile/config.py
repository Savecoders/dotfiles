import subprocess
import os

from libqtile import bar, layout, widget, hook, qtile
from settings.keys import mod, keys
from settings.groups import groups
from settings.screens import screens, extension_defaults, widget_defaults
from settings.layout import layouts, floating_layout
from settings.mouse import mouse
from settings.path import qtile_path


def open_launcher():
    qtile.cmd_spawn("rofi -show drun")


@hook.subscribe.startup_once
def autostart():
    # path to my script, under my user directory
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.call([home])


dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wl_input_rules = None
wmname = "LG3D"
