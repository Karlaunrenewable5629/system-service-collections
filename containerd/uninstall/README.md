# Uninstall containerd

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
# Stop and disable service
sudo systemctl stop containerd
sudo systemctl disable containerd
sudo rm -f /etc/systemd/system/containerd.service
sudo systemctl daemon-reload

# Remove package (if installed via package manager)
sudo apt remove containerd.io      # Debian/Ubuntu
sudo dnf remove containerd.io      # RHEL/Fedora
sudo pacman -R containerd          # Arch
sudo apk del containerd            # Alpine

# Remove binaries (if installed from binary)
sudo rm -f /usr/local/bin/containerd \
           /usr/local/bin/containerd-shim* \
           /usr/local/bin/ctr \
           /usr/local/sbin/runc

# Remove configuration and data
sudo rm -rf /etc/containerd
sudo rm -rf /var/lib/containerd
sudo rm -rf /run/containerd
sudo rm -rf /opt/containerd

# Optionally remove CNI plugins
sudo rm -rf /opt/cni/bin
sudo rm -rf /etc/cni/net.d
```
