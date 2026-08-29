# Uninstallation Guide

This guide covers removing Node.js and its service configuration from your system.

## Prerequisites

- Root or sudo access

## Uninstall Using the Script

```bash
cd uninstall
./uninstall.sh
```

This script will:

1. Stop the Node.js service
2. Remove the service definition for your init system
3. Back up the existing configuration
4. Remove Node.js configuration files
5. Remove logs
6. Remove the node user

## Manual Uninstallation

### systemd

```bash
systemctl stop node
systemctl disable node
rm -f /etc/systemd/system/node.service
systemctl daemon-reload
rm -rf /etc/node
rm -rf /var/log/node
rm -f /run/node/node.pid
```

### OpenRC

```bash
rc-service node stop
rc-update del node default
rm -f /etc/init.d/node
rm -rf /etc/node
rm -rf /var/log/node
rm -f /run/node/node.pid
```

### SysVinit

```bash
service node stop
chkconfig --del node
rm -f /etc/init.d/node
rm -rf /etc/node
rm -rf /var/log/node
rm -f /run/node/node.pid
```

### Windows (NSSM)

```cmd
nssm stop node
nssm remove node confirm
rmdir /s /q C:\node
```

## Backing Up Configuration Before Uninstall

If you want to keep your configuration before uninstalling, back it up first:

```bash
cp /etc/node/config.yaml /path/to/backup/
```

## Reinstallation

After uninstallation, you can reinstall Node.js using the install guide in [install/README.md](install/README.md).

## Notes

- This removes service definitions only; the Node.js package may remain installed
- To completely remove Node.js, also uninstall the Node.js package using your system's package manager
- Configuration backups are saved with timestamps if they exist