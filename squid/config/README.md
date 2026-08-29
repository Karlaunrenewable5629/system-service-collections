# Squid Configuration

## squid.conf

The main configuration file is `squid.conf`. It uses the standard Squid configuration format.

### Structure

```conf
# Basic Squid configuration
http_port 3128 transparent
acl localnet src 192.168.1.0/24
cache_dir ufs /var/spool/squid 100 16 256
cache_mem 256 MB
visible_hostname squid.example.com

# Access control
acl SSL_ports port 443 563
acl Safe_ports port 80 443 21 10-50
http_access allow localnet
http_access deny all

# Logging
cache_log /var/log/squid/cache.log
access_log /var/log/squid/access.log
cache_store_log /var/log/squid/store.log

# Cache options
cache_swap_low 90
cache_swap_high 95
maximum_object_size 0
minimum_object_size 0

# SSL bump (optional)
acl step1 atype ssl_bump
acl step2 atype ssl_bump
acl ssl_ports port 443
ssl_bump none
```

### Common Settings

| Setting | Description |
|---------|-------------|
| `http_port` | Port to listen on (default: 3128) |
| `cache_dir` | Cache directory and size |
| `cache_mem` | Memory used for cache |
| `visible_hostname` | Hostname to report |
| `acl` | Access control lists |
| `http_access` | Access rules |

### Database Setup

Squid does not require a database. Configuration is file-based only.

### File Locations

| System | Config Path | Cache Path | Log Path |
|--------|-------------|------------|----------|
| Linux | `/etc/squid/squid.conf` | `/var/spool/squid` | `/var/log/squid` |

### Reloading/Restarting

```bash
# systemd
systemctl restart squid

# OpenRC
rc-service squid restart

# Windows (NSSM)
nssm restart squid
```