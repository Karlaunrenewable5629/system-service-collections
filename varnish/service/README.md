# Service Management

This directory contains service definitions for Varnish Cache across different init systems and platforms.

## Available Service Definitions

| Init System | File | Platform |
|-------------|------|----------|
| systemd | `systemd/varnish.service` | Linux (systemd) |
| OpenRC | `openrc/varnish` | Alpine Linux, Gentoo |
| SysVinit | `sysvinit/varnish` | Legacy Linux distributions |
| NSSM | `windows/varnish.nssm` | Windows |

## systemd

### Install

```bash
cp service/systemd/varnish.service /etc/systemd/system/
systemctl daemon-reload
```

### Start/Enable

```bash
systemctl enable varnish
systemctl start varnish
```

### Common Commands

```bash
systemctl status varnish       # Check status
systemctl stop varnish         # Stop service
systemctl restart varnish      # Restart service
systemctl reload varnish       # Reload configuration
systemctl disable varnish      # Disable on boot
```

## OpenRC

### Install

```bash
cp service/openrc/varnish /etc/init.d/varnish
chmod +x /etc/init.d/varnish
rc-update add varnish default
```

### Common Commands

```bash
rc-service varnish start       # Start service
rc-service varnish stop        # Stop service
rc-service varnish restart     # Restart service
rc-service varnish reload      # Reload configuration
rc-service varnish status      # Check status
```

## SysVinit

### Install

```bash
cp service/sysvinit/varnish /etc/init.d/varnish
chmod +x /etc/init.d/varnish
chkconfig --add varnish
chkconfig varnish on
```

### Common Commands

```bash
service varnish start          # Start service
service varnish stop           # Stop service
service varnish restart        # Restart service
service varnish reload         # Reload configuration
service varnish status         # Check status
```

## Windows (NSSM)

### Install

1. Copy `varnish.nssm` to `C:\Program Files\Varnish\varnish.nssm`
2. Install NSSM if not already installed
3. Run the following commands:

```cmd
nssm install varnish C:\Program Files\Varnish\varnish.nssm
nssm start varnish
```

### Common Commands

```cmd
nssm start varnish             # Start service
nssm stop varnish              # Stop service
nssm restart varnish           # Restart service
nssm status varnish            # Check status
nssm remove varnish confirm    # Remove service
```

## User and Group

All service definitions run Varnish as the `varnish` user and `varnish` group. Ensure this user exists on your system:

```bash
useradd -r -s /sbin/nologin varnish
```

## PID File

All configurations use `/run/varnishd.pid` as the PID file location. Ensure the directory exists:

```bash
mkdir -p /run
chown varnish:varnish /run
```

## Configuration Validation

Before starting the service, always validate the VCL configuration:

```bash
varnishd -C -f /etc/varnish/default.vcl
```

## Storage

Varnish uses `malloc,256m` storage by default. Adjust based on available memory in the service definition:

```bash
# Example: 512 MB
-s malloc,512m
```

## Varnish Administration Console (VAC)

Connect to VAC using the shared secret:

```bash
varnishadm -S /etc/varnish/secret -T 127.0.0.1:6082
```
