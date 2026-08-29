# Rocket.Chat Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start rocketchat

# Stop
sudo systemctl stop rocketchat

# Restart
sudo systemctl restart rocketchat

# Reload configuration
sudo systemctl reload rocketchat

# Enable on boot
sudo systemctl enable rocketchat

# Disable on boot
sudo systemctl disable rocketchat

# Check status
sudo systemctl status rocketchat

# View logs
journalctl -u rocketchat -f
```

Service file: `service/systemd/rocketchat.service`

## OpenRC (BSD/Linux)

```bash
# Start
sudo rc-service rocketchat start

# Stop
sudo rc-service rocketchat stop

# Restart
sudo rc-service rocketchat restart

# Check status
sudo rc-service rocketchat status
```

Service file: `service/openrc/rocketchat`

## SysVinit (Legacy Linux)

```bash
# Start
sudo service rocketchat start

# Stop
sudo service rocketchat stop

# Restart
sudo service rocketchat restart

# Check status
sudo service rocketchat status
```

Service file: `service/sysvinit/rocketchat`

## Windows (NSSM)

```powershell
# Start
nssm start rocketchat

# Stop
nssm stop rocketchat

# Restart
nssm restart rocketchat

# Check status
nssm status rocketchat

# Remove service
nssm remove rocketchat confirm
```

Service file: `service/windows/rocketchat.nssm`

## Environment Overrides

### systemd

Create `/etc/systemd/system/rocketchat.service.d/override.conf`:
```ini
[Service]
Environment="ROCKET_CHAT_SETTINGS=/etc/rocketchat/settings.json"
Environment="MONGO_URL=mongodb://localhost:27017/rocketchat"
```

### OpenRC

Create `/etc/conf.d/rocketchat`:
```bash
ROCKET_CHAT_SETTINGS=/etc/rocketchat/settings.json
MONGO_URL=mongodb://localhost:27017/rocketchat
```

## Common Issues

| Issue | Solution |
|-------|----------|
| Database connection failed | Check MONGO_URL and credentials in settings.json |
| Port 3000 in use | Change `App.settings.url` in settings.json |
| Login not working | Verify Accounts.LoginMethods setting |
| Email not sending | Check Notifications.Email in settings.json |
| Video calls not working | Ensure Jitsi is configured and accessible |
| SSL certificate errors | Ensure valid certificate is configured |
| Out of memory | Adjust Node.js maximum memory in systemd service |