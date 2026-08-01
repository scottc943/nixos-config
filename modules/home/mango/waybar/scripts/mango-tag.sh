#!/usr/bin/env bash

ACTION="$1"
TAG="$2"

tag_mask() {
  local tag="$1"
  echo $((1 << (tag - 1)))
}

mango_state() {
  mmsg -g -t 2>/dev/null
}

selected_mask() {
  mango_state |
    awk '
      $2 == "tags" &&
      $3 ~ /^(0|[1-9][0-9]*)$/ &&
      $4 ~ /^(0|[1-9][0-9]*)$/ &&
      $5 ~ /^(0|[1-9][0-9]*)$/ {
        print $4;
        exit;
      }
    '
}

occupied_mask() {
  mango_state |
    awk '
      $2 == "tags" &&
      $3 ~ /^(0|[1-9][0-9]*)$/ &&
      $4 ~ /^(0|[1-9][0-9]*)$/ &&
      $5 ~ /^(0|[1-9][0-9]*)$/ {
        print $3;
        exit;
      }
    '
}

tag_clients() {
  local tag="$1"

  mango_state |
    awk -v tag="$tag" '
      $2 == "tag" && $3 == tag {
        print $5;
        exit;
      }
    '
}

label_tag() {
  local tag="$1"
  local mask selected occupied clients class tooltip

  mask="$(tag_mask "$tag")"
  selected="$(selected_mask)"
  occupied="$(occupied_mask)"
  clients="$(tag_clients "$tag")"

  [ -z "$selected" ] && selected="1"
  [ -z "$occupied" ] && occupied="0"
  [ -z "$clients" ] && clients="0"

  if (( selected & mask )); then
    class="mango-active"
  elif (( occupied & mask )); then
    class="mango-occupied"
  else
    class="mango-empty"
  fi

  tooltip="Tag $tag\nOpen apps: $clients"

  echo "{\"text\":\"$tag\",\"class\":\"$class\",\"tooltip\":\"$tooltip\"}"
}

switch_tag() {
  mmsg -s -d "view,$TAG,0" >/dev/null 2>&1 || true
  pkill -RTMIN+8 waybar 2>/dev/null || true
}

case "$ACTION" in
  label)
    label_tag "$TAG"
    ;;
  switch)
    switch_tag "$TAG"
    ;;
  *)
    echo "{\"text\":\"?\",\"class\":\"mango-empty\"}"
    ;;
esac
