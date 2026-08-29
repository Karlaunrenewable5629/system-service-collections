# Uninstall Keycloak

## Automated

```bash
sudo ./uninstall/uninstall.sh
```

The script will prompt for confirmation before removing anything, then:

1. Stops and disables the Keycloak service (systemd, OpenRC, or SysVinit)
2. Removes the systemd unit file
3. Deletes the Keycloak binary and data from `/opt/keycloak`
4. Removes configuration at `/etc/keycloak`
5. Removes logs at `/var/log/keycloak`
6. Deletes the `keycloak` system user

> **Warning:** This is irreversible. All locally stored Keycloak realm data, client definitions, and user records will be permanently deleted. Back up your database before running this script.

---

## Manual Uninstallation

### 1. Stop and Remove the Service

**systemd:**

```bash
sudo systemctl stop keycloak
sudo systemctl disable keycloak
sudo rm /etc/systemd/system/keycloak.service
sudo systemctl daemon-reload
```

**OpenRC:**

```bash
sudo rc-service keycloak stop
sudo rc-update del keycloak default
sudo rm /etc/init.d/keycloak
```

**SysVinit:**

```bash
sudo service keycloak stop
sudo update-rc.d -f keycloak remove   # Debian/Ubuntu
# or
sudo chkconfig --del keycloak         # RHEL/CentOS
sudo rm /etc/init.d/keycloak
```

**Windows (NSSM):**

```powershell
nssm stop keycloak
nssm remove keycloak confirm
```

### 2. Remove Keycloak Files

```bash
# Remove binary and data
sudo rm -rf /opt/keycloak /opt/keycloak-*

# Remove configuration
sudo rm -rf /etc/keycloak

# Remove logs
sudo rm -rf /var/log/keycloak

# Remove PID directory
sudo rm -rf /run/keycloak
```

### 3. Remove the Service User

```bash
sudo userdel keycloak
```

### 4. Remove the Database (Optional)

The uninstall script does **not** drop the database. To remove it manually:

**PostgreSQL:**

```sql
-- Connect as a superuser (e.g. postgres)
DROP DATABASE keycloak;
DROP USER keycloak;
```

**MySQL / MariaDB:**

```sql
DROP DATABASE keycloak;
DROP USER 'keycloak'@'localhost';
```

---

## Windows Manual Uninstallation

```powershell
# Stop and remove NSSM service
nssm stop keycloak
nssm remove keycloak confirm

# Remove Keycloak files
Remove-Item -Recurse -Force C:\keycloak

# Remove logs
Remove-Item -Recurse -Force C:\keycloak\logs
```
