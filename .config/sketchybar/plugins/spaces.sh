#!/usr/bin/env bash
# Renders the left side of the bar: one chip per AeroSpace workspace (grouped
# with a bracket), containing the workspace ID plus one item per app it holds.
# Apps with a Dock notification badge show the count next to their icon.
#
# Item naming:  ws.<sid>            workspace id
#               wa.<sid>.<appslug>  an app in that workspace
#               br.<sid>            bracket grouping the two above
#
# Rendering is incremental: on each change only the chips that actually changed
# are touched (items added/removed, brackets rebuilt), so switching spaces does
# not redraw the whole bar. A no-op run exits early; system_woke/display_change
# force a full reposition + bracket rebuild to heal a scrambled layout.

CONFIG_DIR="$HOME/.config/sketchybar"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/icon_map.sh"

BADGES_BIN="$CONFIG_DIR/helpers/dock_badges"
STATE_FILE="/tmp/sketchybar_spaces_state"    # full visible state (skip no-op renders)
BR_FILE="/tmp/sketchybar_spaces_brackets"    # per-workspace bracket membership
MON_FILE="/tmp/sketchybar_spaces_monitors"   # monitor set (detect real display changes)
APPFONT="sketchybar-app-font:Regular:16.0"
IDFONT="Hack Nerd Font:Bold:13.0"
CNTFONT="Hack Nerd Font:Bold:11.0"

slugify() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '_'; }

# Force a full reposition + bracket rebuild only when the layout can actually be
# scrambled: waking from lock, or a real display reconfiguration (monitor added/
# removed). `display_change` also fires when focus merely moves to another
# monitor — that must NOT force a rebuild, or every cross-monitor switch flickers.
FORCE=0
case "$SENDER" in
  system_woke)
    FORCE=1
    ;;
  display_change)
    mon="$(aerospace list-monitors 2>/dev/null)"
    if [ "$mon" != "$(cat "$MON_FILE" 2>/dev/null)" ]; then
      FORCE=1
      printf '%s' "$mon" > "$MON_FILE"
    fi
    ;;
esac
[ "$FORCE" = 1 ] && rm -f "$STATE_FILE" "$BR_FILE"

FOCUSED="$(aerospace list-workspaces --focused)"

# Dock badges: app name -> count
declare -A BADGE
if [ -x "$BADGES_BIN" ]; then
  while IFS='|' read -r app cnt; do
    [ -n "$app" ] && BADGE["$app"]="$cnt"
  done < <("$BADGES_BIN" 2>/dev/null)
fi

# Ordered, de-duplicated apps per workspace
declare -A WS_APPS
declare -A SEEN
while IFS='|' read -r ws app; do
  [ -z "$ws" ] && continue
  key="$ws|$app"; [ -n "${SEEN[$key]}" ] && continue; SEEN[$key]=1
  WS_APPS[$ws]+="$app"$'\n'
done < <(aerospace list-windows --all --format '%{workspace}|%{app-name}')

# Desired ordered item list + bracket membership (visible = focused or non-empty)
desired=()
visible_sids=()
declare -A MEMBERS
for sid in $(aerospace list-workspaces --all); do
  apps="${WS_APPS[$sid]}"
  [ "$sid" != "$FOCUSED" ] && [ -z "$apps" ] && continue
  visible_sids+=("$sid")
  desired+=("ws.$sid")
  MEMBERS[$sid]="ws.$sid"
  while IFS= read -r app; do
    [ -z "$app" ] && continue
    item="wa.$sid.$(slugify "$app")"
    desired+=("$item")
    MEMBERS[$sid]="${MEMBERS[$sid]} $item"
  done <<< "$apps"
done

# Full render state: focus + membership + per-app badge counts. If nothing that
# affects the bar changed since last run, do nothing — this keeps the 3s poll
# from mutating items under the cursor (which dropped/delayed clicks).
STATE="focus=$FOCUSED"
for it in "${desired[@]}"; do STATE+=$'\n'"$it"; done
for sid in "${visible_sids[@]}"; do
  while IFS= read -r app; do
    [ -z "$app" ] && continue
    STATE+=$'\n'"$sid|$app|${BADGE[$app]}"
  done <<< "${WS_APPS[$sid]}"
done
[ "$STATE" = "$(cat "$STATE_FILE" 2>/dev/null)" ] && exit 0

# ---- Surgical reconciliation (only touch chips that actually changed) ----
declare -A WANT
for it in "${desired[@]}"; do WANT[$it]=1; done

existing="$(sketchybar --query bar | jq -r '.items[]')"
declare -A EXIST
while IFS= read -r it; do [ -n "$it" ] && EXIST[$it]=1; done <<< "$existing"

# Add newly-appearing items.
addargs=()
for it in "${desired[@]}"; do [ -z "${EXIST[$it]}" ] && addargs+=(--add item "$it" left); done
[ ${#addargs[@]} -gt 0 ] && sketchybar "${addargs[@]}" >/dev/null 2>&1

# Position items. Normally only newly-added items are moved (so existing chips
# don't shuffle); on FORCE we reposition everything to heal a scrambled layout.
prev="spaces_manager"
for it in "${desired[@]}"; do
  if [ "$FORCE" = 1 ] || [ -z "${EXIST[$it]}" ]; then
    sketchybar --move "$it" after "$prev" >/dev/null 2>&1
  fi
  prev="$it"
done
{ [ "$FORCE" = 1 ] || [ ${#addargs[@]} -gt 0 ]; } && sketchybar --move front_app after "$prev" >/dev/null 2>&1

# Brackets: rebuild only those whose membership changed (or all, on FORCE).
declare -A PREV_BR
if [ "$FORCE" != 1 ] && [ -f "$BR_FILE" ]; then
  while IFS='=' read -r sid mem; do [ -n "$sid" ] && PREV_BR[$sid]="$mem"; done < "$BR_FILE"
fi
declare -A CUR_BR
for sid in "${visible_sids[@]}"; do CUR_BR[$sid]="${MEMBERS[$sid]}"; done

# Remove brackets for workspaces that vanished or whose membership changed.
for sid in "${!PREV_BR[@]}"; do
  if [ -z "${CUR_BR[$sid]+x}" ] || [ "${PREV_BR[$sid]}" != "${CUR_BR[$sid]}" ]; then
    sketchybar --remove "br.$sid" >/dev/null 2>&1
  fi
done
# (Re)create brackets that are new or changed.
for sid in "${visible_sids[@]}"; do
  if [ "${PREV_BR[$sid]+x}" != "x" ] || [ "${PREV_BR[$sid]}" != "${CUR_BR[$sid]}" ]; then
    # shellcheck disable=SC2086
    sketchybar --remove "br.$sid" >/dev/null 2>&1
    # shellcheck disable=SC2086
    sketchybar --add bracket "br.$sid" ${CUR_BR[$sid]} >/dev/null 2>&1
  fi
done

# Remove stale items no longer wanted (do this after brackets are rebuilt).
for it in "${!EXIST[@]}"; do
  case "$it" in
    ws.*|wa.*) [ -z "${WANT[$it]}" ] && sketchybar --remove "$it" >/dev/null 2>&1 ;;
  esac
done

# Persist bracket membership for the next run.
: > "$BR_FILE"
for sid in "${visible_sids[@]}"; do printf '%s=%s\n' "$sid" "${CUR_BR[$sid]}" >> "$BR_FILE"; done

# ---- Always: properties, badge counts, focus highlight ----
args=()
for sid in "${visible_sids[@]}"; do
  if [ "$sid" = "$FOCUSED" ]; then
    idcol="$BG_BASE"; appcol="$BG_BASE"; cntcol="$BG_BASE"; brbg="$ACCENT"; brborder="$ACCENT"
  else
    idcol="$FG"; appcol="$FG"; cntcol="$RED"; brbg="$ITEM_BG"; brborder="$BG_MANTLE"
  fi

  click="aerospace workspace $sid"

  args+=(--set "ws.$sid"
    icon="$sid" icon.font="$IDFONT" icon.color="$idcol"
    icon.padding_left=9 icon.padding_right=4
    label.drawing=off background.drawing=off
    click_script="$click")

  while IFS= read -r app; do
    [ -z "$app" ] && continue
    item="wa.$sid.$(slugify "$app")"
    __icon_map "$app"; glyph="$icon_result"
    cnt="${BADGE[$app]}"
    if [ -n "$cnt" ]; then
      args+=(--set "$item"
        icon="$glyph" icon.font="$APPFONT" icon.color="$appcol"
        icon.padding_left=2 icon.padding_right=2
        label="$cnt" label.font="$CNTFONT" label.color="$cntcol"
        label.drawing=on label.padding_right=6 background.drawing=off
        click_script="$click")
    else
      args+=(--set "$item"
        icon="$glyph" icon.font="$APPFONT" icon.color="$appcol"
        icon.padding_left=2 icon.padding_right=4
        label.drawing=off background.drawing=off
        click_script="$click")
    fi
  done <<< "${WS_APPS[$sid]}"

  # Make the whole chip clickable (the bracket covers the gaps between glyphs).
  args+=(--set "br.$sid"
    background.drawing=on background.color="$brbg"
    background.border_color="$brborder" background.border_width=1
    background.corner_radius=9 background.height=26
    click_script="$click")
done
[ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}" >/dev/null 2>&1

printf '%s' "$STATE" > "$STATE_FILE"
