#!/bin/bash
# Fluent Bit Uninstallation Script

set -euo pipefail

echo "Stopping and removing Fluent Bit service..."

systemctl stop fluent-bit 2>/dev/null || true
systemctl disable fluent-bit 2>/dev/null || true
rm -f /etc/systemd/system/fluent-bit.service
systemctl daemon-reload

if command -v apt-get &>/dev/null; then
    apt-get remove -y fluent-bit
elif command -v dnf &>/dev/null; then
    dnf remove -y fluent-bit
elif command -v pacman &>/dev/null; then
    pacman -R fluent-bit
elif command -v apk &>/dev/null; then
    apk del fluent-bit
else
    echo "Please manually remove Fluent Bit binary and configuration files."
fi

rm -rf /etc/fluent-bit /var/lib/fluent-bit /var/log/fluent-bit /usr/local/bin/fluent-bit

echo "Fluent Bit has been removed."