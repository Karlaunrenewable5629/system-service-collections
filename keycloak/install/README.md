# Keycloak Installation

## Quick Install

```bash
# Linux (systemd) — run as root or with sudo
sudo ./install/install.sh
```

The script downloads Keycloak, creates a dedicated service user, sets up directories, copies configuration, and installs the systemd unit.

---

## Requirements

- Java 17 or later (OpenJDK recommended)
- A supported database (PostgreSQL recommended for production)
- 512 MB RAM minimum; 2 GB+ recommended for production

---

## Manual Installation

### 1. Install Java

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt install -y openjdk-21-jre-headless` |
| RHEL/CentOS/Fedora | `dnf install -y java-21-openjdk-headless` |
| Alpine | `apk add --no-cache openjdk21-jre-headless` |

Verify:

```bash
java -version
```

### 2. Download Keycloak

```bash
VERSION="25.0.6"
curl -fsSL "https://github.com/keycloak/keycloak/releases/download/${VERSION}/keycloak-${VERSION}.tar.gz" \
    -o /tmp/keycloak.tar.gz
```

### 3. Extract and Place

```bash
tar -xzf /tmp/keycloak.tar.gz -C /opt
ln -sfn /opt/keycloak-${VERSION} /opt/keycloak
```

### 4. Create Service User

```bash
useradd --system --no-create-home --shell /usr/sbin/nologin keycloak
```

### 5. Set Up Directories

```bash
mkdir -p /etc/keycloak /var/log/keycloak /opt/keycloak/data
chown -R keycloak:keycloak /opt/keycloak /etc/keycloak /var/log/keycloak
chmod 750 /etc/keycloak /var/log/keycloak
```

### 6. Configure

```bash
cp config/keycloak.conf /etc/keycloak/keycloak.conf
# Edit the file with your database credentials and hostname
nano /etc/keycloak/keycloak.conf
```

### 7. Link Configuration

```bash
ln -sfn /etc/keycloak/keycloak.conf /opt/keycloak/conf/keycloak.conf
```

### 8. Build Optimized Image

Run the build step once to apply all build-time options (database, features, HTTP):

```bash
sudo -u keycloak /opt/keycloak/bin/kc.sh build
```

### 9. Install Service (systemd)

```bash
cp service/systemd/keycloak.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable keycloak
systemctl start keycloak
```

---

## Post-Installation

### Create Initial Admin User

Set credentials via environment variables before first start, or use the bootstrap script:

```bash
sudo -u keycloak KEYCLOAK_ADMIN=admin KEYCLOAK_ADMIN_PASSWORD=change_me \
    /opt/keycloak/bin/kc.sh start --optimized
```

Or export them in `/etc/keycloak/keycloak.env` and reference from the service file.

### Verify Service

```bash
# Check service status
systemctl status keycloak

# Follow logs
journalctl -u keycloak -f

# Health endpoints (after startup)
curl http://localhost:8080/health
curl http://localhost:8080/health/ready
```

### Access the Admin Console

Open your browser and navigate to:

```
http://localhost:8080/admin
```

Or with a configured hostname:

```
https://auth.example.com/admin
```

---

## Database Setup (PostgreSQL)

```sql
CREATE USER keycloak WITH PASSWORD 'change_me';
CREATE DATABASE keycloak OWNER keycloak;
GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;
```

Update `keycloak.conf`:

```
db=postgres
db-url-host=localhost
db-url-database=keycloak
db-username=keycloak
db-password=change_me
```

---

## Upgrade

```bash
# Download new version
VERSION="26.0.0"
curl -fsSL "https://github.com/keycloak/keycloak/releases/download/${VERSION}/keycloak-${VERSION}.tar.gz" \
    -o /tmp/keycloak.tar.gz

# Stop service
systemctl stop keycloak

# Extract and update symlink
tar -xzf /tmp/keycloak.tar.gz -C /opt
ln -sfn /opt/keycloak-${VERSION} /opt/keycloak

# Fix ownership
chown -R keycloak:keycloak /opt/keycloak

# Re-link config
ln -sfn /etc/keycloak/keycloak.conf /opt/keycloak/conf/keycloak.conf

# Rebuild and start
sudo -u keycloak /opt/keycloak/bin/kc.sh build
systemctl start keycloak
```

---

## Uninstall

```bash
sudo ./uninstall/uninstall.sh
```

---

## Resources

- [Keycloak Downloads](https://www.keycloak.org/downloads)
- [Server Installation Guide](https://www.keycloak.org/guides#server)
- [Getting Started](https://www.keycloak.org/guides#getting-started)
- [Production Deployment](https://www.keycloak.org/server/configuration-production)
