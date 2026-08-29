# Installation

This guide covers installing the Traefik reverse proxy service on various platforms.

## Prerequisites

- Linux or Windows server
- Root or administrator access
- Docker installed (if using Docker provider)
- `traefik` binary available

## Quick Install

```bash
sudo ./install.sh
```

The install script will:

1. Create the `traefik` user and group
2. Create required directories (`/etc/traefik`, `/var/log/traefik`)
3. Install the configuration file
4. Install the appropriate service unit for your init system
5. Start the service

## Custom Installation

### Custom user/group

```bash
sudo TRAEFIK_USER=myuser TRAEFIK_GROUP=mygroup ./install.sh
```

### Custom install prefix

```bash
sudo INSTALL_PREFIX=/opt ./install.sh
```

## Manual Installation

### 1. Copy the binary

```bash
sudo cp traefik /usr/local/bin/
sudo chmod +x /usr/local/bin/traefik
```

### 2. Create the traefik user

```bash
sudo useradd --system --shell /usr/sbin/nologin --home-dir /nonexistent traefik
sudo groupadd traefik
sudo usermod -aG traefik traefik
```

### 3. Create directories

```bash
sudo mkdir -p /etc/traefik/dynamic /var/log/traefik
sudo chown -R traefik:traefik /etc/traefik /var/log/traefik
```

### 4. Install configuration

```bash
sudo cp config/traefik.yml /etc/traefik/traefik.yml
sudo chown traefik:traefik /etc/traefik/traefik.yml
sudo chmod 640 /etc/traefik/traefik.yml

sudo touch /etc/traefik/acme.json
sudo chown traefik:traefik /etc/traefik/acme.json
sudo chmod 600 /etc/traefik/acme.json
```

### 5. Install service

Choose the service definition for your init system:

- **systemd**: `sudo cp service/systemd/traefik.service /etc/systemd/system/`
- **OpenRC**: `sudo cp service/openrc/traefik /etc/init.d/traefik`
- **SysVinit**: `sudo cp service/sysvinit/traefik /etc/init.d/traefik`
- **Windows**: Use `nssm install traefik ...`

### 6. Enable and start

```bash
# systemd
sudo systemctl daemon-reload
sudo systemctl enable traefik
sudo systemctl start traefik

# OpenRC
rc-update add traefik default
rc-service traefik start

# SysVinit
update-rc.d traefik defaults
service traefik start
```

## Verify Installation

```bash
# Check service status
sudo systemctl status traefik

# Check the dashboard
curl https://localhost:8080

# Verify configuration
/usr/local/bin/traefik check --configFile=/etc/traefik/traefik.yml
```

## Windows Installation

```powershell
# Copy binary
Copy-Item .\traefik.exe -Destination "C:\usr\local\bin\"

# Create directories
New-Item -Path "C:\etc\traefik\dynamic" -ItemType Directory -Force
New-Item -Path "C:\var\log\traefik" -ItemType Directory -Force

# Copy config
Copy-Item .\config\traefik.yml -Destination "C:\etc\traefik\traefik.yml"

# Install as Windows service
nssm install traefik "C:\usr\local\bin\traefik.exe" --configFile=C:\etc\traefik\traefik.yml
nssm start traefik
```

## Post-Installation

- Configure DNS to point to your server
- Set up firewall rules for ports 80, 443, and 8080
- Update the `email` in `config/traefik.yml` for Let's Encrypt
- Configure dynamic services in `/etc/traefik/dynamic/`
