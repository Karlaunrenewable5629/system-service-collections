# nginx

System service collection for nginx.

## Features

- Reverse proxy and load balancing
- HTTP/2 and SSL/TLS support
- Gzip compression
- Security headers (HSTS, X-Frame-Options, X-Content-Type-Options, etc.)
- Caching support
- High-performance HTTP serving

## Structure

- install/ - Installation scripts and guides
- config/ - Configuration files and templates
- service/ - Service definitions for different init systems
  - systemd/ - systemd service units
  - openrc/ - OpenRC init scripts
  - sysvinit/ - SysV init scripts
  - windows/ - Windows service definitions (NSSM, etc.)
- uninstall/ - Uninstallation scripts

## Quick Start

### systemd (Linux)

```bash
cp service/systemd/nginx.service /etc/systemd/system/
cp config/nginx.conf /etc/nginx/nginx.conf
systemctl daemon-reload
systemctl enable nginx
systemctl start nginx
```

### OpenRC (Alpine Linux)

```bash
cp service/openrc/nginx /etc/init.d/nginx
cp config/nginx.conf /etc/nginx/nginx.conf
rc-update add nginx default
rc-service nginx start
```

### SysVinit (legacy Linux)

```bash
cp service/sysvinit/nginx /etc/init.d/nginx
cp config/nginx.conf /etc/nginx/nginx.conf
chkconfig --add nginx
chkconfig nginx on
service nginx start
```

### Windows (NSSM)

```cmd
copy service\windows\nginx.nssm C:\nginx\nginx.nssm
copy config\nginx.conf C:\nginx\nginx.conf
nssm install nginx C:\nginx\nginx.exe
nssm start nginx
```

## Configuration

See [config/README.md](config/README.md) for configuration options.

## Service Management

See [service/README.md](service/README.md) for service management across different init systems.

## Installation

See [install/README.md](install/README.md) for installation instructions.

## Uninstallation

See [uninstall/README.md](uninstall/README.md) for uninstallation instructions.