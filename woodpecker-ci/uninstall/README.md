# Uninstall Woodpecker CI

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
# Stop and disable service
sudo systemctl stop woodpecker
sudo systemctl disable woodpecker
sudo rm /etc/systemd/system/woodpecker.service
sudo systemctl daemon-reload

# Remove package (depends on distribution)
sudo apt remove woodpecker-ci  # Debian/Ubuntu
sudo dnf remove woodpecker-ci  # RHEL/Fedora
sudo apk del woodpecker-ci     # Alpine

# Remove data and log directories
sudo rm -rf /var/lib/woodpecker /var/log/woodpecker /etc/woodpecker
```