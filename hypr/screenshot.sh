#!/usr/bin/env sh
case "$1" in
  3)
    output=$(hyprshot -m window 2>&1)
    if [ -z "$output" ]; then
      # No output = success
      paplay "/usr/share/sounds/freedesktop/stereo/screen-capture.oga"
    else
      # Has output = error message
      notify-send "Screenshot Error" "Failed to take window screenshot: $output"
    fi
    ;;
  4)
    output=$(hyprshot -m region )
    if [ -z "$output" ]; then
      # No output = success
      paplay "/usr/share/sounds/freedesktop/stereo/screen-capture.oga"
    else
      # Has output = error message
      notify-send "Screenshot Error" "Failed to take region screenshot: $output"
    fi
    ;;
  *)
    echo "Usage: $0 [3|4]"
    echo "  3 - Take a window screenshot"
    echo "  4 - Take a region screenshot"
    exit 1
    ;;
esac
