#!/usr/bin/env bash
# Shows the active macOS keyboard layout as a short code (EN / NO / ...).

source "$HOME/.config/sketchybar/colors.sh"

LAYOUT="$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist \
  AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null)"
LAYOUT="${LAYOUT##*.}"   # strip com.apple.keylayout. prefix

case "$LAYOUT" in
  ABC|US|USExtended|British|Irish) LABEL="EN" ;;
  Norwegian|NorwegianExtended) LABEL="NO" ;;
  Swedish*) LABEL="SE" ;;
  Danish) LABEL="DK" ;;
  German) LABEL="DE" ;;
  French*) LABEL="FR" ;;
  Spanish*) LABEL="ES" ;;
  *) LABEL="${LAYOUT:0:2}" ;;   # fallback: first two letters of the layout name
esac

sketchybar --set "$NAME" label="$LABEL"
