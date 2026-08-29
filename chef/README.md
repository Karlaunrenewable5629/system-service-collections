# Chef

[![Chef](https://img.shields.io/badge/Chef-v18-blue)](https://www.chef.io/)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](https://github.com/chef/chef/blob/main/LICENSE)

Chef is a powerful automation platform that transforms infrastructure into code. Using Ruby-based recipes and runlists, the Chef client (chef-client) enforces the desired state of your nodes by converging them against a Chef Infra Server or in local solo mode.

## Features

- **Infrastructure as Code** - Define system configuration using Ruby-based recipes and cookbooks
- **Idempotent Convergence** - Safely run repeatedly; only changes what needs changing
- **Chef Solo & Server Modes** - Operate standalone or connected to a Chef Infra Server
- **Resource Model** - Declarative resources for packages, files, services, users, and more
- **Ohai System Profiling** - Automatic node attribute discovery at each run
- **Data Bags & Roles** - Structured data and reusable role definitions
- **Encrypted Data Bags** - Secure secrets storage for sensitive configuration
- **Cross-Platform** - Supports Linux, macOS, and Windows nodes

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- Root or sudo privileges
- Network access to Chef Infra Server (for client mode) or cookbooks on disk (for solo mode)

## Structure

```
chef/
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
sudo cp config/client.rb /etc/chef/client.rb

# Start service
sudo systemctl start chef-client
sudo systemctl enable chef-client

# Check status
sudo systemctl status chef-client
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service chef-client start
sudo rc-update add chef-client default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service chef-client start
sudo update-rc.d chef-client defaults
```

### Windows (NSSM)

```powershell
# Copy files to C:\chef\
# Install service
nssm install chef-client "C:\opscode\chef\bin\chef-client.bat" "-d -i 1800"
nssm start chef-client
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

- [Chef Documentation](https://docs.chef.io/)
- [Chef Infra Client](https://docs.chef.io/chef_client_overview/)
- [GitHub Repository](https://github.com/chef/chef)
- [Chef Supermarket](https://supermarket.chef.io/)
