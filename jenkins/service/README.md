# Jenkins Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start jenkins

# Stop
sudo systemctl stop jenkins

# Restart
sudo systemctl restart jenkins

# Reload configuration
sudo systemctl reload jenkins

# Enable on boot
sudo systemctl enable jenkins

# Disable on boot
sudo systemctl disable jenkins

# Check status
sudo systemctl status jenkins

# View logs
journalctl -u jenkins -f
```

## OpenRC (BSD/Linux)

```bash
# Start
sudo rc-service jenkins start

# Stop
sudo rc-service jenkins stop

# Restart
sudo rc-service jenkins restart

# Reload
sudo rc-service jenkins reload

# Enable on boot
sudo rc-update add jenkins default

# Check status
sudo rc-service jenkins status
```

## SysVinit (Legacy Linux)

```bash
# Start
sudo service jenkins start

# Stop
sudo service jenkins stop

# Restart
sudo service jenkins restart

# Check status
sudo service jenkins status
```

## Windows (NSSM)

```powershell
# Start
nssm start jenkins

# Stop
nssm stop jenkins

# Restart
nssm restart jenkins

# Check status
nssm status jenkins

# Remove service
nssm remove jenkins confirm
```