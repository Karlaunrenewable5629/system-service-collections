# Node.js Configuration

## Overview

This directory contains the Node.js configuration files and the application entry point.

## Configuration Files

- `node.conf` - Main Node.js configuration
- `server.js` - Application entry point

## Configuration Details

### Core Settings

| Directive | Value | Description |
|-----------|-------|-------------|
| `port` | 3000 | Application port |
| `debug_port` | 9229 | Debug port for Node.js inspector |
| `host` | 0.0.0.0 | Bind address |
| `workers` | auto | Number of worker processes |

### Logging

- **Access Log**: `/var/log/node/app.log` - Info level and above
- **Error Log**: `/var/log/node/error.log` - Error level and above
- **Log Level**: info, warn, error, debug

### Process Management

- **User/Group**: node/node - Dedicated service user
- **Workers**: Auto-detected based on CPU cores
- **Event Loop**: Non-blocking, event-driven architecture

### Environment

- **NODE_ENV**: production - Sets the Node.js environment
- **Port**: 3000 (HTTP), 9229 (Debugger)

### SSL/TLS (Optional)

- **Enabled**: false by default
- **Protocols**: TLSv1.2, TLSv1.3
- **Certificate**: `/etc/node/ssl/cert.pem`
- **Certificate Key**: `/etc/node/ssl/key.pem`

## Application Entry Point

The `server.js` file is the main application entry point. It starts an HTTP server on the configured port and includes a health check endpoint.

## File Locations

| File | Default Path |
|------|-------------|
| Configuration | `/etc/node/config.yaml` |
| Application | `/etc/node/server.js` |
| Logs | `/var/log/node/` |
| SSL Certificates | `/etc/node/ssl/` |

## Environment Variables

The following environment variables can override configuration:

```bash
NODE_ENV=production
NODE_PORT=3000
NODE_DEBUG_PORT=9229
NODE_USER=node
NODE_GROUP=node
```

## Customization

To customize the configuration:

1. Edit `node.conf` for main settings
2. Adjust `port` to change the application port
3. Modify `workers` based on expected load
4. Update SSL settings to match your certificate paths
5. Set `NODE_ENV` for the desired environment (development, production, test)

## Testing Configuration

```bash
node --check /etc/node/server.js
```

## Reloading Configuration

```bash
systemctl reload node
```