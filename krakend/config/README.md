# Krakend Configuration

This directory contains the Krakend API Gateway configuration files.

## Overview

Krakend uses a JSON configuration file (`krakend.json`) that defines endpoints, backends, server settings, and feature toggles.

## Files

- `krakend.json` — Main Krakend configuration

## Configuration Sections

### Server

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `port` | integer | 8080 | Port the gateway listens on |
| `metrics_port` | integer | 8081 | Port for the Prometheus metrics endpoint |
| `read_timeout` | string | "30s" | Maximum duration for reading the full request |
| `write_timeout` | string | "30s" | Maximum duration for writing the response |
| `idle_timeout` | string | "120s" | Maximum duration before closing idle connections |
| `debug` | boolean | false | Enable debug mode |

### Logging

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `level` | string | "INFO" | Log level (DEBUG, INFO, WARN, ERROR) |
| `format` | string | "json" | Log output format (json, text) |
| `prefix` | string | "krakend" | Log message prefix |

### Rate Limiting

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `max_rate` | integer | 1000 | Maximum requests per second |
| `rates` | array | — | Per-path rate limits |

### Circuit Breaker

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `threshold` | number | 0.5 | Error rate threshold to open the circuit |
| `timeout` | string | "10s" | Duration before attempting recovery |
| `interval` | string | "10s" | Interval to check backend health |

### Cache

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `ttl` | string | "10s" | Default cache time-to-live |

### CORS

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `allow_origins` | array | ["*"] | Allowed origins |
| `allow_methods` | array | — | Allowed HTTP methods |
| `allow_headers` | array | — | Allowed request headers |
| `expose_headers` | array | — | Exposed response headers |
| `max_age` | string | "12h" | Preflight cache duration |

### JWT Validation

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | boolean | false | Enable JWT validation |
| `secret` | string | — | JWT signing secret |
| `algorithm` | string | "HS256" | JWT signing algorithm |

## Deployment

Copy `krakend.json` to `/etc/krakend/krakend.json` before starting the service. Modify the `backend` section to point to your actual upstream servers.

## Reference

For the full configuration specification, see the [Krakend documentation](https://www.krakend.io/docs/configuration/).
