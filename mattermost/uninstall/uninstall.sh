#!/bin/bash
# Mattermost Uninstallation Script
# Removes Mattermost and its service configuration

set -euo pipefail

CONFIG_DIR="/etc/mattermost"
DATA_DIR="/var/mattermost"
LOG_DIR="/var/log/mattermost"

echo "Uninstalling Mattermost..."

# Stop mattermost service
if systemctl is-active --quiet mattermost 2>/dev/null; then
    systemctl stop mattermost
fi
systemctl disable mattermost 2>/dev/null || true
systemctl daemon-reload 2>/dev/null || true

# Remove systemd service file
if [ -f /etc/systemd/system/mattermost.service ]; then
    rm /etc/systemd/system/mattermost.service
    systemctl daemon-reload
    echo "Removed systemd service file"
fi

# Remove configuration and data
rm -rf "$CONFIG_DIR"
rm -rf "$DATA_DIR"
rm -rf "$LOG_DIR"
echo "Removed configuration and data directories"

# Remove user (optional)
# userdel -r mattermost 2>/dev/null || true

echo "Mattermost uninstalled successfully!"