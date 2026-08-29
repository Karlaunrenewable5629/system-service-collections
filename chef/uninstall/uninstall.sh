#!/bin/bash
# Chef Client Uninstallation Script

set -euo pipefail

echo "Removing Chef Client..."

# Remove package based on distribution
if command -v apt-get &>/dev/null; then
    apt-get remove -y chef 2>/dev/null || true
elif command -v dnf &>/dev/null; then
    dnf remove -y chef 2>/dev/null || true
elif command -v apk &>/dev/null; then
    apk del chef 2>/dev/null || true
else
    echo "Please manually remove Chef binary and configuration files."
fi

# Remove directories
rm -rf /etc/chef /var/cache/chef /var/log/chef /usr/local/bin/chef-client

echo "Chef Client has been removed."