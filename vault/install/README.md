# Vault Installation Guide

This guide covers installing HashiCorp Vault from the official HashiCorp package repository on Linux, and via direct binary download on Windows.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Linux — Automated Install](#linux--automated-install)
- [Linux — Manual Install (Debian/Ubuntu)](#linux--manual-install-debianubuntu)
- [Linux — Manual Install (RHEL/CentOS/Fedora)](#linux--manual-install-rhelcentosfedora)
- [Windows Install](#windows-install)
- [Post-Install Configuration](#post-install-configuration)
- [Initializing Vault](#initializing-vault)
- [Uninstallation](#uninstallation)

---

## Prerequisites

### Linux

- Debian 11+, Ubuntu 20.04+, RHEL/CentOS 8+, Fedora 36+, or Amazon Linux 2
- `curl`, `gpg`, `apt-transport-https` (Debian/Ubuntu) or `yum-utils` (RHEL)
- `sudo` / root access
- Minimum 2 GB RAM, 10 GB disk space for data directory

### Windows

- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1+
- [NSSM](https://nssm.cc/download) for service management
- Administrator privileges

---

## Linux — Automated Install

Use the provided install script for a fully automated setup:

```bash
cd install/
chmod +x install.sh
sudo ./install.sh
```

The script will:
1. Detect your Linux distribution
2. Add the official HashiCorp APT or YUM repository
3. Install the `vault` package
4. Create the `vault` service user and required directories
5. Install the configuration file to `/etc/vault.d/vault.hcl`
6. Enable and start the Vault service

---

## Linux — Manual Install (Debian/Ubuntu)

```bash
# 1. Install dependencies
sudo apt-get update
sudo apt-get install -y curl gnupg apt-transport-https lsb-release

# 2. Import HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# 3. Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

# 4. Install Vault
sudo apt-get update
sudo apt-get install -y vault

# 5. Create service user
sudo useradd --system --home /etc/vault.d --shell /bin/false vault

# 6. Create required directories
sudo mkdir -p /etc/vault.d /opt/vault/data /var/log/vault
sudo chown -R vault:vault /etc/vault.d /opt/vault /var/log/vault
sudo chmod 750 /etc/vault.d /opt/vault/data

# 7. Install configuration
sudo cp ../config/vault.hcl /etc/vault.d/vault.hcl
sudo chown vault:vault /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl
```

---

## Linux — Manual Install (RHEL/CentOS/Fedora)

```bash
# 1. Install dependencies
sudo yum install -y yum-utils curl

# 2. Add HashiCorp repository
sudo yum-config-manager --add-repo \
  https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# 3. Install Vault
sudo yum install -y vault

# 4. Create service user
sudo useradd --system --home /etc/vault.d --shell /bin/false vault

# 5. Create required directories
sudo mkdir -p /etc/vault.d /opt/vault/data /var/log/vault
sudo chown -R vault:vault /etc/vault.d /opt/vault /var/log/vault
sudo chmod 750 /etc/vault.d /opt/vault/data

# 6. Install configuration
sudo cp ../config/vault.hcl /etc/vault.d/vault.hcl
sudo chown vault:vault /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl
```

---

## Windows Install

### 1. Download Vault

Download the latest Vault binary from the official releases page:

```
https://releases.hashicorp.com/vault/
```

Or via PowerShell:

```powershell
# Set version
$VAULT_VERSION = "1.17.2"
$ARCH = "windows_amd64"

# Download and extract
Invoke-WebRequest -Uri "https://releases.hashicorp.com/vault/$VAULT_VERSION/vault_${VAULT_VERSION}_${ARCH}.zip" `
  -OutFile "vault.zip"
Expand-Archive -Path vault.zip -DestinationPath "C:\Vault\bin"
Remove-Item vault.zip
```

### 2. Add to PATH

```powershell
[System.Environment]::SetEnvironmentVariable(
  "Path",
  $env:Path + ";C:\Vault\bin",
  [System.EnvironmentVariableTypes]::Machine
)
```

### 3. Create Directories

```powershell
New-Item -ItemType Directory -Force -Path "C:\Vault\config"
New-Item -ItemType Directory -Force -Path "C:\Vault\data"
New-Item -ItemType Directory -Force -Path "C:\Vault\logs"
```

### 4. Install Configuration

Copy and edit the configuration file:

```powershell
Copy-Item ..\config\vault.hcl -Destination "C:\Vault\config\vault.hcl"
```

Edit `C:\Vault\config\vault.hcl` and set:
- `storage.raft.path = "C:\\Vault\\data"`
- `api_addr` to the server's IP or hostname
- TLS settings if applicable

### 5. Install as Windows Service (NSSM)

See the [service README](../service/README.md) for NSSM-based service installation.

---

## Post-Install Configuration

Edit the configuration file before starting Vault:

```bash
sudo nano /etc/vault.d/vault.hcl
```

Key settings to review:

| Setting | Description |
|---------|-------------|
| `api_addr` | Set to the externally reachable address/hostname |
| `cluster_addr` | Set for HA cluster setups |
| `storage.raft.node_id` | Must be unique per node |
| `storage.raft.path` | Ensure directory exists and is owned by `vault` |
| `listener.tcp.tls_disable` | Set to `false` and configure TLS in production |

---

## Initializing Vault

After Vault is installed and started for the first time:

```bash
# Export Vault address
export VAULT_ADDR='http://127.0.0.1:8200'

# Initialize with 5 key shares, threshold of 3
vault operator init -key-shares=5 -key-threshold=3
```

This outputs:
- **5 unseal keys** — distribute securely to different people/locations
- **1 root token** — used for initial setup only; revoke after configuration

```bash
# Unseal (run 3 times with different keys)
vault operator unseal <unseal-key-1>
vault operator unseal <unseal-key-2>
vault operator unseal <unseal-key-3>

# Verify status
vault status

# Login with root token
vault login <root-token>
```

> **Important:** After initial setup, create admin policies and tokens, then revoke the root token:
> ```bash
> vault token revoke <root-token>
> ```

---

## Verify Installation

```bash
# Check Vault version
vault version

# Check service status (systemd)
sudo systemctl status vault

# Check Vault status (must be running and unsealed)
export VAULT_ADDR='http://127.0.0.1:8200'
vault status
```

Expected output for a healthy, unsealed Vault:

```
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    5
Threshold       3
Version         1.x.x
...
```

---

## Uninstallation

See [uninstall/README.md](../uninstall/README.md) for complete removal instructions.

---

## Further Reading

- [Vault Installation Docs](https://developer.hashicorp.com/vault/docs/install)
- [Vault Getting Started](https://developer.hashicorp.com/vault/tutorials/getting-started)
- [Integrated Storage Guide](https://developer.hashicorp.com/vault/docs/configuration/storage/raft)
- [Production Hardening](https://developer.hashicorp.com/vault/tutorials/operations/production-hardening)
