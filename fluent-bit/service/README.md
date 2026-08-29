# Fluent Bit Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start fluent-bit

# Stop
sudo systemctl stop fluent-bit

# Restart
sudo systemctl restart fluent-bit

# Reload configuration
sudo systemctl reload fluent-bit

# Enable on boot
sudo systemctl enable fluent-bit

# Disable on boot
sudo systemctl disable fluent-bit

# Check status
sudo systemctl status fluent-bit

# View logs
journalctl -u fluent-bit -f
```

## OpenRC (Linux/BSD)

```bash
# Start
sudo rc-service fluent-bit start

# Stop
sudo rc-service fluent-bit stop

# Restart
sudo rc-service fluent-bit restart

# Reload
sudo rc-service fluent-bit reload

# Enable on boot
sudo rc-update add fluent-bit default

# Check status
sudo rc-service fluent-bit status
```

## SysVinit (Legacy Linux)

```bash
# Start
sudo service fluent-bit start

# Stop
sudo service fluent-bit stop

# Restart
sudo service fluent-bit restart

# Reload
sudo service fluent-bit reload

# Enable on boot
sudo update-rc.d fluent-bit defaults

# Check status
sudo service fluent-bit status
```

## Windows (NSSM)

```powershell
# Start
nssm start fluent-bit

# Stop
nssm stop fluent-bit

# Restart
nssm restart fluent-bit

# Check status
nssm status fluent-bit

# Remove service
nssm remove fluent-bit confirm
```