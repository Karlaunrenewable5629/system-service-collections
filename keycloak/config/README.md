# Keycloak Configuration

## keycloak.conf

The main configuration file is `keycloak.conf` located at `/etc/keycloak/keycloak.conf`.

Keycloak reads this file at startup via the `--config-file` flag or by placing it in `$KC_HOME/conf/keycloak.conf`.

---

## Database

| Option | Default | Description |
|--------|---------|-------------|
| `db` | `dev-file` | Database vendor: `dev-file`, `dev-mem`, `postgres`, `mysql`, `mariadb`, `mssql`, `oracle` |
| `db-url` | _(auto)_ | Full JDBC URL. Auto-derived from `db-url-host`, `db-url-database`, `db-url-port` if not set |
| `db-url-host` | `localhost` | Hostname of the database server |
| `db-url-database` | `keycloak` | Name of the database |
| `db-url-port` | _(vendor default)_ | Port of the database server |
| `db-username` | — | Username for database authentication |
| `db-password` | — | Password for database authentication |
| `db-pool-initial-size` | `0` | Initial size of the connection pool |
| `db-pool-min-size` | `0` | Minimum number of pooled connections |
| `db-pool-max-size` | `100` | Maximum number of pooled connections |

---

## HTTP / HTTPS

| Option | Default | Description |
|--------|---------|-------------|
| `http-enabled` | `false` | Enable HTTP listener. Set to `true` for development or when TLS is terminated upstream |
| `http-host` | `0.0.0.0` | Bind address for the HTTP listener |
| `http-port` | `8080` | HTTP listener port |
| `https-port` | `8443` | HTTPS listener port |
| `https-certificate-file` | — | Path to the PEM-encoded TLS certificate file |
| `https-certificate-key-file` | — | Path to the PEM-encoded private key file |
| `https-key-store-file` | — | Path to a Java KeyStore (JKS or PKCS12) |
| `https-key-store-password` | — | Password for the KeyStore |
| `https-protocols` | `TLSv1.3,TLSv1.2` | Comma-separated list of allowed TLS protocols |

---

## Hostname

| Option | Default | Description |
|--------|---------|-------------|
| `hostname` | — | Public hostname for the Keycloak server (e.g. `auth.example.com`) |
| `hostname-port` | _(derived)_ | Override the port used in token and redirect URIs |
| `hostname-path` | _(none)_ | Relative path prefix if Keycloak is served under a subpath |
| `hostname-admin` | — | Separate hostname for admin console (optional) |
| `hostname-strict` | `true` | Disallow requests that do not match the configured hostname |
| `hostname-strict-backchannel` | `false` | Apply strict hostname check to backchannel requests |

---

## Proxy

| Option | Default | Description |
|--------|---------|-------------|
| `proxy` | `none` | Proxy mode: `none`, `edge`, `reencrypt`, `passthrough` |
| `proxy-headers` | — | Comma-separated list of forwarded header names to trust (`xforwarded`, `forwarded`) |

---

## Cache

| Option | Default | Description |
|--------|---------|-------------|
| `cache` | `ispn` | Cache type: `ispn` (Infinispan) or `local` |
| `cache-stack` | `udp` | Cluster transport stack: `udp`, `tcp`, `kubernetes`, `ec2`, `azure`, `google` |
| `cache-config-file` | — | Path to a custom Infinispan cache configuration file |

---

## Logging

| Option | Default | Description |
|--------|---------|-------------|
| `log` | `console` | Log handler(s): `console`, `file`, `syslog` (comma-separated) |
| `log-level` | `info` | Log level: `trace`, `debug`, `info`, `warn`, `error`, `fatal` |
| `log-console-output` | `default` | Console format: `default` (plain text) or `json` |
| `log-file` | `data/log/keycloak.log` | Path for the file log handler |
| `log-file-format` | `%d{yyyy-MM-dd HH:mm:ss,SSS} %-5p [%c] (%t) %s%e%n` | File log format string |

---

## Features

| Option | Default | Description |
|--------|---------|-------------|
| `features` | — | Comma-separated list of features to enable (e.g. `token-exchange,scripts`) |
| `features-disabled` | — | Comma-separated list of features to explicitly disable |

---

## Health & Metrics

| Option | Default | Description |
|--------|---------|-------------|
| `health-enabled` | `true` | Enable `/health`, `/health/live`, `/health/ready` endpoints |
| `metrics-enabled` | `false` | Enable `/metrics` endpoint (Prometheus format) |

---

## Clustering

| Option | Default | Description |
|--------|---------|-------------|
| `cluster` | `default` | Cluster mode: `default` (local JVM) or `kubernetes` |
| `cluster-stack` | `udp` | JGroups transport stack used for cluster communication |

---

## File Locations

| System | Config Path |
|--------|-------------|
| Linux (installed) | `/etc/keycloak/keycloak.conf` |
| Linux (standalone) | `$KC_HOME/conf/keycloak.conf` |
| Windows | `C:\keycloak\conf\keycloak.conf` |

---

## Applying Configuration Changes

Keycloak requires a re-build step when certain options (database, HTTP, features) are changed:

```bash
# Re-optimize after changing build-time options
sudo -u keycloak /opt/keycloak/bin/kc.sh build

# Then restart the service
sudo systemctl restart keycloak
```

For runtime-only options (log level, hostname), a plain service restart is sufficient:

```bash
sudo systemctl restart keycloak
```

---

## Environment Variable Overrides

Any option in `keycloak.conf` can be overridden via environment variables using the `KC_` prefix with uppercase and underscores:

```bash
KC_DB=postgres
KC_DB_URL_HOST=db.example.com
KC_HTTP_PORT=8080
KC_HOSTNAME=auth.example.com
```

---

## Resources

- [Keycloak Configuration Guide](https://www.keycloak.org/server/configuration)
- [All Configuration Options](https://www.keycloak.org/server/all-config)
- [Production Hardening](https://www.keycloak.org/server/configuration-production)
