# Configuration

This directory contains the configuration files for nginx-proxy-manager.

## Files

- `npm.yaml` — Main runtime configuration file

## Configuration Locations

nginx-proxy-manager reads configuration from the following locations in order of priority:

1. `/etc/nginx-proxy-manager/npm.yaml` — System-wide configuration (recommended)
2. `/lib/nginx-proxy-manager/config/default.json` — Built-in defaults

## Configuration Options

### Database

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `db.type` | string | `sqlite` | Database type: `sqlite`, `postgresql`, or `mysql` |
| `db.filename` | string | `/var/lib/nginx-proxy-manager/npm.db` | Path to SQLite database file |
| `db.host` | string | `localhost` | Database host for PostgreSQL/MySQL |
| `db.port` | integer | `5432` / `3306` | Database port |
| `db.name` | string | `nginx_proxy_manager` | Database name |
| `db.user` | string | `npm` | Database user |
| `db.password` | string | — | Database password |

### Server Ports

| Port | Purpose |
|------|---------|
| `80` | HTTP proxy (default) |
| `443` | HTTPS proxy (default) |
| `81` | Admin UI (default) |

### SSL / Let's Encrypt

- Enable automatic certificate provisioning via `ssl.letsencrypt.enabled`
- Set `ssl.letsencrypt.staging: true` to use the Let's Encrypt staging environment for testing
- HTTP-01 challenge type is used by default

### User/Group

The service runs under the `npm:npm` user and group by default. On Debian/Ubuntu systems, `www-data:www-data` can be used instead.

## Applying Changes

After modifying the configuration file, restart the service:

```bash
# systemd
sudo systemctl restart nginx-proxy-manager

# OpenRC
sudo rc-service nginx-proxy-manager restart

# SysVinit
sudo service nginx-proxy-manager restart
```

## Example: PostgreSQL Configuration

```yaml
db:
  type: postgresql
  host: localhost
  port: 5432
  dbname: nginx_proxy_manager
  user: npm
  password: your-secure-password
```

## Example: Custom Ports

```yaml
server:
  http_port: 8080
  https_port: 8443
  admin_port: 8181
```
