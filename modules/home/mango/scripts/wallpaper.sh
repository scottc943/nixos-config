#!/usr/bin/env bash
set -euo pipefail

wall="${XDG_PICTURES_DIR:-$HOME/Pictures}/Wallpapers/NGE4PromoPenPen.png"

if ! pgrep -x awww-daemon >/dev/null; then
    awww-daemon >/dev/null 2>&1 &
fi

for _ in {1..20}; do
    if awww query >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done

if [[ ! -f "$wall" ]]; then
    notify-send "Wallpaper missing" "$wall"
    exit 1
fi

awww img "$wall" \
    --transition-type grow \
    --transition-duration 1
