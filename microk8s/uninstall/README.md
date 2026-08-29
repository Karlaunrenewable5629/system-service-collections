# Uninstall MicroK8s

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
# Stop MicroK8s
microk8s stop

# Remove the snap (--purge removes all data)
sudo snap remove microk8s --purge

# Remove network interfaces
sudo ip link delete cni0 2>/dev/null || true
sudo ip link delete flannel.1 2>/dev/null || true

# Clean up kubeconfig
rm -f ~/.kube/config
```

> **Note:** `--purge` removes all MicroK8s data including images and volumes.  
> Omit it if you want to preserve data for reinstallation.
