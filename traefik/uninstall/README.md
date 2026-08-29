# Uninstallation

This guide covers removing the Traefik reverse proxy service from your system.

## Quick Uninstall

```bash
sudo ./uninstall.sh
```

The uninstall script will:

1. Stop and disable the Traefik service
2. Remove configuration files and logs
3. Remove the Traefik binary
4. Remove the `traefik` user and group

## Manual Uninstallation

### systemd

```bash
sudo systemctl stop traefik
sudo systemctl disable traefik
sudo rm /etc/systemd/system/traefik.service
sudo systemctl daemon-reload
```

### OpenRC

```bash
sudo rc-service traefik stop
sudo rc-update del traefik default
sudo rm /etc/init.d/traefik
```

### SysVinit

```bash
sudo service traefik stop
sudo update-rc.d -f traefik remove
sudo rm /etc/init.d/traefik
```

### Windows

```powershell
nssm stop traefik
nssm remove traefik confirm
```

### Remove all remaining files

```bash
sudo rm -rf /etc/traefik
sudo rm -rf /var/log/traefik
sudo rm -f /usr/local/bin/traefik
sudo userdel traefik
sudo groupdel traefik
```

## Data Preservation

Before uninstalling, consider backing up:

- `/etc/traefik/traefik.yml` — Configuration file
- `/etc/traefik/acme.json` — SSL certificates
- `/etc/traefik/dynamic/` — Dynamic configuration
- `/var/log/traefik/` — Log files

```bash
mkdir -p ~/traefik-backup
cp -r /etc/traefik ~/traefik-backup/
cp -r /var/log/traefik ~/traefik-backup/
```

## Post-Uninstallation

- Ensure no firewall rules reference Traefik ports (80, 443, 8080)
- Docker containers that relied on Traefik labels will no longer be proxied
- Reconfigure any services that pointed to the Traefik dashboard
