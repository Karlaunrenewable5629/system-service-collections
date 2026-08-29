# Uninstall k3s

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Using k3s Built-in Scripts

k3s ships with its own uninstall scripts:

```bash
# Uninstall server
sudo /usr/local/bin/k3s-uninstall.sh

# Uninstall agent
sudo /usr/local/bin/k3s-agent-uninstall.sh
```

## Manual

```bash
# Stop service
sudo systemctl stop k3s
sudo systemctl disable k3s
sudo rm -f /etc/systemd/system/k3s.service
sudo systemctl daemon-reload

# Remove binaries
sudo rm -f /usr/local/bin/k3s /usr/local/bin/kubectl /usr/local/bin/crictl /usr/local/bin/ctr

# Remove data
sudo rm -rf /etc/rancher/k3s /var/lib/rancher/k3s /var/lib/kubelet /run/k3s

# Remove CNI network interfaces
sudo ip link delete cni0 2>/dev/null || true
sudo ip link delete flannel.1 2>/dev/null || true
sudo rm -rf /etc/cni/net.d /opt/cni/bin
```
