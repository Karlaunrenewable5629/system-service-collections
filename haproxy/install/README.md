# HAProxy Installation

## Quick Install

```bash
sudo ./install/install.sh
```

## Manual Installation

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt install haproxy` |
| RHEL/CentOS/Fedora | `dnf install haproxy` |
| Arch/Manjaro | `pacman -S haproxy` |
| Alpine | `apk add haproxy` |

### From Source

```bash
VERSION="2.9.7"
TARGET=linux-glibc
make TARGET=$TARGET
sudo cp haproxy /usr/local/bin/
```

### Windows

Download from [HAProxy Website](https://www.haproxy.org/download/) and extract to `C:\haproxy\`.

## Post-Installation

```bash
sudo mkdir -p /etc/haproxy /var/lib/haproxy /var/log/haproxy
sudo chown -R haproxy:haproxy /etc/haproxy /var/lib/haproxy /var/log/haproxy
sudo cp config/haproxy.cfg /etc/haproxy/
sudo systemctl start haproxy
sudo systemctl enable haproxy
```

## Uninstall

```bash
sudo ./uninstall/uninstall.sh
```