# Uninstallation Guide

This guide covers removing Varnish Cache and its service configuration from your system.

## Prerequisites

- Root or sudo access

## Uninstall Using the Script

```bash
cd uninstall
./uninstall.sh
```

This script will:

1. Stop the Varnish service
2. Remove the service definition for your init system
3. Back up the existing configuration
4. Remove Varnish configuration files
5. Remove cache data
6. Remove Varnish logs
7. Remove the run directory
8. Remove the varnish user

## Manual Uninstallation

### systemd

```bash
systemctl stop varnish
systemctl disable varnish
rm -f /etc/systemd/system/varnish.service
systemctl daemon-reload
rm -rf /etc/varnish
rm -rf /var/lib/varnish
rm -rf /var/log/varnish
rm -f /run/varnishd.pid
```

### OpenRC

```bash
rc-service varnish stop
rc-update del varnish default
rm -f /etc/init.d/varnish
rm -rf /etc/varnish
rm -rf /var/lib/varnish
rm -rf /var/log/varnish
rm -f /run/varnishd.pid
```

### SysVinit

```bash
service varnish stop
chkconfig --del varnish
rm -f /etc/init.d/varnish
rm -rf /etc/varnish
rm -rf /var/lib/varnish
rm -rf /var/log/varnish
rm -f /run/varnishd.pid
```

### Windows (NSSM)

```cmd
nssm stop varnish
nssm remove varnish confirm
rmdir /s /q "C:\Program Files\Varnish"
```

## Backing Up Configuration Before Uninstall

If you want to keep your configuration before uninstalling, back it up first:

```bash
cp /etc/varnish/default.vcl /path/to/backup/
cp /etc/varnish/secret /path/to/backup/
```

## Reinstallation

After uninstallation, you can reinstall Varnish using the install guide in [install/README.md](install/README.md).

## Notes

- This removes service definitions only; the Varnish package may remain installed
- To completely remove Varnish, also uninstall the Varnish package using your system's package manager
- Configuration backups are saved with timestamps if they exist
- The secret file should be securely deleted or backed up as it contains VAC credentials
