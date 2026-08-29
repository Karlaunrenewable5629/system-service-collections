#!/bin/bash
# Caddy Uninstallation Script

set -euo pipefail

echo "Stopping and removing Caddy service..."

systemctl stop caddy 2>/dev/null || true
systemctl disable caddy 2>/dev/null || true
rm -f /etc/systemd/system/caddy.service
systemctl daemon-reload

if command -v apt-get &>/dev/null; then
    apt-get remove -y caddy
elif command -v dnf &>/dev/null; then
    dnf remove -y caddy
elif command -v pacman &>/dev/null; then
    pacman -R caddy
elif command -v apk &>/dev/null; then
    apk del caddy
else
    echo "Please manually remove Caddy binary and configuration files."
fi

rm -rf /etc/caddy /var/lib/caddy /var/log/caddy /usr/local/bin/caddy

echo "Caddy has been removed."