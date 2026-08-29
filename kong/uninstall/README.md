# Uninstall Kong

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
sudo systemctl stop kong
sudo systemctl disable kong
sudo rm /etc/systemd/system/kong.service
sudo systemctl daemon-reload

sudo apt remove kong  # Debian/Ubuntu
sudo dnf remove kong  # RHEL/Fedora

sudo rm -rf /etc/kong /var/lib/kong /var/log/kong /usr/local/bin/kong
```