# Mattermost

[![Mattermost](https://img.shields.io/badge/Mattermost-v9.10-blue)](https://mattermost.com/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/mattermost/mattermost-server/blob/devel/LICENSE)

Mattermost is an open-source, self-hosted online chat service with mattermost teams, mattermost chat, and mattermost messaging. It's designed to replace Slack, Teams, and other proprietary chat platforms, offering data compliance and security for enterprise teams.

## Features

- **Real-time Messaging** - Chat, channels, and direct messaging
- **File Sharing** - Share files, images, and documents
- **Video Conferencing** - Integrated video calls and screen sharing
- **Search** - Powerful search across messages and files
- **API** - Comprehensive REST and GraphQL APIs
- **Plugins** - Extensible plugin system
- **SSO** - Single Sign-On integration
- **Compliance** - GDPR, HIPAA, and SOC 2 ready

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- PostgreSQL 12+ or MySQL 5.7+ database
- Root or sudo privileges
- At least 2GB RAM recommended
- Ports 80 (HTTP) and 443 (HTTPS) open

## Structure

```
mattermost/
├── config/              - Configuration files and templates
│   └── mattermost-settings.json - Mattermost settings
├── install/             - Installation scripts and guides
│   └── install.sh - Installation and setup script
├── service/             - Service definitions for different init systems
│   ├── systemd/         - systemd service unit
│   ├── openrc/          - OpenRC init script
│   ├── sysvinit/        - SysV init script
│   └── windows/         - Windows NSSM service definition
├── uninstall/           - Uninstallation scripts
│   └── uninstall.sh - Uninstallation script
└── README.md            - This file
```

## Quick Start

### Linux (systemd)

```bash
# Install
sudo ./install/install.sh

# Copy configuration
sudo cp config/mattermost-settings.json /etc/mattermost/settings.json

# Start service
sudo systemctl start mattermost
sudo systemctl enable mattermost

# Check status
sudo systemctl status mattermost
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service mattermost start
sudo rc-update add mattermost default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service mattermost start
sudo update-rc.d mattermost defaults
```

### Windows (NSSM)

```powershell
# Copy mattermost to C:\Mattermost\
# Install service
nssm install mattermost "C:\Mattermost\mattermost.exe"
nssm set mattermost AppDirectory "C:\Mattermost"
nssm start mattermost
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

- [Mattermost Documentation](https://docs.mattermost.com/)
- [Mattermost GitHub](https://github.com/mattermost/mattermost-server)
- [Mattermost Community](https://community.mattermost.com/)