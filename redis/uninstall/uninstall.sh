#!/bin/bash
# Redis Uninstallation Script

set -euo pipefail

echo "Stopping and removing Redis..."

systemctl stop redis 2>/dev/null || true
systemctl disable redis 2>/dev/null || true
rm -f /etc/systemd/system/redis.service
systemctl daemon-reload

if command -v apt-get &>/dev/null; then
    apt-get remove -y redis 2>/dev/null || true
elif command -v dnf &>/dev/null; then
    dnf remove -y redis 2>/dev/null || true
elif command -v apk &>/dev/null; then
    apk del redis 2>/dev/null || true
else
    echo "Please manually remove Redis binary and configuration files."
fi

# Remove data and log directories
rm -rf /var/lib/redis /var/log/redis /etc/redis

echo "Redis has been removed."