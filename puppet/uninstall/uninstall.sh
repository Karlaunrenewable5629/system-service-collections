#!/bin/bash
# Puppet Agent Uninstallation Script

set -euo pipefail

echo "Stopping and removing Puppet Agent..."

systemctl stop puppet 2>/dev/null || true
systemctl disable puppet 2>/dev/null || true
rm -f /etc/systemd/system/puppet.service
systemctl daemon-reload

if command -v apt-get &>/dev/null; then
    apt-get remove -y puppet-agent 2>/dev/null || true
elif command -v dnf &>/dev/null; then
    dnf remove -y puppet 2>/dev/null || true
elif command -v apk &>/dev/null; then
    apk del puppet 2>/dev/null || true
else
    echo "Please manually remove Puppet binary and configuration files."
fi

# Remove data and log directories
rm -rf /var/lib/puppet /var/log/puppet /etc/puppetlabs/puppet

echo "Puppet Agent has been removed."