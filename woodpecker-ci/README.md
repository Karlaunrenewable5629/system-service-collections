# Woodpecker CI

[![Woodpecker CI](https://img.shields.io/badge/Woodpecker%20CI-v2.x-blue)](https://woodpecker-ci.org/)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](https://github.com/woodpecker-ci/woodpecker/blob/main/LICENSE)

Woodpecker CI is a self-hosted continuous integration system forked from Drone. It is written in Go and uses Docker-based pipeline execution with pipeline definitions stored as code in your repository. Woodpecker is lightweight, easy to operate, and integrates natively with Gitea, GitHub, GitLab, and Forgejo.

## Features

- **Pipeline as Code** - Define pipelines in a `.woodpecker.yml` file stored in your repository
- **Docker-Based Execution** - Each pipeline step runs in an isolated Docker container
- **Multi-Platform Agents** - Deploy agents on Linux, macOS, or Windows nodes
- **SCM Integrations** - Native support for Gitea, Forgejo, GitHub, GitLab, and Bitbucket
- **Secrets Management** - Store and inject secrets at the pipeline, repository, or organization level
- **Matrix Builds** - Run pipelines across multiple variable combinations in parallel
- **Conditional Steps** - Skip or run steps based on branch, event, or custom conditions
- **Plugin Ecosystem** - Reuse community plugins for common CI tasks (Docker build, deploy, notify)

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- Docker installed and accessible to the agent
- Root or sudo privileges
- A configured SCM (Gitea, GitHub, etc.) OAuth application
- Ports 8000 (server UI/API) and 9000 (agent gRPC) open

## Structure

```
woodpecker-ci/
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
sudo cp config/woodpecker-server.env /etc/woodpecker/server.env
sudo cp config/woodpecker-agent.env /etc/woodpecker/agent.env

# Start services
sudo systemctl start woodpecker-server
sudo systemctl enable woodpecker-server
sudo systemctl start woodpecker-agent
sudo systemctl enable woodpecker-agent

# Check status
sudo systemctl status woodpecker-server
sudo systemctl status woodpecker-agent
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service woodpecker-server start
sudo rc-update add woodpecker-server default
sudo rc-service woodpecker-agent start
sudo rc-update add woodpecker-agent default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service woodpecker-server start
sudo update-rc.d woodpecker-server defaults
sudo service woodpecker-agent start
sudo update-rc.d woodpecker-agent defaults
```

### Windows (NSSM)

```powershell
# Copy woodpecker-server.exe and woodpecker-agent.exe to C:\woodpecker\
# Install server service
nssm install woodpecker-server "C:\woodpecker\woodpecker-server.exe"
nssm set woodpecker-server AppEnvFile "C:\woodpecker\server.env"
nssm start woodpecker-server

# Install agent service
nssm install woodpecker-agent "C:\woodpecker\woodpecker-agent.exe"
nssm set woodpecker-agent AppEnvFile "C:\woodpecker\agent.env"
nssm start woodpecker-agent
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

- [Woodpecker CI Documentation](https://woodpecker-ci.org/docs/intro)
- [Pipeline Syntax Reference](https://woodpecker-ci.org/docs/usage/pipeline-syntax)
- [GitHub Repository](https://github.com/woodpecker-ci/woodpecker)
- [Plugin Registry](https://woodpecker-ci.org/plugins)
