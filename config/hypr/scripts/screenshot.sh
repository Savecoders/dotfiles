#!/bin/bash

# Target directory
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Capture area
if ! GEOM=$(slurp -d); then
    exit 0
fi

# File path
FILE_PATH="$SCREENSHOT_DIR/screenshot_$(date +'%Y%m%d_%H%M%S').png"

# Capture and save
grim -g "$GEOM" "$FILE_PATH"

# Copy to clipboard
wl-copy < "$FILE_PATH"

# Send notification (Quickshell will receive this and show it)
notify-send -a "Screenshot Tool" -i "$FILE_PATH" "Screenshot Saved" "Captured area saved to Pictures/Screenshots and copied to clipboard."
