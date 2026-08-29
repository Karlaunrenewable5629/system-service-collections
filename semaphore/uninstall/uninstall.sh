#!/bin/bash
# Semaphore Uninstallation Script
# Removes Semaphore and its service configuration

set -euo pipefail

CONFIG_DIR="/etc/semaphore"
DATA_DIR="/var/lib/semaphore"
LOG_DIR="/var/log/semaphore"

echo "Uninstalling Semaphore..."

# Stop and disable systemd service
if systemctl is-active --quiet semaphore 2>/dev/null; then
    systemctl stop semaphore
fi
systemctl disable semaphore 2>/dev/null || true
systemctl daemon-reload 2>/dev/null || true

# Remove systemd service file
if [ -f /etc/systemd/system/semaphore.service ]; then
    rm /etc/systemd/system/semaphore.service
    systemctl daemon-reload
    echo "Removed systemd service file"
fi

# Remove configuration and data
rm -rf "$CONFIG_DIR"
rm -rf "$DATA_DIR"
rm -rf "$LOG_DIR"
echo "Removed configuration and data directories"

# Remove user and group (optional - uncomment if desired)
# userdel -r semaphore 2>/dev/null || true

echo "Semaphore uninstalled successfully!"