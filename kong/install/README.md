# Kong Installation

## Quick Install

```bash
sudo ./install/install.sh
```

## Manual Installation

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | Add repo, `apt install kong` |
| RHEL/CentOS/Fedora | Add repo, `dnf install kong` |

### From Binary

```bash
VERSION="3.6.0"
curl -fsSL "https://download.konghq.com/gateway-${VERSION}.tar.gz" | tar -xz
sudo cp kong /usr/local/bin/
```

### Database Setup

```bash
# PostgreSQL required
sudo -u postgres psql -c "CREATE DATABASE kong;"
sudo -u postgres psql -c "CREATE USER kong WITH PASSWORD 'kong_password';"

# Run migrations
kong migrations up
```

## Post-Installation

```bash
sudo mkdir -p /etc/kong /var/lib/kong /var/log/kong
sudo chown -R kong:kong /etc/kong /var/lib/kong /var/log/kong
sudo cp config/kong.conf /etc/kong/
sudo kong migrations up
sudo systemctl start kong
sudo systemctl enable kong
```

## Uninstall

```bash
sudo ./uninstall/uninstall.sh
```