# Uninstall Docker

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
# Stop and disable service
sudo systemctl stop docker
sudo systemctl disable docker
sudo rm -f /etc/systemd/system/docker.service
sudo systemctl daemon-reload

# Remove packages
sudo apt remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin  # Debian/Ubuntu
sudo dnf remove docker-ce docker-ce-cli containerd.io                                              # RHEL/Fedora
sudo pacman -R docker docker-compose                                                               # Arch
sudo apk del docker docker-compose                                                                 # Alpine

# Remove all Docker data (images, containers, volumes, networks)
sudo rm -rf /var/lib/docker
sudo rm -rf /etc/docker
sudo rm -f /usr/local/bin/docker-compose
```

> **Warning:** Removing `/var/lib/docker` deletes all images, containers, and volumes permanently.
