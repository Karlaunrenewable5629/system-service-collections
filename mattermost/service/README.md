# Mattermost Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start mattermost

# Stop
sudo systemctl stop mattermost

# Restart
sudo systemctl restart mattermost

# Reload configuration
sudo systemctl reload mattermost

# Enable on boot
sudo systemctl enable mattermost

# Disable on boot
sudo systemctl disable mattermost

# Check status
sudo systemctl status mattermost

# View logs
journalctl -u mattermost -f
```

Service file: `service/systemd/mattermost.service`

## OpenRC (BSD/Linux)

```bash
# Start
sudo rc-service mattermost start

# Stop
sudo rc-service mattermost stop

# Restart
sudo rc-service mattermost restart

# Check status
sudo rc-service mattermost status
```

Service file: `service/openrc/mattermost`

## SysVinit (Legacy Linux)

```bash
# Start
sudo service mattermost start

# Stop
sudo service mattermost stop

# Restart
sudo service mattermost restart

# Check status
sudo service mattermost status
```

Service file: `service/sysvinit/mattermost`

## Windows (NSSM)

```powershell
# Start
nssm start mattermost

# Stop
nssm stop mattermost

# Restart
nssm restart mattermost

# Check status
nssm status mattermost

# Remove service
nssm remove mattermost confirm
```

Service file: `service/windows/mattermost.nssm`

## Environment Overrides

### systemd

Create `/etc/systemd/system/mattermost.service.d/override.conf`:
```ini
[Service]
Environment="MM_SETTINGS_FILE=/etc/mattermost/settings.json"
Environment="DB_CONNECTION=postgres"
```

### OpenRC

Create `/etc/conf.d/mattermost`:
```bash
MM_SETTINGS_FILE=/etc/mattermost/settings.json
DB_CONNECTION=postgres
```

## Common Issues

| Issue | Solution |
|-------|----------|
| Database connection failed | Check credentials in settings.json |
| Port 8065 in use | Change `SiteConfiguration.ServiceSettings.Port` in settings.json |
| Login not working | Verify SiteConfiguration.LoginAuthenticator setting |
| Email not sending | Check EmailSettings in settings.json |
| SSL certificate errors | Ensure valid certificate is configured |
| Memory issues | Adjust Node.js maximum memory in systemd service |