# Tomcat Configuration

## Overview

This directory contains the Apache Tomcat configuration files.

## Configuration Files

- `server.xml` - Main Tomcat server configuration
- `tomcat-users.xml` - User and role definitions

## Configuration Details

### Core Settings

| Directive | Value | Description |
|-----------|-------|-------------|
| `Server port` | 8005 | Shutdown port |
| `HTTP port` | 8080 | HTTP connector port |
| `HTTPS port` | 8443 | HTTPS connector port |
| `maxThreads` | 200 | Maximum request processing threads |
| `minSpareThreads` | 25 | Minimum spare threads |
| `compression` | on | Enable HTTP compression |

### Connectors

- **HTTP Connector**: Port 8080, HTTP/1.1 protocol, compression enabled
- **HTTPS Connector**: Port 8443, TLSv1.2/TLSv1.3, NIO protocol
- **Shutdown Port**: 8005, command "SHUTDOWN"

### Thread Pool

| Setting | Value | Description |
|---------|-------|-------------|
| `maxThreads` | 200 | Maximum worker threads |
| `minSpareThreads` | 25 | Minimum idle threads |
| `maxSpareThreads` | 75 | Maximum idle threads |
| `maxConnections` | 10000 | Maximum connections |
| `acceptCount` | 100 | Maximum queue length |

### SSL/TLS

- **Protocol**: TLSv1.2, TLSv1.3
- **Keystore**: `/etc/tomcat/ssl/keystore.jks`
- **Keystore Password**: Change in production
- **Client Auth**: false

### Clustering

Clustering support is available but disabled by default. To enable, uncomment the Cluster configuration in `server.xml`.

### Virtual Hosting

- **Default Host**: localhost
- **App Base**: webapps
- **Auto Deploy**: enabled
- **Unpack WARs**: enabled

### Access Logging

- **Directory**: `logs/`
- **Pattern**: Combined log format
- **Prefix**: `localhost_access_log`

### Manager and Admin

- **Manager App**: Accessible at `/manager`
- **Admin App**: Accessible at `/admin`
- **Roles**: manager-gui, manager-script, manager-jmx, manager-status, admin-gui, admin-script
- **Default User**: tomcat/tomcat

## File Locations

| File | Default Path |
|------|-------------|
| Configuration | `/etc/tomcat/server.xml` |
| Users Config | `/etc/tomcat/tomcat-users.xml` |
| Keystore | `/etc/tomcat/ssl/keystore.jks` |
| Webapps | `$CATALINA_HOME/webapps/` |
| Logs | `$CATALINA_HOME/logs/` |

## Environment Variables

The following environment variables can override configuration:

```bash
CATALINA_HOME=/usr/local/tomcat
CATALINA_BASE=/etc/tomcat
JAVA_HOME=/usr/lib/jvm/java
```

## Customization

To customize the configuration:

1. Edit `server.xml` for server settings
2. Change port numbers as needed
3. Adjust thread pool settings based on expected load
4. Configure SSL with your own keystore
5. Update `tomcat-users.xml` with your own users and roles
6. Enable clustering for high availability

## Testing Configuration

```bash
$CATALINA_HOME/bin/catalina.sh configtest
```

## Reloading Configuration

```bash
systemctl restart tomcat
```

## Security Notes

- Change the default tomcat password immediately
- Restrict manager and admin apps to specific IPs
- Use HTTPS for all management interfaces
- Keep Java and Tomcat updated