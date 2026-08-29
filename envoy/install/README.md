# Envoy Installation

## Quick Install

```bash
sudo ./install/install.sh
```

## Manual Installation

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | Add repository and `apt install envoy` |
| RHEL/CentOS/Fedora | Add repository and `dnf install envoy` |

### From Binary

```bash
# Download latest release
VERSION="1.30.0"
ARCH="amd64"  # or arm64
curl -fsSL "https://github.com/envoyproxy/envoy/releases/download/v${VERSION}/envoy-v${VERSION}-linux-${ARCH}.tar.xz" | tar -xJ
sudo mv envoy /usr/local/bin/
```

### Windows

Download from [GitHub Releases](https://github.com/envoyproxy/envoy/releases) and extract to `C:\envoy\`.

## Post-Installation

1. Create configuration directory:
```bash
sudo mkdir -p /etc/envoy /var/lib/envoy /var/log/envoy
sudo chown -R envoy:envoy /etc/envoy /var/lib/envoy /var/log/envoy
```

2. Create configuration:
```bash
sudo cp config/envoy.yaml /etc/envoy/
```

3. Start service:
```bash
sudo systemctl start envoy
sudo systemctl enable envoy
```

## Verify Installation

```bash
envoy --version
systemctl status envoy
curl http://localhost:19000/stats
```

## Uninstall

```bash
sudo ./uninstall/uninstall.sh
```