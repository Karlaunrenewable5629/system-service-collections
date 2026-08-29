# Semaphore Uninstallation

## Quick Uninstall

```bash
sudo ./uninstall/uninstall.sh
```

## Manual Uninstallation

### Stop the service

#### systemd (Linux)
```bash
sudo systemctl stop semaphore
sudo systemctl disable semaphore
```

#### OpenRC (BSD/Linux)
```bash
sudo rc-service semaphore stop
```

#### SysVinit (Legacy Linux)
```bash
sudo service semaphore stop
```

#### Windows (NSSM)
```powershell
nssm stop semaphore
```

### Remove service and configuration

```bash
sudo rm -rf /etc/semaphore
sudo rm -rf /var/lib/semaphore
sudo rm -rf /var/log/semaphore
```

### Remove systemd service (if installed manually)
```bash
sudo rm /etc/systemd/system/semaphore.service
sudo systemctl daemon-reload
```

### Remove service user (optional)
```bash
sudo userdel -r semaphore
```

## Verify Removal

```bash
# Check no semaphore processes are running
ps aux | grep semaphore

# Check service is removed
systemctl list-units | grep semaphore
```