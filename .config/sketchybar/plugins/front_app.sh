#!/usr/bin/env bash

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/plugins/icon_map.sh"

if [ "$SENDER" = "front_app_switched" ]; then
  __icon_map "$INFO"
  sketchybar --set "$NAME" \
    icon="$icon_result" \
    icon.font="sketchybar-app-font:Regular:16.0" \
    icon.color="$CORAL" \
    label="$INFO" \
    label.color="$FG_STRONG"
fi
