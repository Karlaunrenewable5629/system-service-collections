# Uninstall Salt Minion

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
# Stop and disable service
sudo systemctl stop salt-minion
sudo systemctl disable salt-minion
sudo rm /etc/systemd/system/salt-minion.service
sudo systemctl daemon-reload

# Remove package (depends on distribution)
sudo apt remove salt-minion  # Debian/Ubuntu
sudo dnf remove salt-minion  # RHEL/Fedora
sudo apk del salt-minion     # Alpine

# Remove data and log directories
sudo rm -rf /var/cache/salt /var/log/salt /etc/salt
```