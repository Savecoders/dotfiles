#!/usr/bin/env bash
#
# verify-transparency.sh - Verify Quickshell surface transparency via screen capture and pixel classification
#
# USAGE:
#   ./scripts/verify-transparency.sh [output] [x,y,w,h]
#   ./scripts/verify-transparency.sh [output] [x] [y] [w] [h]
#
# ARGUMENTS:
#   output      Wayland output name (default: "eDP-1")
#   x,y,w,h     Optional rectangle coordinates and dimensions to sample (e.g. 100,200,400,300)
#
# EXAMPLES:
#   # Sample entire screen on default output eDP-1:
#   ./scripts/verify-transparency.sh
#
#   # Sample entire screen on specific output:
#   ./scripts/verify-transparency.sh eDP-1
#
#   # Sample a specific window/region:
#   ./scripts/verify-transparency.sh eDP-1 100,200,400,300
#   ./scripts/verify-transparency.sh eDP-1 100 200 400 300
#
# DESCRIPTION:
#   Captures the screen using `grim`, loads palette color tokens from
#   ~/.config/quickshell/settings/colours.json, and analyzes pixels using Python 3 + PIL.
#   Each pixel is checked against all opaque palette color tokens (with per-channel tolerance <= 3).
#   - High opaque-token % indicates opaque surfaces (transparency disabled).
#   - Low opaque-token % indicates translucent/blended pixels (transparency enabled with blur/background showing).

set -euo pipefail

# 1. Dependency checks
if ! command -v grim >/dev/null 2>&1; then
    echo "Error: 'grim' is required for capturing Wayland outputs but is not installed." >&2
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: 'python3' is required but is not installed." >&2
    exit 1
fi

if ! python3 -c "import PIL" >/dev/null 2>&1; then
    echo "Error: Python PIL/Pillow module is required but not installed." >&2
    exit 1
fi

COLOURS_PATH="${HOME}/.config/quickshell/settings/colours.json"
if [[ ! -f "$COLOURS_PATH" ]]; then
    echo "Error: Quickshell palette file not found at: $COLOURS_PATH" >&2
    exit 1
fi

# 2. Argument parsing
OUTPUT="${1:-eDP-1}"
CROP_X=""
CROP_Y=""
CROP_W=""
CROP_H=""

if [[ $# -eq 2 ]]; then
    IFS=',' read -r CROP_X CROP_Y CROP_W CROP_H <<< "$2"
elif [[ $# -ge 5 ]]; then
    CROP_X="$2"
    CROP_Y="$3"
    CROP_W="$4"
    CROP_H="$5"
fi

# 3. Capture screen to temporary PNG
TMP_IMG=$(mktemp --suffix=.png /tmp/qs-transparency-XXXXXX)
trap 'rm -f "$TMP_IMG"' EXIT INT TERM

if ! grim -o "$OUTPUT" "$TMP_IMG" 2>/dev/null; then
    echo "Error: Failed to capture screen output '$OUTPUT' with grim." >&2
    exit 1
fi

# 4. Analyze pixels using Python + PIL
python3 - "$TMP_IMG" "$COLOURS_PATH" "$OUTPUT" "$CROP_X" "$CROP_Y" "$CROP_W" "$CROP_H" <<'EOF'
import sys
import json
from PIL import Image

tmp_img_path = sys.argv[1]
colours_path = sys.argv[2]
output_name = sys.argv[3]
crop_x = sys.argv[4] if len(sys.argv) > 4 else ""
crop_y = sys.argv[5] if len(sys.argv) > 5 else ""
crop_w = sys.argv[6] if len(sys.argv) > 6 else ""
crop_h = sys.argv[7] if len(sys.argv) > 7 else ""

try:
    with open(colours_path, "r", encoding="utf-8") as f:
        tokens = json.load(f)
except Exception as e:
    print(f"Error loading palette JSON: {e}", file=sys.stderr)
    sys.exit(1)

# Build set of all RGB tuples within tolerance 3 of any palette token
TOLERANCE = 3
matching_colors = set()
token_count = 0

for name, hex_val in tokens.items():
    if isinstance(hex_val, str) and hex_val.startswith("#") and len(hex_val) == 7:
        try:
            r = int(hex_val[1:3], 16)
            g = int(hex_val[3:5], 16)
            b = int(hex_val[5:7], 16)
            token_count += 1
            for dr in range(-TOLERANCE, TOLERANCE + 1):
                for dg in range(-TOLERANCE, TOLERANCE + 1):
                    for db in range(-TOLERANCE, TOLERANCE + 1):
                        nr, ng, nb = r + dr, g + dg, b + db
                        if 0 <= nr <= 255 and 0 <= ng <= 255 and 0 <= nb <= 255:
                            matching_colors.add((nr, ng, nb))
        except ValueError:
            continue

try:
    img = Image.open(tmp_img_path).convert("RGB")
except Exception as e:
    print(f"Error opening image: {e}", file=sys.stderr)
    sys.exit(1)

orig_w, orig_h = img.size

# Apply crop if region specified
region_str = "full screen"
if crop_x != "" and crop_y != "" and crop_w != "" and crop_h != "":
    try:
        x, y, w, h = int(crop_x), int(crop_y), int(crop_w), int(crop_h)
        x = max(0, min(orig_w - 1, x))
        y = max(0, min(orig_h - 1, y))
        x2 = max(x + 1, min(orig_w, x + w))
        y2 = max(y + 1, min(orig_h, y + h))
        img = img.crop((x, y, x2, y2))
        region_str = f"region ({x}, {y}, {x2 - x}x{y2 - y})"
    except ValueError:
        pass

colors = img.getcolors(maxcolors=img.width * img.height)
if not colors:
    # Fallback to getdata if getcolors exceeded maxcolors
    colors = [(1, p) for p in img.getdata()]

total_pixels = sum(count for count, _ in colors)
opaque_pixels = sum(count for count, col in colors if col in matching_colors)
translucent_pixels = total_pixels - opaque_pixels

opaque_pct = (opaque_pixels / total_pixels) * 100 if total_pixels > 0 else 0.0
translucent_pct = (translucent_pixels / total_pixels) * 100 if total_pixels > 0 else 0.0

print(f"==================================================")
print(f" Quickshell Transparency Verification")
print(f" Output: {output_name} ({img.width}x{img.height}, {region_str})")
print(f" Palette tokens loaded: {token_count} (tolerance: ±{TOLERANCE})")
print(f"--------------------------------------------------")
print(f" Total sampled pixels : {total_pixels:,}")
print(f" Opaque-token pixels  : {opaque_pixels:,} ({opaque_pct:.2f}%)")
print(f" Translucent/blended  : {translucent_pixels:,} ({translucent_pct:.2f}%)")
print(f"==================================================")
EOF
