# Memcached

[![Memcached](https://img.shields.io/badge/Memcached-v1.6-blue)](https://memcached.org/)
[![License](https://img.shields.io/badge/license-BSD-green.svg)](https://github.com/memcached/memcached/blob/master/LICENSE)

Memcached is a high-performance, distributed memory object caching system. It is designed to speed up dynamic web applications by alleviating database load, storing arbitrary data (strings, objects) from the results of database calls, API calls, or page rendering in memory.

## Features

- **High Throughput** - Handles hundreds of thousands of requests per second with microsecond latency
- **Distributed Caching** - Simple key/value store that scales horizontally across many nodes
- **Memory Efficiency** - Slab allocator minimizes fragmentation for small object storage
- **Binary & Text Protocols** - Support for both the legacy text protocol and the faster binary protocol
- **Multi-Threading** - Takes full advantage of multi-core systems
- **Expiry & Eviction** - Configurable TTL per item and LRU-based eviction under memory pressure
- **SASL Authentication** - Optional SASL support for securing access
- **UDP Support** - Optional UDP interface for lower-overhead bulk operations

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- Root or sudo privileges
- Port 11211 open (TCP/UDP)

## Structure

```
memcached/
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
sudo cp config/memcached.conf /etc/memcached.conf

# Start service
sudo systemctl start memcached
sudo systemctl enable memcached

# Check status
sudo systemctl status memcached
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service memcached start
sudo rc-update add memcached default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service memcached start
sudo update-rc.d memcached defaults
```

### Windows (NSSM)

```powershell
# Copy memcached.exe to C:\memcached\
# Install service
nssm install memcached "C:\memcached\memcached.exe" "-m 256 -p 11211 -l 127.0.0.1"
nssm start memcached
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

- [Memcached Wiki](https://github.com/memcached/memcached/wiki)
- [Memcached Documentation](https://memcached.org/)
- [GitHub Repository](https://github.com/memcached/memcached)
- [Protocol Specification](https://github.com/memcached/memcached/blob/master/doc/protocol.txt)
