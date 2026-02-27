#!/bin/bash

# Ensure the directory exists
SAVE_DIR="$HOME/Videos/Screencasts"
mkdir -p "$SAVE_DIR"

if pgrep -x "wf-recorder" > /dev/null; then
    killall -s SIGINT wf-recorder
    notify-send "Recording" "Stopped and saved to $SAVE_DIR"
else
    # Store slurp output to check if user cancelled
    GEOM=$(slurp)
    
    if [ -z "$GEOM" ]; then
        notify-send "Recording" "Cancelled"
        exit 0
    fi

    wf-recorder -g "$GEOM" -f "$SAVE_DIR/$(date +'%Y-%m-%d_%H-%M-%S')_recording.mp4" &
    notify-send "Recording" "Started"
fi
