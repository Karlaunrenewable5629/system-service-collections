# Uninstall Jenkins

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

## Manual

```bash
# Stop and disable service
sudo systemctl stop jenkins
sudo systemctl disable jenkins
sudo rm /etc/systemd/system/jenkins.service
sudo systemctl daemon-reload

# Remove package (depends on distribution)
sudo apt remove jenkins  # Debian/Ubuntu
sudo dnf remove jenkins  # RHEL/Fedora
sudo apk del jenkins     # Alpine

# Remove data and log directories
sudo rm -rf /var/jenkins_home /var/log/jenkins /etc/jenkins
```