#!/usr/bin/env bash

text="$(curl -s "https://wttr.in/?format=1")"
tooltip="$(
  curl -s "https://wttr.in/?0QT" |
    sed 's/\\/\\\\/g' |
    sed ':a;N;$!ba;s/\n/\\n/g' |
    sed 's/"/\\"/g'
)"

if [ -n "$text" ] && ! grep -q "Unknown location" <<< "$text"; then
  echo "{\"text\": \"$text\", \"tooltip\": \"<tt>$tooltip</tt>\", \"class\": \"weather\"}"
else
  echo "{\"text\": \"󰖐\", \"tooltip\": \"Weather unavailable\", \"class\": \"weather\"}"
fi
