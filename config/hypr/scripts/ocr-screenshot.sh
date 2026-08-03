#!/usr/bin/env bash
# Dependencies grim, slurp, tesseract, wl-copy, libnotify

TMPIMG=$(mktemp /tmp/ocr-XXXXXX.png)

# select area
grim -g "$(slurp)" "$TMPIMG" || {
  rm -f "$TMPIMG"
  exit 1
}

# OCR → clipboard
# Switch "spa+eng" to other language
tesseract "$TMPIMG" stdout -l spa+eng 2>/dev/null | wl-copy

notify-send "OCR Tool" "All Copy text to screenshot"

rm -f "$TMPIMG"
