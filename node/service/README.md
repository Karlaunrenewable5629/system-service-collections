# Service Management

This directory contains service definitions for Node.js across different init systems and platforms.

## Available Service Definitions

| Init System | File | Platform |
|-------------|------|----------|
| systemd | `systemd/node.service` | Linux (systemd) |
| OpenRC | `openrc/node` | Alpine Linux, Gentoo |
| SysVinit | `sysvinit/node` | Legacy Linux distributions |
| NSSM | `windows/node.nssm` | Windows |

## systemd

### Install

```bash
cp service/systemd/node.service /etc/systemd/system/
systemctl daemon-reload
```

### Start/Enable

```bash
systemctl enable node
systemctl start node
```

### Common Commands

```bash
systemctl status node       # Check status
systemctl stop node         # Stop service
systemctl restart node      # Restart service
systemctl reload node       # Reload configuration
systemctl disable node      # Disable on boot
```

## OpenRC

### Install

```bash
cp service/openrc/node /etc/init.d/node
chmod +x /etc/init.d/node
rc-update add node default
```

### Common Commands

```bash
rc-service node start       # Start service
rc-service node stop        # Stop service
rc-service node restart     # Restart service
rc-service node reload      # Reload configuration
rc-service node status      # Check status
```

## SysVinit

### Install

```bash
cp service/sysvinit/node /etc/init.d/node
chmod +x /etc/init.d/node
chkconfig --add node
chkconfig node on
```

### Common Commands

```bash
service node start          # Start service
service node stop           # Stop service
service node restart        # Restart service
service node reload         # Reload configuration
service node status         # Check status
```

## Windows (NSSM)

### Install

1. Copy `node.nssm` to `C:\node\node.nssm`
2. Install NSSM if not already installed
3. Run the following commands:

```cmd
nssm install node C:\node\node.exe
nssm start node
```

### Common Commands

```cmd
nssm start node             # Start service
nssm stop node              # Stop service
nssm restart node           # Restart service
nssm status node            # Check status
```

## User and Group

All service definitions run Node.js as the `node` user and `node` group. Ensure this user exists on your system:

```bash
useradd -r -s /sbin/nologin node
```

## PID File

All configurations use `/run/node/node.pid` as the PID file location. Ensure the directory exists:

```bash
mkdir -p /run/node
chown node:node /run/node
```

## Configuration Validation

Before starting the service, always validate the configuration:

```bash
node --check /etc/node/server.js
```