#!/bin/bash

# Introduce Applications folder if not exist
# make a hidden folder named .icons to hold the appimage icons
mkdir -p $HOME/Applications/.icons

# Check if an argument was provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <AppImage>"
    exit 1
fi

APPIMAGE="$1"

# Check if the file exists
if [ ! -f "$APPIMAGE" ]; then
    echo "File not found: $APPIMAGE"
    exit 1
fi

APPIMAGE_FULL_NAME="${APPIMAGE##*/}"
APPIMAGE_NAME="${APPIMAGE_FULL_NAME%%.*}"

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

# Define paths
EXTRACTED_DIR="./squashfs-root"

# Check if the extraction directory exists
if [ ! -d "$EXTRACTED_DIR" ]; then
    echo "Extraction directory not found: $EXTRACTED_DIR"
    exit 1
fi

# Locate .desktop and icon files into extracted appimage
DESKTOP_FILE=$(find "$EXTRACTED_DIR" -name "*.desktop" | head -n 1)
ICON_FILE=$(find "$EXTRACTED_DIR" -name "*.png" | head -n 1)
ICON_FILE_NAME="${ICON_FILE##*/}"

# Check if .desktop file and icon file were found
if [ -z "$DESKTOP_FILE" ]; then
    echo "No .desktop file found in the AppImage."
    exit 1
fi

if [ -z "$ICON_FILE" ]; then
    echo "No icon file found in the AppImage."
    exit 1
fi

# Define paths for extracted files
ICON_PATH="$HOME/Applications/.icons"
UPDATED_DESKTOP_FILE="$HOME/.local/share/applications/$APPIMAGE_NAME.desktop"

# Copy files
cp "$DESKTOP_FILE" "$UPDATED_DESKTOP_FILE"
cp "$ICON_FILE" "$ICON_PATH"


sed -i "s|Exec=.*|Exec=${APPIMAGE}|g" "$UPDATED_DESKTOP_FILE"
sed -i "s|Icon=.*|Icon=${ICON_PATH}/$ICON_FILE_NAME|g" "$UPDATED_DESKTOP_FILE"

# Output results
echo "Updated .desktop file:"
cat "$UPDATED_DESKTOP_FILE"
echo "Icon extracted to: $ICON_PATH"


echo "Cleanup..."
rm -rf $WORKDIR

notify-send "Appimage integrator" "$APPIMAGE_NAME is ready to use."
