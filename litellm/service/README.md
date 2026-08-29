# LiteLLM Service Management

## systemd (systemctl)

### Install Service

```bash
sudo cp service/systemd/litellm.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable litellm
sudo systemctl start litellm
```

### Common Commands

```bash
# Status
sudo systemctl status litellm

# Start/Stop/Restart
sudo systemctl start litellm
sudo systemctl stop litellm
sudo systemctl restart litellm

# Reload config
sudo systemctl reload litellm

# Logs
journalctl -u litellm -f
journalctl -u litellm --since "1 hour ago"

# Enable/Disable auto-start
sudo systemctl enable litellm
sudo systemctl disable litellm
```

### Override Settings

```bash
# Create override
sudo systemctl edit litellm

# Example override.conf:
# [Service]
# Environment="LITELLM_CONFIG=/custom/path/config.yaml"
# MemoryLimit=8G
```

## OpenRC (rc-service)

### Install Service

```bash
sudo cp service/openrc/litellm /etc/init.d/
sudo chmod +x /etc/init.d/litellm
sudo rc-update add litellm default
sudo rc-service litellm start
```

### Common Commands

```bash
# Status
sudo rc-service litellm status

# Start/Stop/Restart
sudo rc-service litellm start
sudo rc-service litellm stop
sudo rc-service litellm restart

# Logs
tail -f /var/log/litellm/litellm.log
```

## SysVinit (service)

### Install Service

```bash
sudo cp service/sysvinit/litellm /etc/init.d/
sudo chmod +x /etc/init.d/litellm
sudo update-rc.d litellm defaults
sudo service litellm start
```

### Common Commands

```bash
# Status
sudo service litellm status

# Start/Stop/Restart
sudo service litellm start
sudo service litellm stop
sudo service litellm restart
```

## Windows (NSSM)

### Install Service

```powershell
# Download NSSM: https://nssm.cc/download
# Extract and add to PATH

# Install
nssm install litellm < service\windows\litellm.nssm

# Or manually:
nssm install litellm "C:\Python311\python.exe" "-m litellm --config C:\etc\litellm\config.yaml --host 0.0.0.0 --port 4000"
nssm set litellm AppDirectory "C:\opt\litellm"
nssm set litellm DisplayName "LiteLLM API Proxy"
nssm set litellm Description "Unified LLM API Proxy"
nssm set litellm Start SERVICE_AUTO_START
```

### Common Commands

```powershell
# Start/Stop/Restart
nssm start litellm
nssm stop litellm
nssm restart litellm

# Status
nssm status litellm

# Logs
Get-Content C:\var\log\litellm\litellm-out.log -Wait
Get-Content C:\var\log\litellm\litellm-err.log -Wait

# Remove
nssm remove litellm confirm
```

## Health Checks

```bash
# HTTP health endpoint
curl -f http://localhost:4000/health

# systemd health check (in service file)
# ExecStartPre=/usr/bin/curl -f http://localhost:4000/health || exit 1
```

## Log Rotation

### logrotate (Linux)

```bash
# /etc/logrotate.d/litellm
/var/log/litellm/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 640 litellm litellm
    sharedscripts
    postrotate
        systemctl reload litellm > /dev/null 2>&1 || true
    endscript
}
```

### NSSM (Windows)

Configured in .nssm file:
- RotateFiles: 1
- RotateBytes: 10485760 (10MB)
- RotateSeconds: 86400 (24h)

## Troubleshooting

### Service Won't Start

```bash
# Check logs
journalctl -u litellm -n 50

# Check config
litellm --config /etc/litellm/config.yaml --validate

# Check permissions
ls -la /etc/litellm/ /var/lib/litellm/ /var/log/litellm/
```

### High Memory Usage

```bash
# Reduce workers in config.yaml
workers: 2

# Enable caching
cache:
  type: "redis"
```

### Port Conflicts

```bash
# Check what's using port 4000
ss -tlnp | grep 4000
netstat -tlnp | grep 4000

# Change port in config.yaml
server:
  port: 4001
```