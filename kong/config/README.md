# Kong Configuration

## kong.conf

The main configuration file is `kong.conf` located at `/etc/kong/kong.conf`.

### Database Configuration

```ini
database = postgres
pg_host = localhost
pg_port = 5432
pg_database = kong
pg_user = kong
pg_password = kong_password
```

### Server Configuration

```ini
proxy_listen = 0.0.0.0:8000
proxy_listen_ssl = 0.0.0.0:8443
admin_listen = 0.0.0.0:8001
admin_gui_listen = 0.0.0.0:8002
```

### Plugins

```ini
plugins = bundled
# Or to load specific plugins:
# plugins = cors, key-auth, rate-limiting, jwt
```

### Logging

```ini
log_level = notice
error_tracing = on
```

### Worker Processes

```ini
worker_processes = auto
worker_rlimit_nofile = 65535
```

### Nginx Directives

```ini
nginx_http_custom_lua = /etc/kong/lua/custom.lua
nginx_http_module = modules/ngx_http_lua_module.so
```

### File Locations

| System | Config Path |
|--------|-------------|
| Linux (systemd) | `/etc/kong/kong.conf` |
| Windows | `C:\kong\kong.conf` |

### Environment Variables

Kong also supports environment variable configuration:

```bash
KONG_DATABASE=postgres
KONG_PG_HOST=localhost
KONG_PROXY_LISTEN=0.0.0.0:8000
KONG_ADMIN_LISTEN=0.0.0.0:8001
```

### Database Migrations

```bash
# Run migrations
kong migrations up

# Reset database
kong migrations reset

# Rollback migrations
kong migrations rollback
```

### Resources

- [Kong Configuration Reference](https://docs.konghq.com/gateway/3.x/references/configuration/)
- [Kong Admin API](https://docs.konghq.com/gateway/3.x/references/admin-api/)
- [Kong Plugins](https://docs.konghq.com/hub/)