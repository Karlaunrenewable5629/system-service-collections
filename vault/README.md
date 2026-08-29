# Vault

[![Vault](https://img.shields.io/badge/Vault-v1.17-blue)](https://www.vaultproject.io/)
[![License](https://img.shields.io/badge/license-BUSL%201.1-green.svg)](https://github.com/hashicorp/vault/blob/main/LICENSE)

HashiCorp Vault is a tool for securely accessing secrets. A secret is anything that you want to tightly control access to — API keys, passwords, certificates, encryption keys, and more. Vault provides a unified interface to any secret while providing tight access control and recording a detailed audit log.

## Features

- **Dynamic Secrets** - Generate on-demand, short-lived secrets for AWS, databases, SSH, and more
- **Secret Leasing & Renewal** - Time-bound leases with automatic revocation
- **Encryption as a Service** - Encrypt/decrypt data without storing it using the Transit engine
- **Multiple Auth Methods** - AppRole, Kubernetes, AWS IAM, LDAP, GitHub, and more
- **PKI Secrets Engine** - Generate and manage X.509 certificates and CAs
- **Database Secrets** - Dynamic credentials for PostgreSQL, MySQL, MongoDB, and others
- **Audit Logging** - Detailed tamper-evident audit log of all Vault operations
- **High Availability** - Active/standby clustering with integrated Raft storage

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- Root or sudo privileges
- Port 8200 (API/UI) open
- Storage backend: integrated Raft (recommended), Consul, or etcd

## Structure

```
vault/
├── config/              - Configuration files and templates
│   └── README.md        - Configuration documentation
├── install/             - Installation scripts and guides
│   └── README.md        - Installation instructions
├── service/             - Service definitions for different init systems
│   ├── systemd/         - systemd service unit
│   ├── openrc/          - OpenRC init script
│   ├── sysvinit/        - SysV init script
│   ├── windows/         - Windows NSSM service definition
│   └── README.md        - Service management guide
├── uninstall/           - Uninstallation scripts
│   └── README.md        - Uninstallation instructions
└── README.md            - This file
```

## Quick Start

### Linux (systemd)

```bash
# Install
sudo ./install/install.sh

# Copy configuration
sudo cp config/vault.hcl /etc/vault.d/vault.hcl

# Start service
sudo systemctl start vault
sudo systemctl enable vault

# Initialize and unseal (first run only)
vault operator init
vault operator unseal

# Check status
sudo systemctl status vault
vault status
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service vault start
sudo rc-update add vault default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service vault start
sudo update-rc.d vault defaults
```

### Windows (NSSM)

```powershell
# Copy vault.exe to C:\vault\
# Install service
nssm install vault "C:\vault\vault.exe" "server -config=C:\vault\config\vault.hcl"
nssm set vault AppDirectory "C:\vault"
nssm start vault
```

## Configuration

See [config/README.md](config/README.md) for configuration options.

## Service Management

See [service/README.md](service/README.md) for service management across different init systems.

## Installation Guide

See [install/README.md](install/README.md) for detailed installation instructions.

## Uninstallation

See [uninstall/README.md](uninstall/README.md) for removal instructions.

## Resources

- [Vault Documentation](https://developer.hashicorp.com/vault/docs)
- [Getting Started Guide](https://developer.hashicorp.com/vault/tutorials/getting-started)
- [GitHub Repository](https://github.com/hashicorp/vault)
- [Vault Tutorials](https://developer.hashicorp.com/vault/tutorials)
