# Redis Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install/install.sh

# Or manually on Debian/Ubuntu:
curl -fsSL https://download.redis.io/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/debian focal main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt update && sudo apt install redis
```

## Manual Installation

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt install redis` (via Redis repo) |
| RHEL/CentOS/Fedora | `dnf copr enable redis/stable && dnf install redis` |
| Alpine | `apk add redis` |

### From Binary

```bash
VERSION="7.0.5"
ARCH="amd64"  # or arm64
curl -fsSL "https://download.redis.io/releases/redis-${VERSION}.tar.gz" -o /tmp/redis.tar.gz
tar -xzf /tmp/redis.tar.gz -C /tmp redis-${VERSION}
cd /tmp/redis-${VERSION}
make -j$(nproc)
sudo make install
```

## Post-Installation

1. Configure Redis:
```bash
sudo mkdir -p /var/lib/redis /var/log/redis /etc/redis
sudo chown -R redis:redis /var/lib/redis /var/log/redis /etc/redis
```

2. Edit config:
```bash
sudo nano /etc/redis/redis.conf
# Set: bind 0.0.0.0 (listen on all interfaces)
# Set: port 6379 (TCP port)
# Set: requirepass yourpassword (require authentication)
# Set: maxmemory 256mb (memory limit)
```

3. Start service:
```bash
sudo systemctl start redis
sudo systemctl enable redis
```

4. Verify connection:
```bash
redis-cli ping
redis-cli set test "hello"
redis-cli get test
```
```

## Verify Installation

```bash
redis-server --version
systemctl status redis
```