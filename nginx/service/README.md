# Service Management

This directory contains service definitions for nginx across different init systems and platforms.

## Available Service Definitions

| Init System | File | Platform |
|-------------|------|----------|
| systemd | `systemd/nginx.service` | Linux (systemd) |
| OpenRC | `openrc/nginx` | Alpine Linux, Gentoo |
| SysVinit | `sysvinit/nginx` | Legacy Linux distributions |
| NSSM | `windows/nginx.nssm` | Windows |

## systemd

### Install

```bash
cp service/systemd/nginx.service /etc/systemd/system/
systemctl daemon-reload
```

### Start/Enable

```bash
systemctl enable nginx
systemctl start nginx
```

### Common Commands

```bash
systemctl status nginx       # Check status
systemctl stop nginx         # Stop service
systemctl restart nginx      # Restart service
systemctl reload nginx       # Reload configuration
systemctl disable nginx      # Disable on boot
```

## OpenRC

### Install

```bash
cp service/openrc/nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx
rc-update add nginx default
```

### Common Commands

```bash
rc-service nginx start       # Start service
rc-service nginx stop        # Stop service
rc-service nginx restart     # Restart service
rc-service nginx reload      # Reload configuration
rc-service nginx status      # Check status
```

## SysVinit

### Install

```bash
cp service/sysvinit/nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx
chkconfig --add nginx
chkconfig nginx on
```

### Common Commands

```bash
service nginx start          # Start service
service nginx stop           # Stop service
service nginx restart        # Restart service
service nginx reload         # Reload configuration
service nginx status         # Check status
```

## Windows (NSSM)

### Install

1. Copy `nginx.nssm` to `C:\nginx\nginx.nssm`
2. Install NSSM if not already installed
3. Run the following commands:

```cmd
nssm install nginx C:\nginx\nginx.nssm
nssm start nginx
```

### Common Commands

```cmd
nssm start nginx             # Start service
nssm stop nginx              # Stop service
nssm restart nginx           # Restart service
nssm status nginx            # Check status
nssm stop nginx              # Stop service
```

## User and Group

All service definitions run nginx as the `nginx` user and `nginx` group. Ensure this user exists on your system:

```bash
useradd -r -s /sbin/nologin nginx
```

## PID File

All configurations use `/run/nginx.pid` as the PID file location. Ensure the directory exists:

```bash
mkdir -p /run
chown nginx:nginx /run
```

## Configuration Validation

Before starting the service, always validate the configuration:

```bash
nginx -t
```