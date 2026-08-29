#!/bin/bash
# k3s Uninstallation Script
# k3s ships its own uninstall scripts — this wraps them.

set -euo pipefail

echo "Uninstalling k3s..."

# Use k3s-provided uninstall scripts if available
if [ -f /usr/local/bin/k3s-uninstall.sh ]; then
    echo "Running k3s server uninstall script..."
    /usr/local/bin/k3s-uninstall.sh
elif [ -f /usr/local/bin/k3s-agent-uninstall.sh ]; then
    echo "Running k3s agent uninstall script..."
    /usr/local/bin/k3s-agent-uninstall.sh
else
    echo "k3s uninstall scripts not found. Performing manual cleanup..."

    systemctl stop k3s k3s-agent 2>/dev/null || true
    systemctl disable k3s k3s-agent 2>/dev/null || true
    rm -f /etc/systemd/system/k3s.service
    rm -f /etc/systemd/system/k3s-agent.service
    systemctl daemon-reload

    # Kill any remaining k3s processes
    for process in containerd-shim-runc-v2 k3s; do
        pkill -9 "$process" 2>/dev/null || true
    done

    # Remove binaries
    rm -f /usr/local/bin/k3s
    rm -f /usr/local/bin/kubectl
    rm -f /usr/local/bin/crictl
    rm -f /usr/local/bin/ctr

    # Remove data
    rm -rf /etc/rancher/k3s
    rm -rf /var/lib/rancher/k3s
    rm -rf /var/lib/kubelet
    rm -rf /run/k3s

    # Remove CNI interfaces
    ip link delete cni0 2>/dev/null || true
    ip link delete flannel.1 2>/dev/null || true
    ip link delete flannel-wg 2>/dev/null || true

    rm -rf /etc/cni/net.d
    rm -rf /opt/cni/bin
fi

echo "k3s has been removed."
