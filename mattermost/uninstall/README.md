# Mattermost Uninstallation

## Quick Uninstall

```bash
sudo ./uninstall/uninstall.sh
```

## Manual Uninstallation

### Stop the service

#### systemd (Linux)
```bash
sudo systemctl stop mattermost
sudo systemctl disable mattermost
```

#### OpenRC (BSD/Linux)
```bash
sudo rc-service mattermost stop
```

#### SysVinit (Legacy Linux)
```bash
sudo service mattermost stop
```

#### Windows (NSSM)
```powershell
nssm stop mattermost
```

### Remove service and configuration

```bash
sudo rm -rf /etc/mattermost
sudo rm -rf /var/mattermost
sudo rm -rf /var/log/mattermost
```

### Remove service user (optional)
```bash
sudo userdel -r mattermost
```

## Verify Removal

```bash
# Check no mattermost processes are running
ps aux | grep mattermost

# Check service is removed
systemctl list-units | grep mattermost
```