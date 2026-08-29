# Rocket.Chat

[![Rocket.Chat](https://img.shields.io/badge/Rocket.Chat-v9.0-blue)](https://rocket.chat/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/RocketChat/Rocket.Chat/blob/develop/LICENSE)

Rocket.Chat is an open-source, self-hosted online chat platform designed as a Slack alternative. It offers team chat, video conferencing, file sharing, and integrates with various services. Rocket.Chat is ideal for businesses, communities, and developers looking for a customizable chat solution.

## Features

- **Real-time Messaging** - Chat, channels, and direct messaging
- **Video Conferencing** - Integrated Jitsi video calls
- **File Sharing** - Share files, images, and documents
- **Screen Sharing** - Share your screen in channels
- **API** - Comprehensive REST and GraphQL APIs
- **Plugins** - Extensible plugin system
- **SSO** - Single Sign-On integration (LDAP, SAML, OAuth)
- **Compliance** - GDPR and HIPAA ready
- **Mobile Apps** - Native iOS and Android applications

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- MongoDB 5.0+ database
- Root or sudo privileges
- At least 2GB RAM recommended
- Port 3000 (HTTP) open

## Structure

```
rocket-chat/
├── config/              - Configuration files and templates
│   └── rocket-chat-settings.json - Rocket.Chat settings
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
sudo cp config/rocket-chat-settings.json /etc/rocketchat/settings.json

# Start service
sudo systemctl start rocketchat
sudo systemctl enable rocketchat

# Check status
sudo systemctl status rocketchat
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service rocketchat start
sudo rc-update add rocketchat default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service rocketchat start
sudo update-rc.d rocketchat defaults
```

### Windows (NSSM)

```powershell
# Copy rocketchat to C:\Rocket.Chat\
# Install service
nssm install rocketchat "C:\Rocket.Chat\rocketchat.exe"
nssm set rocketchat AppDirectory "C:\Rocket.Chat"
nssm start rocketchat
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

- [Rocket.Chat Documentation](https://docs.rocket.chat/)
- [Rocket.Chat GitHub](https://github.com/RocketChat/Rocket.Chat)
- [Rocket.Chat Community](https://community.rocket.chat/)