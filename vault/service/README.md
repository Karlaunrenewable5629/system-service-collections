# Vault Service Management

This directory contains service definitions for managing HashiCorp Vault across multiple init systems.

## Directory Structure

```
service/
├── systemd/
│   └── vault.service      # systemd unit file
├── openrc/
│   └── vault              # OpenRC init script
├── sysvinit/
│   └── vault              # SysVinit LSB init script
└── windows/
    └── vault.nssm         # NSSM PowerShell installation script
```

## systemd (Linux — Debian, Ubuntu, RHEL, Fedora, etc.)

### Install

```bash
sudo cp systemd/vault.service /etc/systemd/system/vault.service
sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault
```

### Manage

| Action | Command |
|--------|---------|
| Start | `sudo systemctl start vault` |
| Stop | `sudo systemctl stop vault` |
| Restart | `sudo systemctl restart vault` |
| Reload config | `sudo systemctl reload vault` |
| Enable on boot | `sudo systemctl enable vault` |
| Disable on boot | `sudo systemctl disable vault` |
| Status | `sudo systemctl status vault` |
| Logs (live) | `journalctl -u vault -f` |
| Logs (recent) | `journalctl -u vault -n 100` |
| Logs (since boot) | `journalctl -u vault -b` |

### Environment Overrides

Create `/etc/vault.d/vault.env` to override environment variables:

```bash
VAULT_ADDR=http://127.0.0.1:8200
VAULT_LOG_LEVEL=debug
```

The systemd unit reads this file via `EnvironmentFile=-/etc/vault.d/vault.env` (the `-` prefix means the file is optional).

### Key Unit Settings

| Setting | Value | Description |
|---------|-------|-------------|
| `Type` | `notify` | Vault notifies systemd when ready via `sd_notify` |
| `User` / `Group` | `vault` | Run as dedicated service user |
| `LimitMEMLOCK` | `infinity` | Allows Vault to lock memory (`mlock`) |
| `LimitNOFILE` | `65536` | Open file descriptor limit |
| `AmbientCapabilities` | `CAP_IPC_LOCK` | Allows mlock without running as root |
| `Restart` | `on-failure` | Restart automatically on non-zero exit |
| `KillSignal` | `SIGINT` | Graceful shutdown signal |

---

## OpenRC (Alpine Linux, Gentoo, Artix)

### Install

```bash
sudo cp openrc/vault /etc/init.d/vault
sudo chmod +x /etc/init.d/vault
sudo rc-update add vault default
sudo rc-service vault start
```

### Manage

| Action | Command |
|--------|---------|
| Start | `sudo rc-service vault start` |
| Stop | `sudo rc-service vault stop` |
| Restart | `sudo rc-service vault restart` |
| Status | `sudo rc-service vault status` |
| Enable on boot | `sudo rc-update add vault default` |
| Disable on boot | `sudo rc-update del vault default` |
| Logs | `tail -f /var/log/vault/vault.log` |

### Configuration Variables

Override these variables in `/etc/conf.d/vault` (create if needed):

```bash
VAULT_USER="vault"
VAULT_GROUP="vault"
VAULT_CONFIG="/etc/vault.d/vault.hcl"
VAULT_LOG="/var/log/vault/vault.log"
VAULT_PID="/run/vault/vault.pid"
VAULT_ENV="/etc/vault.d/vault.env"
```

---

## SysVinit (Debian 8, Ubuntu 14.04, CentOS 6)

### Install

```bash
sudo cp sysvinit/vault /etc/init.d/vault
sudo chmod +x /etc/init.d/vault

# Debian/Ubuntu
sudo update-rc.d vault defaults

# RHEL/CentOS
sudo chkconfig vault on

# Start
sudo service vault start
```

### Manage

| Action | Command |
|--------|---------|
| Start | `sudo service vault start` |
| Stop | `sudo service vault stop` |
| Restart | `sudo service vault restart` |
| Reload | `sudo service vault reload` |
| Status | `sudo service vault status` |
| Logs | `tail -f /var/log/vault/vault.log` |

### Configuration Overrides

Create `/etc/default/vault` (Debian/Ubuntu) or `/etc/sysconfig/vault` (RHEL) to override defaults:

```bash
VAULT_USER="vault"
VAULT_CONFIG="/etc/vault.d/vault.hcl"
VAULT_LOG="/var/log/vault/vault.log"
PID_FILE="/run/vault/vault.pid"
```

---

## Windows (NSSM)

### Prerequisites

1. Download NSSM from [https://nssm.cc/download](https://nssm.cc/download)
2. Extract and add `nssm.exe` to your PATH (e.g., `C:\Windows\System32\`)
3. Download the Vault binary from [https://releases.hashicorp.com/vault/](https://releases.hashicorp.com/vault/)
4. Place `vault.exe` in `C:\Vault\bin\`
5. Create and edit `C:\Vault\config\vault.hcl`

### Install

Run PowerShell as Administrator:

```powershell
powershell -ExecutionPolicy Bypass -File windows\vault.nssm
```

### Manage

| Action | Command |
|--------|---------|
| Status | `nssm status vault` |
| Start | `nssm start vault` |
| Stop | `nssm stop vault` |
| Restart | `nssm restart vault` |
| Edit config | `nssm edit vault` |
| Remove service | `nssm remove vault confirm` |

Alternatively, use the standard Windows Service Manager:

```powershell
Start-Service vault
Stop-Service vault
Restart-Service vault
Get-Service vault
```

### Logs

```
C:\Vault\logs\vault-stdout.log
C:\Vault\logs\vault-stderr.log
```

---

## Vault Operations (All Platforms)

After starting Vault, set the address and perform operations:

```bash
export VAULT_ADDR='http://127.0.0.1:8200'

# Check status
vault status

# Initialize (first run only)
vault operator init

# Unseal
vault operator unseal <unseal-key>

# Log in
vault login <root-token>

# Check cluster peers (Raft)
vault operator raft list-peers
```

### Seal / Unseal

```bash
# Seal Vault (for maintenance)
vault operator seal

# Unseal Vault (provide keys until threshold met)
vault operator unseal <unseal-key-1>
vault operator unseal <unseal-key-2>
vault operator unseal <unseal-key-3>
```

### Audit Logs

Enable audit logging after unsealing:

```bash
vault audit enable file file_path=/var/log/vault/audit.log
vault audit list
```

---

## Firewall Rules

| Port | Protocol | Purpose |
|------|----------|---------|
| `8200` | TCP | Vault API / UI / Client traffic |
| `8201` | TCP | Vault cluster (Raft) communication — internal only |

```bash
# UFW (Ubuntu/Debian)
sudo ufw allow 8200/tcp

# firewalld (RHEL/Fedora)
sudo firewall-cmd --permanent --add-port=8200/tcp
sudo firewall-cmd --reload

# iptables
sudo iptables -A INPUT -p tcp --dport 8200 -j ACCEPT
```

> **Note:** Port 8201 should only be accessible between cluster nodes, not exposed publicly.
