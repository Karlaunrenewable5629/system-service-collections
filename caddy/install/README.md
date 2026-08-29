# Caddy Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install.sh

# Or manually:
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy
```

## Manual Installation

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt install caddy` |
| RHEL/CentOS/Fedora | `dnf copr enable @caddy/caddy && dnf install caddy` |
| Arch/Manjaro | `pacman -S caddy` |
| Alpine | `apk add caddy` |

### From Binary

```bash
# Download latest release
VERSION="2.8.4"
ARCH="amd64"  # or arm64, armv7
curl -fsSL "https://github.com/caddyserver/caddy/releases/download/v${VERSION}/caddy_${VERSION}_linux_${ARCH}.tar.gz" | tar -xz caddy
sudo mv caddy /usr/local/bin/
```

### Windows

Download from [GitHub Releases](https://github.com/caddyserver/caddy/releases) and extract to `C:\caddy\`.

## Post-Installation

1. Create config directory:
```bash
sudo mkdir -p /etc/caddy /var/lib/caddy /var/log/caddy
sudo chown -R caddy:caddy /etc/caddy /var/lib/caddy /var/log/caddy
```

2. Create Caddyfile:
```bash
sudo cp config/Caddyfile /etc/caddy/
```

3. Start service:
```bash
sudo systemctl start caddy
sudo systemctl enable caddy
```

## Verify Installation

```bash
caddy version
systemctl status caddy
curl http://localhost
```

## Uninstall

```bash
sudo ./uninstall/uninstall.sh
```