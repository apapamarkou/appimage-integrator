#!/bin/bash

# Logging helper function for appimage-integrator
# Uses systemd-cat for proper systemd journal integration

log() {
    local level="$1"
    shift
    
    # Load config to check log_level setting
    local config_user="$HOME/.config/appimage-integrator/appimage-integrator.conf"
    local config_system="/etc/appimage-integrator/appimage-integrator.conf"
    local log_level=3
    
    if [[ -f "$config_user" ]]; then
        source "$config_user"
    elif [[ -f "$config_system" ]]; then
        source "$config_system"
    fi
    
    # Check if we should log based on level
    case "$log_level" in
        0) return 0 ;;  # No logs
        1) [[ "$level" != "err" ]] && return 0 ;;  # Only errors
        2) [[ "$level" != "err" && "$level" != "warning" ]] && return 0 ;;  # Errors and warnings
        3) ;;  # All logs (info, warning, err, debug)
    esac
    
    if command -v systemd-cat &> /dev/null; then
        # Try with --user flag, fall back without it if not supported
        if systemd-cat --user -t appimage-integrator -p "$level" echo "$*" 2>/dev/null; then
            return 0
        else
            systemd-cat -t appimage-integrator -p "$level" echo "$*" 2>/dev/null || echo "[$level] $*" >&2
        fi
    else
        # Fallback to stderr if systemd-cat not available
        echo "[$level] $*" >&2
    fi
}
