# Authentik Installation Guide

This guide covers installing Authentik as a native system service on Linux and Windows. For Docker-based deployments, see the [official documentation](https://docs.goauthentik.io/docs/installation/docker-compose).

## Prerequisites

### All Platforms

- PostgreSQL 14 or newer
- Redis 6.0 or newer
- Ports 9000 (HTTP) and 9443 (HTTPS) open in your firewall

### Linux

- A supported Linux distribution (Debian 11+, Ubuntu 20.04+, RHEL 8+, or equivalent)
- `sudo` or root access
- Python 3.12+ (for source-based installs)

### Windows

- Windows 10/11 or Windows Server 2016+
- Administrator privileges
- [NSSM](https://nssm.cc/) (Non-Sucking Service Manager)
- Visual C++ Redistributable 2019+

## Automated Installation (Linux)

The `install.sh` script handles dependency checks, user creation, directory setup, and service registration.

```bash
# Clone or copy this repository
cd authentik/install

# Make the script executable
chmod +x install.sh

# Run as root or with sudo
sudo ./install.sh
```

After installation, edit the configuration file before starting the service:

```bash
sudo nano /etc/authentik/.env
```

## Manual Installation (Linux)

### 1. Create the System User

Authentik should run as a dedicated non-privileged user:

```bash
sudo useradd --system --no-create-home --shell /usr/sbin/nologin --comment "Authentik Service" authentik
```

### 2. Install Dependencies

**Debian / Ubuntu:**

```bash
sudo apt update
sudo apt install -y python3 python3-pip python3-venv libpq-dev libffi-dev libssl-dev \
    gcc build-essential nodejs npm redis postgresql
```

**RHEL / Rocky / AlmaLinux:**

```bash
sudo dnf install -y python3 python3-pip python3-devel libpq-devel libffi-devel openssl-devel \
    gcc gcc-c++ make nodejs npm redis postgresql-server postgresql-contrib
```

### 3. Download Authentik

Download the latest release from the [Authentik releases page](https://github.com/goauthentik/authentik/releases) or install via pip:

```bash
# Create installation directory
sudo mkdir -p /opt/authentik
sudo chown authentik:authentik /opt/authentik

# Create a virtual environment
sudo -u authentik python3 -m venv /opt/authentik/venv

# Install Authentik
sudo -u authentik /opt/authentik/venv/bin/pip install --upgrade pip
sudo -u authentik /opt/authentik/venv/bin/pip install authentik
```

### 4. Create Directories

```bash
sudo mkdir -p /etc/authentik
sudo mkdir -p /var/lib/authentik/media
sudo mkdir -p /var/log/authentik
sudo chown -R authentik:authentik /etc/authentik /var/lib/authentik /var/log/authentik
sudo chmod 750 /etc/authentik
```

### 5. Configure Authentik

```bash
sudo cp /path/to/this/repo/authentik/config/.env /etc/authentik/.env
sudo chown authentik:authentik /etc/authentik/.env
sudo chmod 640 /etc/authentik/.env
```

Edit the file and set at minimum:
- `AUTHENTIK_SECRET_KEY` — generate with `openssl rand -base64 60`
- `AUTHENTIK_POSTGRESQL__PASSWORD`
- `AUTHENTIK_BOOTSTRAP_EMAIL`

### 6. Set Up the Database

```bash
# Connect to PostgreSQL as the postgres superuser
sudo -u postgres psql <<EOF
CREATE USER authentik WITH PASSWORD 'your-strong-password';
CREATE DATABASE authentik OWNER authentik;
GRANT ALL PRIVILEGES ON DATABASE authentik TO authentik;
EOF
```

### 7. Run Database Migrations

```bash
sudo -u authentik /opt/authentik/venv/bin/python -m authentik.manage migrate
```

### 8. Install and Enable the Service

See [service/README.md](../service/README.md) for init system-specific instructions.

**systemd (most common):**

```bash
sudo cp ../service/systemd/authentik-server.service /etc/systemd/system/
sudo cp ../service/systemd/authentik-worker.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now authentik-server authentik-worker
```

### 9. Verify the Installation

```bash
# Check service status
sudo systemctl status authentik-server
sudo systemctl status authentik-worker

# Watch logs
journalctl -u authentik-server -f
```

Access the web UI at `http://your-server:9000/if/flow/initial-setup/` to complete the setup wizard.

## Manual Installation (Windows)

### 1. Install Prerequisites

- Install [Python 3.12+](https://www.python.org/downloads/windows/) (check "Add Python to PATH")
- Install [Node.js LTS](https://nodejs.org/)
- Install [PostgreSQL 14+](https://www.postgresql.org/download/windows/)
- Install [Redis for Windows](https://github.com/microsoftarchive/redis/releases) or use WSL
- Download [NSSM](https://nssm.cc/download) and place `nssm.exe` in `C:\Windows\System32\`

### 2. Create Directory Structure

```powershell
New-Item -ItemType Directory -Path C:\authentik
New-Item -ItemType Directory -Path C:\authentik\media
New-Item -ItemType Directory -Path C:\authentik\logs
New-Item -ItemType Directory -Path C:\ProgramData\authentik
```

### 3. Install Authentik

```powershell
cd C:\authentik
python -m venv venv
.\venv\Scripts\pip install authentik
```

### 4. Configure

```powershell
Copy-Item C:\path\to\repo\authentik\config\.env C:\authentik\.env
notepad C:\authentik\.env
```

### 5. Run Migrations

```powershell
C:\authentik\venv\Scripts\python.exe -m authentik.manage migrate
```

### 6. Install as Windows Service

```powershell
# Install server service
nssm install authentik-server "C:\authentik\venv\Scripts\python.exe" "-m authentik.manage server"
nssm set authentik-server AppDirectory "C:\authentik"
nssm set authentik-server AppEnvFile "C:\authentik\.env"
nssm set authentik-server Description "Authentik Identity Provider - Server"
nssm set authentik-server AppStdout "C:\authentik\logs\server.log"
nssm set authentik-server AppStderr "C:\authentik\logs\server-error.log"
nssm start authentik-server

# Install worker service
nssm install authentik-worker "C:\authentik\venv\Scripts\python.exe" "-m authentik.manage worker"
nssm set authentik-worker AppDirectory "C:\authentik"
nssm set authentik-worker AppEnvFile "C:\authentik\.env"
nssm set authentik-worker Description "Authentik Identity Provider - Worker"
nssm set authentik-worker AppStdout "C:\authentik\logs\worker.log"
nssm set authentik-worker AppStderr "C:\authentik\logs\worker-error.log"
nssm start authentik-worker
```

## Post-Installation

### Initial Setup

On first run, Authentik will create the initial `akadmin` superuser. If `AUTHENTIK_BOOTSTRAP_PASSWORD` is set, that password is used. Otherwise, navigate to:

```
http://your-server:9000/if/flow/initial-setup/
```

### Firewall Rules

**Linux (ufw):**

```bash
sudo ufw allow 9000/tcp   # HTTP
sudo ufw allow 9443/tcp   # HTTPS
```

**Linux (firewalld):**

```bash
sudo firewall-cmd --permanent --add-port=9000/tcp
sudo firewall-cmd --permanent --add-port=9443/tcp
sudo firewall-cmd --reload
```

**Windows (PowerShell):**

```powershell
New-NetFirewallRule -DisplayName "Authentik HTTP" -Direction Inbound -Protocol TCP -LocalPort 9000 -Action Allow
New-NetFirewallRule -DisplayName "Authentik HTTPS" -Direction Inbound -Protocol TCP -LocalPort 9443 -Action Allow
```

### TLS / HTTPS

For production, place a reverse proxy (Nginx, Caddy, Traefik) in front of Authentik and terminate TLS there, forwarding to `http://localhost:9000`. Authentik also supports direct TLS — place your certificate and key at:

- `/etc/authentik/ssl/server.pem` (certificate + chain)
- `/etc/authentik/ssl/server.key` (private key)

## Upgrades

```bash
# Stop services
sudo systemctl stop authentik-server authentik-worker

# Update the package
sudo -u authentik /opt/authentik/venv/bin/pip install --upgrade authentik

# Run migrations
sudo -u authentik /opt/authentik/venv/bin/python -m authentik.manage migrate

# Restart services
sudo systemctl start authentik-server authentik-worker
```

## References

- [Authentik Installation Documentation](https://docs.goauthentik.io/docs/installation/)
- [Authentik GitHub Releases](https://github.com/goauthentik/authentik/releases)
- [Configuration Reference](../config/README.md)
