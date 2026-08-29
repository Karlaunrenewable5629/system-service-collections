# Uninstall Chef Client

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
# Remove package (depends on distribution)
sudo apt remove chef  # Debian/Ubuntu
sudo dnf remove chef  # RHEL/Fedora
sudo apk del chef     # Alpine

# Remove data and log directories
sudo rm -rf /etc/chef /var/cache/chef /var/log/chef
```