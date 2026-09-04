#!/usr/bin/env bash
# Renders one chip per AeroSpace workspace, showing the app icons it contains.
# Focused workspace is highlighted. Empty, unfocused workspaces are hidden.
# Triggered by: aerospace_workspace_change, front_app_switched, periodic refresh.

CONFIG_DIR="$HOME/.config/sketchybar"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/icon_map.sh"

FOCUSED="$(aerospace list-workspaces --focused)"

# Build "workspace -> concatenated app glyphs" in a single query.
declare -A WS_ICONS
while IFS='|' read -r ws app; do
  [ -z "$ws" ] && continue
  __icon_map "$app"
  WS_ICONS[$ws]="${WS_ICONS[$ws]}${icon_result} "
done < <(aerospace list-windows --all --format '%{workspace}|%{app-name}')

args=()
for sid in $(aerospace list-workspaces --all); do
  icons="${WS_ICONS[$sid]}"
  item="space.$sid"

  if [ "$sid" = "$FOCUSED" ]; then
    # Focused: coral highlight, show id + icons (or just id if empty)
    args+=(--set "$item" drawing=on
           icon.color="$BG_BASE"
           label.color="$BG_BASE"
           background.color="$ACCENT"
           background.border_color="$ACCENT"
           label="${icons:-  }")
  elif [ -n "$icons" ]; then
    # Non-empty, unfocused: surface chip
    args+=(--set "$item" drawing=on
           icon.color="$FG"
           label.color="$FG_MUTED"
           background.color="$ITEM_BG"
           background.border_color="$BG_MANTLE"
           label="$icons")
  else
    # Empty and unfocused: hide
    args+=(--set "$item" drawing=off)
  fi
done

sketchybar "${args[@]}"
