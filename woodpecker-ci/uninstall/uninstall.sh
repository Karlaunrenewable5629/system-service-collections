#!/bin/bash
# Woodpecker CI Uninstallation Script

set -euo pipefail

echo "Stopping and removing Woodpecker CI..."

systemctl stop woodpecker 2>/dev/null || true
systemctl disable woodpecker 2>/dev/null || true
rm -f /etc/systemd/system/woodpecker.service
systemctl daemon-reload

if command -v apt-get &>/dev/null; then
    apt-get remove -y woodpecker-ci 2>/dev/null || true
elif command -v dnf &>/dev/null; then
    dnf remove -y woodpecker-ci 2>/dev/null || true
elif command -v apk &>/dev/null; then
    apk del woodpecker-ci 2>/dev/null || true
else
    echo "Please manually remove Woodpecker CI binary and configuration files."
fi

# Remove data and log directories
rm -rf /var/lib/woodpecker /var/log/woodpecker /etc/woodpecker

echo "Woodpecker CI has been removed."