# Chef Client Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install/install.sh

# Or using Chef Omnitruck:
curl -1sLf https://omnitruck.chef.sh/install.sh | sudo bash -s -- -v 17.0
```

## Manual Installation

### From Omnitruck

```bash
# Install specific version
VERSION="17.0"
ARCH="amd64"
curl -1sLf https://omnitruck.chef.sh/install.sh | sudo bash -s -- -v ${VERSION}
```

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt install chef` (via Chef repo) |
| RHEL/CentOS/Fedora | `dnf copr enable chef/stable && dnf install chef` |

## Post-Installation

1. Configure client:
```bash
sudo mkdir -p /etc/chef /var/cache/chef /var/log/chef
sudo chown -R chef:chef /etc/chef /var/cache/chef /var/log/chef
```

2. Create client key:
```bash
# Generate or obtain your client.pem
sudo cp client.pem /etc/chef/client.pem
```

3. Set server URL:
```bash
sudo nano /etc/chef/client.rb
# Set: server_url "https://api.chef.io/organizations/myorg"
```

4. Start service:
```bash
sudo systemctl start chef-client
sudo systemctl enable chef-client
```

## Verify Installation

```bash
chef-client --version
systemctl status chef-client
```

## Run Chef Client Manually

```bash
sudo chef-client
# Or with specific runlist
sudo chef-client -r 'recipe[apache],recipe[nginx]'
```