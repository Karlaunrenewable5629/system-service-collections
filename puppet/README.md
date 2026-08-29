# Puppet

[![Puppet](https://img.shields.io/badge/Puppet-v8-blue)](https://www.puppet.com/)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](https://github.com/puppetlabs/puppet/blob/main/LICENSE)

Puppet is a declarative configuration management platform that automates the provisioning and enforcement of system state. The Puppet agent runs on managed nodes and periodically checks in with a Puppet server (or applies manifests locally) to ensure the system configuration matches what is declared in Puppet code.

## Features

- **Declarative Language** - Define desired system state using Puppet DSL; Puppet handles the how
- **Agent/Server & Agentless Modes** - Run with a central Puppet server or apply manifests locally with puppet apply
- **Idempotent Enforcement** - Converge safely on every run without unintended side effects
- **Resource Abstraction Layer** - Manage packages, files, services, users, and more across platforms
- **Facter Integration** - Automatic collection of system facts used in manifests
- **Hiera Data Separation** - Keep configuration data separate from code with hierarchical lookups
- **Forge Module Ecosystem** - Thousands of community and supported modules for common services
- **Role & Profile Pattern** - Composable, reusable classification for nodes

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- Root or sudo privileges
- Network access to Puppet server (for agent mode) or manifests on disk (for apply mode)

## Structure

```
puppet/
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
sudo cp config/puppet.conf /etc/puppetlabs/puppet/puppet.conf

# Start service
sudo systemctl start puppet
sudo systemctl enable puppet

# Check status
sudo systemctl status puppet
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service puppet start
sudo rc-update add puppet default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service puppet start
sudo update-rc.d puppet defaults
```

### Windows (NSSM)

```powershell
# Puppet agent is installed via the official MSI package
# Install service via Puppet installer or NSSM
nssm install puppet "C:\Program Files\Puppet Labs\Puppet\bin\ruby.exe" "C:\Program Files\Puppet Labs\Puppet\service\daemon.rb"
nssm start puppet
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

- [Puppet Documentation](https://www.puppet.com/docs/puppet/)
- [Puppet Language Reference](https://www.puppet.com/docs/puppet/latest/puppet_language.html)
- [GitHub Repository](https://github.com/puppetlabs/puppet)
- [Puppet Forge](https://forge.puppet.com/)
