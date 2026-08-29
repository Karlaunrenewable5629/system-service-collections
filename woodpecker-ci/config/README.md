# Woodpecker CI Configuration

## woodpecker.yml

The main configuration file is `woodpecker.yml`. It uses YAML format for server, database, and runner settings.

### Structure

```yaml
server:
  addr: ":80"
  domain: "ci.example.com"

database:
  driver: "postgres"
  source: "postgres://user:password@localhost:5432/woodpecker?sslmode=disable"

runner:
  type: "ssh"
  ssh:
    addr: "localhost:3000"
```

### Server Options

| Option | Description | Default |
|--------|-------------|---------|
| `addr` | Web server address | `:80` |
| `domain` | Server domain | - |
| `tls` | HTTPS/TLS configuration | - |

### Database Options

| Driver | Description |
|--------|-------------|
| `postgres` | PostgreSQL connection string |
| `sqlite3` | SQLite database file path |

### Runner Options

| Runner | Description |
|--------|-------------|
| `ssh` | SSH-based job execution |
| `docker` | Docker container execution |

### File Locations

| System | Config Path |
|--------|-------------|
| Linux (systemd) | `/etc/woodpecker/woodpecker.yml` |
| Windows | `C:\woodpecker\woodpecker.yml` |

### Reloading Configuration

```bash
# systemd
systemctl restart woodpecker

# OpenRC
rc-service woodpecker restart

# Windows (NSSM)
nssm restart woodpecker
```