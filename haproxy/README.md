# HAProxy

[![HAProxy](https://img.shields.io/badge/HAProxy-v2.9-blue)](https://www.haproxy.org/)
[![License](https://img.shields.io/badge/license-MPL%202.0-green.svg)](https://github.com/haproxy/haproxy/blob/master/LICENSE)

HAProxy is a free, very fast and reliable solution offering high availability, load balancing, and proxying for TCP and HTTP-based applications.

## Features

- **High Availability** with health checking and failover
- **Load Balancing** with multiple algorithms (round-robin, leastconn, source, etc.)
- **Layer 4 (TCP) and Layer 7 (HTTP) Proxying**
- **SSL/TLS Termination**
- **Session Persistence** (cookie-based, source IP)
- **Real-time Statistics Dashboard**
- **Access Logging**
- **Rate Limiting**
- **ACL-based Routing**

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- Root or sudo privileges
- Ports 80, 443, and 8404 (stats) open
- HAProxy binary installed

## Structure

```
haproxy/
├── config/              - HAProxy configuration files
│   └── README.md        - Configuration documentation
├── install/             - Installation scripts and guides
│   └── README.md        - Installation instructions
├── service/             - Service definitions
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
sudo ./install/install.sh
sudo cp config/haproxy.cfg /etc/haproxy/haproxy.cfg
sudo systemctl start haproxy
sudo systemctl enable haproxy
sudo systemctl status haproxy
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service haproxy start
sudo rc-update add haproxy default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service haproxy start
sudo update-rc.d haproxy defaults
```

### Windows (NSSM)

```powershell
nssm install haproxy "C:\haproxy\haproxy.exe" "-f C:\haproxy\haproxy.cfg"
nssm start haproxy
```

## Configuration

See [config/README.md](config/README.md) for configuration options.

## Service Management

See [service/README.md](service/README.md) for service management.

## Installation Guide

See [install/README.md](install/README.md) for detailed installation instructions.

## Resources

- [HAProxy Documentation](https://www.haproxy.org/)
- [Configuration Reference](https://cbonte.github.io/haproxy-dconv/)
- [GitHub Repository](https://github.com/haproxy/haproxy)