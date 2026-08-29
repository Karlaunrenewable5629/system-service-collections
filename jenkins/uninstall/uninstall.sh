#!/bin/bash
# Jenkins Uninstallation Script

set -euo pipefail

echo "Stopping and removing Jenkins service..."

systemctl stop jenkins 2>/dev/null || true
systemctl disable jenkins 2>/dev/null || true
rm -f /etc/systemd/system/jenkins.service
systemctl daemon-reload

if command -v apt-get &>/dev/null; then
    apt-get remove -y jenkins 2>/dev/null || true
elif command -v dnf &>/dev/null; then
    dnf remove -y jenkins 2>/dev/null || true
elif command -v apk &>/dev/null; then
    apk del jenkins 2>/dev/null || true
else
    echo "Please manually remove Jenkins binary and configuration files."
fi

rm -rf /var/jenkins_home /var/log/jenkins /etc/jenkins /usr/local/bin/jenkins.war

echo "Jenkins has been removed."