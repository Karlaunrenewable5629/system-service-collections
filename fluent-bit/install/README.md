# Fluent Bit Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install.sh

# Or manually:
# Debian/Ubuntu
curl -1sLf 'https://packages.fluentbit.fluentd.google.com/fluentbit.key' | sudo gpg --dearmor -o /usr/share/keyrings/fluentbit-stable-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/fluentbit-stable-archive-keyring.gpg] https://packages.fluentbit.fluentd.google.com/debian stable main" | sudo tee /etc/apt/sources.list.d/fluentbit-stable.list
sudo apt update && sudo apt install fluent-bit

# RHEL/CentOS/Fedora
sudo dnf install fluent-bit
```

## Manual Installation

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt install fluent-bit` |
| RHEL/CentOS/Fedora | `dnf install fluent-bit` |
| Arch/Manjaro | `pacman -S fluent-bit` |
| Alpine | `apk add fluent-bit` |

### From Binary

```bash
VERSION="1.9.4"
ARCH="amd64"  # or arm64, armv7
curl -fsSL "https://github.com/fluent/fluent-bit/releases/download/v${VERSION}/fluent-bit-${VERSION}-linux-${ARCH}.tar.gz" | tar -xz
sudo mv fluent-bit/sbin/fluent-bit /usr/local/bin/
```

### Configuration

```bash
sudo cp config/fluent-bit.conf /etc/fluent-bit/
```

### Start Service

```bash
sudo systemctl start fluent-bit
sudo systemctl enable fluent-bit
```

## Verify Installation

```bash
fluent-bit --version
systemctl status fluent-bit
```

## Uninstall

```bash
sudo ./uninstall/uninstall.sh
```