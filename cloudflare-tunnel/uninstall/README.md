# Cloudflare Tunnel Uninstallation

## Quick Uninstall

```bash
sudo ./uninstall/uninstall.sh
```

## Manual Uninstallation

### Stop the service

#### systemd (Linux)
```bash
sudo systemctl stop cloudflared
sudo systemctl disable cloudflared
```

#### OpenRC (BSD/Linux)
```bash
sudo rc-service cloudflared stop
```

#### SysVinit (Legacy Linux)
```bash
sudo service cloudflared stop
```

#### Windows (NSSM)
```powershell
nssm stop cloudflared
```

### Remove service and configuration

```bash
sudo rm -rf /etc/cloudflared
sudo rm -rf /var/lib/cloudflared
sudo rm -rf /var/log/cloudflared
```

### Remove binary (optional)
```bash
sudo rm /usr/local/bin/cloudflared
```

## Verify Removal

```bash
# Check no cloudflared processes are running
ps aux | grep cloudflared

# Check service is removed
systemctl list-units | grep cloudflared
```