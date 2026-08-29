# Caddy

[![Caddy](https://img.shields.io/badge/Caddy-v2.8.4-blue)](https://caddyserver.com/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/caddyserver/caddy/blob/master/LICENSE)

Caddy is a powerful, enterprise-ready, open source web server with automatic HTTPS. It is the successor to HTTP/2-based web servers and uses the Cadmium language for its configuration.

## Features

- **Automatic HTTPS** - Built-in Let's Encrypt support with automatic certificate provisioning and renewal
- **HTTP/2 and HTTP/3** - Native support for modern protocols
- **Reverse Proxy** - Built-in load balancing with health checks
- **TLS 1.3** - Built-in TLS with automatic certificate management
- **File Server** - Static file serving with directory browsing
- **WebSocket Support** - Native WebSocket proxying
- **Site Blocks** - Virtual host configuration
- **JSON API** - Full API for runtime configuration management

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- Root or sudo privileges
- A domain name (for automatic HTTPS)
- Ports 80 and 443 open

## Structure

```
caddy/
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
sudo cp config/Caddyfile /etc/caddy/Caddyfile

# Start service
sudo systemctl start caddy
sudo systemctl enable caddy

# Check status
sudo systemctl status caddy
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service caddy start
sudo rc-update add caddy default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service caddy start
sudo update-rc.d caddy defaults
```

### Windows (NSSM)

```powershell
# Copy files to C:\caddy\
# Install service
nssm install caddy "C:\caddy\caddy.exe" "run --config C:\caddy\Caddyfile"
nssm start caddy
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

- [Caddy Documentation](https://caddyserver.com/docs/)
- [Caddyfile Guide](https://caddyserver.com/docs/caddyfile)
- [GitHub Repository](https://github.com/caddyserver/caddy)
- [Caddy Community](https://caddyserver.com/community)