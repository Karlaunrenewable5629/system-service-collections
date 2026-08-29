# Chef Client Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start chef-client

# Stop
sudo systemctl stop chef-client

# Restart
sudo systemctl restart chef-client

# Reload configuration
sudo systemctl reload chef-client

# Enable on boot
sudo systemctl enable chef-client

# Disable on boot
sudo systemctl disable chef-client

# Check status
sudo systemctl status chef-client

# View logs
journalctl -u chef-client -f
```

## OpenRC (BSD/Linux)

```bash
# Start
sudo rc-service chef-client start

# Stop
sudo rc-service chef-client stop

# Restart
sudo rc-service chef-client restart

# Check status
sudo rc-service chef-client status
```

## SysVinit (Legacy Linux)

```bash
# Start
sudo service chef-client start

# Stop
sudo service chef-client stop

# Restart
sudo service chef-client restart

# Check status
sudo service chef-client status
```

## Windows (NSSM)

```powershell
# Start
nssm start chef-client

# Stop
nssm stop chef-client

# Restart
nssm restart chef-client

# Check status
nssm status chef-client

# Remove service
nssm remove chef-client confirm
```