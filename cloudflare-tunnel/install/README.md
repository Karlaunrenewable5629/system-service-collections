# Cloudflare Tunnel Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install/install.sh

# Or manually:
# 1. Download from https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/cloudflared/
# 2. Install using package manager or download binary
# 3. Authenticate: cloudflared tunnel login
# 4. Create tunnel: cloudflared tunnel create <name>
# 5. Start service: systemctl start cloudflared
```

## Manual Installation

### From Package (Ubuntu/Debian)

```bash
curl -fsSL https://pkg.cloudflare.com/cloudflared-stable-amd64.deb -o /tmp/cloudflared.deb
sudo dpkg -i /tmp/cloudflared.deb
```

### From Package (RHEL/CentOS/Fedora)

```bash
curl -fsSL https://pkg.cloudflare.com/cloudflared-stable-amd64.rpm -o /tmp/cloudflared.rpm
sudo dnf install /tmp/cloudflared.rpm
```

### From Binary (All platforms)

```bash
# Linux amd64
wget https://.cloudflare.com/cloudflare-1.3.0/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared

# Linux arm64
wget https://.cloudflare.com/cloudflare-1.3.0/cloudflared-linux-arm64 -O /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared

# macOS
brew install cloudflared
```

### Post-Installation

1. **Authenticate**:
   ```bash
   cloudflared tunnel login
   ```

2. **Create tunnel**:
   ```bash
   cloudflared tunnel create <tunnel-name>
   ```

3. **Configure tunnel**:
   ```bash
   # Route to local service
   cloudflared tunnel route dns <tunnel-name> <domain>
   
   # Or route to URL
   cloudflared tunnel route url <tunnel-name> http://localhost:8080
   ```

4. **Start service**:
   ```bash
   # systemd
   sudo systemctl start cloudflared
   sudo systemctl enable cloudflared
   
   # OpenRC
   sudo rc-service cloudflared start
   sudo rc-update add cloudflared default
   
   # SysVinit
   sudo service cloudflared start
   sudo update-rc.d cloudflared defaults
   ```

### Verify Installation

```bash
# Check version
cloudflared --version

# Check status
systemctl status cloudflared

# Test tunnel
curl -I https://<tunnel-name>.cfargotunnel.com
```

## Configuration

See [config/README.md](config/README.md) for cloudflared configuration options.

## Service Management

See [service/README.md](service/README.md) for service management across different init systems.

## Resources

- [cloudflared GitHub Releases](https://github.com/cloudflare/cloudflared/releases)
- [Cloudflare Tunnel Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/cloudflared/)
- [Cloudflare Zero Trust](https://developers.cloudflare.com/cloudflare-one/)