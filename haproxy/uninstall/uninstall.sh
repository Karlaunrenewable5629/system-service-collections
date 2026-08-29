#!/bin/bash
# HAProxy Uninstallation Script

set -euo pipefail

echo "Stopping and removing HAProxy service..."

systemctl stop haproxy 2>/dev/null || true
systemctl disable haproxy 2>/dev/null || true
rm -f /etc/systemd/system/haproxy.service
systemctl daemon-reload

if command -v apt-get &>/dev/null; then
    apt-get remove -y haproxy
elif command -v dnf &>/dev/null; then
    dnf remove -y haproxy
elif command -v pacman &>/dev/null; then
    pacman -R haproxy
elif command -v apk &>/dev/null; then
    apk del haproxy
else
    echo "Please manually remove HAProxy binary and configuration files."
fi

rm -rf /etc/haproxy /var/lib/haproxy /var/log/haproxy /usr/local/bin/haproxy

echo "HAProxy has been removed."