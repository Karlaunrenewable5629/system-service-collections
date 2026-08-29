# Installation Guide

This guide covers installing Node.js with the service definitions from this repository.

## Prerequisites

- Root or sudo access
- Node.js installed on the system
- Supported init system (systemd, OpenRC, or SysVinit) or Windows with NSSM
- Port 3000 (app), 9229 (debug)

## Install Node.js

### Debian/Ubuntu

```bash
apt update
apt install nodejs npm
```

### RHEL/CentOS/Fedora

```bash
dnf install nodejs npm
```

### Alpine Linux

```bash
apk add nodejs npm
```

### Arch Linux

```bash
pacman -S nodejs npm
```

### Windows

Download Node.js from [nodejs.org](https://nodejs.org/en/download/) and install.

## Install from This Repository

### Clone the Repository

```bash
git clone <repository-url>
cd system-service-collections/node
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
cp config/node.conf /etc/node/config.yaml
cp config/server.js /etc/node/server.js
mkdir -p /etc/node/ssl
mkdir -p /var/log/node
mkdir -p /var/www/node
mkdir -p /run/node

# Copy service file
cp service/systemd/node.service /etc/systemd/system/
systemctl daemon-reload

# Enable and start
systemctl enable node
systemctl start node
```

### OpenRC

```bash
# Copy configuration
cp config/node.conf /etc/node/config.yaml
cp config/server.js /etc/node/server.js
mkdir -p /etc/node/ssl
mkdir -p /var/log/node
mkdir -p /var/www/node
mkdir -p /run/node

# Copy init script
cp service/openrc/node /etc/init.d/node
chmod +x /etc/init.d/node

# Enable and start
rc-update add node default
rc-service node start
```

### SysVinit

```bash
# Copy configuration
cp config/node.conf /etc/node/config.yaml
cp config/server.js /etc/node/server.js
mkdir -p /etc/node/ssl
mkdir -p /var/log/node
mkdir -p /var/www/node
mkdir -p /run/node

# Copy init script
cp service/sysvinit/node /etc/init.d/node
chmod +x /etc/init.d/node

# Enable and start
chkconfig --add node
chkconfig node on
service node start
```

### Windows (NSSM)

```cmd
copy config\node.conf C:\node\config.yaml
copy config\server.js C:\node\server.js
mkdir C:\node\ssl
mkdir C:\node\logs
mkdir C:\node\www

nssm install node C:\node\node.exe
nssm set node AppDirectory C:\node
nssm set node Start SERVICE_AUTO_START
nssm start node
```

## Post-Installation

1. **Validate configuration**: `node --check /etc/node/server.js`
2. **Place SSL certificates** in `/etc/node/ssl/`
3. **Install npm dependencies** as needed
4. **Configure firewall** to allow port 3000
5. **Reload node** after any configuration changes

## Creating the node User

If the node user doesn't exist:

```bash
useradd -r -s /sbin/nologin node
```

## Troubleshooting

- Check logs: `/var/log/node/error.log`
- Validate config: `node --check /etc/node/server.js`
- Test service status using your init system's status command