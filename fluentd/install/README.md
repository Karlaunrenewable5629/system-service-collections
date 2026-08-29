# Fluentd Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install.sh

# Or manually:
# Debian/Ubuntu
curl -1sLf 'https://packages.treasuredata.com/GPG-KEY-yum' | sudo gpg --dearmor -o /usr/share/keyrings/treasuredata-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/treasuredata-archive-keyring.gpg] https://packages.treasuredata.com/debian stable-2" | sudo tee /etc/apt/sources.list.d/treasuredata.list
sudo apt update && sudo apt install fluentd

# RHEL/CentOS/Fedora
sudo dnf install fluentd
```

## Manual Installation

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt install fluentd` |
| RHEL/CentOS/Fedora | `dnf install fluentd` |
| Arch/Manjaro | `pacman -S fluentd` |
| Alpine | `apk add fluentd` |

### From Gem

```bash
VERSION="1.17.3"
gem install fluentd -v "${VERSION}" --no-document
fluentd --setup
```

### Configuration

```bash
sudo cp config/fluentd.conf /etc/fluentd/
```

### Start Service

```bash
sudo systemctl start fluentd
sudo systemctl enable fluentd
```

## Verify Installation

```bash
fluentd --version
systemctl status fluentd
```

## Uninstall

```bash
sudo ./uninstall/uninstall.sh
```