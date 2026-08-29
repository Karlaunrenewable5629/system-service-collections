# Squid Uninstallation

## Quick Uninstall

```bash
sudo ./uninstall/uninstall.sh
```

## Manual Uninstallation

### Stop the service

#### systemd (Linux)
```bash
sudo systemctl stop squid
sudo systemctl disable squid
```

#### OpenRC (BSD/Linux)
```bash
sudo rc-service squid stop
```

#### SysVinit (Legacy Linux)
```bash
sudo service squid stop
```

#### Windows (NSSM)
```powershell
nssm stop squid
```

### Remove service and configuration

```bash
sudo rm -rf /etc/squid
sudo rm -rf /var/spool/squid
sudo rm -rf /var/log/squid
```

### Remove service user (optional)
```bash
sudo userdel -r proxy
```

## Verify Removal

```bash
# Check no squid processes are running
ps aux | grep squid

# Check service is removed
systemctl list-units | grep squid
```