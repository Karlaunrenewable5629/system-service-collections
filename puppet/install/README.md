# Puppet Agent Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install/install.sh

# Or manually on Debian/Ubuntu:
curl -1sLf https://apt.puppet.com/puppet6-release.deb | sudo gpg --dearmor -o /usr/share/keyrings/puppet-archive-keyring.gpg
sudo gdebi -i https://apt.puppet.com/puppet6-release.deb
sudo apt update && sudo apt install puppet-agent
```

## Manual Installation

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt install puppet-agent` |
| RHEL/CentOS/Fedora | `dnf copr enable puppet7/puppet && dnf install puppet` |
| Alpine | `apk add puppet` |

### From Binary

```bash
VERSION="8.10.0"
ARCH="amd64"  # or arm64
curl -1sLf https://downloads.puppet.com/yum/el/7/PC1/${ARCH}/puppet-release-${VERSION}-1.el7.no.rpm -o /tmp/puppet.rpm
sudo dnf install /tmp/puppet.rpm
sudo dnf install -y puppet-agent
```

## Post-Installation

1. Configure agent:
```bash
sudo mkdir -p /etc/puppetlabs/puppet /var/lib/puppet /var/log/puppet
sudo chown -R puppet:puppet /etc/puppetlabs/puppet /var/lib/puppet /var/log/puppet
```

2. Edit config:
```bash
sudo nano /etc/puppetlabs/puppet/puppet.conf
# Set: server = your-puppet-master
# Set: runinterval = 1h
```

3. Start service:
```bash
sudo systemctl start puppet
sudo systemctl enable puppet
```

4. Verify connection:
```bash
puppet agent --test
```

## Verify Installation

```bash
puppet --version
systemctl status puppet
```

## Master Installation

For the puppet master, install `puppetserver` package and configure:
```bash
# Add Puppet Labs repo
# Install puppetserver package
# Configure /etc/puppetlabs/puppet/puppet.conf on master
# Start: systemctl start puppetserver
```