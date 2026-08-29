# Jenkins

[![Jenkins](https://img.shields.io/badge/Jenkins-v2.x-blue)](https://www.jenkins.io/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/jenkinsci/jenkins/blob/master/LICENSE.txt)

Jenkins is the leading open source automation server. It provides hundreds of plugins to support building, deploying, and automating any project. Jenkins supports pipeline as code via Jenkinsfile, distributed builds across multiple agents, and an extensive plugin ecosystem covering every stage of the software delivery lifecycle.

## Features

- **Pipeline as Code** - Define CI/CD pipelines in a Jenkinsfile stored alongside source code
- **Distributed Builds** - Scale out with controller/agent architecture across many machines
- **Vast Plugin Ecosystem** - 1800+ plugins for integration with almost any tool
- **Blue Ocean UI** - Modern pipeline visualization and editor
- **Multibranch Pipelines** - Automatically detect branches and PRs
- **Shared Libraries** - Reuse pipeline logic across multiple projects
- **Role-Based Access Control** - Fine-grained permissions for teams and projects
- **Declarative & Scripted Pipelines** - Choose between structured or Groovy-based pipeline syntax

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- Java 17 or Java 21 (LTS)
- Root or sudo privileges
- Port 8080 (HTTP) and 50000 (agent JNLP) open

## Structure

```
jenkins/
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

# Start service
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check status
sudo systemctl status jenkins

# View logs
journalctl -u jenkins -f
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service jenkins start
sudo rc-update add jenkins default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service jenkins start
sudo update-rc.d jenkins defaults
```

### Windows (NSSM)

```powershell
# Copy jenkins.war to C:\jenkins\
# Install service
nssm install jenkins "C:\Program Files\Java\jdk-21\bin\java.exe" "-jar C:\jenkins\jenkins.war --httpPort=8080"
nssm set jenkins AppDirectory "C:\jenkins"
nssm start jenkins
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

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Pipeline Syntax Reference](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [GitHub Repository](https://github.com/jenkinsci/jenkins)
- [Jenkins Plugin Index](https://plugins.jenkins.io/)
