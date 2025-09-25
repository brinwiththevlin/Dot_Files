#!/usr/bin/env bash
## Author : SUDOER1337
## Rofi Pomodoro Timer

# Configuration
dir="$HOME/.config/rofi/pomodoro/"
theme='pomodoro'
state_file="$HOME/.cache/pomodoro-state"
pid_file="$HOME/.cache/pomodoro-pid"

# Default times (in minutes)
WORK_TIME=25
SHORT_BREAK=5
LONG_BREAK=15
CYCLES_UNTIL_LONG=4

# Create directories
mkdir -p "$dir" "$(dirname "$state_file")"

# Colors for notifications
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize state if it doesn't exist
initialize_state() {
    if [[ ! -f "$state_file" ]]; then
        cat > "$state_file" << EOF
STATE=idle
REMAINING=0
CYCLE=1
TOTAL_CYCLES=0
WORK_TIME=$WORK_TIME
SHORT_BREAK=$SHORT_BREAK
LONG_BREAK=$LONG_BREAK
CYCLES_UNTIL_LONG=$CYCLES_UNTIL_LONG
EOF
    fi
}

# Load current state
load_state() {
    [[ -f "$state_file" ]] && source "$state_file"
}

# Save state
save_state() {
    cat > "$state_file" << EOF
STATE=$STATE
REMAINING=$REMAINING
CYCLE=$CYCLE
TOTAL_CYCLES=$TOTAL_CYCLES
WORK_TIME=$WORK_TIME
SHORT_BREAK=$SHORT_BREAK
LONG_BREAK=$LONG_BREAK
CYCLES_UNTIL_LONG=$CYCLES_UNTIL_LONG
EOF
}

# Format time for display
format_time() {
    local seconds=$1
    local minutes=$((seconds / 60))
    local secs=$((seconds % 60))
    printf "%02d:%02d" $minutes $secs
}

# Get appropriate break type
get_break_type() {
    if ((CYCLE % CYCLES_UNTIL_LONG == 0)); then
        echo "long_break"
    else
        echo "short_break"
    fi
}

# Send notification
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    local icon="${4:-clock}"
    
    notify-send "$title" "$message" -u "$urgency" -i "$icon" -t 5000
    
    # Optional: Play a sound (uncomment if you have a sound file)
    # paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null &
}

# Start timer
start_timer() {
    local duration=$1
    local type="$2"
    
    STATE="$type"
    REMAINING=$((duration * 60))
    save_state()
    
    # Background timer process
    (
        while ((REMAINING > 0)); do
            sleep 1
            ((REMAINING--))
            
            # Update state file every 10 seconds to avoid too much I/O
            if ((REMAINING % 10 == 0)); then
                load_state
                save_state
            fi
        done
        
        # Timer finished
        case "$type" in
            "work")
                ((CYCLE++))
                ((TOTAL_CYCLES++))
                send_notification "🍅 Work Complete!" "Time for a break! Cycle $TOTAL_CYCLES finished." "critical"
                
                # Auto-start break
                break_type=$(get_break_type)
                if [[ "$break_type" == "long_break" ]]; then
                    start_timer $LONG_BREAK "long_break"
                else
                    start_timer $SHORT_BREAK "short_break"
                fi
                ;;
            "short_break")
                send_notification "☕ Break Over!" "Back to work! Starting work session." "normal"
                start_timer $WORK_TIME "work"
                ;;
            "long_break")
                CYCLE=1
                send_notification "🎉 Long Break Over!" "Great job! Ready for a new set of cycles?" "normal"
                STATE="idle"
                REMAINING=0
                ;;
        esac
        
        save_state
        
    ) &
    
    echo $! > "$pid_file"
}

# Stop timer
stop_timer() {
    if [[ -f "$pid_file" ]]; then
        local pid=$(cat "$pid_file")
        kill "$pid" 2>/dev/null
        rm -f "$pid_file"
    fi
    STATE="idle"
    REMAINING=0
    save_state
}

# Pause/Resume timer
toggle_timer() {
    if [[ -f "$pid_file" ]]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            kill -STOP "$pid"
            STATE="${STATE}_paused"
        else
            kill -CONT "$pid"
            STATE="${STATE/_paused/}"
        fi
        save_state
    fi
}

# Build menu
build_menu() {
    load_state
    
    local status_icon="⏸️"
    local status_text="Idle"
    local time_display=""
    
    case "$STATE" in
        "work")
            status_icon="🍅"
            status_text="Working"
            time_display=" ($(format_time $REMAINING))"
            ;;
        "short_break")
            status_icon="☕"
            status_text="Short Break"
            time_display=" ($(format_time $REMAINING))"
            ;;
        "long_break")
            status_icon="🛋️"
            status_text="Long Break"
            time_display=" ($(format_time $REMAINING))"
            ;;
        "work_paused"|"short_break_paused"|"long_break_paused")
            status_icon="⏸️"
            status_text="Paused"
            time_display=" ($(format_time $REMAINING))"
            ;;
        *)
            status_icon="⏸️"
            status_text="Idle"
            ;;
    esac
    
    echo "$status_icon $status_text$time_display"
    echo "---"
    
    if [[ "$STATE" == "idle" ]]; then
        echo "🍅 Start Work ($WORK_TIME min)"
        echo "☕ Start Short Break ($SHORT_BREAK min)"
        echo "🛋️ Start Long Break ($LONG_BREAK min)"
    else
        if [[ "$STATE" == *"paused"* ]]; then
            echo "▶️ Resume Timer"
        else
            echo "⏸️ Pause Timer"
        fi
        echo "⏹️ Stop Timer"
    fi
    
    echo "---"
    echo "📊 Stats: Cycle $CYCLE | Completed: $TOTAL_CYCLES"
    echo "⚙️ Settings"
    echo "🔄 Reset All"
    echo "❌ Exit"
}

# Settings menu
show_settings() {
    while true; do
        choice=$(echo -e "Work Time: ${WORK_TIME}m\nShort Break: ${SHORT_BREAK}m\nLong Break: ${LONG_BREAK}m\nCycles until long break: $CYCLES_UNTIL_LONG\n---\nBack to Timer" | rofi \
            -dmenu \
            -theme "${dir}/${theme}.rasi" \
            -p "Settings " \
            -mesg "Select setting to modify" \
            2>/dev/null)
        
        case "$choice" in
            "Work Time:"*)
                new_time=$(echo "" | rofi -dmenu -p "Work time (minutes): " -theme "${dir}/${theme}.rasi")
                [[ "$new_time" =~ ^[0-9]+$ ]] && WORK_TIME="$new_time" && save_state
                ;;
            "Short Break:"*)
                new_time=$(echo "" | rofi -dmenu -p "Short break (minutes): " -theme "${dir}/${theme}.rasi")
                [[ "$new_time" =~ ^[0-9]+$ ]] && SHORT_BREAK="$new_time" && save_state
                ;;
            "Long Break:"*)
                new_time=$(echo "" | rofi -dmenu -p "Long break (minutes): " -theme "${dir}/${theme}.rasi")
                [[ "$new_time" =~ ^[0-9]+$ ]] && LONG_BREAK="$new_time" && save_state
                ;;
            "Cycles until long break:"*)
                new_cycles=$(echo "" | rofi -dmenu -p "Cycles until long break: " -theme "${dir}/${theme}.rasi")
                [[ "$new_cycles" =~ ^[0-9]+$ ]] && CYCLES_UNTIL_LONG="$new_cycles" && save_state
                ;;
            "Back to Timer")
                return
                ;;
            *)
                [[ -z "$choice" ]] && return
                ;;
        esac
    done
}

# Main interface
show_interface() {
    while true; do
        choice=$(build_menu | rofi \
            -dmenu \
            -theme "${dir}/${theme}.rasi" \
            -p "Pomodoro " \
            -mesg "Current: $(date '+%H:%M') | Total sessions: $TOTAL_CYCLES" \
            2>/dev/null)
        
        case "$choice" in
            "🍅 Start Work"*)
                start_timer $WORK_TIME "work"
                send_notification "🍅 Work Started!" "Focus time! $WORK_TIME minutes of productivity." "normal"
                ;;
            "☕ Start Short Break"*)
                start_timer $SHORT_BREAK "short_break"
                send_notification "☕ Break Started!" "Relax for $SHORT_BREAK minutes." "normal"
                ;;
            "🛋️ Start Long Break"*)
                start_timer $LONG_BREAK "long_break"
                send_notification "🛋️ Long Break!" "Enjoy your $LONG_BREAK minute break!" "normal"
                ;;
            "▶️ Resume Timer"|"⏸️ Pause Timer")
                toggle_timer
                ;;
            "⏹️ Stop Timer")
                stop_timer
                send_notification "⏹️ Timer Stopped" "Pomodoro session ended." "low"
                ;;
            "⚙️ Settings")
                show_settings
                ;;
            "🔄 Reset All")
                stop_timer
                CYCLE=1
                TOTAL_CYCLES=0
                save_state
                send_notification "🔄 Reset Complete" "All timers and stats reset." "low"
                ;;
            "❌ Exit"|"")
                exit 0
                ;;
        esac
        
        # Small delay to prevent rapid reopening
        sleep 0.1
    done
}

# Parse arguments
case "${1:-}" in
    --start-work)
        initialize_state
        load_state
        start_timer $WORK_TIME "work"
        send_notification "🍅 Work Started!" "Focus time! $WORK_TIME minutes." "normal"
        ;;
    --stop)
        stop_timer
        send_notification "⏹️ Timer Stopped" "Pomodoro session ended." "low"
        ;;
    --toggle)
        initialize_state
        load_state
        toggle_timer
        ;;
    --status)
        initialize_state
        load_state
        echo "State: $STATE, Remaining: $(format_time $REMAINING), Cycle: $CYCLE"
        ;;
    *)
        initialize_state
        show_interface
        ;;
esac
