#!/usr/bin/env bash
# Renders the left side of the bar: a flat taskbar with one icon per open app
# (the "regular" apps that show in the Dock / Cmd-Tab), focused app highlighted.
# This replaces the old AeroSpace per-workspace rendering — there are no
# workspaces or brackets now, just the running apps in a stable order.
#
# Item naming:  app.<appslug>   an open app
#
# Apps with a Dock notification badge show the count next to their icon, so the
# Dock can stay hidden. Clicking an icon focuses (or relaunches) that app.
#
# Triggers: front_app_switched (instant focus/launch/quit changes), system_woke,
# and a slow poll (safety net for launches/quits that don't move focus, plus the
# Dock-badge refresh). Rendering is incremental and a no-op run exits early, so
# the poll never redraws items under the cursor.

CONFIG_DIR="$HOME/.config/sketchybar"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/icon_map.sh"

APPS_BIN="$CONFIG_DIR/helpers/app_list"
BADGES_BIN="$CONFIG_DIR/helpers/dock_badges"
STATE_FILE="/tmp/sketchybar_apps_state"      # full visible state (skip no-op renders)
APPFONT="sketchybar-app-font:Regular:16.0"
CNTFONT="Hack Nerd Font:Bold:11.0"

slugify() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '_'; }

# Waking from lock can leave the layout scrambled — force a full rebuild.
FORCE=0
[ "$SENDER" = "system_woke" ] && FORCE=1
[ "$FORCE" = 1 ] && rm -f "$STATE_FILE"

# Open apps + which one is frontmost (ordered, stable). Bail if the helper is
# missing so we never wipe the bar to an empty row.
[ -x "$APPS_BIN" ] || exit 0
APPS=()
declare -A IS_FRONT
FOCUSED=""
while IFS='|' read -r app front; do
  [ -z "$app" ] && continue
  APPS+=("$app")
  IS_FRONT["$app"]="$front"
  [ "$front" = "1" ] && FOCUSED="$app"
done < <("$APPS_BIN" 2>/dev/null)

[ ${#APPS[@]} -eq 0 ] && exit 0

# Dock badges: app name -> count
declare -A BADGE
if [ -x "$BADGES_BIN" ]; then
  while IFS='|' read -r app cnt; do
    [ -n "$app" ] && BADGE["$app"]="$cnt"
  done < <("$BADGES_BIN" 2>/dev/null)
fi

# Desired ordered item list.
desired=()
for app in "${APPS[@]}"; do desired+=("app.$(slugify "$app")"); done

# Full render state: focus + ordered items + per-app badge counts. If nothing
# that affects the bar changed since last run, do nothing — keeps the poll from
# mutating items under the cursor (which drops/delays clicks).
STATE="focus=$FOCUSED"
for app in "${APPS[@]}"; do
  STATE+=$'\n'"$app|${BADGE[$app]}"
done
[ "$STATE" = "$(cat "$STATE_FILE" 2>/dev/null)" ] && exit 0

# ---- Surgical reconciliation (only touch icons that actually changed) ----
declare -A WANT
for it in "${desired[@]}"; do WANT[$it]=1; done

existing="$(sketchybar --query bar | jq -r '.items[]')"
declare -A EXIST
while IFS= read -r it; do [ -n "$it" ] && EXIST[$it]=1; done <<< "$existing"

# Add newly-appearing apps.
addargs=()
for it in "${desired[@]}"; do [ -z "${EXIST[$it]}" ] && addargs+=(--add item "$it" left); done
[ ${#addargs[@]} -gt 0 ] && sketchybar "${addargs[@]}" >/dev/null 2>&1

# Position items. Normally only newly-added items move (so existing icons don't
# shuffle); on FORCE we reposition everything to heal a scrambled layout.
prev="apps_manager"
for it in "${desired[@]}"; do
  if [ "$FORCE" = 1 ] || [ -z "${EXIST[$it]}" ]; then
    sketchybar --move "$it" after "$prev" >/dev/null 2>&1
  fi
  prev="$it"
done
# Keep the focused-app name label to the right of the taskbar.
{ [ "$FORCE" = 1 ] || [ ${#addargs[@]} -gt 0 ]; } && sketchybar --move front_app after "$prev" >/dev/null 2>&1

# Remove apps that closed.
for it in "${!EXIST[@]}"; do
  case "$it" in
    app.*) [ -z "${WANT[$it]}" ] && sketchybar --remove "$it" >/dev/null 2>&1 ;;
  esac
done

# ---- Always: glyph, badge count, focus highlight ----
args=()
for app in "${APPS[@]}"; do
  item="app.$(slugify "$app")"
  __icon_map "$app"; glyph="$icon_result"
  cnt="${BADGE[$app]}"

  if [ "$app" = "$FOCUSED" ]; then
    appcol="$BG_BASE"; cntcol="$BG_BASE"
    bg=(background.drawing=on background.color="$ACCENT"
        background.border_color="$ACCENT" background.border_width=1
        background.corner_radius=9 background.height=26)
  else
    appcol="$FG"; cntcol="$RED"
    bg=(background.drawing=off)
  fi

  # open -a focuses the app (or relaunches it if it has since quit).
  click="open -a \"$app\""

  if [ -n "$cnt" ]; then
    args+=(--set "$item"
      icon="$glyph" icon.font="$APPFONT" icon.color="$appcol"
      icon.padding_left=8 icon.padding_right=2
      label="$cnt" label.font="$CNTFONT" label.color="$cntcol"
      label.drawing=on label.padding_right=8
      "${bg[@]}" click_script="$click")
  else
    args+=(--set "$item"
      icon="$glyph" icon.font="$APPFONT" icon.color="$appcol"
      icon.padding_left=8 icon.padding_right=8
      label.drawing=off
      "${bg[@]}" click_script="$click")
  fi
done
[ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}" >/dev/null 2>&1

printf '%s' "$STATE" > "$STATE_FILE"
