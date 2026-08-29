#!/bin/bash
# Memcached Uninstallation Script

set -euo pipefail

echo "Stopping and removing Memcached..."

systemctl stop memcached 2>/dev/null || true
systemctl disable memcached 2>/dev/null || true
rm -f /etc/systemd/system/memcached.service
systemctl daemon-reload

if command -v apt-get &>/dev/null; then
    apt-get remove -y memcached 2>/dev/null || true
elif command -v dnf &>/dev/null; then
    dnf remove -y memcached 2>/dev/null || true
elif command -v apk &>/dev/null; then
    apk del memcached 2>/dev/null || true
else
    echo "Please manually remove Memcached binary and configuration files."
fi

rm -rf /var/lib/memcached /var/log/memcached /etc/memcached

echo "Memcached has been removed."