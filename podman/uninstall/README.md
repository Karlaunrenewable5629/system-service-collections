# Uninstall Podman

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
# Stop and disable socket
systemctl --user stop podman.socket
systemctl --user disable podman.socket
sudo systemctl stop podman.socket 2>/dev/null || true
sudo systemctl disable podman.socket 2>/dev/null || true

# Remove packages
sudo apt remove podman podman-compose buildah skopeo   # Debian/Ubuntu
sudo dnf remove podman podman-compose buildah skopeo   # RHEL/Fedora
sudo pacman -R podman podman-compose buildah skopeo    # Arch
sudo apk del podman podman-compose buildah skopeo      # Alpine

# Remove system-wide config and data
sudo rm -rf /etc/containers
sudo rm -rf /var/lib/containers
sudo rm -rf /run/podman

# Remove user-level config and data
rm -rf ~/.config/containers
rm -rf ~/.local/share/containers
```
