#!/usr/bin/env bash
set -euo pipefail

# Watches for a PipeWire/Pulse stream that indicates Discord is sharing the screen,
# and sets .privacy.hide-previews in the swaync config accordingly.

DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$DIR/config.json"
INTERVAL=2

if [ ! -f "$CONFIG" ]; then
  echo "Config not found: $CONFIG"
  exit 1
fi

command -v jq >/dev/null 2>&1 || { echo "jq is required. Install it and retry."; exit 2; }

has_pw_dump() { command -v pw-dump >/dev/null 2>&1; }
has_pactl() { command -v pactl >/dev/null 2>&1; }

check_pw_dump() {
  pw-dump 2>/dev/null | jq -e '.[] | select(.type=="stream") | .props? | select(
      (."media.class"|tostring|test("video|Video/Source";"i"))
    or (."node.name"|tostring|test("screen|capture";"i"))
    or (."application.name"|tostring|test("discord";"i"))
    or (."application.process.binary"|tostring|test("discord";"i"))
  )' >/dev/null 2>&1
}

check_pactl() {
  pactl list source-outputs 2>/dev/null | grep -Ei 'discord|monitor|screen|capture' >/dev/null 2>&1
}

set_privacy() {
  local val=$1 # "true" or "false"
  local tmp
  tmp=$(mktemp)
  # Ensure privacy object exists and set hide-previews. Keep placeholder if present.
  jq --argjson v $( [ "$val" = "true" ] && echo true || echo false ) '
    if .privacy == null then . + {privacy: {"hide-previews": $v, "placeholder-text": "Hidden while streaming"}} 
    else .privacy["hide-previews"] = $v | . end' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"
  # Ask swaync to reload if running
  if pgrep -x swaync >/dev/null 2>&1; then
    pkill -HUP swaync || true
  fi
}

# initial state
prev=0
if has_pw_dump || has_pactl; then
  :
else
  echo "Requires either pw-dump (pipewire-utils) or pactl (pulseaudio/pulse) to detect streams." >&2
  exit 2
fi

while true; do
  streaming=0
  if has_pw_dump; then
    if check_pw_dump; then streaming=1; fi
  elif has_pactl; then
    if check_pactl; then streaming=1; fi
  fi

  if [ "$streaming" -ne "$prev" ]; then
    if [ "$streaming" -eq 1 ]; then
      echo "Detected Discord screen share — enabling hide-previews"
      set_privacy true
    else
      echo "No screen share detected — disabling hide-previews"
      set_privacy false
    fi
    prev=$streaming
  fi

  sleep "$INTERVAL"
done
