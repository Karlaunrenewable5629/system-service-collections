# Squid

[![Squid](https://img.shields.io/badge/Squid-v6.5-blue)](https://www.squid-cache.org/)
[![License](https://img.shields.io/badge/license-GPL- green.svg)](https://www.squid-cache.org/Versions/LICENSE/)

Squid is a caching proxy for the Web supporting HTTP, HTTPS, FTP, and more. It reduces bandwidth and improves response times by caching and reusing frequently-requested web pages. Squid offers a rich access classification, traffic reduction, and access control, and is widely used by ISPs and enterprise networks.

## Features

- **Web Caching** - Cache web content to reduce bandwidth usage
- **Access Control** - Fine-grained ACL rules for access management
- **Traffic Reduction** - Cache peer and sibling configurations
- **SSL/Bump** - SSL bump and intercept capabilities
- **Traffic Shaping** - Bandwidth management and throttling
- **Request Routing** - Redirect and rewrite request handling
- **Logging** - Comprehensive access and cache logs
- **Monitoring** - SNMP and cache info support

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit
- Minimum 1GB disk space for cache
- Root or sudo privileges
- Ports 3128 (HTTP) and 3130 (HTTPS) open

## Structure

```
squid/
├── config/              - Configuration files and templates
│   └── squid.conf       - Main Squid configuration
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

# Copy configuration
sudo cp config/squid.conf /etc/squid/squid.conf

# Start service
sudo systemctl start squid
sudo systemctl enable squid

# Check status
sudo systemctl status squid
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service squid start
sudo rc-update add squid default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service squid start
sudo update-rc.d squid defaults
```

### Windows (NSSM)

```powershell
# Copy squid to C:\Squid\
# Install service
nssm install squid "C:\Squid\squid.exe" -n
nssm set squid AppDirectory "C:\Squid"
nssm start squid
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

- [Squid Documentation](https://www.squid-cache.org/Doc/)
- [Squid Wiki](https://wiki.squid-cache.org/)
- [Squid Release](https://www.squid-cache.org/Versions/)
- [Squid Community](https://www.squid-cache.org/Features/)