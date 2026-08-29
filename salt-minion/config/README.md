# Salt Minion Configuration

## minion config file

The main configuration file is `minion`. It uses INI-style format for salt minion settings.

### Structure

```ini
# Master configuration
master: salt

# Interface configuration
interface: 0.0.0.0
disable_ring: True

# Keepalive configuration
keepalive_interval: 30
keepalive_max_retries: 3

# Cache configuration
cache: file
compression: zlib

# Log configuration
log_level: info
log_file: /var/log/salt/minion

# Root directory
root_dir: /etc/salt
```

### Common Settings

| Setting | Description |
|---------|-------------|
| `master` | Salt master address |
| `master_port` | Connection port (4505) |
| `id` | Minion ID (defaults to hostname) |
| `log_level` | Logging verbosity (info, debug, trace) |
| `log_file` | Path to log file |
| `cache` | Cache backend (file, memory, redis) |

### File Locations

| System | Config Path |
|--------|-------------|
| Linux | `/etc/salt/minion` |
| Windows | `C:\salt\minion.conf` |

### Reloading Configuration

```bash
# systemd
systemctl restart salt-minion

# OpenRC
rc-service salt-minion restart

# Windows (NSSM)
nssm restart salt-minion
```