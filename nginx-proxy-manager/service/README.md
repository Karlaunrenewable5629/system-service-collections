# Service Management

This guide covers managing nginx-proxy-manager across different init systems and platforms.

## Table of Contents

- [systemd](#systemd)
- [OpenRC](#openrc)
- [SysVinit](#sysvinit)
- [Windows NSSM](#windows-nssm)

## systemd

### Install the service

```bash
sudo cp service/systemd/nginx-proxy-manager.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable nginx-proxy-manager
sudo systemctl start nginx-proxy-manager
```

### Common operations

```bash
# Start the service
sudo systemctl start nginx-proxy-manager

# Stop the service
sudo systemctl stop nginx-proxy-manager

# Restart the service
sudo systemctl restart nginx-proxy-manager

# Check status
sudo systemctl status nginx-proxy-manager

# View logs
sudo journalctl -u nginx-proxy-manager -f
```

### Enable auto-restart on failure

The systemd unit includes `Restart=on-failure` with a 5-second delay.

## OpenRC

### Install the service

```bash
sudo cp service/openrc/nginx-proxy-manager /etc/init.d/nginx-proxy-manager
sudo chmod +x /etc/init.d/nginx-proxy-manager
sudo rc-update add nginx-proxy-manager default
sudo rc-service nginx-proxy-manager start
```

### Common operations

```bash
# Start the service
sudo rc-service nginx-proxy-manager start

# Stop the service
sudo rc-service nginx-proxy-manager stop

# Restart the service
sudo rc-service nginx-proxy-manager restart

# Check status
sudo rc-service nginx-proxy-manager status

# View logs
sudo tail -f /var/log/nginx-proxy-manager/npm.log
```

## SysVinit

### Install the service

```bash
sudo cp service/sysvinit/nginx-proxy-manager /etc/init.d/nginx-proxy-manager
sudo chmod +x /etc/init.d/nginx-proxy-manager
sudo update-rc.d nginx-proxy-manager defaults
sudo service nginx-proxy-manager start
```

### Common operations

```bash
# Start the service
sudo service nginx-proxy-manager start

# Stop the service
sudo service nginx-proxy-manager stop

# Restart the service
sudo service nginx-proxy-manager restart

# Check status
sudo service nginx-proxy-manager status

# View logs
sudo tail -f /var/log/nginx-proxy-manager/npm.log
```

## Windows NSSM

### Install the service

```powershell
# Copy the NSSM config file
copy service\windows\nginx-proxy-manager.nssm C:\ProgramData\nginx-proxy-manager\

# Install the service
nssm install nginx-proxy-manager

# Start the service
nssm start nginx-proxy-manager
```

### Common operations

```powershell
# Stop the service
nssm stop nginx-proxy-manager

# Restart the service
nssm restart nginx-proxy-manager

# Check status
nssm status nginx-proxy-manager

# Remove the service
nssm remove nginx-proxy-manager confirm

# View logs
Get-Content C:\var\log\nginx-proxy-manager\npm.log -Tail 50 -Wait
```

## Service User

All service configurations run under the `npm:npm` user/group by default. On Debian/Ubuntu systems, `www-data:www-data` may be used instead.

## Ports

| Port | Purpose |
|------|---------|
| `80` | HTTP proxy |
| `443` | HTTPS proxy |
| `81` | Admin UI |

The admin interface is accessible at `http://localhost:81`.
