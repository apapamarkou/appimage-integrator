#!/bin/bash

#     _               ___
#    / \   _ __  _ __|_ _|_ __ ___   __ _  __ _  ___
#   / _ \ | '_ \| '_ \| || '_ ` _ \ / _` |/ _` |/ _ \
#  / ___ \| |_) | |_) | || | | | | | (_| | (_| |  __/
# /_/   \_\ .__/| .__/___|_| |_| |_|\__,_|\__, |\___|
#         |_|   |_|                       |___/
#  ___       _                       _
# |_ _|_ __ | |_ ___  __ _ _ __ __ _| |_ ___  _ __
#  | || '_ \| __/ _ \/ _` | '__/ _` | __/ _ \| '__|
#  | || | | | ||  __/ (_| | | | (_| | || (_) | |
# |___|_| |_|\__\___|\__, |_|  \__,_|\__\___/|_|
#                    |___/
#
# Author Andrianos Papamarkou
# Email: apapamarkou@yahoo.com
#

get_translated() {
	local key="$1"
	local lang="${LANG%%.*}"
	local msg_file
	local fallback_file
	msg_file="$(dirname "$0")/messages.$lang"
	fallback_file="$(dirname "$0")/messages.en_US"

	# Try locale-specific file first
	if [ -f "$msg_file" ]; then
		local result
		result=$(grep "^$key=" "$msg_file" 2>/dev/null | cut -d'=' -f2-)
		[ -n "$result" ] && echo "$result" && return
	fi

	# Fallback to English
	if [ -f "$fallback_file" ]; then
		grep "^$key=" "$fallback_file" 2>/dev/null | cut -d'=' -f2- || echo "$key"
	else
		echo "$key"
	fi
}
