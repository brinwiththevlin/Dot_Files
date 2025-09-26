#!/bin/bash
if pgrep wf-recorder > /dev/null; then
    killall wf-recorder
    notify-send "Recording stopped"
else
    wf-recorder -g "$(slurp)" -f ~/Videos/Screencasts/$(date +'%Y-%m-%d_%H-%M-%S-')recording.mp4 &
    notify-send "Recording started"
fi
