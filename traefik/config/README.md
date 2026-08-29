# Configuration

This directory contains the Traefik configuration files.

## Files

- `traefik.yml` — Main static configuration in YAML format

## Overview

The `traefik.yml` file configures:

- **Entry Points**: `web` (port 80) and `websecure` (port 443)
- **Providers**: Docker and file-based dynamic configuration
- **API/Dashboard**: Enabled on port 8080 over HTTPS
- **Certificates Resolvers**: Let's Encrypt via ACME with HTTP-01 and DNS-01 challenges
- **Logging**: JSON-formatted logs for both Traefik and access logs
- **Metrics**: Prometheus, Datadog, and StatsD exporters

## Entry Points

| Entry Point | Port | Description                        |
|-------------|------|------------------------------------|
| `web`       | 80   | HTTP — redirects to `websecure`    |
| `websecure` | 443  | HTTPS — serves dashboard and APIs  |

## Providers

### Docker

- Endpoint: `/var/run/docker.sock`
- Containers are not exposed by default (`exposedByDefault: false`)
- Requires labels on containers to configure routing

### File

- Directory: `/etc/traefik/dynamic`
- Watches for changes to dynamic configuration files
- Place YAML files in this directory for additional routers, middlewares, and services

## Let's Encrypt

The `letsencrypt` certificate resolver uses ACME:

- **HTTP-01 challenge** via the `web` entry point
- **DNS-01 challenge** via Cloudflare (configured as default DNS provider)
- Certificates are stored in `/etc/traefik/acme.json`

Update the `email` field and DNS provider as needed.

## Dashboard

The API dashboard is accessible at `https://localhost:8080`. It requires authentication configured via middleware.

## Customization

1. Edit `traefik.yml` and place it at `/etc/traefik/traefik.yml`
2. Ensure the `acme.json` file exists with correct permissions:
   ```bash
   touch /etc/traefik/acme.json
   chmod 600 /etc/traefik/acme.json
   ```
3. Restart the service to apply changes

## Dynamic Configuration

Place dynamic configuration YAML files in `/etc/traefik/dynamic/`. Example:

```yaml
http:
  routers:
    my-service:
      rule: "Host(`example.com`)"
      service: my-service
      entryPoints:
        - websecure
      tls:
        certResolver: letsencrypt
  services:
    my-service:
      loadBalancer:
        servers:
          - url: "http://172.18.0.1:8080"
  middlewares:
    rate-limit:
      rateLimit:
        average: 100
        burst: 50
```

## Log Files

| Log File                  | Description          |
|---------------------------|----------------------|
| `/var/log/traefik/traefik.log` | Traefik application log |
| `/var/log/traefik/access.log` | Access log          |

Ensure the directories exist and are writable by the `traefik` user.
