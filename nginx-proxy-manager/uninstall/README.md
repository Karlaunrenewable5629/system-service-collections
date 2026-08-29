# Uninstallation Guide

This guide covers removing nginx-proxy-manager from your system.

## Quick Uninstall

If you installed using the automated script:

```bash
sudo bash uninstall/uninstall.sh
```

## Manual Uninstallation

### 1. Stop the Service

```bash
# systemd
sudo systemctl stop nginx-proxy-manager
sudo systemctl disable nginx-proxy-manager

# OpenRC
sudo rc-service nginx-proxy-manager stop
rc-update del nginx-proxy-manager default

# SysVinit
sudo service nginx-proxy-manager stop
sudo update-rc.d -f nginx-proxy-manager remove

# Windows
nssm stop nginx-proxy-manager
nssm remove nginx-proxy-manager confirm
```

### 2. Remove Service Files

```bash
# systemd
sudo rm -f /etc/systemd/system/nginx-proxy-manager.service
sudo systemctl daemon-reload

# OpenRC
sudo rm -f /etc/init.d/nginx-proxy-manager

# SysVinit
sudo rm -f /etc/init.d/nginx-proxy-manager

# Windows
# Service was removed by the nssm command above
```

### 3. Remove Application Files

```bash
sudo rm -rf /usr/lib/nginx-proxy-manager
```

### 4. Remove Configuration

```bash
sudo rm -rf /etc/nginx-proxy-manager
```

### 5. Remove Logs

```bash
sudo rm -rf /var/log/nginx-proxy-manager
```

### 6. Remove Data (Database, Certificates)

```bash
sudo rm -rf /var/lib/nginx-proxy-manager
```

### 7. Remove Application User

```bash
sudo userdel npm
sudo groupdel npm
```

### 8. Clean Firewall Rules

```bash
# UFW
sudo ufw delete allow 80/tcp
sudo ufw delete allow 443/tcp
sudo ufw delete allow 81/tcp

# firewalld
sudo firewall-cmd --permanent --remove-port=80/tcp
sudo firewall-cmd --permanent --remove-port=443/tcp
sudo firewall-cmd --permanent --remove-port=81/tcp
sudo firewall-cmd --reload
```

## Data Backup

Before uninstalling, you may want to back up your configuration and database:

```bash
# Back up configuration
cp -r /etc/nginx-proxy-manager ~/npm-config-backup-$(date +%Y%m%d)

# Back up database
cp /var/lib/nginx-proxy-manager/npm.db ~/npm-db-backup-$(date +%Y%m%d)

# Back up SSL certificates
cp -r /etc/letsencrypt/live ~/letsencrypt-backup-$(date +%Y%m%d)
```

## Windows Uninstall

### Using NSSM

```powershell
# Stop and remove the service
nssm stop nginx-proxy-manager
nssm remove nginx-proxy-manager confirm

# Remove application files
Remove-Item -Recurse -Force C:\lib\nginx-proxy-manager
Remove-Item -Recurse -Force C:\etc\nginx-proxy-manager
Remove-Item -Recurse -Force C:\var\log\nginx-proxy-manager
```

## Verification

After uninstallation, verify the service is completely removed:

```bash
# Check service is gone
systemctl status nginx-proxy-manager 2>&1 || true
rc-service nginx-proxy-manager status 2>&1 || true
service nginx-proxy-manager status 2>&1 || true

# Check no processes remain
ps aux | grep nginx-proxy-manager | grep -v grep || true

# Check ports are free
ss -tlnp | grep -E ':(80|443|81)\s' || echo "All ports are free."
```

## Reinstallation

If you plan to reinstall, you can keep the database by skipping the `remove_data` step. This allows you to preserve your proxy hosts, SSL certificates, and other configurations when reinstalling.
