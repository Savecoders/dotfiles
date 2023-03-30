#!/usr/bin/env bash

rofi -dmenu \
     -password \
     -i \
     -no-fixed-num-lines \
     -p "User Password: " \
     -theme ~/.xmonad/rofi/themes/askpass.rasi &
