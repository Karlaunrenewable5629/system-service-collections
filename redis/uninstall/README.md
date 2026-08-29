# Uninstall Redis

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
# Stop and disable service
sudo systemctl stop redis
sudo systemctl disable redis
sudo rm /etc/systemd/system/redis.service
sudo systemctl daemon-reload

# Remove package (depends on distribution)
sudo apt remove redis  # Debian/Ubuntu
sudo dnf remove redis  # RHEL/Fedora
sudo apk del redis     # Alpine

# Remove data and log directories
sudo rm -rf /var/lib/redis /var/log/redis /etc/redis
```