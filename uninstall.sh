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


# Define target directories and files
LOCAL_BIN_DIR="$HOME/.local/bin"
AUTOSTART_DIR="$HOME/.config/autostart"
SCRIPTS=("appimage-integrator-observer.sh" "appimage-integrator-cleanup.sh" "appimage-integrator-extract.sh")
DESKTOP_FILE="$AUTOSTART_DIR/Appimage-Integrator.desktop"

# Remove scripts from ~/.local/bin
echo "Removing scripts from $LOCAL_BIN_DIR"
for script in "${SCRIPTS[@]}"; do
    if [ -f "$LOCAL_BIN_DIR/$script" ]; then
        echo "Removing $script"
        rm "$LOCAL_BIN_DIR/$script"
    else
        echo "Warning: $script not found in $LOCAL_BIN_DIR"
    fi
done

# Remove Appimage-Integrator.desktop from ~/.config/autostart
if [ -f "$DESKTOP_FILE" ]; then
    echo "Removing $DESKTOP_FILE"
    rm "$DESKTOP_FILE"
else
    echo "Warning: $DESKTOP_FILE not found in $AUTOSTART_DIR"
fi

# Remove ~/.local/bin directory if it is empty
if [ -d "$LOCAL_BIN_DIR" ] && [ "$(ls -A $LOCAL_BIN_DIR)" ]; then
    echo "Directory $LOCAL_BIN_DIR is not empty, skipping removal."
else
    echo "Removing empty directory $LOCAL_BIN_DIR"
    rmdir "$LOCAL_BIN_DIR"
fi

# Remove ~/.config/autostart directory if it is empty
if [ -d "$AUTOSTART_DIR" ] && [ "$(ls -A $AUTOSTART_DIR)" ]; then
    echo "Directory $AUTOSTART_DIR is not empty, skipping removal."
else
    echo "Removing empty directory $AUTOSTART_DIR"
    rmdir "$AUTOSTART_DIR"
fi

# Define the name of the script
SCRIPT_NAME="appimage-integrator-observer.sh"

# Find all PIDs of the script
pids=$(pgrep -f "$SCRIPT_NAME")

if [ -z "$pids" ]; then
    echo "Appimage Intergrator not running."
else
    echo "Stopping Appimage Integrator"
    # Send SIGTERM to gracefully stop the processes
    kill $pids

    # Optionally, wait for processes to terminate
    sleep 2

    # Ensure processes are terminated
    for pid in $pids; do
        if ps -p $pid > /dev/null; then
            echo "Process $pid is still running. Sending SIGKILL."
            kill -9 $pid
        fi
    done
fi

echo "Uninstallation complete."
