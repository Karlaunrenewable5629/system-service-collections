# Redis Configuration

## redis.conf

The main configuration file is `redis.conf`. It uses a custom format for Redis settings.

### Structure

```conf
# Network settings
bind 127.0.0.1
port 6379

# Logging
loglevel notice
logfile /var/log/redis/redis.log

# Persistence
save 900 1
save 300 10
save 60 10000
dbfilename dump.rdb
dir /var/lib/redis/

# Memory limits
maxmemory 256mb
maxmemory-policy allkeys-lru

# Security
requirepass ""
```

### Common Settings

| Setting | Description |
|---------|-------------|
| `bind` | Interface to listen on (0.0.0.0 for all, 127.0.0.1 for localhost) |
| `port` | TCP port number |
| `timeout` | Client inactivity timeout |
| `loglevel` | Verbosity of logs (debug, verbose, notice, warning) |
| `logfile` | Path to log file |
| `maxmemory` | Maximum memory to use before evicting keys |
| `requirepass` | Password required for authentication |

### Persistence Modes

| Mode | Description |
|------|-------------|
| `RDB` | Point-in-time snapshots (default) |
| `AOF` | Append-only file (log of every write) |
| `Both` | Both RDB and AOF (recommended for durability) |

### File Locations

| System | Config Path |
|--------|-------------|
| Linux | `/etc/redis/redis.conf` |
| Windows | `C:\Redis\redis.conf` |

### Reloading/Restarting

```bash
# systemd
systemctl restart redis-server

# OpenRC
rc-service redis-server restart

# Windows (NSSM)
nssm restart redis
```