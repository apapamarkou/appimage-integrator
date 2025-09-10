#!/bin/bash

get_translated() {
    local key="$1"
    local lang="${LANG%%.*}"
    local msg_file="$(dirname "$0")/messages.$lang"
    local fallback_file="$(dirname "$0")/messages.en_US"
    
    # Try locale-specific file first
    if [ -f "$msg_file" ]; then
        local result=$(grep "^$key=" "$msg_file" 2>/dev/null | cut -d'=' -f2-)
        [ -n "$result" ] && echo "$result" && return
    fi
    
    # Fallback to English
    if [ -f "$fallback_file" ]; then
        grep "^$key=" "$fallback_file" 2>/dev/null | cut -d'=' -f2- || echo "$key"
    else
        echo "$key"
    fi
}