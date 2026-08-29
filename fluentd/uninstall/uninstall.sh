#!/bin/bash
# Fluentd Uninstallation Script

set -euo pipefail

echo "Stopping and removing Fluentd service..."

systemctl stop fluentd 2>/dev/null || true
systemctl disable fluentd 2>/dev/null || true
rm -f /etc/systemd/system/fluentd.service
systemctl daemon-reload

if command -v apt-get &>/dev/null; then
    apt-get remove -y fluentd
elif command -v dnf &>/dev/null; then
    dnf remove -y fluentd
elif command -v pacman &>/dev/null; then
    pacman -R fluentd
elif command -v apk &>/dev/null; then
    apk del fluentd
else
    echo "Please manually remove Fluentd binary and configuration files."
fi

rm -rf /etc/fluentd /var/lib/fluentd /var/log/fluentd /usr/local/bin/fluentd

echo "Fluentd has been removed."