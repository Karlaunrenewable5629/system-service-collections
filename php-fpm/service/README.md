# Service Management

This directory contains service definitions for PHP-FPM across different init systems and platforms.

## Available Service Definitions

| Init System | File | Platform |
|-------------|------|----------|
| systemd | `systemd/php-fpm.service` | Linux (systemd) |
| OpenRC | `openrc/php-fpm` | Alpine Linux, Gentoo |
| SysVinit | `sysvinit/php-fpm` | Legacy Linux distributions |
| NSSM | `windows/php-fpm.nssm` | Windows |

## systemd

### Install

```bash
cp service/systemd/php-fpm.service /etc/systemd/system/
systemctl daemon-reload
```

### Start/Enable

```bash
systemctl enable php-fpm
systemctl start php-fpm
```

### Common Commands

```bash
systemctl status php-fpm       # Check status
systemctl stop php-fpm         # Stop service
systemctl restart php-fpm      # Restart service
systemctl reload php-fpm       # Reload configuration
systemctl disable php-fpm      # Disable on boot
```

## OpenRC

### Install

```bash
cp service/openrc/php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
rc-update add php-fpm default
```

### Common Commands

```bash
rc-service php-fpm start       # Start service
rc-service php-fpm stop        # Stop service
rc-service php-fpm restart     # Restart service
rc-service php-fpm reload      # Reload configuration
rc-service php-fpm status      # Check status
```

## SysVinit

### Install

```bash
cp service/sysvinit/php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on
```

### Common Commands

```bash
service php-fpm start          # Start service
service php-fpm stop           # Stop service
service php-fpm restart        # Restart service
service php-fpm reload         # Reload configuration
service php-fpm status         # Check status
```

## Windows (NSSM)

### Install

1. Copy `php-fpm.nssm` to `C:\php-fpm\php-fpm.nssm`
2. Install NSSM if not already installed
3. Run the following commands:

```cmd
nssm install php-fpm C:\php-fpm\php-fpm.exe
nssm start php-fpm
```

### Common Commands

```cmd
nssm start php-fpm             # Start service
nssm stop php-fpm              # Stop service
nssm restart php-fpm           # Restart service
nssm status php-fpm            # Check status
```

## User and Group

All service definitions run PHP-FPM as the `nginx` user and `nginx` group. Ensure this user exists on your system:

```bash
useradd -r -s /sbin/nologin nginx
```

## PID File

All configurations use `/run/php-fpm/php-fpm.pid` as the PID file location. Ensure the directory exists:

```bash
mkdir -p /run/php-fpm
chown nginx:nginx /run/php-fpm
```

## Configuration Validation

Before starting the service, always validate the configuration:

```bash
php-fpm -t
```