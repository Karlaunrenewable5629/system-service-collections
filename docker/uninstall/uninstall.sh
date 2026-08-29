#!/bin/bash
# Docker Uninstallation Script

set -euo pipefail

echo "Stopping and removing Docker service..."

systemctl stop docker 2>/dev/null || true
systemctl disable docker 2>/dev/null || true
rm -f /etc/systemd/system/docker.service
systemctl daemon-reload

if command -v apt-get &>/dev/null; then
    apt-get remove -y docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
elif command -v dnf &>/dev/null; then
    dnf remove -y docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
elif command -v pacman &>/dev/null; then
    pacman -R --noconfirm docker docker-compose 2>/dev/null || true
elif command -v apk &>/dev/null; then
    apk del docker docker-compose 2>/dev/null || true
fi

rm -rf /etc/docker
rm -rf /var/lib/docker
rm -rf /var/run/docker
rm -f /usr/local/bin/docker-compose

echo "Docker has been removed."
echo "Note: Container images and volumes in /var/lib/docker were removed."
