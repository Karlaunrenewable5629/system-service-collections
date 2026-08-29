# Uninstall Envoy

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
sudo systemctl stop envoy
sudo systemctl disable envoy
sudo rm /etc/systemd/system/envoy.service
sudo systemctl daemon-reload

sudo apt remove envoy  # Debian/Ubuntu
sudo dnf remove envoy  # RHEL/Fedora

sudo rm -rf /etc/envoy /var/lib/envoy /var/log/envoy /usr/local/bin/envoy
```