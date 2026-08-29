# Squid Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start squid

# Stop
sudo systemctl stop squid

# Restart
sudo systemctl restart squid

# Reload configuration
sudo systemctl reload squid

# Enable on boot
sudo systemctl enable squid

# Disable on boot
sudo systemctl disable squid

# Check status
sudo systemctl status squid

# View logs
journalctl -u squid -f
```

## OpenRC (BSD/Linux)

```bash
# Start
sudo rc-service squid start

# Stop
sudo rc-service squid stop

# Restart
sudo rc-service squid restart

# Check status
sudo rc-service squid status
```

## SysVinit (Legacy Linux)

```bash
# Start
sudo service squid start

# Stop
sudo service squid stop

# Restart
sudo service squid restart

# Check status
sudo service squid status
```

## Windows (NSSM)

```powershell
# Start
nssm start squid

# Stop
nssm stop squid

# Restart
nssm restart squid

# Check status
nssm status squid

# Remove service
nssm remove squid confirm
```

## Environment Overrides

### systemd

Create `/etc/systemd/system/squid.service.d/override.conf`:
```ini
[Service]
Environment="SQUID_CACHE_DIR=/var/spool/squid"
```

### OpenRC

Create `/etc/conf.d/squid`:
```bash
SQUID_CACHE_DIR=/var/spool/squid
```

## Common Issues

| Issue | Solution |
|-------|----------|
| Cache directory not found | Initialize squid with `squid -z` |
| Port 3128 in use | Change `http_port` in squid.conf |
| Access denied | Check cache_dir and permissions |
| Log rotation failed | Verify log directory permissions |
| Memory issues | Adjust `cache_mem` in squid.conf |