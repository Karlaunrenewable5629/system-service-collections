#!/bin/bash
# Podman Uninstallation Script

set -euo pipefail

echo "Stopping and removing Podman service..."

systemctl stop podman.socket 2>/dev/null || true
systemctl disable podman.socket 2>/dev/null || true
systemctl daemon-reload 2>/dev/null || true

if command -v apt-get &>/dev/null; then
    apt-get remove -y podman podman-compose buildah skopeo 2>/dev/null || true
elif command -v dnf &>/dev/null; then
    dnf remove -y podman podman-compose buildah skopeo 2>/dev/null || true
elif command -v pacman &>/dev/null; then
    pacman -R --noconfirm podman podman-compose buildah skopeo 2>/dev/null || true
elif command -v apk &>/dev/null; then
    apk del podman podman-compose buildah skopeo 2>/dev/null || true
fi

rm -rf /etc/containers
rm -rf /var/lib/containers
rm -rf /run/podman
rm -rf /tmp/containers-user-*

echo "Podman has been removed."
echo "Note: User-level config in ~/.config/containers/ was NOT removed."
echo "      Remove manually with: rm -rf ~/.config/containers ~/.local/share/containers"
