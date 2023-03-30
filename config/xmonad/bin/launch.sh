#!/usr/bin/env bash

# Add this script to your wm startup file.

DIR="$HOME/.xmonad/polybar"

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch the bar
#polybar -q top1 -c ~/.xmonad/polybar/config.ini &
#polybar -q top2 -c ~/.xmonad/polybar/config.ini &
#polybar -q top3 -c ~/.xmonad/polybar/config.ini &
#polybar -q bottom1 -c "$DIR"/config.ini &
polybar -q bottom2 -c "$DIR"/config.ini &
#polybar -q bottom3 -c "$DIR"/config.ini &
