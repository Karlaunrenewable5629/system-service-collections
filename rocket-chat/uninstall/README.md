# Rocket.Chat Uninstallation

## Quick Uninstall

```bash
sudo ./uninstall/uninstall.sh
```

## Manual Uninstallation

### Stop the service

#### systemd (Linux)
```bash
sudo systemctl stop rocketchat
sudo systemctl disable rocketchat
```

#### OpenRC (BSD/Linux)
```bash
sudo rc-service rocketchat stop
```

#### SysVinit (Legacy Linux)
```bash
sudo service rocketchat stop
```

#### Windows (NSSM)
```powershell
nssm stop rocketchat
```

### Remove service and configuration

```bash
sudo rm -rf /etc/rocketchat
sudo rm -rf /var/rocketchat
sudo rm -rf /var/log/rocketchat
```

### Remove service user (optional)
```bash
sudo userdel -r rocketchat
```

## Verify Removal

```bash
# Check no rocketchat processes are running
ps aux | grep rocketchat

# Check service is removed
systemctl list-units | grep rocketchat
```