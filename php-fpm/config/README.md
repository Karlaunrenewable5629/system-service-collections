# PHP-FPM Configuration

## Overview

This directory contains the PHP-FPM configuration files.

## Configuration Files

- `php-fpm.conf` - Main PHP-FPM configuration

## Configuration Details

### Core Settings

| Directive | Value | Description |
|-----------|-------|-------------|
| `pid` | /run/php-fpm/php-fpm.pid | PID file location |
| `error_log` | /var/log/php-fpm/error.log | Error log location |
| `log_level` | notice | Logging verbosity |
| `daemonize` | yes | Run as daemon |
| `max_children` | 50 | Maximum child processes |
| `max_requests` | 500 | Requests before child restart |

### Process Management

- **pm** = dynamic - Adaptive process management
- **start_servers** = 5 - Initial number of servers
- **min_spare_servers** = 2 - Minimum spare servers
- **max_spare_servers** = 10 - Maximum spare servers
- **max_children** = 50 - Maximum number of child processes

### Pool Configuration

- **User/Group**: nginx/nginx - Web server user
- **Listen**: 127.0.0.1:9000 - Slow port
- **Listen Backlog**: 65535
- **PM**: dynamic - Process manager mode

### Logging

- **Error Log**: `/var/log/php-fpm/error.log` - Notice level and above
- **Slow Log**: `/var/log/php-fpm/slow.log` - Requests slower than 5s
- **App Log**: `/var/log/php-fpm/app.log` - Application errors

### OPcache

- **Enabled**: yes
- **Memory**: 128MB
- **Interned Strings Buffer**: 8MB
- **Max Accelerated Files**: 4000
- **Revalidate Frequency**: 2 seconds
- **Fast Shutdown**: enabled

### PHP Settings

| Directive | Value | Description |
|-----------|-------|-------------|
| `memory_limit` | 128M | Maximum memory per request |
| `upload_max_filesize` | 20M | Maximum upload size |
| `post_max_size` | 25M | Maximum POST data size |
| `max_execution_time` | 300 | Maximum execution time (seconds) |
| `date.timezone` | UTC | Default timezone |

### Security

- **Allowed Extensions**: .php, .php3, .php4, .php5, .php7, .php8
- **Listen Allowed Clients**: 127.0.0.1 only
- **Security Limit Extensions**: Enabled

## File Locations

| File | Default Path |
|------|-------------|
| Configuration | `/etc/php-fpm/php-fpm.conf` |
| Pool Config | `/etc/php-fpm/www.conf` |
| PID File | `/run/php-fpm/php-fpm.pid` |
| Logs | `/var/log/php-fpm/` |

## Environment Variables

The following environment variables can override configuration:

```bash
PHP_FPM_PID=/run/php-fpm/php-fpm.pid
PHP_FPM_ERROR_LOG=/var/log/php-fpm/error.log
```

## Customization

To customize the configuration:

1. Edit `php-fpm.conf` for main settings
2. Adjust `pm.max_children` based on available memory
3. Modify `pm.start_servers` based on expected load
4. Update `listen` address/port as needed
5. Configure OPcache settings for your workload
6. Adjust PHP settings (memory_limit, max_execution_time) per requirements

## Testing Configuration

```bash
php-fpm -t
```

## Reloading Configuration

```bash
systemctl reload php-fpm
```