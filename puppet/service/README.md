# Puppet Agent Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start puppet

# Stop
sudo systemctl stop puppet

# Restart
sudo systemctl restart puppet

# Reload configuration
sudo systemctl reload puppet

# Enable on boot
sudo systemctl enable puppet

# Disable on boot
sudo systemctl disable puppet

# Check status
sudo systemctl status puppet

# View logs
journalctl -u puppet -f
```

## OpenRC (BSD/Linux)

```bash
# Start
sudo rc-service puppet start

# Stop
sudo rc-service puppet stop

# Restart
sudo rc-service puppet restart

# Check status
sudo rc-service puppet status
```

## SysVinit (Legacy Linux)

```bash
# Start
sudo service puppet start

# Stop
sudo service puppet stop

# Restart
sudo service puppet restart

# Check status
sudo service puppet status
```

## Windows (NSSM)

```powershell
# Start
nssm start puppet

# Stop
nssm stop puppet

# Restart
nssm restart puppet

# Check status
nssm status puppet

# Remove service
nssm remove puppet confirm
```