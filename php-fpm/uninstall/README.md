# Uninstall PHP-FPM

This guide covers removing PHP-FPM and its service configuration from your system.

## Prerequisites

- Root or sudo access

## Uninstall Using the Script

```bash
cd uninstall
./uninstall.sh
```

This script will:

1. Stop the PHP-FPM service
2. Remove the service definition for your init system
3. Back up the existing configuration
4. Remove PHP-FPM configuration files
5. Remove logs
6. Remove the nginx user

## Manual Uninstallation

### systemd

```bash
systemctl stop php-fpm
systemctl disable php-fpm
rm -f /etc/systemd/system/php-fpm.service
systemctl daemon-reload
rm -rf /etc/php-fpm
rm -rf /var/log/php-fpm
rm -f /run/php-fpm/php-fpm.pid
```

### OpenRC

```bash
rc-service php-fpm stop
rc-update del php-fpm default
rm -f /etc/init.d/php-fpm
rm -rf /etc/php-fpm
rm -rf /var/log/php-fpm
rm -f /run/php-fpm/php-fpm.pid
```

### SysVinit

```bash
service php-fpm stop
chkconfig --del php-fpm
rm -f /etc/init.d/php-fpm
rm -rf /etc/php-fpm
rm -rf /var/log/php-fpm
rm -f /run/php-fpm/php-fpm.pid
```

### Windows (NSSM)

```cmd
nssm stop php-fpm
nssm remove php-fpm confirm
rmdir /s /q C:\php-fpm
```

## Backing Up Configuration Before Uninstall

If you want to keep your configuration before uninstalling, back it up first:

```bash
cp /etc/php-fpm/php-fpm.conf /path/to/backup/
```

## Reinstallation

After uninstallation, you can reinstall PHP-FPM using the install guide in [install/README.md](install/README.md).

## Notes

- This removes service definitions only; the PHP-FPM package may remain installed
- To completely remove PHP-FPM, also uninstall the PHP-FPM package using your system's package manager
- Configuration backups are saved with timestamps if they exist