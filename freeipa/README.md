# FreeIPA

[![FreeIPA](https://img.shields.io/badge/FreeIPA-v4.x-blue)](https://www.freeipa.org/)
[![License](https://img.shields.io/badge/license-GPL%20v3-green.svg)](https://github.com/freeipa/freeipa/blob/master/COPYING)

FreeIPA is an integrated identity and authentication solution for Linux/UNIX networked environments. It combines 389 Directory Server (LDAP), MIT Kerberos, DNS, NTP, a PKI certificate authority (Dogtag), and a web UI into a single deployable package, providing centralised identity management for enterprise environments.

## Features

- **Integrated LDAP** - 389 Directory Server as the identity backend for users, groups, and hosts
- **Kerberos SSO** - MIT Kerberos KDC for single sign-on across Linux hosts
- **PKI / CA** - Dogtag-based certificate authority for issuing and managing X.509 certificates
- **DNS Integration** - BIND-based authoritative DNS with dynamic updates and DNSSEC
- **Host-Based Access Control** - Fine-grained HBAC rules controlling which users can log in to which hosts
- **Sudo Rules** - Centrally managed sudo policy distributed to all enrolled hosts
- **Replication** - Multi-master replication for high availability across multiple IPA servers
- **Web UI & CLI** - Browser-based administration interface and full `ipa` command-line tool

## Prerequisites

- Linux with systemd (RHEL/CentOS/Fedora/Rocky/AlmaLinux recommended)
- Root or sudo privileges
- A fully qualified domain name (FQDN) configured for the server
- Ports 80, 443, 389, 636, 88, 464, 53 open

## Structure

```
freeipa/
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

# Run IPA server setup
sudo ipa-server-install --setup-dns

# Start services (managed as a group)
sudo systemctl start ipa
sudo systemctl enable ipa

# Check status
sudo systemctl status ipa
sudo ipactl status
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service ipa start
sudo rc-update add ipa default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service ipa start
sudo update-rc.d ipa defaults
```

### Windows (NSSM)

```powershell
# FreeIPA is Linux-only; Windows clients enroll via SSSD or winbind
# See install/README.md for Windows client enrollment instructions
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

- [FreeIPA Documentation](https://www.freeipa.org/page/Documentation)
- [Installation Guide](https://www.freeipa.org/page/Quick_Start_Guide)
- [GitHub Repository](https://github.com/freeipa/freeipa)
- [FreeIPA Community](https://www.freeipa.org/page/Contribute)
