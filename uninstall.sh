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

# Detect installation mode
if [ -d "/opt/appimage-integrator" ]; then
    INSTALL_MODE="system"
    BIN_DIR="/opt/appimage-integrator"
    CONFIG_DIR="/etc/appimage-integrator"
else
    INSTALL_MODE="user"
    BIN_DIR="$HOME/.local/bin/appimage-integrator"
    CONFIG_DIR="$HOME/.config/appimage-integrator"
fi

# Detect start mode
if [ -f "$HOME/.config/systemd/user/appimage-integrator.service" ]; then
    START_MODE="systemd"
else
    START_MODE="autostart"
fi

# Stop service
if [ "$START_MODE" = "systemd" ]; then
    if systemctl --user is-active --quiet appimage-integrator.service; then
        echo "Stopping systemd service"
        systemctl --user stop appimage-integrator.service
        systemctl --user disable appimage-integrator.service
    fi
    rm -f "$HOME/.config/systemd/user/appimage-integrator.service"
    systemctl --user daemon-reload
else
    pids=$(pgrep -f "appimage-integrator-observer.sh")
    if [ -n "$pids" ]; then
        echo "Stopping Appimage Integrator"
        kill $pids
        sleep 2
        for pid in $pids; do
            if ps -p $pid > /dev/null 2>&1; then
                kill -9 $pid
            fi
        done
    fi
    rm -f "$HOME/.config/autostart/Appimage-Integrator.desktop"
fi

# Remove files
if [ "$INSTALL_MODE" = "system" ]; then
    sudo rm -rf "$BIN_DIR" "$CONFIG_DIR"
else
    rm -rf "$BIN_DIR" "$CONFIG_DIR"
fi

echo "Uninstallation complete."
