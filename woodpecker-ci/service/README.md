# Woodpecker CI Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start woodpecker

# Stop
sudo systemctl stop woodpecker

# Restart
sudo systemctl restart woodpecker

# Reload configuration
sudo systemctl reload woodpecker

# Enable on boot
sudo systemctl enable woodpecker

# Disable on boot
sudo systemctl disable woodpecker

# Check status
sudo systemctl status woodpecker

# View logs
journalctl -u woodpecker -f
```

## OpenRC (BSD/Linux)

```bash
# Start
sudo rc-service woodpecker start

# Stop
sudo rc-service woodpecker stop

# Restart
sudo rc-service woodpecker restart

# Reload
sudo rc-service woodpecker reload

# Enable on boot
sudo rc-update add woodpecker default

# Check status
sudo rc-service woodpecker status
```

## SysVinit (Legacy Linux)

```bash
# Start
sudo service woodpecker start

# Stop
sudo service woodpecker stop

# Restart
sudo service woodpecker restart

# Check status
sudo service woodpecker status
```

## Windows (NSSM)

```powershell
# Start
nssm start woodpecker

# Stop
nssm stop woodpecker

# Restart
nssm restart woodpecker

# Check status
nssm status woodpecker

# Remove service
nssm remove woodpecker confirm
```