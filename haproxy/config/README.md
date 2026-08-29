# HAProxy Configuration

## haproxy.cfg

The main configuration file is `haproxy.cfg` located at `/etc/haproxy/haproxy.cfg`.

### Structure

HAProxy configuration has two main sections:

1. **global** - Process-wide settings (logging, user, limits)
2. **defaults** - Default settings for all proxies
3. **frontend** - Defines how incoming traffic is received
4. **backend** - Defines where traffic is sent
5. **listen** - Combines frontend and backend

### Global Section

| Parameter | Description |
|-----------|-------------|
| `log` | Syslog facility |
| `chroot` | Change root directory |
| `stats socket` | Enable stats socket |
| `user/group` | Run as specified user/group |
| `ssl-default-bind-ciphers` | Default cipher suites |

### Frontend

```haproxy
frontend http_front
    bind *:80
    bind *:443 ssl crt /etc/haproxy/certs/default.pem
    default_backend http_back
```

### Backend

```haproxy
backend http_back
    balance roundrobin
    server app1 127.0.0.1:8080 check
    server app2 127.0.0.1:8081 check backup
```

### Load Balancing Algorithms

| Algorithm | Description |
|-----------|-------------|
| `roundrobin` | Round-robin distribution |
| `leastconn` | Least connections |
| `source` | Source IP hash |
| `uri` | URI hash |
| `hdr` | Header value hash |

### Health Checks

```haproxy
option httpchk GET /health
server app1 127.0.0.1:8080 check inter 2000 rise 2 fall 3
```

### Stats Dashboard

```haproxy
listen stats
    bind *:8404
    stats enable
    stats uri /
    stats refresh 10s
    stats admin if TRUE
```

### File Locations

| System | Config Path |
|--------|-------------|
| Linux (systemd) | `/etc/haproxy/haproxy.cfg` |
| Windows | `C:\haproxy\haproxy.cfg` |

### Reload Configuration

```bash
# Via stats socket
echo "reload" | sudo socat stdio /run/haproxy/admin.sock

# Or
sudo systemctl reload haproxy
```

### Resources

- [Configuration Manual](https://cbonte.github.io/haproxy-dconv/)
- [HAProxy Website](https://www.haproxy.org/)
- [Management Guide](https://www.haproxy.org/download/2.9/doc/management.txt)