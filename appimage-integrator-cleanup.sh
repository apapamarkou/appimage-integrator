#!/bin/bash

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