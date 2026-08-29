# Redis Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start redis

# Stop
sudo systemctl stop redis

# Restart
sudo systemctl restart redis

# Reload configuration
sudo systemctl reload redis

# Enable on boot
sudo systemctl enable redis

# Disable on boot
sudo systemctl disable redis

# Check status
sudo systemctl status redis

# View logs
journalctl -u redis -f
```

## OpenRC (BSD/Linux)

```bash
# Start
sudo rc-service redis start

# Stop
sudo rc-service redis stop

# Restart
sudo rc-service redis restart

# Check status
sudo rc-service redis status
```

## SysVinit (Legacy Linux)

```bash
# Start
sudo service redis start

# Stop
sudo service redis stop

# Restart
sudo service redis restart

# Check status
sudo service redis status
```

## Windows (NSSM)

```powershell
# Start
nssm start redis

# Stop
nssm stop redis

# Restart
nssm restart redis

# Check status
nssm status redis

# Remove service
nssm remove redis confirm
```