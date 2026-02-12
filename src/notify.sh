#!/bin/bash

# Notification helper function for appimage-integrator
# Respects silent setting from config file

notify() {
    local title="$1"
    local message="$2"
    local button_text="${3:-}"  # Optional button text
    local command_to_execute="${4:-}"  # Optional command to execute
    
    # Load config to check silent setting
    local config_user="$HOME/.config/appimage-integrator/appimage-integrator.conf"
    local config_system="/etc/appimage-integrator/appimage-integrator.conf"
    local silent=false
    
    if [[ -f "$config_user" ]]; then
        source "$config_user"
    elif [[ -f "$config_system" ]]; then
        source "$config_system"
    fi
    
    # Only send notification if not silent
    if [[ "$silent" != "true" ]] && command -v notify-send &> /dev/null; then
        if [ -n "$button_text" ] && [ -n "$command_to_execute" ]; then
            # Send notification with action button in background
            # --expire-time=0 makes it persist until user interacts
            (notify-send "$title" "$message" --expire-time=0 --action="action=$button_text" 2>/dev/null | while read -r response; do
                if [ "$response" = "action" ]; then
                    eval "$command_to_execute" &
                fi
            done) &
        else
            # Send notification without action
            notify-send "$title" "$message" &
        fi
    fi
}
