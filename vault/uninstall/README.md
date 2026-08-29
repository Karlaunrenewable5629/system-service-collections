# Vault Uninstallation Guide

This guide covers completely removing HashiCorp Vault from your system.

> **Warning:** Uninstalling Vault will stop the service and remove its data. Back up your Vault data and unseal keys before proceeding if you need to retain them.

## Table of Contents

- [Automated Uninstall (Linux)](#automated-uninstall-linux)
- [Manual Uninstall — Debian/Ubuntu](#manual-uninstall--debianubuntu)
- [Manual Uninstall — RHEL/CentOS/Fedora](#manual-uninstall--rhelcentosfedora)
- [Windows Uninstall](#windows-uninstall)
- [What Gets Removed](#what-gets-removed)

---

## Automated Uninstall (Linux)

Use the provided uninstall script for a fully automated removal:

```bash
cd uninstall/
chmod +x uninstall.sh
sudo bash uninstall.sh
```

Pass `--remove-data` to also delete the Vault data directory (irreversible):

```bash
sudo bash uninstall.sh --remove-data
```

---

## Manual Uninstall — Debian/Ubuntu

### 1. Stop and Disable the Service

```bash
# systemd
sudo systemctl stop vault
sudo systemctl disable vault
sudo rm -f /etc/systemd/system/vault.service
sudo systemctl daemon-reload
sudo systemctl reset-failed

# OpenRC
sudo rc-service vault stop
sudo rc-update del vault default
sudo rm -f /etc/init.d/vault

# SysVinit
sudo service vault stop
sudo update-rc.d vault remove
sudo rm -f /etc/init.d/vault
```

### 2. Remove the Package

```bash
sudo apt-get remove --purge -y vault
sudo apt-get autoremove -y
```

### 3. Remove the Repository

```bash
sudo rm -f /etc/apt/sources.list.d/hashicorp.list
sudo rm -f /usr/share/keyrings/hashicorp-archive-keyring.gpg
sudo apt-get update
```

### 4. Remove Files and Directories

```bash
# Configuration
sudo rm -rf /etc/vault.d

# Logs
sudo rm -rf /var/log/vault

# PID / runtime
sudo rm -rf /run/vault

# Data (WARNING: irreversible — back up first)
# sudo rm -rf /opt/vault
```

### 5. Remove Service User

```bash
sudo userdel vault
sudo groupdel vault 2>/dev/null || true
```

---

## Manual Uninstall — RHEL/CentOS/Fedora

### 1. Stop and Disable the Service

```bash
# systemd
sudo systemctl stop vault
sudo systemctl disable vault
sudo rm -f /etc/systemd/system/vault.service
sudo systemctl daemon-reload
sudo systemctl reset-failed

# SysVinit (CentOS 6)
sudo service vault stop
sudo chkconfig vault off
sudo rm -f /etc/init.d/vault
```

### 2. Remove the Package

```bash
sudo yum remove -y vault
```

### 3. Remove the Repository

```bash
sudo rm -f /etc/yum.repos.d/hashicorp.repo
sudo yum clean all
```

### 4. Remove Files and Directories

```bash
# Configuration
sudo rm -rf /etc/vault.d

# Logs
sudo rm -rf /var/log/vault

# PID / runtime
sudo rm -rf /run/vault

# Lock file
sudo rm -f /var/lock/subsys/vault

# Data (WARNING: irreversible — back up first)
# sudo rm -rf /opt/vault
```

### 5. Remove Service User

```bash
sudo userdel vault
sudo groupdel vault 2>/dev/null || true
```

---

## Windows Uninstall

### 1. Stop and Remove the Service

Run PowerShell as Administrator:

```powershell
# Stop the service
nssm stop vault

# Remove the service
nssm remove vault confirm
```

Or using PowerShell built-ins:

```powershell
Stop-Service vault -Force
& sc.exe delete vault
```

### 2. Remove Vault Files

```powershell
# Remove binary and config
Remove-Item -Recurse -Force "C:\Vault\bin"
Remove-Item -Recurse -Force "C:\Vault\config"
Remove-Item -Recurse -Force "C:\Vault\logs"

# Remove data (WARNING: irreversible — back up first)
# Remove-Item -Recurse -Force "C:\Vault\data"

# Remove the Vault base directory if empty
Remove-Item -Force "C:\Vault" -ErrorAction SilentlyContinue
```

### 3. Remove from PATH

```powershell
$oldPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$newPath = ($oldPath -split ";") | Where-Object { $_ -notlike "*Vault*" } | Join-String -Separator ";"
[System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
```

---

## What Gets Removed

| Item | Linux Path | Windows Path | Removed by Script |
|------|-----------|--------------|-------------------|
| Vault binary | `/usr/bin/vault` | `C:\Vault\bin\vault.exe` | Yes (via package) |
| Config directory | `/etc/vault.d/` | `C:\Vault\config\` | Yes |
| Service unit | `/etc/systemd/system/vault.service` | NSSM service registration | Yes |
| Log directory | `/var/log/vault/` | `C:\Vault\logs\` | Yes |
| PID directory | `/run/vault/` | N/A | Yes |
| Service user | `vault` user/group | N/A | Yes |
| Package repo | `/etc/apt/sources.list.d/hashicorp.list` | N/A | Yes |
| **Data directory** | `/opt/vault/data/` | `C:\Vault\data\` | **Only with `--remove-data`** |

---

## Data Backup Before Uninstalling

Before removing the data directory, create a Vault snapshot:

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
vault login <token>

# Create a Raft snapshot
vault operator raft snapshot save vault-backup-$(date +%Y%m%d).snap

# Verify the snapshot
vault operator raft snapshot inspect vault-backup-$(date +%Y%m%d).snap
```

Store the snapshot file in a secure, separate location before proceeding with uninstallation.
