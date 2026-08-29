# Authentik

[![Authentik](https://img.shields.io/badge/Authentik-v2024.x-blue)](https://goauthentik.io/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/goauthentik/authentik/blob/main/LICENSE)

Authentik is an open-source identity provider focused on flexibility and versatility. It supports OAuth2, OpenID Connect, SAML, LDAP, and SCIM, making it a drop-in replacement for services requiring SSO, social login, or multi-factor authentication.

## Features

- **OAuth2 / OpenID Connect** - Full OIDC provider for SSO across all your applications
- **SAML 2.0** - Act as an IdP for SAML-based service providers
- **LDAP Provider** - Expose user directory over LDAP for legacy applications
- **SCIM Support** - Automated user provisioning and deprovisioning
- **Multi-Factor Authentication** - TOTP, WebAuthn, Duo, and static tokens
- **Social Login** - Built-in support for GitHub, Google, Discord, and more
- **Flow Engine** - Visual policy and authentication flow builder
- **Outposts** - Deploy lightweight proxy or LDAP outposts for application-level enforcement

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- PostgreSQL 14+ and Redis
- Root or sudo privileges
- Ports 9000 (HTTP) and 9443 (HTTPS) open

## Structure

```
authentik/
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
sudo cp config/.env /etc/authentik/.env

# Start service
sudo systemctl start authentik-server
sudo systemctl enable authentik-server
sudo systemctl start authentik-worker
sudo systemctl enable authentik-worker

# Check status
sudo systemctl status authentik-server
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service authentik-server start
sudo rc-update add authentik-server default
sudo rc-service authentik-worker start
sudo rc-update add authentik-worker default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service authentik-server start
sudo update-rc.d authentik-server defaults
```

### Windows (NSSM)

```powershell
# Copy authentik files to C:\authentik\
# Install server service
nssm install authentik-server "C:\authentik\authentik.exe" "server"
nssm set authentik-server AppEnvFile "C:\authentik\.env"
nssm start authentik-server

# Install worker service
nssm install authentik-worker "C:\authentik\authentik.exe" "worker"
nssm set authentik-worker AppEnvFile "C:\authentik\.env"
nssm start authentik-worker
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

- [Authentik Documentation](https://docs.goauthentik.io/)
- [Configuration Reference](https://docs.goauthentik.io/docs/installation/configuration)
- [GitHub Repository](https://github.com/goauthentik/authentik)
- [Authentik Community](https://discord.gg/jg33eMhnj6)
