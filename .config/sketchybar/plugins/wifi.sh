#!/usr/bin/env bash

source "$HOME/.config/sketchybar/colors.sh"

DEVICE="$(networksetup -listallhardwareports \
  | awk '/Wi-Fi|AirPort/ { getline; print $2; exit }')"

[ -z "$DEVICE" ] && exit 0

if [ "${1:-}" = "toggle" ]; then
  POWER="$(networksetup -getairportpower "$DEVICE" | awk '{ print $NF }')"

  if [ "$POWER" = "On" ]; then
    networksetup -setairportpower "$DEVICE" off
  else
    networksetup -setairportpower "$DEVICE" on
  fi

  sketchybar --trigger wifi_change
  exit 0
fi

POWER="$(networksetup -getairportpower "$DEVICE" | awk '{ print $NF }')"

if [ "$POWER" != "On" ]; then
  sketchybar --set "$NAME" icon="󰖪" icon.color="$FG_DIM" label="Off"
  exit 0
fi

NETWORK="$(ipconfig getsummary "$DEVICE" 2>/dev/null \
  | awk '/^[[:space:]]*SSID[[:space:]]*:/ { sub(/^[^:]*:[[:space:]]*/, ""); print; exit }')"

if [ -z "$NETWORK" ]; then
  NETWORK="$(networksetup -getairportnetwork "$DEVICE" | sed 's/^Current Wi-Fi Network: //')"
fi

if [ "$NETWORK" = "<redacted>" ]; then
  sketchybar --set "$NAME" icon="󰖩" icon.color="$BLUE" label="Connected"
elif [ -z "$NETWORK" ] || [ "$NETWORK" = "You are not associated with an AirPort network." ]; then
  sketchybar --set "$NAME" icon="󰖩" icon.color="$KHAKI" label="No Wi-Fi"
else
  sketchybar --set "$NAME" icon="󰖩" icon.color="$BLUE" label="$NETWORK"
fi
