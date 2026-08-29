# Redis

[![Redis](https://img.shields.io/badge/Redis-v7.x-blue)](https://redis.io/)
[![License](https://img.shields.io/badge/license-BSD-green.svg)](https://github.com/redis/redis/blob/unstable/COPYING)

Redis is an in-memory data structure store used as a database, cache, and message broker. It supports rich data types including strings, hashes, lists, sets, sorted sets, bitmaps, hyperloglogs, and streams. Redis provides optional persistence, replication, Lua scripting, transactions, and high availability via Redis Sentinel and Cluster.

## Features

- **Rich Data Structures** - Strings, lists, sets, sorted sets, hashes, streams, and more
- **Sub-millisecond Latency** - Extremely fast reads and writes via in-memory storage
- **Persistence Options** - RDB snapshots and AOF append-only log for durability
- **Pub/Sub Messaging** - Lightweight publish/subscribe messaging system
- **Lua Scripting** - Atomic server-side scripting with Lua
- **Transactions** - MULTI/EXEC blocks for atomic command sequences
- **Redis Sentinel** - High availability with automatic failover
- **Redis Cluster** - Horizontal scaling with automatic sharding across nodes
- **ACL & TLS** - Fine-grained access control lists and TLS encryption

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- Root or sudo privileges
- Port 6379 open

## Structure

```
redis/
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
sudo cp config/redis.conf /etc/redis/redis.conf

# Start service
sudo systemctl start redis
sudo systemctl enable redis

# Check status
sudo systemctl status redis
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service redis start
sudo rc-update add redis default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service redis start
sudo update-rc.d redis defaults
```

### Windows (NSSM)

```powershell
# Copy redis-server.exe to C:\redis\
# Install service
nssm install redis "C:\redis\redis-server.exe" "C:\redis\redis.conf"
nssm set redis AppDirectory "C:\redis"
nssm start redis
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

- [Redis Documentation](https://redis.io/docs/)
- [Redis Commands Reference](https://redis.io/commands/)
- [GitHub Repository](https://github.com/redis/redis)
- [Redis University](https://university.redis.io/)
