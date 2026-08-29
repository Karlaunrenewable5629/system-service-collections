# Installation Guide

This guide covers installing nginx-proxy-manager on various platforms.

## Prerequisites

- **Node.js** 18 or higher
- **npm** 9 or higher
- **Nginx** (installed and configured by the application)
- **Root/sudo access**
- Ports **80**, **443**, and **81** available

## Quick Install

```bash
# Clone the repository
git clone https://github.com/jc21/nginx-proxy-manager.git
cd nginx-proxy-manager

# Run the installation script
sudo bash install/install.sh
```

## Manual Installation

### 1. Install Node.js

```bash
# Using NodeSource (Debian/Ubuntu)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version
npm --version
```

### 2. Create Application User

```bash
sudo groupadd -f npm
sudo useradd -r -s /bin/false -g npm npm
```

### 3. Create Directories

```bash
sudo mkdir -p /usr/lib/nginx-proxy-manager
sudo mkdir -p /etc/nginx-proxy-manager
sudo mkdir -p /var/log/nginx-proxy-manager
sudo mkdir -p /var/lib/nginx-proxy-manager

sudo chown -R npm:npm /var/log/nginx-proxy-manager
sudo chown -R npm:npm /var/lib/nginx-proxy-manager
```

### 4. Install Application

```bash
# Copy application files
cp -r ./* /usr/lib/nginx-proxy-manager/
cd /usr/lib/nginx-proxy-manager
npm install --production
```

### 5. Install Configuration

```bash
cp config/npm.yaml /etc/nginx-proxy-manager/npm.yaml
sudo chown npm:npm /etc/nginx-proxy-manager/npm.yaml
sudo chmod 640 /etc/nginx-proxy-manager/npm.yaml
```

### 6. Install Service

Choose your init system:

#### systemd

```bash
cp service/systemd/nginx-proxy-manager.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable nginx-proxy-manager
sudo systemctl start nginx-proxy-manager
```

#### OpenRC

```bash
cp service/openrc/nginx-proxy-manager /etc/init.d/nginx-proxy-manager
chmod +x /etc/init.d/nginx-proxy-manager
rc-update add nginx-proxy-manager default
rc-service nginx-proxy-manager start
```

#### SysVinit

```bash
cp service/sysvinit/nginx-proxy-manager /etc/init.d/nginx-proxy-manager
chmod +x /etc/init.d/nginx-proxy-manager
update-rc.d nginx-proxy-manager defaults
service nginx-proxy-manager start
```

### 7. Configure Firewall

```bash
# UFW (Debian/Ubuntu)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 81/tcp

# firewalld (CentOS/RHEL)
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-port=81/tcp
sudo firewall-cmd --reload
```

### 8. Verify

```bash
sudo systemctl status nginx-proxy-manager
curl http://localhost:81
```

Open http://localhost:81 in your browser and log in with:

- **Email:** `admin@example.com`
- **Password:** `changeme`

## Database Setup

### SQLite (Default)

No additional setup required. The database file is stored at `/var/lib/nginx-proxy-manager/npm.db`.

### PostgreSQL

1. Create the database and user:

```sql
CREATE USER npm WITH PASSWORD 'your-password';
CREATE DATABASE nginx_proxy_manager OWNER npm;
```

2. Edit `/etc/nginx-proxy-manager/npm.yaml`:

```yaml
db:
  type: postgresql
  host: localhost
  port: 5432
  dbname: nginx_proxy_manager
  user: npm
  password: your-password
```

### MySQL

1. Create the database and user:

```sql
CREATE USER 'npm'@'localhost' IDENTIFIED BY 'your-password';
CREATE DATABASE nginx_proxy_manager;
GRANT ALL PRIVILEGES ON nginx_proxy_manager.* TO 'npm'@'localhost';
FLUSH PRIVILEGES;
```

2. Edit `/etc/nginx-proxy-manager/npm.yaml`:

```yaml
db:
  type: mysql
  host: localhost
  port: 3306
  dbname: nginx_proxy_manager
  user: npm
  password: your-password
```

## Windows Installation

### Prerequisites

- **Node.js** 18+ installed
- **NSSM** (Non-Sucking Service Manager) installed and in PATH

### Steps

1. Copy `service/windows/nginx-proxy-manager.nssm` to `C:\ProgramData\nginx-proxy-manager\`
2. Copy `config\npm.yaml` to `C:\etc\nginx-proxy-manager\npm.yaml`
3. Edit the NSSM config to match your Node.js and application paths
4. Install the service:

```powershell
nssm install nginx-proxy-manager "C:\Program Files\nodejs\node.exe" "C:\lib\nginx-proxy-manager\start.js"
nssm start nginx-proxy-manager
```

## Troubleshooting

### Service fails to start

Check the logs:

```bash
# systemd
journalctl -u nginx-proxy-manager -n 50 --no-pager

# OpenRC/SysVinit
tail -n 50 /var/log/nginx-proxy-manager/npm.log
```

### Port already in use

```bash
sudo ss -tlnp | grep -E ':(80|443|81)\s'
```

### Permission denied

Ensure all files are owned by the correct user:

```bash
sudo chown -R npm:npm /usr/lib/nginx-proxy-manager
sudo chown -R npm:npm /var/lib/nginx-proxy-manager
sudo chown -R npm:npm /var/log/nginx-proxy-manager
```
