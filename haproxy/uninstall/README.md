# Uninstall HAProxy

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
sudo systemctl stop haproxy
sudo systemctl disable haproxy
sudo rm /etc/systemd/system/haproxy.service
sudo systemctl daemon-reload

sudo apt remove haproxy  # Debian/Ubuntu
sudo dnf remove haproxy  # RHEL/Fedora
sudo pacman -R haproxy   # Arch
sudo apk del haproxy     # Alpine

sudo rm -rf /etc/haproxy /var/lib/haproxy /var/log/haproxy /usr/local/bin/haproxy
```