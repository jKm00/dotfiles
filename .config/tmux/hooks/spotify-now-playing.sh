#!/bin/bash
# Print the currently playing Spotify track for the tmux status bar.
# Reads playback state from spotify_player's CLI (`get key playback`), which
# returns the standard Spotify Web API "CurrentPlaybackContext" JSON.
#
# Output examples:
#   ▶ Mr. Bambam — Ari Bajgora
#   ▌▌ Mr. Bambam — Ari Bajgora
# Prints nothing when: nothing is playing, no active device, rate-limited,
# spotify_player is missing, or the API errors.

set -uo pipefail

# Icons (override via env if desired).
PLAY_ICON="${SPOTIFY_PLAY_ICON:-▶}"
PAUSE_ICON="${SPOTIFY_PAUSE_ICON:-▌▌}"
# Max characters for the "track — artist" text before truncating with an ellipsis.
MAX_LEN="${SPOTIFY_MAX_LEN:-40}"

command -v spotify_player >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

# Cache the raw playback JSON briefly so frequent status-bar redraws don't hit
# the Spotify API on every refresh (avoids rate-limiting / 429s).
CACHE_TTL="${SPOTIFY_CACHE_TTL:-6}"
CACHE_FILE="${TMPDIR:-/tmp}/tmux-spotify-now-playing.$(id -u).json"

# How long (seconds) a cached track stays valid to display when fresh fetches
# keep failing (e.g. sustained rate-limiting). After this, we stop showing a
# stale song rather than freeze forever.
STALE_MAX="${SPOTIFY_STALE_MAX:-60}"

cache_age() {
  [ -f "$CACHE_FILE" ] || { echo 999999; return; }
  local now mtime
  now="$(date +%s)"
  mtime="$(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)"
  echo $((now - mtime))
}

age="$(cache_age)"
playback=""

if [ "$age" -lt "$CACHE_TTL" ]; then
  # Fresh cache: reuse it, no API call.
  playback="$(cat "$CACHE_FILE" 2>/dev/null)"
else
  # Stale/missing cache: fetch fresh. Discard stderr (auth prompts, 429, etc.).
  fresh="$(spotify_player get key playback 2>/dev/null)"
  if echo "$fresh" | jq -e 'type == "object" and .item != null' >/dev/null 2>&1; then
    # Good response with a track: cache it and use it.
    printf '%s' "$fresh" > "$CACHE_FILE" 2>/dev/null
    playback="$fresh"
  elif [ "$age" -lt "$STALE_MAX" ]; then
    # Fetch failed/empty (rate-limited, no device, etc.) but the last known
    # track is still recent enough: keep showing it to avoid flicker.
    playback="$(cat "$CACHE_FILE" 2>/dev/null)"
  fi
fi

# Bail out unless we ended up with a JSON object with a track item.
echo "$playback" | jq -e 'type == "object" and .item != null' >/dev/null 2>&1 || exit 0

is_playing="$(echo "$playback" | jq -r '.is_playing // false')"
track="$(echo "$playback" | jq -r '.item.name // empty')"
artists="$(echo "$playback" | jq -r '[.item.artists[]?.name] | join(", ")')"

[ -z "$track" ] && exit 0

if [ "$is_playing" = "true" ]; then
  icon="$PLAY_ICON"
else
  icon="$PAUSE_ICON"
fi

if [ -n "$artists" ]; then
  text="$track — $artists"
else
  text="$track"
fi

# Truncate long text so it doesn't blow out the status bar.
if [ "${#text}" -gt "$MAX_LEN" ]; then
  text="${text:0:$((MAX_LEN - 1))}…"
fi

printf '%s %s' "$icon" "$text"
