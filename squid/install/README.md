# Squidge Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install/install.sh

# Or manually:
# 1. Download from https://www.squid-cache.org/
# 2. Install package manager
# 3. Copy config to /etc/squid/squid.conf
# 4. Initialize cache: squid -z
# 5. Start: systemctl start squid
```

## Manual Installation

### From Package

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt-get install squid` |
| RHEL/CentOS/Fedora | `dnf install squid` |
| Alpine | `apk add squid` |

### From Source

```bash
# Download latest version
wget https://www.squid-cache.org/Versions/v6/squid-6.5.tar.gz
tar -xzf squid-6.5.tar.gz
cd squid-6.5

# Configure
./configure --prefix=/usr/local/sbin \
    --enable-arp-acl \
    --enable-delay-pools \
    --with-ssl

# Build and install
make
make install

# Create directories
mkdir -p /etc/squid /var/spool/squid /var/log/squid
chown proxy:proxy /var/spool/squid /var/log/squid
```

### Prerequisites

1. **Disk space** - At least 1GB for cache
2. **Memory** - Recommended 256MB minimum
3. **Permissions** - Write access to `/var/spool/squid` and `/var/log/squid`

### Post-Installation

1. **Configure squid**:
   ```bash
   sudo nano /etc/squid/squid.conf
   ```

2. **Initialize cache**:
   ```bash
   sudo squid -z
   ```

3. **Start service**:
   ```bash
   sudo systemctl start squid
   sudo systemctl enable squid
   ```

4. **Verify running**:
   ```bash
   systemctl status squid
   # Or: ps aux | grep squid
   ```

### Verify Installation

```bash
# Check version
squid --version

# Test connectivity
curl -x http://localhost:3128 http://example.com

# Check cache
sudo squid -k reconfigure
```

## Configuration

See [config/README.md](config/README.md) for squid configuration options.

## Service Management

See [service/README.md](service/README.md) for service management across different init systems.

## Installation Guide

See [install/README.md](install/README.md) for detailed installation instructions.

## Uninstallation

See [uninstall/README.md](uninstall/README.md) for removal instructions.

## Resources

- [Squid Documentation](https://www.squid-cache.org/Doc/)
- [Squid Wiki](https://wiki.squid-cache.org/)
- [Squid Community](https://www.squid-cache.org/Features/)