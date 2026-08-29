# Authentik Configuration

This directory contains configuration templates for Authentik. Copy `.env` to your deployment location and customize the values before starting the service.

## Configuration File

Authentik is configured primarily through environment variables. The `.env` file in this directory serves as a template. On Linux, copy it to `/etc/authentik/.env`. On Windows, copy it to `C:\authentik\.env`.

## Environment Variables

### Core Settings

| Variable | Default | Description |
|---|---|---|
| `AUTHENTIK_SECRET_KEY` | *(required)* | Django secret key. Must be a long random string. Never reuse across environments. |
| `AUTHENTIK_ERROR_REPORTING__ENABLED` | `false` | Send anonymous error reports to Sentry (goauthentik.io). |
| `AUTHENTIK_DISABLE_UPDATE_CHECK` | `false` | Disable automatic version update checks. |
| `AUTHENTIK_DISABLE_STARTUP_ANALYTICS` | `true` | Disable startup analytics reporting. |
| `AUTHENTIK_AVATARS` | `gravatar,initials` | Avatar sources. Options: `gravatar`, `initials`, `none`, or a custom URL. |
| `AUTHENTIK_DEFAULT_USER_CHANGE_NAME` | `true` | Allow users to change their own display name. |
| `AUTHENTIK_DEFAULT_USER_CHANGE_EMAIL` | `false` | Allow users to change their own email address. |
| `AUTHENTIK_DEFAULT_USER_CHANGE_USERNAME` | `false` | Allow users to change their own username. |
| `AUTHENTIK_GDPR_COMPLIANCE` | `true` | Enable GDPR compliance mode (hides IP addresses in logs). |
| `AUTHENTIK_DEFAULT_TOKEN_LENGTH` | `60` | Default length for generated tokens. |
| `AUTHENTIK_IMPERSONATION` | `true` | Allow superusers to impersonate other users. |
| `AUTHENTIK_FOOTER_LINKS` | *(empty)* | JSON array of additional footer links. |

### HTTP / Listen Settings

| Variable | Default | Description |
|---|---|---|
| `AUTHENTIK_LISTEN__HTTP` | `0.0.0.0:9000` | HTTP listen address for the Authentik server. |
| `AUTHENTIK_LISTEN__HTTPS` | `0.0.0.0:9443` | HTTPS listen address for the Authentik server. |
| `AUTHENTIK_LISTEN__LDAP` | `0.0.0.0:3389` | LDAP listen address (if LDAP outpost is embedded). |
| `AUTHENTIK_LISTEN__LDAPS` | `0.0.0.0:6636` | LDAPS listen address (if LDAP outpost is embedded). |
| `AUTHENTIK_LISTEN__METRICS` | `0.0.0.0:9300` | Prometheus metrics endpoint address. |
| `AUTHENTIK_LISTEN__DEBUG` | `0.0.0.0:9900` | Debug/pprof endpoint address (disable in production). |

### PostgreSQL Settings

| Variable | Default | Description |
|---|---|---|
| `AUTHENTIK_POSTGRESQL__HOST` | `localhost` | PostgreSQL server hostname or IP address. |
| `AUTHENTIK_POSTGRESQL__PORT` | `5432` | PostgreSQL server port. |
| `AUTHENTIK_POSTGRESQL__NAME` | `authentik` | PostgreSQL database name. |
| `AUTHENTIK_POSTGRESQL__USER` | `authentik` | PostgreSQL user for authentication. |
| `AUTHENTIK_POSTGRESQL__PASSWORD` | *(required)* | PostgreSQL password for authentication. |
| `AUTHENTIK_POSTGRESQL__SSLMODE` | `prefer` | SSL mode: `disable`, `allow`, `prefer`, `require`, `verify-ca`, `verify-full`. |
| `AUTHENTIK_POSTGRESQL__SSLROOTCERT` | *(empty)* | Path to SSL root certificate file. |
| `AUTHENTIK_POSTGRESQL__SSLCERT` | *(empty)* | Path to SSL client certificate. |
| `AUTHENTIK_POSTGRESQL__SSLKEY` | *(empty)* | Path to SSL client key. |

### Redis Settings

| Variable | Default | Description |
|---|---|---|
| `AUTHENTIK_REDIS__HOST` | `localhost` | Redis server hostname or IP address. |
| `AUTHENTIK_REDIS__PORT` | `6379` | Redis server port. |
| `AUTHENTIK_REDIS__DB` | `0` | Redis database index. |
| `AUTHENTIK_REDIS__PASSWORD` | *(empty)* | Redis password (if AUTH is enabled). |
| `AUTHENTIK_REDIS__TLS` | `false` | Enable TLS for Redis connection. |
| `AUTHENTIK_REDIS__TLS_REQS` | `none` | TLS requirements: `none`, `optional`, `required`. |

### Email Settings

| Variable | Default | Description |
|---|---|---|
| `AUTHENTIK_EMAIL__HOST` | `localhost` | SMTP server hostname. |
| `AUTHENTIK_EMAIL__PORT` | `25` | SMTP server port. |
| `AUTHENTIK_EMAIL__USERNAME` | *(empty)* | SMTP authentication username. |
| `AUTHENTIK_EMAIL__PASSWORD` | *(empty)* | SMTP authentication password. |
| `AUTHENTIK_EMAIL__USE_TLS` | `false` | Use STARTTLS for SMTP connection. |
| `AUTHENTIK_EMAIL__USE_SSL` | `false` | Use SSL/TLS (implicit TLS) for SMTP connection. |
| `AUTHENTIK_EMAIL__TIMEOUT` | `10` | SMTP connection timeout in seconds. |
| `AUTHENTIK_EMAIL__FROM` | `authentik@localhost` | From address for outbound emails. |

### Logging Settings

| Variable | Default | Description |
|---|---|---|
| `AUTHENTIK_LOG_LEVEL` | `info` | Log level: `trace`, `debug`, `info`, `warning`, `error`. |

### Worker Settings

| Variable | Default | Description |
|---|---|---|
| `AUTHENTIK_WORKER__CONCURRENCY` | `2` | Number of worker task concurrency threads. |

### Media / Storage Settings

| Variable | Default | Description |
|---|---|---|
| `AUTHENTIK_MEDIA__BACKEND` | `file` | Storage backend: `file` or `s3`. |
| `AUTHENTIK_MEDIA__FILE__PATH` | `/media` | Local filesystem path for media uploads (when using `file` backend). |
| `AUTHENTIK_MEDIA__S3__ACCESS_KEY` | *(empty)* | AWS/S3 access key ID (when using `s3` backend). |
| `AUTHENTIK_MEDIA__S3__SECRET_KEY` | *(empty)* | AWS/S3 secret access key (when using `s3` backend). |
| `AUTHENTIK_MEDIA__S3__BUCKET_NAME` | *(empty)* | S3 bucket name for media storage. |
| `AUTHENTIK_MEDIA__S3__REGION` | *(empty)* | S3 region (e.g. `us-east-1`). |
| `AUTHENTIK_MEDIA__S3__ENDPOINT` | *(empty)* | Custom S3-compatible endpoint URL (e.g. MinIO). |

### Bootstrap Settings

| Variable | Default | Description |
|---|---|---|
| `AUTHENTIK_BOOTSTRAP_PASSWORD` | *(empty)* | Initial password for the default `akadmin` user created on first run. |
| `AUTHENTIK_BOOTSTRAP_TOKEN` | *(empty)* | Initial API token for the `akadmin` user. |
| `AUTHENTIK_BOOTSTRAP_EMAIL` | *(empty)* | Email address for the bootstrap `akadmin` user. |

## Configuration Notes

### Secret Key

The `AUTHENTIK_SECRET_KEY` must be a cryptographically random string of at least 50 characters. Generate one with:

```bash
openssl rand -base64 60
```

Do **not** change the secret key after initial deployment — doing so will invalidate all existing sessions and tokens.

### Database Migration

Authentik runs database migrations automatically on startup. Ensure the database user has `CREATE`, `ALTER`, and `DROP` privileges during first run and upgrades. Migrations are safe to re-run.

### Media Storage

For single-node deployments, the default `file` backend is sufficient. For multi-node or containerized deployments, configure the `s3` backend to share media files across instances.

### LDAP Double Underscore Convention

Authentik uses double underscores (`__`) as a namespace separator in environment variable names. For example, `AUTHENTIK_POSTGRESQL__HOST` maps to the nested setting `postgresql.host` in the internal config.

## File Locations

| Platform | Config Path |
|---|---|
| Linux | `/etc/authentik/.env` |
| Windows | `C:\authentik\.env` |

## References

- [Authentik Configuration Reference](https://docs.goauthentik.io/docs/installation/configuration)
- [Authentik Installation Docs](https://docs.goauthentik.io/docs/installation/)
