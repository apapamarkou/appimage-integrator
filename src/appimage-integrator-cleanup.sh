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
# This script removes the application icon and the .desktop entry for the given AppImage.

# Check if an argument was provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <AppImage>"
    exit 1
fi

APPIMAGE="$1"

APPIMAGE_FULL_NAME="${APPIMAGE##*/}"
APPIMAGE_NAME="${APPIMAGE_FULL_NAME%%.*}"

# remove application icon
rm "$HOME/Applications/.icons/$APPIMAGE_NAME*"
# remove .desktop entry
rm "$HOME/.local/share/applications/$APPIMAGE_NAME.desktop"


notify-send "Appimage integrator" "The application $APPIMAGE_NAME removed."
