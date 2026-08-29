# Salt Minion Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start salt-minion

# Stop
sudo systemctl stop salt-minion

# Restart
sudo systemctl restart salt-minion

# Reload configuration
sudo systemctl reload salt-minion

# Enable on boot
sudo systemctl enable salt-minion

# Disable on boot
sudo systemctl disable salt-minion

# Check status
sudo systemctl status salt-minion

# View logs
journalctl -u salt-minion -f
```

## OpenRC (BSD/Linux)

```bash
# Start
sudo rc-service salt-minion start

# Stop
sudo rc-service salt-minion stop

# Restart
sudo rc-service salt-minion restart

# Check status
sudo rc-service salt-minion status
```

## SysVinit (Legacy Linux)

```bash
# Start
sudo service salt-minion start

# Stop
sudo service salt-minion stop

# Restart
sudo service salt-minion restart

# Check status
sudo service salt-minion status
```

## Windows (NSSM)

```powershell
# Start
nssm start salt-minion

# Stop
nssm stop salt-minion

# Restart
nssm restart salt-minion

# Check status
nssm status salt-minion

# Remove service
nssm remove salt-minion confirm
```