# Memcached Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start memcached

# Stop
sudo systemctl stop memcached

# Restart
sudo systemctl restart memcached

# Reload configuration
sudo systemctl reload memcached

# Enable on boot
sudo systemctl enable memcached

# Disable on boot
sudo systemctl disable memcached

# Check status
sudo systemctl status memcached

# View logs
journalctl -u memcached -f
```

## OpenRC (BSD/Linux)

```bash
# Start
sudo rc-service memcached start

# Stop
sudo rc-service memcached stop

# Restart
sudo rc-service memcached restart

# Check status
sudo rc-service memcached status
```

## SysVinit (Legacy Linux)

```bash
# Start
sudo service memcached start

# Stop
sudo service memcached stop

# Restart
sudo service memcached restart

# Check status
sudo service memcached status
```

## Windows (NSSM)

```powershell
# Start
nssm start memcached

# Stop
nssm stop memcached

# Restart
nssm restart memcached

# Check status
nssm status memcached

# Remove service
nssm remove memcached confirm
```