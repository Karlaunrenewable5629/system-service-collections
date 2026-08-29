# Keycloak

[![Keycloak](https://img.shields.io/badge/Keycloak-v25.x-blue)](https://www.keycloak.org/)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](https://github.com/keycloak/keycloak/blob/main/LICENSE.txt)

Keycloak is an open-source identity and access management solution for modern applications and services. It provides SSO, social login, identity brokering, and user federation out of the box, supporting OAuth2, OpenID Connect, and SAML 2.0.

## Features

- **Single Sign-On** - Login once and access multiple applications without re-authenticating
- **OAuth2 & OpenID Connect** - Standards-based authorization and authentication protocols
- **SAML 2.0** - Enterprise-grade federated identity support
- **Identity Brokering** - Delegate authentication to external providers (Google, GitHub, LDAP, AD)
- **User Federation** - Sync users from LDAP or Active Directory
- **Multi-Factor Authentication** - TOTP, WebAuthn, and OTP credential support
- **Admin Console** - Web-based UI for realm, client, and user management
- **Fine-Grained Authorization** - Policy-based authorization services via UMA 2.0

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- Java 17 or Java 21 (JDK)
- PostgreSQL, MySQL, or MariaDB recommended for production
- Root or sudo privileges
- Ports 8080 (HTTP) and 8443 (HTTPS) open

## Structure

```
keycloak/
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
sudo cp config/keycloak.conf /etc/keycloak/keycloak.conf

# Start service
sudo systemctl start keycloak
sudo systemctl enable keycloak

# Check status
sudo systemctl status keycloak
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service keycloak start
sudo rc-update add keycloak default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service keycloak start
sudo update-rc.d keycloak defaults
```

### Windows (NSSM)

```powershell
# Copy Keycloak to C:\keycloak\
# Install service
nssm install keycloak "C:\keycloak\bin\kc.bat" "start"
nssm set keycloak AppDirectory "C:\keycloak"
nssm start keycloak
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

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [Server Configuration Guide](https://www.keycloak.org/server/configuration)
- [GitHub Repository](https://github.com/keycloak/keycloak)
- [Keycloak Community](https://www.keycloak.org/community)
