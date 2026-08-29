# Cloudflare Tunnel Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start cloudflared

# Stop
sudo systemctl stop cloudflared

# Restart
sudo systemctl restart cloudflared

# Reload configuration
sudo systemctl reload cloudflared

# Enable on boot
sudo systemctl enable cloudflared

# Disable on boot
sudo systemctl disable cloudflared

# Check status
sudo systemctl status cloudflared

# View logs
journalctl -u cloudflared -f
```

## OpenRC (BSD/Linux)

```bash
# Start
sudo rc-service cloudflared start

# Stop
sudo rc-service cloudflared stop

# Restart
sudo rc-service cloudflared restart

# Check status
sudo rc-service cloudflared status
```

## SysVinit (Legacy Linux)

```bash
# Start
sudo service cloudflared start

# Stop
sudo service cloudflared stop

# Restart
sudo service cloudflared restart

# Check status
sudo service cloudflared status
```

## Windows (NSSM)

```powershell
# Start
nssm start cloudflared

# Stop
nssm stop cloudflared

# Restart
nssm restart cloudflared

# Check status
nssm status cloudflared

# Remove service
nssm remove cloudflared confirm
```

## Environment Overrides

### systemd

Create `/etc/systemd/system/cloudflared.service.d/override.conf`:
```ini
[Service]
Environment="TUNNEL_NAME=<tunnel-name>"
Environment="LOG_LEVEL=info"
```

### OpenRC

Create `/etc/conf.d/cloudflared`:
```bash
TUNNEL_NAME=<tunnel-name>
LOG_LEVEL=info
```

## Common Issues

| Issue | Solution |
|-------|----------|
| Connection refused | Check tunnel is running and credentials are valid |
| DNS propagation | Wait for DNS to propagate or use `--no-autodns` |
| Certificates expired | Renew certificates via dashboard or API |
| Performance slow | Enable caching or use closer data center |
| Authentication failed | Re-run `cloudflared tunnel login` |
| Port already in use | Change local service port or tunnel config |
| Too many connections | Adjust rate limiting in dashboard |