# cloudflare-tunnel

[![Cloudflare](https://img.shields.io/badge/Cloudflare-Tunnel-blue)](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/cloudflared/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/cloudflare/cloudflared/blob/master/LICENSE)

Cloudflare Tunnel (cloudflared) creates a secure outbound connection between your network and Cloudflare's edge, eliminating the need to expose ports or use a public IP address. It's ideal for accessing local services, homelabs, or internal networks securely.

## Features

- **Secure Tunneling** - Outbound-only connection, no inbound ports needed
- **Zero Trust** - Integrates with Cloudflare Access for authentication
- **Autoscaling** - Automatically handles traffic spikes
- **SSL/TLS** - Automatic HTTPS with Cloudflare's certificate authority
- **Multiple Protocols** - HTTP, TCP, and HTTPS protocol support
- **Geo-Routing** - Route traffic to specific data centers
- **Load Balancing** - Distribute traffic across multiple origins
- **Dashboard** - Real-time metrics and traffic monitoring

## Prerequisites

- Cloudflare account
- cloudflared binary (v1.35.0+)
- Root or sudo privileges (for system service installation)
- Port 2000-65535 available (for local service)
- Linux with systemd, OpenRC, or Windows with NSSM

## Structure

```
cloudflare-tunnel/
├── config/              - Configuration files and templates
│   └── config.yml       - cloudflared tunnel configuration
├── install/             - Installation scripts and guides
│   └── install.sh       - Installation and setup script
├── service/             - Service definitions for different init systems
│   ├── systemd/         - systemd service unit
│   ├── openrc/          - OpenRC init script
│   ├── sysvinit/        - SysV init script
│   └── windows/         - Windows NSSM service definition
├── uninstall/           - Uninstallation scripts
│   └── uninstall.sh     - Uninstallation script
└── README.md            - This file
```

## Quick Start

### Linux (systemd)

```bash
# Install
sudo ./install/install.sh

# Authenticate
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create <tunnel-name>

# Configure tunnel
cloudflared tunnel route dns <tunnel-name> <domain>

# Start service
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service cloudflared start
sudo rc-update add cloudflared default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service cloudflared start
sudo update-rc.d cloudflared defaults
```

### Windows (NSSM)

```powershell
# Copy cloudflared to C:\cloudflared\
# Install service
nssm install cloudflared "C:\cloudflared\cloudflared.exe" service
nssm set cloudflared AppDirectory "C:\cloudflared"
nssm start cloudflared
```

## Configuration

See [config/README.md](config/README.md) for cloudflared configuration options.

## Service Management

See [service/README.md](service/README.md) for service management across different init systems.

## Installation Guide

See [install/README.md](install/README.md) for detailed installation instructions.

## Uninstallation

See [uninstall/README.md](uninstall/README.md) for removal instructions.

## Resources

- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/cloudflared/)
- [cloudflared GitHub](https://github.com/cloudflare/cloudflared)
- [Cloudflare Zero Trust](https://developers.cloudflare.com/cloudflare-one/)