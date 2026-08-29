#!/bin/bash
# Envoy Uninstallation Script

set -euo pipefail

echo "Stopping and removing Envoy service..."

systemctl stop envoy 2>/dev/null || true
systemctl disable envoy 2>/dev/null || true
rm -f /etc/systemd/system/envoy.service
systemctl daemon-reload

if command -v apt-get &>/dev/null; then
    apt-get remove -y envoy
elif command -v dnf &>/dev/null; then
    dnf remove -y envoy
else
    echo "Please manually remove Envoy binary and configuration files."
fi

rm -rf /etc/envoy /var/lib/envoy /var/log/envoy /usr/local/bin/envoy

echo "Envoy has been removed."