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
# This script is the observer service
# for the Appimage integrator.
# It watches the Applications folder
# for new AppImages and calls the
# processing script when a new AppImage
# is detected. It also calls the cleanup
# script when an AppImage is deleted or
# moved out of the Applications folder.
# The script uses inotifywait to monitor
# the Applications folder for changes.
# It also checks if another instance of
# the script is running and exits if it does.
# The script is designed to run in the
# background and notify the user when
# an AppImage is detected or when the
# script exits.


# exit on logout
trap 'echo "Cleaning up..."; exit' EXIT

# Get the name of the script (the script's basename)
SCRIPT_NAME=$(basename "$0")

# Get the PID of the current script
CURRENT_PID=$$

# Get all same script PIDs
PIDS_FOUND=$(pidof -x "$SCRIPT_NAME")

# Remove the current instance PID from the PIDs found
OTHER_PIDS=$(echo "$PIDS_FOUND" | sed "s/$CURRENT_PID//")

# Check is OTHER_PIDS except for CURRENT_PID exist
if [ -n "$OTHER_PIDS" ]; then
    echo "Another instance of the script is running."
    exit 1
fi

# Define the directories and scripts
watch_directory="$HOME/Applications"
processing_script="$HOME/.local/bin/appimage-integrator-extract.sh"
cleanup_script="$HOME/.local/bin/appimage-integrator-cleanup.sh"

# Ensure both scripts exist and are executable
if [[ ! -x "$processing_script" ]]; then
    notify-send "Appimage integrator error" "Processing script not found or not executable. Appimage inegration is not running."
    exit 1
fi

if [[ ! -x "$cleanup_script" ]]; then
    notify-send "Appimage integrator error" "Cleanup script not found or not executable. Appimage inegration is not running."
    exit 1
fi

notify-send "Appimage integrator" "Drop appimages any AppImage into your Applications folder and start using it!"

# Start watching the directory
inotifywait -m -e create,moved_to,delete,moved_from "$watch_directory" | while
echo "Watch for $watch_directory"
read -r directory event file; do
	echo "Event = $event $file"
    # Check if the event is related to adding AppImages
    if [[ "$event" == *"CREATE"* || "$event" == *"MOVED_TO"* ]]; then
        if [[ "${file,,}" == *.appimage ]]; then
            echo "New or moved AppImage detected: $file"
            full_path="$directory$file"
            # Call your processing script with the AppImage as an argument
            $processing_script "$full_path"
        fi
    # if the event is related to deleting or moving out AppImages
    elif [[ "$event" == *"DELETE"* || "$event" == *"MOVED_FROM"* ]]; then
        if [[ "${file,,}" == *.appimage ]]; then
            echo "AppImage deleted or moved out: $file"
            full_path="$directory$file"
            # Call your cleanup script with the AppImage as an argument
            $cleanup_script "$full_path"
        fi
    fi
done
