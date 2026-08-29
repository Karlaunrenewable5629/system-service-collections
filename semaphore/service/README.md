# Semaphore Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start semaphore

# Stop
sudo systemctl stop semaphore

# Restart
sudo systemctl restart semaphore

# Reload configuration
sudo systemctl reload semaphore

# Enable on boot
sudo systemctl enable semaphore

# Disable on boot
sudo systemctl disable semaphore

# Check status
sudo systemctl status semaphore

# View logs
journalctl -u semaphore -f
```

## OpenRC (BSD/Linux)

```bash
# Start
sudo rc-service semaphore start

# Stop
sudo rc-service semaphore stop

# Restart
sudo rc-service semaphore restart

# Check status
sudo rc-service semaphore status
```

## SysVinit (Legacy Linux)

```bash
# Start
sudo service semaphore start

# Stop
sudo service semaphore stop

# Restart
sudo service semaphore restart

# Check status
sudo service semaphore status
```

## Windows (NSSM)

```powershell
# Start
nssm start semaphore

# Stop
nssm stop semaphore

# Restart
nssm restart semaphore

# Check status
nssm status semaphore

# Remove service
nssm remove semaphore confirm
```

## Environment Overrides

### systemd

Create `/etc/systemd/system/semaphore.service.d/override.conf`:
```ini
[Service]
Environment="SEMAPHORE_DB_HOST=localhost"
Environment="SEMAPHORE_DB_USER=semaphore"
```

### OpenRC

Create `/etc/conf.d/semaphore`:
```bash
SEMAPHORE_DB_HOST=localhost
SEMAPHORE_DB_USER=semaphore
```

## Common Issues

| Issue | Solution |
|-------|----------|
| Database connection failed | Check credentials in config.json |
| SSH key not found | Ensure keys are in /var/lib/semaphore/.ssh |
| Port 3000 in use | Change `bind` setting in config.json |
| Ansible not found | Set `ansible.playbook_path` in config.json |