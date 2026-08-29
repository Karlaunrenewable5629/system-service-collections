# Uninstall Memcached

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
# Stop and disable service
sudo systemctl stop memcached
sudo systemctl disable memcached
sudo rm /etc/systemd/system/memcached.service
sudo systemctl daemon-reload

# Remove package
sudo apt remove memcached  # Debian/Ubuntu
sudo dnf remove memcached  # RHEL/Fedora
sudo apk del memcached     # Alpine

# Remove data and log directories
sudo rm -rf /var/lib/memcached /var/log/memcached /etc/memcached
```