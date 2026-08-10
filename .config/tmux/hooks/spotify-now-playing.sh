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

playback=""
if [ -f "$CACHE_FILE" ]; then
  now="$(date +%s)"
  mtime="$(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)"
  if [ $((now - mtime)) -lt "$CACHE_TTL" ]; then
    playback="$(cat "$CACHE_FILE" 2>/dev/null)"
  fi
fi

if [ -z "$playback" ]; then
  # Fetch playback JSON. Discard stderr (auth prompts, rate-limit messages, etc.).
  playback="$(spotify_player get key playback 2>/dev/null)" || exit 0
  # Only cache well-formed JSON objects.
  if echo "$playback" | jq -e 'type == "object"' >/dev/null 2>&1; then
    printf '%s' "$playback" > "$CACHE_FILE" 2>/dev/null
  fi
fi

# Bail out unless we got a JSON object with a track item.
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
