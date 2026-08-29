# Uninstall Fluent Bit

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
# Stop and disable service
sudo systemctl stop fluent-bit
sudo systemctl disable fluent-bit
sudo rm /etc/systemd/system/fluent-bit.service
sudo systemctl daemon-reload

# Remove package
sudo apt remove fluent-bit  # Debian/Ubuntu
sudo dnf remove fluent-bit  # RHEL/Fedora
sudo pacman -R fluent-bit   # Arch
sudo apk del fluent-bit     # Alpine

# Remove directories
sudo rm -rf /etc/fluent-bit /var/lib/fluent-bit /var/log/fluent-bit /usr/local/bin/fluent-bit
```