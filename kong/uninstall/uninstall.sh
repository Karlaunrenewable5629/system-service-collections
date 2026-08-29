#!/bin/bash
# Kong Uninstallation Script

set -euo pipefail

echo "Stopping and removing Kong service..."

systemctl stop kong 2>/dev/null || true
systemctl disable kong 2>/dev/null || true
rm -f /etc/systemd/system/kong.service
systemctl daemon-reload

if command -v apt-get &>/dev/null; then
    apt-get remove -y kong
elif command -v dnf &>/dev/null; then
    dnf remove -y kong
else
    echo "Please manually remove Kong binary and configuration files."
fi

rm -rf /etc/kong /var/lib/kong /var/log/kong /usr/local/bin/kong

echo "Kong has been removed."