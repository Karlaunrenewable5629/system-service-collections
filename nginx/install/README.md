# Installation Guide

This guide covers installing nginx with the service definitions from this repository.

## Prerequisites

- Root or sudo access
- nginx installed on the system
- Supported init system (systemd, OpenRC, or SysVinit) or Windows with NSSM

## Install nginx

### Debian/Ubuntu

```bash
apt update
apt install nginx
```

### RHEL/CentOS/Fedora

```bash
dnf install nginx
```

### Alpine Linux

```bash
apk add nginx
```

### Arch Linux

```bash
pacman -S nginx
```

### Windows

Download nginx from [nginx.org](https://nginx.org/en/download.html) and extract to `C:\nginx`.

## Install from This Repository

### Clone the Repository

```bash
git clone <repository-url>
cd system-service-collections/nginx
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
cp config/nginx.conf /etc/nginx/nginx.conf
mkdir -p /etc/nginx/ssl
mkdir -p /var/log/nginx
mkdir -p /var/www/html

# Copy service file
cp service/systemd/nginx.service /etc/systemd/system/
systemctl daemon-reload

# Enable and start
systemctl enable nginx
systemctl start nginx
```

### OpenRC

```bash
# Copy configuration
cp config/nginx.conf /etc/nginx/nginx.conf
mkdir -p /etc/nginx/ssl
mkdir -p /var/log/nginx
mkdir -p /var/www/html

# Copy init script
cp service/openrc/nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx

# Enable and start
rc-update add nginx default
rc-service nginx start
```

### SysVinit

```bash
# Copy configuration
cp config/nginx.conf /etc/nginx/nginx.conf
mkdir -p /etc/nginx/ssl
mkdir -p /var/log/nginx
mkdir -p /var/www/html

# Copy init script
cp service/sysvinit/nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx

# Enable and start
chkconfig --add nginx
chkconfig nginx on
service nginx start
```

### Windows (NSSM)

```cmd
copy config\nginx.conf C:\nginx\nginx.conf
mkdir C:\nginx\ssl
mkdir C:\nginx\logs
mkdir C:\nginx\html

nssm install nginx C:\nginx\nginx.exe
nssm set nginx AppDirectory C:\nginx
nssm set nginx Start SERVICE_AUTO_START
nssm start nginx
```

## Post-Installation

1. **Validate configuration**: `nginx -t`
2. **Place SSL certificates** in `/etc/nginx/ssl/`
3. **Add your website content** to `/var/www/html/`
4. **Configure firewall** to allow ports 80 and 443
5. **Reload nginx** after any configuration changes

## Creating the nginx User

If the nginx user doesn't exist:

```bash
useradd -r -s /sbin/nologin nginx
```

## Troubleshooting

- Check logs: `/var/log/nginx/error.log`
- Validate config: `nginx -t`
- Test service status using your init system's status command