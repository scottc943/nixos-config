#!/usr/bin/env bash
set -euo pipefail

screenshot_directory="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$screenshot_directory"

file="$screenshot_directory/satty-$(date +'%Y-%m-%d_%H-%M-%S').png"
geometry="$(slurp -d)" || exit 0
[[ -n "$geometry" ]] || exit 0

grim -g "$geometry" "$file"

satty \
    --filename "$file" \
    --output-filename "$file" \
    --copy-command wl-copy \
    --actions-on-enter "save-to-clipboard,exit" \
    --actions-on-escape "exit" \
    --early-exit
