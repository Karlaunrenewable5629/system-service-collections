# Salt Minion Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install/install.sh

# Or manually on Debian/Ubuntu:
curl -fsSL https://repo.saltstack.com/apt/debian/$(lsb_release -rs)/saltstack-2023.key | sudo gpg --dearmor -o /usr/share/keyrings/salt-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg] https://repo.saltstack.com/apt/debian/$(lsb_release -rs) saltstack-2023/ | sudo tee /etc/apt/sources.list.d/salt.list"
sudo apt update && sudo apt install salt-minion
```

## Manual Installation

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt install salt-minion` |
| RHEL/CentOS/Fedora | `dnf copr enable saltstack/salt && dnf install salt-minion` |
| Alpine | `apk add salt-minion` |

### From Binary

```bash
VERSION="3005.3"
ARCH="amd64"  # or arm64
curl -fsSL "https://repo.saltstack.com/yum/el7/x86_64/salt-minion-${VERSION}-1.el7.centos.${ARCH}.rpm" -o /tmp/salt-minion.rpm
sudo dnf install /tmp/salt-minion.rpm
```

## Post-Installation

1. Configure minion:
```bash
sudo mkdir -p /etc/salt /var/cache/salt /var/log/salt
sudo chown -R salt:salt /etc/salt /var/cache/salt /var/log/salt
```

2. Edit config:
```bash
sudo nano /etc/salt/minion
# Set: master: your-master-hostname
```

3. Start service:
```bash
sudo systemctl start salt-minion
sudo systemctl enable salt-minion
```

4. Verify connection:
```bash
salt-key -L  # List connected minions
```

## Verify Installation

```bash
salt-minion --version
systemctl status salt-minion
```