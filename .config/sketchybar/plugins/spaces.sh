#!/usr/bin/env bash
# Renders the left side of the bar: one chip per AeroSpace workspace (grouped
# with a bracket), containing the workspace ID plus one item per app it holds.
# Apps with a Dock notification badge show the count next to their icon.
#
# Item naming:  ws.<sid>            workspace id
#               wa.<sid>.<appslug>  an app in that workspace
#               br.<sid>            bracket grouping the two above
#
# Items/brackets are only rebuilt when membership changes (tracked via a
# signature); badge counts and focus highlight are refreshed every run so the
# 3s badge poll doesn't cause flicker.

CONFIG_DIR="$HOME/.config/sketchybar"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/icon_map.sh"

BADGES_BIN="$CONFIG_DIR/helpers/dock_badges"
SIG_FILE="/tmp/sketchybar_spaces_sig"
APPFONT="sketchybar-app-font:Regular:16.0"
IDFONT="Hack Nerd Font:Bold:13.0"
CNTFONT="Hack Nerd Font:Bold:11.0"

slugify() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '_'; }

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

SIG="$(printf '%s\n' "${desired[@]}")"

# ---- Membership rebuild (only when the set/order changed) ----
if [ "$SIG" != "$(cat "$SIG_FILE" 2>/dev/null)" ]; then
  declare -A WANT
  for it in "${desired[@]}"; do WANT[$it]=1; done
  existing="$(sketchybar --query bar | jq -r '.items[]')"

  # remove stale ws./wa. items and all brackets (cheap to rebuild)
  while IFS= read -r it; do
    case "$it" in
      ws.*|wa.*) [ -z "${WANT[$it]}" ] && sketchybar --remove "$it" >/dev/null 2>&1 ;;
      br.*)      sketchybar --remove "$it" >/dev/null 2>&1 ;;
    esac
  done <<< "$existing"

  # add missing items
  addargs=()
  for it in "${desired[@]}"; do
    grep -qx "$it" <<< "$existing" || addargs+=(--add item "$it" left)
  done
  [ ${#addargs[@]} -gt 0 ] && sketchybar "${addargs[@]}" >/dev/null 2>&1

  # (re)create brackets for grouping
  for sid in "${visible_sids[@]}"; do
    # shellcheck disable=SC2086
    sketchybar --add bracket "br.$sid" ${MEMBERS[$sid]} >/dev/null 2>&1
  done

  # enforce left-to-right order, keeping front_app to the right of the block
  moveargs=(); prev="spaces_manager"
  for it in "${desired[@]}"; do moveargs+=(--move "$it" after "$prev"); prev="$it"; done
  moveargs+=(--move front_app after "$prev")
  sketchybar "${moveargs[@]}" >/dev/null 2>&1

  printf '%s' "$SIG" > "$SIG_FILE"
fi

# ---- Always: properties, badge counts, focus highlight ----
args=()
for sid in "${visible_sids[@]}"; do
  if [ "$sid" = "$FOCUSED" ]; then
    idcol="$BG_BASE"; appcol="$BG_BASE"; cntcol="$BG_BASE"; brbg="$ACCENT"; brborder="$ACCENT"
  else
    idcol="$FG"; appcol="$FG"; cntcol="$RED"; brbg="$ITEM_BG"; brborder="$BG_MANTLE"
  fi

  click="aerospace workspace $sid; sketchybar --trigger aerospace_workspace_change"

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

  args+=(--set "br.$sid"
    background.drawing=on background.color="$brbg"
    background.border_color="$brborder" background.border_width=1
    background.corner_radius=9 background.height=26)
done
[ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}" >/dev/null 2>&1
