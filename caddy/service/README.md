# Caddy Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start caddy

# Stop
sudo systemctl stop caddy

# Restart
sudo systemctl restart caddy

# Reload configuration
sudo systemctl reload caddy

# Enable on boot
sudo systemctl enable caddy

# Disable on boot
sudo systemctl disable caddy

# Check status
sudo systemctl status caddy

# View logs
journalctl -u caddy -f
```

## OpenRC (BSD/Linux)

```bash
# Start
sudo rc-service caddy start

# Stop
sudo rc-service caddy stop

# Restart
sudo rc-service caddy restart

# Reload
sudo rc-service caddy reload

# Enable on boot
sudo rc-update add caddy default

# Check status
sudo rc-service caddy status
```

## SysVinit (Legacy Linux)

```bash
# Start
sudo service caddy start

# Stop
sudo service caddy stop

# Restart
sudo service caddy restart

# Reload
sudo service caddy reload

# Enable on boot
sudo update-rc.d caddy defaults

# Check status
sudo service caddy status
```

## Windows (NSSM)

```powershell
# Start
nssm start caddy

# Stop
nssm stop caddy

# Restart
nssm restart caddy

# Check status
nssm status caddy

# Remove service
nssm remove caddy confirm
```