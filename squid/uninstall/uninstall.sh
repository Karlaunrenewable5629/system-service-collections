#!/bin/bash
# Squid Uninstallation Script
# Removes Squid and its service configuration

set -euo pipefail

CONFIG_DIR="/etc/squid"
DATA_DIR="/var/spool/squid"
LOG_DIR="/var/log/squid"

echo "Uninstalling Squid..."

# Stop squid service
if systemctl is-active --quiet squid 2>/dev/null; then
    systemctl stop squid
fi
systemctl disable squid 2>/dev/null || true
systemctl daemon-reload 2>/dev/null || true

# Remove package-installed service
if [ -f /etc/systemd/system/squid.service ]; then
    rm /etc/systemd/system/squid.service
    systemctl daemon-reload
    echo "Removed systemd service file"
fi

# Remove configuration and data
rm -rf "$CONFIG_DIR"
rm -rf "$DATA_DIR"
rm -rf "$LOG_DIR"
echo "Removed configuration and data directories"

# Remove user (optional)
# userdel -r proxy 2>/dev/null || true

echo "Squid uninstalled successfully!"