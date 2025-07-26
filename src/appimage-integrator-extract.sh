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
# This script is used to extract AppImages and create desktop entries for them.


# Introduce Applications folder if not exist
# make a hidden folder named .icons to hold the appimage icons
mkdir -p $HOME/Applications/.icons

# Check if an argument was provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <AppImage>"
    exit 1
fi

# Wait until the file is finished (if the action is copy or download)
wait_for_file_copy() {
    local file="$1"
    local previous_size=0
    local current_size=0
    local stable_count=0

    while true; do
        if [ -f "$file" ]; then
            current_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            
            if [ "$current_size" = "$previous_size" ]; then
                stable_count=$((stable_count + 1))
                # If file size remains same for 3 checks (3 seconds), consider it complete
                if [ $stable_count -ge 3 ]; then
                    break
                fi
            else
                stable_count=0
            fi
            
            previous_size=$current_size
        fi
        sleep 1
    done
}
# Get the AppImage file path from the command line argument
APPIMAGE="$1"

# Wait for file to finish copying
echo "Waiting for file to finish copying..."
wait_for_file_copy "$APPIMAGE"

# Check if the file exists
if [ ! -f "$APPIMAGE" ]; then
    echo "File not found: $APPIMAGE"
    exit 1
fi

# Get the AppImage name with the extension
APPIMAGE_FULL_NAME="${APPIMAGE##*/}"

# Get the AppImage name without the extension
APPIMAGE_NAME="${APPIMAGE_FULL_NAME%%.*}"

# Notify the desktop user that the script is running
notify-send "Appimage integrator" "Setting up $APPIMAGE_NAME"

# Create a unique temporary working directory in ~/tmp
WORKDIR="$HOME/tmp/$APPIMAGE_NAME/"
mkdir -p "$WORKDIR"

# Change to the working directory
cd "$WORKDIR" || exit

# make appimage executable
chmod a+x $APPIMAGE

# Extract the AppImage
echo "Extracting -$APPIMAGE- -$APPIMAGE_NAME- -$APPIMAGE_FULL_NAME-"
if ! "$APPIMAGE" --appimage-extract > /dev/null 2>&1; then
    echo "Failed to extract the AppImage. Make sure it's a valid AppImage."
    exit 1
fi

# Define paths for extracted files
EXTRACTED_DIR="./squashfs-root"
echo "Extracted directory: $EXTRACTED_DIR"


# Check if the extraction directory exists
if [ ! -d "$EXTRACTED_DIR" ]; then
    echo "Extraction directory not found: $EXTRACTED_DIR"
    exit 1
fi

# Locate .desktop and icon files into extracted appimage
# replaced DESKTOP_FILE=$(find "$EXTRACTED_DIR" -maxdepth 1 -name "*.desktop" | head -n 1)
# causing possible locale problems
for f in "$EXTRACTED_DIR"/*.desktop*; do
    [ -f "$f" ] && DESKTOP_FILE="$f" && break
done
echo "Desktop file $DESKTOP_FILE"


# replaced ICON_FILE=$(find "$EXTRACTED_DIR" -maxdepth 1 \( -name "*.png" -o -name "*.svg" \) | head -n 1)
# causing possible locale problems
for f in "$EXTRACTED_DIR"/*.png "$EXTRACTED_DIR"/*.svg; do
    [ -f "$f" ] && ICON_FILE="$f" && break
done
ICON_FILE_NAME="${ICON_FILE##*/}"
echo "Icon file $ICON_FILE"

# Check if .desktop file and icon file were found
if [ -z "$DESKTOP_FILE" ]; then
    echo "No .desktop file found in the AppImage."
    exit 1
fi

# Check if an icon file was found
if [ -z "$ICON_FILE" ]; then
    echo "No icon file found in the AppImage."
    exit 1
fi

# Define paths for extracted files
ICON_PATH="$HOME/Applications/.icons"
UPDATED_DESKTOP_FILE="$HOME/.local/share/applications/$APPIMAGE_NAME.desktop"

# Copy files to their respective destinations
cp "$DESKTOP_FILE" "$UPDATED_DESKTOP_FILE"
cp "$ICON_FILE" "$ICON_PATH"

# Update the .desktop file
sed -i "s|Exec=.*|Exec=${APPIMAGE}|g" "$UPDATED_DESKTOP_FILE"
sed -i "s|Icon=.*|Icon=${ICON_PATH}/$ICON_FILE_NAME|g" "$UPDATED_DESKTOP_FILE"

echo "Cleanup..."
rm -rf $WORKDIR

# Notify the desktop user that the script is done
notify-send "Appimage integrator" "$APPIMAGE_NAME is ready to use."
