#!/bin/bash
# MicroK8s Uninstallation Script

set -euo pipefail

echo "Stopping and removing MicroK8s..."

# Stop the cluster first
microk8s stop 2>/dev/null || true

# Remove the snap
snap remove microk8s --purge 2>/dev/null || snap remove microk8s 2>/dev/null || true

# Clean up remaining network interfaces
ip link delete cni0 2>/dev/null || true
ip link delete flannel.1 2>/dev/null || true
ip link delete vxlan.calico 2>/dev/null || true

# Remove kubeconfig if it was pointing at microk8s
if grep -q "microk8s" ~/.kube/config 2>/dev/null; then
    echo "Note: ~/.kube/config may reference MicroK8s. Back it up or regenerate it."
fi

echo "MicroK8s has been removed."
echo "Note: User kubeconfig (~/.kube/config) was NOT removed. Clean up manually if needed."
