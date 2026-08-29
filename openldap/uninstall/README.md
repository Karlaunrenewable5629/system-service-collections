# OpenLDAP Uninstallation Guide

This document describes how to fully remove OpenLDAP (`slapd`) from your system.

> **Warning:** Uninstalling OpenLDAP will permanently delete the directory database and all LDAP data unless you export it first. Back up your data before proceeding.

---

## Automated Uninstallation (Linux)

```bash
cd openldap/uninstall
chmod +x uninstall.sh
sudo ./uninstall.sh
```

The script will:
1. Stop and disable the slapd service
2. Remove OpenLDAP packages
3. Optionally remove configuration, data, and log files

---

## Manual Uninstallation

### Step 1 — Back Up Your Data First

```bash
# Export directory to LDIF
sudo -u ldap slapcat -l /tmp/ldap-backup-$(date +%Y%m%d-%H%M%S).ldif
```

### Step 2 — Stop and Disable the Service

#### systemd

```bash
sudo systemctl stop slapd
sudo systemctl disable slapd
sudo rm -f /etc/systemd/system/slapd.service
sudo systemctl daemon-reload
sudo systemctl reset-failed
```

#### OpenRC

```bash
sudo rc-service slapd stop
sudo rc-update del slapd default
sudo rm -f /etc/init.d/slapd
```

#### SysVinit

```bash
sudo service slapd stop

# Debian/Ubuntu
sudo update-rc.d slapd remove

# RHEL/CentOS
sudo chkconfig slapd off

sudo rm -f /etc/init.d/slapd
```

### Step 3 — Remove Packages

#### Debian / Ubuntu

```bash
# Remove packages only (keep config)
sudo apt-get remove slapd ldap-utils

# Remove packages AND configuration files
sudo apt-get purge slapd ldap-utils
sudo apt-get autoremove
```

#### RHEL / CentOS / AlmaLinux / Rocky

```bash
sudo dnf remove openldap-servers openldap-clients openldap
# or: sudo yum remove openldap-servers openldap-clients openldap
```

#### Alpine Linux

```bash
apk del openldap openldap-back-mdb openldap-clients
```

#### Arch Linux

```bash
sudo pacman -Rns openldap
```

### Step 4 — Remove Configuration Files

```bash
# Debian/Ubuntu
sudo rm -rf /etc/ldap/

# RHEL / other distros
sudo rm -rf /etc/openldap/

# Remove OLC (cn=config) directory if used
sudo rm -rf /etc/ldap/slapd.d/
sudo rm -rf /etc/openldap/slapd.d/
```

### Step 5 — Remove Data Directory

```bash
# This permanently deletes all LDAP data
sudo rm -rf /var/lib/ldap/
sudo rm -rf /var/lib/openldap/
```

### Step 6 — Remove Runtime and Log Files

```bash
sudo rm -rf /var/run/openldap/
sudo rm -f /var/log/slapd.log
```

### Step 7 — Remove Service User and Group (Optional)

```bash
sudo userdel ldap
sudo groupdel ldap
```

---

## Windows Uninstallation

### Remove the NSSM Service

```powershell
# Stop and remove the service
nssm stop slapd
nssm remove slapd confirm

# Verify removal
sc query slapd   # Should return: "service does not exist"
```

### Remove OpenLDAP Files

```powershell
# Remove the OpenLDAP installation directory
Remove-Item -Recurse -Force "C:\openldap"
```

### Remove Firewall Rules (if added)

```powershell
# Remove any firewall rules for OpenLDAP ports
Remove-NetFirewallRule -DisplayName "OpenLDAP LDAP" -ErrorAction SilentlyContinue
Remove-NetFirewallRule -DisplayName "OpenLDAP LDAPS" -ErrorAction SilentlyContinue
```

---

## Post-Removal Verification

```bash
# Verify slapd is no longer running
pgrep slapd && echo "slapd still running" || echo "slapd not running"

# Verify port 389 is free
ss -tlnp | grep :389 || echo "Port 389 is free"

# Verify package is removed (Debian)
dpkg -l slapd 2>/dev/null | grep -q "^ii" && echo "slapd still installed" || echo "slapd removed"

# Verify package is removed (RHEL)
rpm -q openldap-servers 2>/dev/null || echo "openldap-servers removed"
```

---

## Reinstallation

To reinstall after removing, run the install script:

```bash
sudo ./install/install.sh
```

Or follow the manual installation steps in [install/README.md](../install/README.md).
