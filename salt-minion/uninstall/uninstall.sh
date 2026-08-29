#!/bin/bash
# Salt Minion Uninstallation Script

set -euo pipefail

echo "Stopping and removing Salt Minion..."

systemctl stop salt-minion 2>/dev/null || true
systemctl disable salt-minion 2>/dev/null || true
rm -f /etc/systemd/system/salt-minion.service
systemctl daemon-reload

if command -v apt-get &>/dev/null; then
    apt-get remove -y salt-minion 2>/dev/null || true
elif command -v dnf &>/dev/null; then
    dnf remove -y salt-minion 2>/dev/null || true
elif command -v apk &>/dev/null; then
    apk del salt-minion 2>/dev/null || true
else
    echo "Please manually remove Salt Minion binary and configuration files."
fi

# Remove data and log directories
rm -rf /var/cache/salt /var/log/salt /etc/salt

echo "Salt Minion has been removed."