#!/bin/bash
# Rocket.Chat Uninstallation Script
# Removes Rocket.Chat and its service configuration

set -euo pipefail

CONFIG_DIR="/etc/rocketchat"
DATA_DIR="/var/rocketchat"
LOG_DIR="/var/log/rocketchat"

echo "Uninstalling Rocket.Chat..."

# Stop rocketchat service
if systemctl is-active --quiet rocketchat 2>/dev/null; then
    systemctl stop rocketchat
fi
systemctl disable rocketchat 2>/dev/null || true
systemctl daemon-reload 2>/dev/null || true

# Remove systemd service file
if [ -f /etc/systemd/system/rocketchat.service ]; then
    rm /etc/systemd/system/rocketchat.service
    systemctl daemon-reload
    echo "Removed systemd service file"
fi

# Remove configuration and data
rm -rf "$CONFIG_DIR"
rm -rf "$DATA_DIR"
rm -rf "$LOG_DIR"
echo "Removed configuration and data directories"

# Remove user (optional)
# userdel -r rocketchat 2>/dev/null || true

echo "Rocket.Chat uninstalled successfully!"