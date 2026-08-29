#!/bin/bash
# containerd Uninstallation Script

set -euo pipefail

echo "Stopping and removing containerd service..."

systemctl stop containerd 2>/dev/null || true
systemctl disable containerd 2>/dev/null || true
rm -f /etc/systemd/system/containerd.service
systemctl daemon-reload

if command -v apt-get &>/dev/null; then
    apt-get remove -y containerd.io 2>/dev/null || apt-get remove -y containerd 2>/dev/null || true
elif command -v dnf &>/dev/null; then
    dnf remove -y containerd.io 2>/dev/null || dnf remove -y containerd 2>/dev/null || true
elif command -v pacman &>/dev/null; then
    pacman -R --noconfirm containerd 2>/dev/null || true
elif command -v apk &>/dev/null; then
    apk del containerd 2>/dev/null || true
fi

# Remove binaries
rm -f /usr/local/bin/containerd
rm -f /usr/local/bin/containerd-shim
rm -f /usr/local/bin/containerd-shim-runc-v1
rm -f /usr/local/bin/containerd-shim-runc-v2
rm -f /usr/local/bin/ctr
rm -f /usr/local/sbin/runc

# Remove configuration and data
rm -rf /etc/containerd
rm -rf /var/lib/containerd
rm -rf /run/containerd
rm -rf /opt/containerd

echo "containerd has been removed."
echo "Note: CNI plugins in /opt/cni/bin were NOT removed. Remove manually if needed."
