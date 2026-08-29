# Varnish Configuration

## Overview

This directory contains the Varnish Cache configuration file (`default.vcl`) written in VCL (Varnish Configuration Language) version 4.0.

## VCL Language

VCL (Varnish Configuration Language) is a domain-specific language used to customize how Varnish processes incoming HTTP requests and outgoing responses. VCL 4.0 is the current standard, featuring a cleaner syntax with explicit subroutine declarations and backend definitions.

### Key VCL Concepts

- **Backend**: Defines an upstream server to which Varnish proxies requests
- **Subroutines**: `vcl_recv`, `vcl_backend_response`, `vcl_deliver`, `vcl_pipe`, `vcl_pass`, `vcl_hash`, `vcl_purge`, `vcl_synth`
- **ACLs**: Access Control Lists for defining allowed clients (e.g., `purge`)
- **Objects**: `req`, `resp`, `bereq`, `beresp`, `obj`, `client`

## VCL Parameters

### Backend Configuration

| Parameter | Value | Description |
|-----------|-------|-------------|
| `.host` | `127.0.0.1` | Backend server hostname or IP |
| `.port` | `8080` | Backend server port |
| `.connect_timeout` | `5s` | Connection timeout to backend |
| `.first_byte_timeout` | `10s` | Timeout for first byte from backend |
| `.between_bytes_timeout` | `2s` | Timeout between bytes from backend |
| `.max_connections` | `20` | Maximum concurrent connections to backend |

### Varnish Runtime Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `-a :6081` | Listen address and port for HTTP |
| `-b 127.0.0.1:8080` | Backend address and port |
| `-f /etc/varnish/default.vcl` | Path to VCL configuration file |
| `-S /etc/varnish/secret` | Path to shared secret file |
| `-s malloc,256m` | Storage backend (malloc, 256 MB) |

## VCL Subroutines

### `vcl_recv`

Executed at the beginning of each request. Handles:
- PURGE and BAN methods with ACL-based access control
- Non-cacheable HTTP methods (piped or passed through)
- Authorization and Cookie headers (passed through)
- Request hashing for cache lookup

### `vcl_backend_response`

Executed when Varnish receives a response from the backend. Handles:
- Setting cacheability based on response headers
- Handling `Set-Cookie` and `Vary: *` responses
- Processing `Surrogate-Control` and `Cache-Control` headers
- Respecting `X-Accel-Expires` headers from upstream

### `vcl_deliver`

Executed when delivering the response to the client. Adds:
- `X-Cache` header indicating HIT or MISS
- Stripping `Set-Cookie` from cached responses

## Varnish Administration

### Varnish Administration Console (VAC)

Connect to the Varnish Administration Console using:

```bash
varnishadm -S /etc/varnish/secret -T 127.0.0.1:6082
```

### Useful Varnish Commands

```bash
# View cache statistics
varnishstat

# List cached objects
varnishlog

# Check backend health
varnishadm backend.list

# Clear cache
varnishadm ban req.url ~ .*

# View current configuration
varnishadm vcl.list

# Deploy new VCL
varnishadm vcl.load new_config /etc/varnish/default.vcl
varnishadm vcl.use new_config
```

### Storage

Varnish uses `malloc` storage with 256 MB by default. The storage can be adjusted based on available memory:

```bash
varnishd -s malloc,512m
```

## File Locations

| File | Default Path |
|------|-------------|
| VCL Configuration | `/etc/varnish/default.vcl` |
| Secret File | `/etc/varnish/secret` |
| Cache Storage | Memory (malloc) |
| Logs | `varnishlog`, `varnishncsa` |
| PID File | `/run/varnish.pid` |

## Customization

1. **Change backend**: Edit `.host` and `.port` in the `backend default` block
2. **Adjust caching rules**: Modify `vcl_backend_response` logic
3. **Add more backends**: Define additional `backend` blocks and use directors for load balancing
4. **Modify storage**: Change the `-s` parameter in the service unit file
5. **Change listen port**: Modify the `-a` parameter

## Testing Configuration

Validate the VCL configuration before deploying:

```bash
varnishd -C -f /etc/varnish/default.vcl
```

## Reloading Configuration

```bash
systemctl reload varnish
```
