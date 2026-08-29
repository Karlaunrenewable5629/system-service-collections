# Semaphore

[![Semaphore](https://img.shields.io/badge/Semaphore-v2.98-blue)](https://www.ansible-semaphore.com/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/ansible-semaphore/semaphore/blob/master/LICENSE)

Semaphore is an open-source continuous integration and deployment platform built with Go. It provides a web-based UI for managing Ansible playbooks, Terraform configurations, and shell scripts. Semaphore supports parallel execution, templates, and integrates with Git repositories for automated pipelines.

## Features

- **Web UI Dashboard** - Manage projects, templates, and executions via browser
- **Ansible Integration** - First-class support for Ansible playbooks and inventories
- **Multi-Project Support** - Organize work by team, project, or environment
- **Parallel Execution** - Run jobs concurrently across multiple targets
- **Template System** - Reusable job templates with variables
- **Git Webhooks** - Trigger pipelines on repository events (push, PR, tag)
- **SSH Key Management** - Securely store and inject SSH keys for remote hosts
- **Docker & Docker Compose** - Run jobs in containers for isolation

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- MySQL 5.7+ or MariaDB 10.3+ database
- Root or sudo privileges
- Git, Ansible, and SSH installed (for job execution)
- Ports 3000 (HTTP) open

## Structure

```
semaphore/
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
sudo cp config/config.json /etc/semaphore/config.json

# Start service
sudo systemctl start semaphore
sudo systemctl enable semaphore

# Check status
sudo systemctl status semaphore
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service semaphore start
sudo rc-update add semaphore default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service semaphore start
sudo update-rc.d semaphore defaults
```

### Windows (NSSM)

```powershell
# Copy semaphore to C:\semaphore\
# Install service
nssm install semaphore "C:\semaphore\semaphore.exe" "server -config C:\semaphore\config.json"
nssm set semaphore AppDirectory "C:\semaphore"
nssm start semaphore
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

- [Semaphore Documentation](https://docs.ansible-semaphore.com/)
- [GitHub Repository](https://github.com/ansible-semaphore/semaphore)
- [Semaphore Community](https://github.com/ansible-semaphore/semaphore/discussions)