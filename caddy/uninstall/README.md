# Uninstall Caddy

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
# Stop and disable service
sudo systemctl stop caddy
sudo systemctl disable caddy
sudo rm /etc/systemd/system/caddy.service
sudo systemctl daemon-reload

# Remove package
sudo apt remove caddy  # Debian/Ubuntu
sudo dnf remove caddy  # RHEL/Fedora
sudo pacman -R caddy   # Arch
sudo apk del caddy     # Alpine

# Remove directories
sudo rm -rf /etc/caddy /var/lib/caddy /var/log/caddy /usr/local/bin/caddy
```