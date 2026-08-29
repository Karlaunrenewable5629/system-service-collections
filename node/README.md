# Node.js

[![Node.js](https://img.shields.io/badge/Node.js-20.x-green)](https://nodejs.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/nodejs/node/blob/main/LICENSE)

Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine. It provides a fast, lightweight foundation for building scalable network applications.

## Features

- **JavaScript runtime** - Built on Chrome's V8 engine
- **NPM** - Largest package ecosystem in the world
- **Async I/O** - Non-blocking I/O operations
- **Event-driven** - Event loop architecture for high concurrency
- **HTTP Server** - Built-in HTTP server module
- **WebSocket support** - Real-time bidirectional communication

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- Root or sudo privileges
- Port 3000 (app), 9229 (debug)
- Node.js installed on the system

## Structure

```
node/
├── config/              - Node.js configuration files
│   ├── node.conf        - Main configuration
│   ├── README.md        - Configuration documentation
│   └── server.js        - Application entry point
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
sudo cp config/node.conf /etc/node/config.yaml
sudo systemctl start node
sudo systemctl enable node
sudo systemctl status node
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service node start
sudo rc-update add node default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service node start
sudo chkconfig --add node
sudo chkconfig node on
```

### Windows (NSSM)

```powershell
nssm install node "C:\node\node.exe"
nssm start node
```

## Configuration

See [config/README.md](config/README.md) for configuration options.

## Service Management

See [service/README.md](service/README.md) for service management across different init systems.

## Installation

See [install/README.md](install/README.md) for installation instructions.

## Uninstallation

See [uninstall/README.md](uninstall/README.md) for uninstallation instructions.