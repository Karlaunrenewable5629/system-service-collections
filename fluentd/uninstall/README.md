# Uninstall Fluentd

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
# Stop and disable service
sudo systemctl stop fluentd
sudo systemctl disable fluentd
sudo rm /etc/systemd/system/fluentd.service
sudo systemctl daemon-reload

# Remove package
sudo apt remove fluentd  # Debian/Ubuntu
sudo dnf remove fluentd  # RHEL/Fedora
sudo pacman -R fluentd   # Arch
sudo apk del fluentd     # Alpine

# Remove directories
sudo rm -rf /etc/fluentd /var/lib/fluentd /var/log/fluentd /usr/local/bin/fluentd
```