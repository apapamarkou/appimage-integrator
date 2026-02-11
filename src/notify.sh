#!/bin/bash

# Notification helper function for appimage-integrator
# Respects silent setting from config file

notify() {
    local title="$1"
    local message="$2"
    
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
        notify-send "$title" "$message"
    fi
}
