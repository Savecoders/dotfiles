#!/usr/bin/env bash
#
# sync-quickshell.sh - Sync repo Quickshell files to the active live shell directory
#
# USAGE:
#   ./scripts/sync-quickshell.sh
#
# DESCRIPTION:
#   Quickshell runs from ~/.config/quickshell (a copy of config/quickshell).
#   This script synchronizes source files to ~/.config/quickshell while preserving
#   runtime state (settings/settings.json, settings/colours.json, and cache/).
#   Strictly does NOT use --delete to avoid accidental loss of runtime state.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${REPO_ROOT}/config/quickshell/"
TARGET_DIR="${HOME}/.config/quickshell/"

if [[ ! -d "$SRC_DIR" ]]; then
    echo "Error: Source directory '$SRC_DIR' not found." >&2
    exit 1
fi

mkdir -p "$TARGET_DIR"

echo "Syncing ${SRC_DIR} -> ${TARGET_DIR} (excluding runtime state)..."

rsync -a \
    --exclude="settings/settings.json" \
    --exclude="settings/colours.json" \
    --exclude="cache/" \
    --exclude="AUDIT.md" \
    "$SRC_DIR" "$TARGET_DIR"

echo "Sync complete."
echo "Reminder: Check 'qs log -t 20' to verify that Quickshell reloaded cleanly without QML errors."
