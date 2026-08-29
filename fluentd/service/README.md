# Fluentd Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start fluentd

# Stop
sudo systemctl stop fluentd

# Restart
sudo systemctl restart fluentd

# Reload configuration
sudo systemctl reload fluentd

# Enable on boot
sudo systemctl enable fluentd

# Disable on boot
sudo systemctl disable fluentd

# Check status
sudo systemctl status fluentd

# View logs
journalctl -u fluentd -f
```

## OpenRC (Linux/BSD)

```bash
# Start
sudo rc-service fluentd start

# Stop
sudo rc-service fluentd stop

# Restart
sudo rc-service fluentd restart

# Reload
sudo rc-service fluentd reload

# Enable on boot
sudo rc-update add fluentd default

# Check status
sudo rc-service fluentd status
```

## SysVinit (Legacy Linux)

```bash
# Start
sudo service fluentd start

# Stop
sudo service fluentd stop

# Restart
sudo service fluentd restart

# Reload
sudo service fluentd reload

# Enable on boot
sudo update-rc.d fluentd defaults

# Check status
sudo service fluentd status
```

## Windows (NSSM)

```powershell
# Start
nssm start fluentd

# Stop
nssm stop fluentd

# Restart
nssm restart fluentd

# Check status
nssm status fluentd

# Remove service
nssm remove fluentd confirm
```