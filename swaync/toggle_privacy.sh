#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$DIR/config.json"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required. Install it and retry."
  exit 2
fi

if [ ! -f "$CONFIG" ]; then
  echo "Config not found: $CONFIG"
  exit 1
fi

# Toggle the boolean at .privacy["hide-previews"]
TMP=$(mktemp)
jq 'if .privacy and (.privacy["hide-previews"]|type)=="boolean" then .privacy["hide-previews"] |= not else . end' "$CONFIG" > "$TMP" && mv "$TMP" "$CONFIG"

NEW=$(jq -r '.privacy["hide-previews"]' "$CONFIG")
echo "privacy.hide-previews is now: $NEW"

# Try to reload swaync if running (send HUP). If not running, inform the user.
if pgrep -x swaync >/dev/null 2>&1; then
  pkill -HUP swaync && echo "Sent HUP to swaync to reload config."
else
  echo "swaync is not running; restart it to apply the change."
fi
