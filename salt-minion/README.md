# Salt Minion

[![Salt](https://img.shields.io/badge/Salt-v3007-blue)](https://saltproject.io/)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](https://github.com/saltstack/salt/blob/master/LICENSE)

Salt Minion is the agent component of SaltStack (Salt Project), a powerful remote execution and configuration management framework. The minion runs on managed nodes and communicates with a Salt Master to receive commands, apply states, and report back system data. It can also run in masterless mode using salt-call.

## Features

- **Remote Execution** - Run commands across thousands of nodes simultaneously
- **State Management** - Declarative configuration using SLS state files (YAML + Jinja2)
- **Grains System** - Automatic and custom node attribute collection for targeting
- **Pillar Data** - Secure, targeted data delivery to specific minions
- **Event-Driven Automation** - React to events with Salt Reactor
- **Masterless Mode** - Use salt-call to apply states locally without a master
- **Beacons & Returners** - Monitor system events and send results to external systems
- **Encrypted Communication** - ZeroMQ-based transport with public-key encryption

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- Root or sudo privileges
- Network access to Salt Master on ports 4505 and 4506 (for master mode)

## Structure

```
salt-minion/
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
sudo cp config/minion /etc/salt/minion

# Start service
sudo systemctl start salt-minion
sudo systemctl enable salt-minion

# Check status
sudo systemctl status salt-minion
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service salt-minion start
sudo rc-update add salt-minion default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service salt-minion start
sudo update-rc.d salt-minion defaults
```

### Windows (NSSM)

```powershell
# Salt installer sets up the service automatically
# Or install manually with NSSM
nssm install salt-minion "C:\salt\salt-minion.exe" "-c C:\salt\conf"
nssm set salt-minion AppDirectory "C:\salt"
nssm start salt-minion
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

- [Salt Project Documentation](https://docs.saltproject.io/)
- [Salt States Reference](https://docs.saltproject.io/en/latest/ref/states/)
- [GitHub Repository](https://github.com/saltstack/salt)
- [Salt Community](https://saltproject.io/community/)
