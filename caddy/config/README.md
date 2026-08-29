# Caddy Configuration

## Caddyfile

The main configuration file is `Caddyfile`. It uses Caddy's human-readable configuration format.

### Structure

```
{
    # Global options
}

# Site configurations
example.com {
    # Site-specific directives
}
```

### Common Directives

| Directive | Description |
|-----------|-------------|
| `root` | Set document root |
| `file_server` | Enable static file serving |
| `reverse_proxy` | Proxy requests to upstream |
| `respond` | Return static response |
| `header` | Manipulate HTTP headers |
| `encode` | Enable compression |
| `log` | Configure access logging |
| `tls` | Configure TLS/SSL |

### Environment Variables

Caddy supports environment variable expansion:

```caddyfile
reverse_proxy {$UPSTREAM_HOST}:{$UPSTREAM_PORT}
```

### File Locations

| System | Config Path |
|--------|-------------|
| Linux (systemd) | `/etc/caddy/Caddyfile` |
| Windows | `C:\caddy\Caddyfile` |

### Reloading Configuration

```bash
# systemd
systemctl reload caddy

# OpenRC
rc-service caddy reload

# Windows (NSSM)
nssm restart caddy
```

### Resources

- [Caddyfile Documentation](https://caddyserver.com/docs/caddyfile)
- [Directives Reference](https://caddyserver.com/docs/caddyfile/directives)
- [JSON Config](https://caddyserver.com/docs/json)