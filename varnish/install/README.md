# Installation Guide

This guide covers installing Varnish Cache with the service definitions from this repository.

## Prerequisites

- Root or sudo access
- Varnish installed on the system
- Supported init system (systemd, OpenRC, or SysVinit) or Windows with NSSM

## Install Varnish

### Debian/Ubuntu

```bash
apt update
apt install varnish
```

### RHEL/CentOS/Fedora

```bash
dnf install varnish
```

### Alpine Linux

```bash
apk add varnish
```

### Arch Linux

```bash
pacman -S varnish
```

### Windows

Download Varnish from [varnish-cache.org](https://varnish-cache.org/) and install using the Windows installer.

## Install from This Repository

### Clone the Repository

```bash
git clone <repository-url>
cd system-service-collections/varnish
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
cp config/default.vcl /etc/varnish/default.vcl
cp config/secret /etc/varnish/secret
chmod 600 /etc/varnish/secret
chown varnish:varnish /etc/varnish/secret

# Copy service file
cp service/systemd/varnish.service /etc/systemd/system/
systemctl daemon-reload

# Enable and start
systemctl enable varnish
systemctl start varnish
```

### OpenRC

```bash
# Copy configuration
cp config/default.vcl /etc/varnish/default.vcl
cp config/secret /etc/varnish/secret
chmod 600 /etc/varnish/secret
chown varnish:varnish /etc/varnish/secret

# Copy init script
cp service/openrc/varnish /etc/init.d/varnish
chmod +x /etc/init.d/varnish

# Enable and start
rc-update add varnish default
rc-service varnish start
```

### SysVinit

```bash
# Copy configuration
cp config/default.vcl /etc/varnish/default.vcl
cp config/secret /etc/varnish/secret
chmod 600 /etc/varnish/secret
chown varnish:varnish /etc/varnish/secret

# Copy init script
cp service/sysvinit/varnish /etc/init.d/varnish
chmod +x /etc/init.d/varnish

# Enable and start
chkconfig --add varnish
chkconfig varnish on
service varnish start
```

### Windows (NSSM)

```cmd
copy config\default.vcl C:\Program Files\Varnish\default.vcl
copy config\secret C:\Program Files\Varnish\secret

nssm install varnish C:\Program Files\Varnish\varnish.nssm
nssm start varnish
```

## Post-Installation

1. **Validate VCL configuration**: `varnishd -C -f /etc/varnish/default.vcl`
2. **Place SSL certificates** in `/etc/varnish/ssl/` if using TLS termination
3. **Configure firewall** to allow port 6081 (HTTP) and 6082 (VAC)
4. **Reload Varnish** after any configuration changes
5. **Check backend connectivity** on port 8080

## Creating the varnish User

If the varnish user doesn't exist:

```bash
useradd -r -s /sbin/nologin varnish
```

## Secret File

The secret file is used for Varnish Administration Console (VAC) authentication. Generate one if it doesn't exist:

```bash
openssl rand -hex 32 > /etc/varnish/secret
chown varnish:varnish /etc/varnish/secret
chmod 600 /etc/varnish/secret
```

## Troubleshooting

- Check logs: `/var/log/varnish/`
- Validate config: `varnishd -C -f /etc/varnish/default.vcl`
- Test service status using your init system's status command
- Check backend: `curl http://127.0.0.1:8080`
