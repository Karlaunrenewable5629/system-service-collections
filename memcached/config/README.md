# Memcached Configuration

## memcached.conf

The main configuration file is `memcached.conf`. It uses INI-style format for memcached settings.

### Structure

```ini
# Memory allocation
-m 64  # 64 MB

# Network settings
-l 127.0.0.1  # Listen on localhost
-p 11211  # TCP port
-U 0  # UDP port (disabled)

# Connection limits
-c 1024  # Max connections
-G 64  # GC time

# Performance
-O  # Use raw system calls
-v  # Verbose output
```

### Common Settings

| Setting | Description |
|---------|-------------|
| `-m` | Memory to use (in MB) |
| `-l` | Interface to listen on |
| `-p` | TCP port number |
| `-U` | UDP port number |
| `-maxconns` | Maximum connections |
| `-l` | Listen address |

### File Locations

| System | Config Path |
|--------|-------------|
| Linux | `/etc/memcached.conf` |
| Windows | `C:\memcached\memcached.ini` |

### Reloading/Restarting

```bash
# systemd
systemctl restart memcached

# OpenRC
rc-service memcached restart

# Windows (NSSM)
nssm restart memcached
```