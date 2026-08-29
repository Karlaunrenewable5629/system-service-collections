# Uninstall Puppet Agent

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
# Stop and disable service
sudo systemctl stop puppet
sudo systemctl disable puppet
sudo rm /etc/systemd/system/puppet.service
sudo systemctl daemon-reload

# Remove package (depends on distribution)
sudo apt remove puppet-agent  # Debian/Ubuntu
sudo dnf remove puppet        # RHEL/Fedora
sudo apk del puppet           # Alpine

# Remove data and log directories
sudo rm -rf /var/lib/puppet /var/log/puppet /etc/puppetlabs/puppet
```