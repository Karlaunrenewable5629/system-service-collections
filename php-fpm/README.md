# PHP-FPM

[![PHP-FPM](https://img.shields.io/badge/PHP-FPM-8.2-blue)](https://www.php.net/manual/en/install.fpm.php)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/php/php-src/blob/master/LICENSE)

PHP FastCGI Process Manager is an alternative PHP FastCGI implementation with additional features useful for sites of any size, especially busier sites.

## Features

- **PHP processing** - Fast and efficient PHP execution
- **FastCGI** - Improved performance over traditional CGI
- **Process pooling** - Multiple pools with different settings
- **OPcache support** - Enhanced performance through bytecode caching
- **Advanced process management** - Graceful stop/start, emergency restart
- **Static and dynamic process spawning** - Adaptive to load

## Prerequisites

- Linux with systemd, OpenRC, or SysVinit, or Windows 10/11 / Server 2016+ with NSSM
- Root or sudo privileges
- Port 9000 (slow)
- PHP-FPM installed on the system

## Structure

```
php-fpm/
├── config/              - PHP-FPM configuration files
│   ├── php-fpm.conf     - Main configuration
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
sudo cp config/php-fpm.conf /etc/php-fpm/php-fpm.conf
sudo systemctl start php-fpm
sudo systemctl enable php-fpm
sudo systemctl status php-fpm
```

### Linux (OpenRC)

```bash
sudo ./install/install.sh
sudo rc-service php-fpm start
sudo rc-update add php-fpm default
```

### Linux (SysVinit)

```bash
sudo ./install/install.sh
sudo service php-fpm start
sudo chkconfig --add php-fpm
sudo chkconfig php-fpm on
```

### Windows (NSSM)

```powershell
nssm install php-fpm "C:\php-fpm\sbin\php-fpm.exe"
nssm start php-fpm
```

## Configuration

See [config/README.md](config/README.md) for configuration options.

## Service Management

See [service/README.md](service/README.md) for service management across different init systems.

## Installation

See [install/README.md](install/README.md) for installation instructions.

## Uninstallation

See [uninstall/README.md](uninstall/README.md) for uninstallation instructions.