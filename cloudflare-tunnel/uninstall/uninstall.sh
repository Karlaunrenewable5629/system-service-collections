#!/bin/bash
# Cloudflare Tunnel (cloudflared) Uninstallation Script
# Removes cloudflared and its service configuration

set -euo pipefail

CONFIG_DIR="/etc/cloudflared"
DATA_DIR="/var/lib/cloudflared"
LOG_DIR="/var/log/cloudflared"

echo "Uninstalling Cloudflare Tunnel..."

# Stop and disable systemd service
if systemctl is-active --quiet cloudflared 2>/dev/null; then
    systemctl stop cloudflared
fi
systemctl disable cloudflared 2>/dev/null || true
systemctl daemon-reload 2>/dev/null || true

# Remove systemd service file
if [ -f /etc/systemd/system/cloudflared.service ]; then
    rm /etc/systemd/system/cloudflared.service
    systemctl daemon-reload
    echo "Removed systemd service file"
fi

# Remove OpenRC service
if [ -f /etc/init.d/cloudflared ]; then
    rm /etc/init.d/cloudflared
    rc-update del cloudflared default 2>/dev/null || true
    echo "Removed OpenRC service file"
fi

# Remove SysVinit service
if [ -f /etc/init.d/cloudflared ]; then
    rm /etc/init.d/cloudflared
    update-rc.d cloudflared remove 2>/dev/null || true
    echo "Removed SysVinit service file"
fi

# Remove configuration and data
rm -rf "$CONFIG_DIR"
rm -rf "$DATA_DIR"
rm -rf "$LOG_DIR"
echo "Removed configuration and data directories"

# Remove binary (optional)
# rm /usr/local/bin/cloudflared 2>/dev/null || true

echo "Cloudflare Tunnel uninstalled successfully!"