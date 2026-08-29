# Uninstallation Guide

This guide covers removing nginx and its service configuration from your system.

## Prerequisites

- Root or sudo access

## Uninstall Using the Script

```bash
cd uninstall
./uninstall.sh
```

This script will:

1. Stop the nginx service
2. Remove the service definition for your init system
3. Back up the existing configuration
4. Remove nginx configuration files
5. Remove SSL certificates
6. Remove nginx logs
7. Remove the web root directory
8. Remove the nginx user

## Manual Uninstallation

### systemd

```bash
systemctl stop nginx
systemctl disable nginx
rm -f /etc/systemd/system/nginx.service
systemctl daemon-reload
rm -rf /etc/nginx
rm -rf /var/log/nginx
rm -f /run/nginx.pid
```

### OpenRC

```bash
rc-service nginx stop
rc-update del nginx default
rm -f /etc/init.d/nginx
rm -rf /etc/nginx
rm -rf /var/log/nginx
rm -f /run/nginx.pid
```

### SysVinit

```bash
service nginx stop
chkconfig --del nginx
rm -f /etc/init.d/nginx
rm -rf /etc/nginx
rm -rf /var/log/nginx
rm -f /run/nginx.pid
```

### Windows (NSSM)

```cmd
nssm stop nginx
nssm remove nginx confirm
rmdir /s /q C:\nginx
```

## Backing Up Configuration Before Uninstall

If you want to keep your configuration before uninstalling, back it up first:

```bash
cp /etc/nginx/nginx.conf /path/to/backup/
cp -r /etc/nginx/ssl /path/to/backup/
```

## Reinstallation

After uninstallation, you can reinstall nginx using the install guide in [install/README.md](install/README.md).

## Notes

- This removes service definitions only; the nginx package may remain installed
- To completely remove nginx, also uninstall the nginx package using your system's package manager
- Configuration backups are saved with timestamps if they exist