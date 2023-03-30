#!/usr/bin/env bash

## rofi sudo askpass helper
export SUDO_ASKPASS=~/.xmonad/bin/askpass.sh

## execute the application
sudo -A $1
