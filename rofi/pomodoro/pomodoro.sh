#!/usr/bin/env bash
## Author : SUDOER1337
## Enhanced Rofi Pomodoro Timer with Custom Named Timers

# Configuration
dir="$HOME/.config/rofi/pomodoro/"
theme='pomodoro.rasi'
state_file="$HOME/.cache/pomodoro-state"
pid_file="$HOME/.cache/pomodoro-pid"
custom_timers_file="$HOME/.cache/pomodoro-custom-timers"

# Default times (in minutes)
WORK_TIME=25
SHORT_BREAK=5
LONG_BREAK=15
CYCLES_UNTIL_LONG=4

# Create directories
mkdir -p "$dir" "$(dirname "$state_file")"

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
CURRENT_TIMER_NAME=""
EOF
    fi
}

# Initialize custom timers file
initialize_custom_timers() {
    if [[ ! -f "$custom_timers_file" ]]; then
        cat > "$custom_timers_file" << EOF
# Custom Timer Presets (format: NAME:MINUTES:DESCRIPTION)
Deep Work:45:Focused coding/writing session
Quick Break:3:Short mental break
Meeting:30:Standard meeting duration
Coding Sprint:90:Extended coding session
Reading:20:Reading/learning time
Exercise:15:Quick workout break
Meditation:10:Mindfulness session
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
CURRENT_TIMER_NAME="$CURRENT_TIMER_NAME"
EOF
}

# Load custom timers, filtering comments and blank lines
load_custom_timers() {
    if [[ -f "$custom_timers_file" ]]; then
        grep -v '^#' "$custom_timers_file" | grep -v '^[[:space:]]*$'
    fi
}

# Add custom timer
add_custom_timer() {
    local name duration description
    
    name=$(echo "" | rofi -dmenu -p "Timer name: " -theme "${dir}/${theme}")
    [[ -z "$name" ]] && return
    
    duration=$(echo "" | rofi -dmenu -p "Duration (minutes): " -theme "${dir}/${theme}")
    [[ ! "$duration" =~ ^[0-9]+$ ]] && return
    
    description=$(echo "" | rofi -dmenu -p "Description (optional): " -theme "${dir}/${theme}")
    [[ -z "$description" ]] && description="Custom timer"
    
    # Check if timer already exists
    if grep -q "^${name}:" "$custom_timers_file" 2>/dev/null; then
        local confirm
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Timer '$name' exists. Replace? " -theme "${dir}/${theme}")
        [[ "$confirm" != "Yes" ]] && return
        
        # Remove existing timer
        grep -v "^${name}:" "$custom_timers_file" > "${custom_timers_file}.tmp" 2>/dev/null || true
        mv "${custom_timers_file}.tmp" "$custom_timers_file" 2>/dev/null || true
    fi
    
    # Add new timer
    echo "${name}:${duration}:${description}" >> "$custom_timers_file"
    notify-send "Timer Added" "Custom timer '$name' ($duration min) created!" -u "normal"
}

# Edit custom timer
edit_custom_timer() {
    local timers selected name duration description
    
    timers=$(load_custom_timers | sed 's/:/ | /g')
    [[ -z "$timers" ]] && { notify-send "No Timers" "No custom timers found"; return; }
    
    selected=$(echo "$timers" | rofi -dmenu -p "Select timer to edit: " -theme "${dir}/${theme}")
    [[ -z "$selected" ]] && return
    
    name=$(echo "$selected" | cut -d'|' -f1 | xargs)
    
    # Get current values
    local timer_line current_duration current_desc
    timer_line=$(grep "^${name}:" "$custom_timers_file")
    current_duration=$(echo "$timer_line" | cut -d':' -f2)
    current_desc=$(echo "$timer_line" | cut -d':' -f3)
    
    # Edit values
    duration=$(echo "$current_duration" | rofi -dmenu -p "Duration (minutes): " -theme "${dir}/${theme}")
    [[ ! "$duration" =~ ^[0-9]+$ ]] && duration="$current_duration"
    
    description=$(echo "$current_desc" | rofi -dmenu -p "Description: " -theme "${dir}/${theme}")
    [[ -z "$description" ]] && description="$current_desc"
    
    # Update timer
    grep -v "^${name}:" "$custom_timers_file" > "${custom_timers_file}.tmp"
    echo "${name}:${duration}:${description}" >> "${custom_timers_file}.tmp"
    mv "${custom_timers_file}.tmp" "$custom_timers_file"
    
    notify-send "Timer Updated" "Timer '$name' updated to $duration minutes" -u "normal"
}

# Delete custom timer
delete_custom_timer() {
    local timers selected name
    
    timers=$(load_custom_timers | sed 's/:/ | /g')
    [[ -z "$timers" ]] && { notify-send "No Timers" "No custom timers found"; return; }
    
    selected=$(echo "$timers" | rofi -dmenu -p "Select timer to delete: " -theme "${dir}/${theme}")
    [[ -z "$selected" ]] && return
    
    name=$(echo "$selected" | cut -d'|' -f1 | xargs)
    
    local confirm
    confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Delete timer '$name'? " -theme "${dir}/${theme}")
    [[ "$confirm" != "Yes" ]] && return
    
    grep -v "^${name}:" "$custom_timers_file" > "${custom_timers_file}.tmp"
    mv "${custom_timers_file}.tmp" "$custom_timers_file"
    
    notify-send "Timer Deleted" "Custom timer '$name' removed" -u "low"
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
    local timer_name="${3:-$type}"
    
    STATE="$type"
    REMAINING=$((duration * 60))
    CURRENT_TIMER_NAME="$timer_name"
    save_state
    
    # Background timer process
    (
        while ((REMAINING > 0)); do
            sleep 1
            ((REMAINING--))
            
            # Update state file periodically to avoid too much I/O
            if ((REMAINING % 5 == 0)); then
                save_state
            fi
        done
        
        # Timer finished, load the latest state before modifying
        load_state
        case "$type" in
            "work")
                ((CYCLE++))
                ((TOTAL_CYCLES++))
                send_notification "🍅 Work Complete!" "Time for a break! Cycle $TOTAL_CYCLES finished." "critical"
                
                # Auto-start break
                break_type=$(get_break_type)
                if [[ "$break_type" == "long_break" ]]; then
                    start_timer "$LONG_BREAK" "long_break" "Long Break"
                else
                    start_timer "$SHORT_BREAK" "short_break" "Short Break"
                fi
                ;;
            "short_break"|"long_break")
                send_notification "☕ Break Over!" "Back to work! Starting work session." "normal"
                start_timer "$WORK_TIME" "work" "Work Session"
                ;;
            "custom")
                send_notification "✅ Timer Complete!" "'$timer_name' session finished!" "critical"
                STATE="idle"
                REMAINING=0
                CURRENT_TIMER_NAME=""
                ;;
        esac
        
        save_state
        
    ) &
    
    echo $! > "$pid_file"
}

# Stop timer
stop_timer() {
    if [[ -f "$pid_file" ]]; then
        local pid
        pid=$(cat "$pid_file")
        kill "$pid" 2>/dev/null
        rm -f "$pid_file"
    fi
    STATE="idle"
    REMAINING=0
    CURRENT_TIMER_NAME=""
    save_state
}

# Pause/Resume timer
toggle_timer() {
    if [[ -f "$pid_file" ]]; then
        local pid
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            if [[ "$STATE" == *"_paused" ]]; then
                kill -CONT "$pid" 2>/dev/null
                STATE="${STATE/_paused/}"
            else
                kill -STOP "$pid" 2>/dev/null
                STATE="${STATE}_paused"
            fi
        fi
        save_state
    fi
}

# Build main menu
build_menu() {
    load_state
    
    local status_icon="✨"
    local status_text="Idle"
    local time_display=""
    
    case "$STATE" in
        "work")
            status_icon="🍅"
            status_text="${CURRENT_TIMER_NAME:-Working}"
            time_display=" ($(format_time $REMAINING))"
            ;;
        "short_break")
            status_icon="☕"
            status_text="${CURRENT_TIMER_NAME:-Short Break}"
            time_display=" ($(format_time $REMAINING))"
            ;;
        "long_break")
            status_icon="🛋️"
            status_text="${CURRENT_TIMER_NAME:-Long Break}"
            time_display=" ($(format_time $REMAINING))"
            ;;
        "custom")
            status_icon="⏱️"
            status_text="${CURRENT_TIMER_NAME:-Custom Timer}"
            time_display=" ($(format_time $REMAINING))"
            ;;
        *"_paused")
            status_icon="⏸️"
            status_text="${CURRENT_TIMER_NAME:-Paused}"
            time_display=" ($(format_time $REMAINING))"
            ;;
        *)
            status_icon="✨"
            status_text="Idle"
            ;;
    esac
    
    echo "$status_icon $status_text$time_display"
    echo "---"
    
    if [[ "$STATE" == "idle" ]]; then
        echo "🍅 Start Work ($WORK_TIME min)"
        echo "☕ Start Short Break ($SHORT_BREAK min)"
        echo "🛋️ Start Long Break ($LONG_BREAK min)"
        echo "---"
        
        # Show custom timers
        local custom_timers
        custom_timers=$(load_custom_timers)
        if [[ -n "$custom_timers" ]]; then
            echo "⏱️ Custom Timers..." # Go to submenu
            while IFS=':' read -r name duration description; do
                [[ -n "$name" && -n "$duration" ]] && echo "▶️ $name ($duration min)"
            done <<< "$custom_timers"
        fi
        
    else
        if [[ "$STATE" == *"_paused" ]]; then
            echo "▶️ Resume Timer"
        else
            echo "⏸️ Pause Timer"
        fi
        echo "⏹️ Stop Timer"
    fi
    
    echo "---"
    echo "📊 Stats: Cycle $CYCLE | Completed: $TOTAL_CYCLES"
    echo "⚙️ Settings"
    echo "🛠️ Manage Custom Timers"
    echo "🔄 Reset All"
    echo "❌ Exit"
}

# Custom timers submenu
show_custom_timers() {
    while true; do
        local menu_items=""
        local custom_timers
        custom_timers=$(load_custom_timers)
        
        if [[ -n "$custom_timers" ]]; then
            while IFS=':' read -r name duration description; do
                menu_items="${menu_items}▶️ $name ($duration min) - $description\n"
            done <<< "$custom_timers"
            menu_items="${menu_items}---\n"
        else
            menu_items="No custom timers found\n---\n"
        fi
        
        menu_items="${menu_items}➕ Add New Timer\n"
        menu_items="${menu_items}✏️ Edit Timer\n"
        menu_items="${menu_items}🗑️ Delete Timer\n"
        menu_items="${menu_items}---\n"
        menu_items="${menu_items}🔙 Back to Main Menu"
        
        local choice
        choice=$(echo -e "$menu_items" | rofi \
            -dmenu \
            -theme "${dir}/${theme}" \
            -p "Custom Timers" \
            -mesg "Manage your custom timer presets" \
            2>/dev/null)
        
        case "$choice" in
            "▶️ "*)
                local timer_name timer_line duration
                timer_name=$(echo "$choice" | sed 's/▶️ //' | cut -d'(' -f1 | xargs)
                timer_line=$(grep "^${timer_name}:" "$custom_timers_file")
                duration=$(echo "$timer_line" | cut -d':' -f2)
                
                start_timer "$duration" "custom" "$timer_name"
                send_notification "⏱️ Custom Timer Started!" "'$timer_name' ($duration min) started!" "normal"
                return
                ;;
            "➕ Add New Timer")
                add_custom_timer
                ;;
            "✏️ Edit Timer")
                edit_custom_timer
                ;;
            "🗑️ Delete Timer")
                delete_custom_timer
                ;;
            "🔙 Back to Main Menu"|"")
                return
                ;;
        esac
    done
}

# Manage custom timers menu
show_manage_timers() {
    local choice
    choice=$(echo -e "➕ Add New Timer\n✏️ Edit Existing Timer\n🗑️ Delete Timer\n🔙 Back" | rofi \
        -dmenu \
        -theme "${dir}/${theme}" \
        -p "Manage Timers" \
        2>/dev/null)
    
    case "$choice" in
        "➕ Add New Timer")
            add_custom_timer
            ;;
        "✏️ Edit Existing Timer")
            edit_custom_timer
            ;;
        "🗑️ Delete Timer")
            delete_custom_timer
            ;;
    esac
}

# Settings menu
show_settings() {
    while true; do
        local choice
        choice=$(echo -e "Work Time: ${WORK_TIME}m\nShort Break: ${SHORT_BREAK}m\nLong Break: ${LONG_BREAK}m\nCycles until long break: $CYCLES_UNTIL_LONG\n---\nBack to Timer" | rofi \
            -dmenu \
            -theme "${dir}/${theme}" \
            -p "Settings" \
            -mesg "Configure default Pomodoro settings" \
            2>/dev/null)
        
        case "$choice" in
            "Work Time:"*)
                new_time=$(echo "" | rofi -dmenu -p "Work time (minutes): " -theme "${dir}/${theme}")
                [[ "$new_time" =~ ^[0-9]+$ ]] && WORK_TIME="$new_time" && save_state
                ;;
            "Short Break:"*)
                new_time=$(echo "" | rofi -dmenu -p "Short break (minutes): " -theme "${dir}/${theme}")
                [[ "$new_time" =~ ^[0-9]+$ ]] && SHORT_BREAK="$new_time" && save_state
                ;;
            "Long Break:"*)
                new_time=$(echo "" | rofi -dmenu -p "Long break (minutes): " -theme "${dir}/${theme}")
                [[ "$new_time" =~ ^[0-9]+$ ]] && LONG_BREAK="$new_time" && save_state
                ;;
            "Cycles until long break:"*)
                new_cycles=$(echo "" | rofi -dmenu -p "Cycles until long break: " -theme "${dir}/${theme}")
                [[ "$new_cycles" =~ ^[0-9]+$ ]] && CYCLES_UNTIL_LONG="$new_cycles" && save_state
                ;;
            "Back to Timer"|"")
                return
                ;;
        esac
    done
}

# Main interface loop
show_interface() {
    while true; do
        local choice
        choice=$(build_menu | rofi \
            -dmenu \
            -theme "${dir}/${theme}" \
            -p "Pomodoro" \
            -mesg "Current: $(date '+%H:%M') | Total sessions: $TOTAL_CYCLES" \
            2>/dev/null)
        
        case "$choice" in
            "🍅 Start Work"*)
                start_timer "$WORK_TIME" "work" "Work Session"
                send_notification "🍅 Work Started!" "Focus time! $WORK_TIME minutes of productivity." "normal"
                ;;
            "☕ Start Short Break"*)
                start_timer "$SHORT_BREAK" "short_break" "Short Break"
                send_notification "☕ Break Started!" "Relax for $SHORT_BREAK minutes." "normal"
                ;;
            "🛋️ Start Long Break"*)
                start_timer "$LONG_BREAK" "long_break" "Long Break"
                send_notification "🛋️ Long Break!" "Enjoy your $LONG_BREAK minute break!" "normal"
                ;;
            "⏱️ Custom Timers...")
                show_custom_timers
                ;;
            "▶️ "*)
                # Handle custom timer selection from main menu
                local timer_name timer_line duration
                timer_name=$(echo "$choice" | sed 's/▶️ //' | cut -d'(' -f1 | xargs)
                timer_line=$(grep "^${timer_name}:" "$custom_timers_file")
                duration=$(echo "$timer_line" | cut -d':' -f2)
                
                start_timer "$duration" "custom" "$timer_name"
                send_notification "⏱️ Timer Started!" "'$timer_name' ($duration min) started!" "normal"
                ;;
            "▶️ Resume Timer"|"⏸️ Pause Timer")
                toggle_timer
                ;;
            "⏹️ Stop Timer")
                stop_timer
                send_notification "⏹️ Timer Stopped" "Timer session ended." "low"
                ;;
            "⚙️ Settings")
                show_settings
                ;;
            "🛠️ Manage Custom Timers")
                show_manage_timers
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

### MAIN SCRIPT LOGIC ###
initialize_state
initialize_custom_timers
load_state

# Parse command-line arguments
case "${1:-}" in
    --start-work)
        start_timer "$WORK_TIME" "work" "Work Session"
        send_notification "🍅 Work Started!" "Focus time! $WORK_TIME minutes." "normal"
        ;;
    --start-custom)
        if [[ -n "$2" ]]; then
            timer_line=$(grep "^${2}:" "$custom_timers_file")
            if [[ -n "$timer_line" ]]; then
                duration=$(echo "$timer_line" | cut -d':' -f2)
                start_timer "$duration" "custom" "$2"
                send_notification "⏱️ Timer Started!" "'$2' started!" "normal"
            else
                notify-send "Timer Not Found" "Custom timer '$2' not found" -u "critical"
            fi
        else
            echo "Usage: $0 --start-custom <timer-name>"
        fi
        ;;
    --add-timer)
        add_custom_timer
        ;;
    --list-timers)
        echo "Built-in Pomodoro timers:"
        echo "🍅 Work: $WORK_TIME minutes"
        echo "☕ Short Break: $SHORT_BREAK minutes"
        echo "🛋️ Long Break: $LONG_BREAK minutes"
        echo ""
        echo "Custom timers:"
        load_custom_timers | while IFS=':' read -r name duration description; do
            echo "⏱️ $name: $duration minutes - $description"
        done
        ;;
    --stop)
        stop_timer
        send_notification "⏹️ Timer Stopped" "Timer session ended." "low"
        ;;
    --toggle)
        toggle_timer
        ;;
    --status)
        if [[ "$STATE" != "idle" ]]; then
            echo "Timer: ${CURRENT_TIMER_NAME:-$STATE} | Remaining: $(format_time "$REMAINING") | Cycle: $CYCLE"
        else
            echo "Idle | Completed sessions: $TOTAL_CYCLES"
        fi
        ;;
    *)
        # Default action: show the Rofi interface
        show_interface
        ;;
esac
