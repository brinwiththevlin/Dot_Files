#!/usr/bin/env bash
## Author : Ghostvox
## Github : ?
#
## Rofi   : Calculator (rofi-calc - back to working version)

# Configuration  
dir="$HOME/.config/rofi/calc/"
theme='calc'

# Simple addition: save last result for reference
last_result_file="$HOME/.cache/rofi-last-result"

# Show last result if requested
if [[ "$1" == "--last" ]]; then
    if [[ -f "$last_result_file" ]]; then
        echo "Last result: $(cat "$last_result_file")"
    else
        echo "No previous result"
    fi
    exit 0
fi

# Your original working rofi-calc command with live preview enabled
rofi \
    -show calc \
    -theme ${dir}/${theme}.rasi \
    -no-show-match false \
    -auto-select false \
    -calc-command "echo '{result}' > '$last_result_file' && echo -n '{result}' | wl-copy && notify-send 'Calculator' 'Result: {result}' -t 2000"
