# Authentik Uninstallation Guide

This guide covers removing Authentik from your system. The uninstall script and manual steps below handle service removal, application files, and optionally configuration and data.

## Before You Begin

- **Back up your configuration** at `/etc/authentik/.env` if you plan to reinstall later.
- **Export your data** via the Authentik admin UI (`Admin → System → Backups`) before removing the database.
- The uninstall process does **not** remove the PostgreSQL database or Redis data by default. You must do this manually if desired.

## Automated Uninstall (Linux)

```bash
cd authentik/uninstall
chmod +x uninstall.sh
sudo ./uninstall.sh
```

### Options

| Option | Description |
|---|---|
| *(none)* | Removes services and application files. Preserves `/etc/authentik`, `/var/lib/authentik`, and `/var/log/authentik`. |
| `--purge` | Also removes configuration, data, and log directories. **Irreversible.** |
| `--keep-data` | Explicitly preserves `/var/lib/authentik` even when combined with `--purge`. |

### Examples

```bash
# Default — safe removal, keep config and data
sudo ./uninstall.sh

# Remove everything including config and data
sudo ./uninstall.sh --purge

# Remove config but keep uploaded media files
sudo ./uninstall.sh --purge --keep-data
```

## Manual Uninstall (Linux)

### 1. Stop and Disable Services

**systemd:**

```bash
sudo systemctl stop authentik-server authentik-worker
sudo systemctl disable authentik-server authentik-worker
sudo rm -f /etc/systemd/system/authentik-server.service
sudo rm -f /etc/systemd/system/authentik-worker.service
sudo systemctl daemon-reload
```

**OpenRC:**

```bash
sudo rc-service authentik-server stop
sudo rc-service authentik-worker stop
sudo rc-update del authentik-server default
sudo rc-update del authentik-worker default
sudo rm -f /etc/init.d/authentik-server
sudo rm -f /etc/init.d/authentik-worker
```

**SysVinit:**

```bash
sudo service authentik-server stop
sudo service authentik-worker stop
sudo update-rc.d authentik-server remove
sudo update-rc.d authentik-worker remove
sudo rm -f /etc/init.d/authentik-server
sudo rm -f /etc/init.d/authentik-worker
```

### 2. Remove Application Files

```bash
sudo rm -rf /opt/authentik
sudo rm -rf /run/authentik
```

### 3. Remove Configuration (optional)

```bash
# WARNING: This permanently deletes your configuration
sudo rm -rf /etc/authentik
```

### 4. Remove Data and Logs (optional)

```bash
# WARNING: This permanently deletes media uploads and logs
sudo rm -rf /var/lib/authentik
sudo rm -rf /var/log/authentik
```

### 5. Remove System User

```bash
sudo userdel authentik
sudo groupdel authentik
```

### 6. Remove Database (optional)

If you no longer need the Authentik database, drop it from PostgreSQL:

```bash
sudo -u postgres psql <<EOF
DROP DATABASE IF EXISTS authentik;
DROP USER IF EXISTS authentik;
EOF
```

## Uninstall on Windows

### 1. Stop and Remove Services

Run **PowerShell as Administrator:**

```powershell
# Stop services
nssm stop authentik-server
nssm stop authentik-worker

# Remove services
nssm remove authentik-server confirm
nssm remove authentik-worker confirm
```

Or use the NSSM script:

```batch
cd service\windows
authentik-server.nssm remove
```

### 2. Remove Application Files

```powershell
# Remove Authentik installation
Remove-Item -Recurse -Force "C:\authentik\venv"

# Optional: remove all Authentik files including config and logs
# Remove-Item -Recurse -Force "C:\authentik"
```

### 3. Remove Firewall Rules

```powershell
Remove-NetFirewallRule -DisplayName "Authentik HTTP"
Remove-NetFirewallRule -DisplayName "Authentik HTTPS"
```

## What Is NOT Removed

The following are intentionally left in place unless explicitly removed:

| Item | Path | Reason |
|---|---|---|
| Configuration | `/etc/authentik/` | May be needed for reinstall |
| Media uploads | `/var/lib/authentik/media/` | User-uploaded files |
| Log files | `/var/log/authentik/` | May be needed for audit |
| PostgreSQL database | *(your DB server)* | Requires separate manual step |
| Redis data | *(your Redis server)* | Authentik data is transient |
| Python runtime | `/usr/bin/python3` | System dependency |

## Reinstalling

After uninstalling without `--purge`, you can reinstall Authentik and reuse your existing configuration:

```bash
sudo ./install/install.sh
# Existing /etc/authentik/.env will be preserved automatically
sudo systemctl start authentik-server authentik-worker
```

## References

- [Authentik Installation Guide](../install/README.md)
- [Configuration Reference](../config/README.md)
- [Authentik Documentation](https://docs.goauthentik.io/)
