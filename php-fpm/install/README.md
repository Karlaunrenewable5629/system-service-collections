# Installation Guide

This guide covers installing PHP-FPM with the service definitions from this repository.

## Prerequisites

- Root or sudo access
- PHP-FPM installed on the system
- Supported init system (systemd, OpenRC, or SysVinit) or Windows with NSSM
- Port 9000 (slow)

## Install PHP-FPM

### Debian/Ubuntu

```bash
apt update
apt install php-fpm
```

### RHEL/CentOS/Fedora

```bash
dnf install php-fpm
```

### Alpine Linux

```bash
apk add php82-php-fpm
```

### Arch Linux

```bash
pacman -S php-fpm
```

### Windows

Download PHP from [windows.php.net](https://windows.php.net/download/) and extract to `C:\php-fpm`.

## Install from This Repository

### Clone the Repository

```bash
git clone <repository-url>
cd system-service-collections/php-fpm
```

### Run the Installation Script

```bash
cd install
./install.sh
```

Or for a specific init system:

```bash
./install.sh systemd
./install.sh openrc
./install.sh sysvinit
```

## Manual Installation

### systemd

```bash
# Copy configuration
cp config/php-fpm.conf /etc/php-fpm/php-fpm.conf
mkdir -p /etc/php-fpm/ssl
mkdir -p /var/log/php-fpm
mkdir -p /var/lib/php-fpm
mkdir -p /run/php-fpm

# Copy service file
cp service/systemd/php-fpm.service /etc/systemd/system/
systemctl daemon-reload

# Enable and start
systemctl enable php-fpm
systemctl start php-fpm
```

### OpenRC

```bash
# Copy configuration
cp config/php-fpm.conf /etc/php-fpm/php-fpm.conf
mkdir -p /etc/php-fpm/ssl
mkdir -p /var/log/php-fpm
mkdir -p /var/lib/php-fpm
mkdir -p /run/php-fpm

# Copy init script
cp service/openrc/php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

# Enable and start
rc-update add php-fpm default
rc-service php-fpm start
```

### SysVinit

```bash
# Copy configuration
cp config/php-fpm.conf /etc/php-fpm/php-fpm.conf
mkdir -p /etc/php-fpm/ssl
mkdir -p /var/log/php-fpm
mkdir -p /var/lib/php-fpm
mkdir -p /run/php-fpm

# Copy init script
cp service/sysvinit/php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

# Enable and start
chkconfig --add php-fpm
chkconfig php-fpm on
service php-fpm start
```

### Windows (NSSM)

```cmd
copy config\php-fpm.conf C:\php-fpm\php-fpm.conf
mkdir C:\php-fpm\ssl
mkdir C:\php-fpm\logs
mkdir C:\php-fpm\lib

nssm install php-fpm C:\php-fpm\sbin\php-fpm.exe
nssm set php-fpm AppDirectory C:\php-fpm
nssm set php-fpm Start SERVICE_AUTO_START
nssm start php-fpm
```

## Post-Installation

1. **Validate configuration**: `php-fpm -t`
2. **Place SSL certificates** in `/etc/php-fpm/ssl/`
3. **Configure OPcache** in `/etc/php-fpm/php-fpm.conf`
4. **Configure firewall** to allow port 9000
5. **Reload php-fpm** after any configuration changes

## Creating the nginx User

If the nginx user doesn't exist:

```bash
useradd -r -s /sbin/nologin nginx
```

## Troubleshooting

- Check logs: `/var/log/php-fpm/error.log`
- Validate config: `php-fpm -t`
- Test service status using your init system's status command