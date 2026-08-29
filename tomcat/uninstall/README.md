# Uninstall Tomcat

This guide covers removing Apache Tomcat and its service configuration from your system.

## Prerequisites

- Root or sudo access

## Uninstall Using the Script

```bash
cd uninstall
./uninstall.sh
```

This script will:

1. Stop the Tomcat service
2. Remove the service definition for your init system
3. Back up the existing configuration
4. Remove Tomcat configuration files
5. Remove logs
6. Remove the tomcat user

## Manual Uninstallation

### systemd

```bash
systemctl stop tomcat
systemctl disable tomcat
rm -f /etc/systemd/system/tomcat.service
systemctl daemon-reload
rm -rf /etc/tomcat
rm -rf /var/log/tomcat
rm -f /run/tomcat/tomcat.pid
```

### OpenRC

```bash
rc-service tomcat stop
rc-update del tomcat default
rm -f /etc/init.d/tomcat
rm -rf /etc/tomcat
rm -rf /var/log/tomcat
rm -f /run/tomcat/tomcat.pid
```

### SysVinit

```bash
service tomcat stop
chkconfig --del tomcat
rm -f /etc/init.d/tomcat
rm -rf /etc/tomcat
rm -rf /var/log/tomcat
rm -f /run/tomcat/tomcat.pid
```

### Windows (NSSM)

```cmd
nssm stop tomcat
nssm remove tomcat confirm
rmdir /s /q C:\tomcat
```

## Backing Up Configuration Before Uninstall

If you want to keep your configuration before uninstalling, back it up first:

```bash
cp /etc/tomcat/server.xml /path/to/backup/
cp /etc/tomcat/tomcat-users.xml /path/to/backup/
```

## Reinstallation

After uninstallation, you can reinstall Tomcat using the install guide in [install/README.md](install/README.md).

## Notes

- This removes service definitions only; the Tomcat package may remain installed
- To completely remove Tomcat, also uninstall the Tomcat package using your system's package manager
- Configuration backups are saved with timestamps if they exist