# Cloudflare Tunnel Configuration

## config.yml

The main configuration file is `config.yml`. It uses YAML format for Cloudflare cloudflared settings.

### Structure

```yaml
tunnel: "<tunnel-id>"
credentials-file: "/root/.cloudflared/<tunnel-id>.json"

ingress:
  - service: http://localhost:8080
    autodns: true
  - service: http://localhost:3000 when/hostname "app.example.com"
    autodns: false
  - service: http_status:404

ingress_rules:
  - identifier: "cloudflare-domain-matching"
    action: "route"
    domain: "example.com"
    edge_certiface: "ssl"
  - identifier: "cloudflare-domain-wildcard"
    action: "route"
    domain: "*.example.com"
    edge_certiface: "ssl"
  - identifier: "bypass"
    action: "bypass"

policy:
  issuers:
    - name: "Cloudflare Origin CA"
      type: "origin_ca"
  certificates:
    - dns_challenge:
        proxy: true
      domain: "example.com"

metrics: true
logfile: "/var/log/cloudflared.log"
edgeport: 2000
```

### Common Settings

| Setting | Description |
|---------|-------------|
| `tunnel` | Your Cloudflare tunnel ID |
| `credentials-file` | Path to tunnel credentials JSON |
| `ingress` | Define services and routing rules |
| `ingress_rules` | Advanced domain matching and routing |
| `policy` | Certificate issuers and policies |
| `metrics` | Enable metrics endpoint |
| `logfile` | Path to log file |
| `edgeport` | Port for Cloudflare edge connection |

### TLS Certificates

- **Cloudflare Origin CA** - Auto-generated certificates
- **Self-managed** - Your own certificates via DNS challenge
- **Full mode** - Cloudflare manages all TLS

### File Locations

| System | Config Path |
|--------|-------------|
| Linux | `/etc/cloudflared/config.yml` |
| Windows | `C:\cloudflared\config.yml` |

### Reloading/Restarting

```bash
# systemd
systemctl restart cloudflared

# OpenRC
rc-service cloudflared restart

# Windows (NSSM)
nssm restart cloudflared
```