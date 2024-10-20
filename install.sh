#!/usr/bin/bash
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

if ! command -v inotifywait &> /dev/null; then
    echo "inotify-tools is not installed."
    echo "Please see the dependencies section."
    exit 1
fi

# Get the directory of the script
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Define target directories
LOCAL_BIN_DIR="$HOME/.local/bin/appimage-integrator"
AUTOSTART_DIR="$HOME/.config/autostart"

# Create the ~/.local/bin directory if it doesn't exist
if [ ! -d "$LOCAL_BIN_DIR" ]; then
    echo "Creating directory $LOCAL_BIN_DIR"
    mkdir -p "$LOCAL_BIN_DIR"
fi

# Copy scripts to ~/.local/bin
for script in appimage-integrator-observer.sh appimage-integrator-cleanup.sh appimage-integrator-extract.sh; do
    if [ -f "$SCRIPT_DIR/src/$script" ]; then
        echo "Copying $script to $LOCAL_BIN_DIR"
        cp "$SCRIPT_DIR/src/$script" "$LOCAL_BIN_DIR"
        chmod a+x "$LOCAL_BIN_DIR/$script"  # Make sure the script is executable
    else
        echo "Warning: $script not found in $SCRIPT_DIR"
    fi
done

# Create the ~/.config/autostart directory if it doesn't exist
if [ ! -d "$AUTOSTART_DIR" ]; then
    echo "Creating directory $AUTOSTART_DIR"
    mkdir -p "$AUTOSTART_DIR"
fi

# Create Appimage-Integrator.desktop in ~/.config/autostart
DESKTOP_FILE="$AUTOSTART_DIR/Appimage-Integrator.desktop"
echo "Adding Appimage Integrator to autostart apps"
cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=Appimage integration
Comment=Appimage integration
Exec=$LOCAL_BIN_DIR/appimage-integrator-observer.sh
RunHook=0
StartupNotify=false
Terminal=false
Hidden=false
EOF

# Ensure the .desktop file has the right permissions
chmod 644 "$DESKTOP_FILE"

# Make the Applications dir
mkdir -p "$HOME/Applications"
echo "Introducing your new Applications folder!"

# Start the Appimage Integrator
echo "Starting Appimage Integrator"
$LOCAL_BIN_DIR/appimage-integrator-observer.sh &

sleep 2

echo "Installation complete."
echo
echo "Simply drop or delete appimages to your Applications folder"
echo "Have fun!"
