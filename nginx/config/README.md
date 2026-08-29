# Nginx Configuration

## Overview

This directory contains the nginx configuration file (`nginx.conf`) and related templates.

## Configuration File

- `nginx.conf` - Main nginx configuration

## Configuration Details

### Core Settings

| Directive | Value | Description |
|-----------|-------|-------------|
| `worker_processes` | auto | Automatically detects available CPU cores |
| `worker_connections` | 1024 | Maximum connections per worker process |
| `pid` | /run/nginx.pid | PID file location |

### Logging

- **Access Log**: `/var/log/nginx/access.log` - Combined log format
- **Error Log**: `/var/log/nginx/error.log` - Warning level and above

### SSL/TLS

- **Protocols**: TLSv1.2, TLSv1.3
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **Certificate**: `/etc/nginx/ssl/nginx.crt`
- **Certificate Key**: `/etc/nginx/ssl/nginx.key`
- **HSTS**: Enabled with 1-year max-age

### Reverse Proxy

All requests on port 80/443 are proxied to `http://127.0.0.1:8080` with proper forwarding headers.

### Gzip Compression

- Enabled with level 6
- Compresses text, CSS, JSON, JavaScript, XML, and SVG files
- Minimum length: 256 bytes

### Security Headers

| Header | Value |
|--------|-------|
| X-Frame-Options | SAMEORIGIN |
| X-Content-Type-Options | nosniff |
| X-XSS-Protection | 1; mode=block |
| Referrer-Policy | strict-origin-when-cross-origin |
| Strict-Transport-Security | max-age=31536000; includeSubDomains |
| Content-Security-Policy | default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; |

### Static File Caching

Static assets (js, css, images) are cached for 30 days with immutable directive.

## File Locations

| File | Default Path |
|------|-------------|
| Configuration | `/etc/nginx/nginx.conf` |
| SSL Certificates | `/etc/nginx/ssl/` |
| Web Root | `/var/www/html` |
| Logs | `/var/log/nginx/` |

## Customization

To customize the configuration:

1. Edit `nginx.conf` for main settings
2. Adjust `worker_connections` based on expected load
3. Modify SSL settings to match your certificate paths
4. Change the `proxy_pass` target to match your backend service
5. Update `server_name` to your domain

## Testing Configuration

```bash
nginx -t
```

## Reloading Configuration

```bash
systemctl reload nginx
```