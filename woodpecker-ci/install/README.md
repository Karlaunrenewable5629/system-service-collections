# Woodpecker CI Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install/install.sh

# Or manually on Debian/Ubuntu:
curl -fsSL https://download.woodpecker-ci.org/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/woodpecker-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/woodpecker-keyring.gpg] https://download.woodpecker-ci.org/apt stable/ | sudo tee /etc/apt/sources.list.d/woodpecker.list"
sudo apt update && sudo apt install woodpecker-ci
```

## Manual Installation

### From Binary

```bash
VERSION="2.24.0"
ARCH="amd64"  # or arm64
curl -fsSL "https://github.com/woodpecker-ci/woodpecker/releases/download/v${VERSION}/woodpecker-${VERSION}-linux-${ARCH}.tar.gz" | tar -xz
sudo mv woodpecker /usr/local/bin/
```

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt install woodpecker-ci` |
| RHEL/CentOS/Fedora | `dnf copr enable woodpecker/woodpecker && dnf install woodpecker-ci` |

## Post-Installation

1. Create config directory:
```bash
sudo mkdir -p /etc/woodpecker /var/lib/woodpecker /var/log/woodpecker
sudo chown -R woodpecker:woodpecker /etc/woodpecker /var/lib/woodpecker /var/log/woodpecker
```

2. Create woodpecker.yml config:
```bash
sudo cp config/woodpecker.yml /etc/woodpecker/
```

3. Start service:
```bash
sudo systemctl start woodpecker
sudo systemctl enable woodpecker
```

4. Access Woodpecker at `http://localhost`

## Verify Installation

```bash
woodpecker --version
systemctl status woodpecker
```