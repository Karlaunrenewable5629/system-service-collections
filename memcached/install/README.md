# Memcached Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install/install.sh

# Or manually on Debian/Ubuntu:
sudo apt update
sudo apt install memcached

# Or manually on RHEL/CentOS/Fedora:
sudo dnf install epel-release
sudo dnf install memcached
```

## Manual Installation

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt install memcached` |
| RHEL/CentOS/Fedora | `dnf install epel-release && dnf install memcached` |
| Alpine | `apk add memcached` |

### From Binary

```bash
VERSION="1.6.17"
ARCH="amd64"  # or arm64
curl -fsSL "https://memcached.org/files/${VERSION}/memcached-${VERSION}.tar.gz" | tar -xz
cd memcached-${VERSION}
./configure --prefix=/usr/local/bin/memcached
make -j$(nproc)
sudo make install
```

## Post-Installation

1. Configure memcached:
```bash
sudo mkdir -p /var/lib/memcached /var/log/memcached /etc/memcached
sudo chown -R memcached:memcached /var/lib/memcached /var/log/memcached /etc/memcached
```

2. Edit config:
```bash
sudo nano /etc/memcached.conf
# Set: -m 256 (memory in MB)
# Set: -p 11211 (port)
# Set: -l 127.0.0.1 (interface)
```

3. Start service:
```bash
sudo systemctl start memcached
sudo systemctl enable memcached
```

4. Verify connection:
```bash
echo "test" | nc localhost 11211
memc-tool set test 0 0 4
test
```
```

## Verify Installation

```bash
memcached --version
systemctl status memcached
```