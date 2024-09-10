#!/bin/bash
# Author Andrianos Papamarkou


# Get the directory of the script
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Define target directories
LOCAL_BIN_DIR="$HOME/.local/bin"
AUTOSTART_DIR="$HOME/.config/autostart"

# Create the ~/.local/bin directory if it doesn't exist
if [ ! -d "$LOCAL_BIN_DIR" ]; then
    echo "Creating directory $LOCAL_BIN_DIR"
    mkdir -p "$LOCAL_BIN_DIR"
fi

# Copy scripts to ~/.local/bin
for script in appimage-integrator-observer.sh appimage-integrator-cleanup.sh appimage-integrator-extract.sh; do
    if [ -f "$SCRIPT_DIR/$script" ]; then
        echo "Copying $script to $LOCAL_BIN_DIR"
        cp "$SCRIPT_DIR/$script" "$LOCAL_BIN_DIR"
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
Exec=$HOME/.local/bin/appimage-integrator-observer.sh
RunHook=0
StartupNotify=false
Terminal=false
Hidden=false
EOF

# Ensure the .desktop file has the right permissions
chmod 644 "$DESKTOP_FILE"

# Make the Applications dir
mkdir -p "$HOME/Applcations"
echo "Introducing your new Applications folder!"

echo "Starting Appimage Integrator"
$HOME/.local/bin/appimage-integrator-observer.sh &

sleep 2
 
echo "Installation complete."
echo
echo "Simply drop or delete appimages to your Applications folder" 
echo "Have fun!"


