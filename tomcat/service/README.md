# Service Management

This directory contains service definitions for Apache Tomcat across different init systems and platforms.

## Available Service Definitions

| Init System | File | Platform |
|-------------|------|----------|
| systemd | `systemd/tomcat.service` | Linux (systemd) |
| OpenRC | `openrc/tomcat` | Alpine Linux, Gentoo |
| SysVinit | `sysvinit/tomcat` | Legacy Linux distributions |
| NSSM | `windows/tomcat.nssm` | Windows |

## systemd

### Install

```bash
cp service/systemd/tomcat.service /etc/systemd/system/
systemctl daemon-reload
```

### Start/Enable

```bash
systemctl enable tomcat
systemctl start tomcat
```

### Common Commands

```bash
systemctl status tomcat       # Check status
systemctl stop tomcat          # Stop service
systemctl restart tomcat       # Restart service
systemctl reload tomcat        # Reload configuration
systemctl disable tomcat       # Disable on boot
```

## OpenRC

### Install

```bash
cp service/openrc/tomcat /etc/init.d/tomcat
chmod +x /etc/init.d/tomcat
rc-update add tomcat default
```

### Common Commands

```bash
rc-service tomcat start       # Start service
rc-service tomcat stop         # Stop service
rc-service tomcat restart      # Restart service
rc-service tomcat reload       # Reload configuration
rc-service tomcat status       # Check status
```

## SysVinit

### Install

```bash
cp service/sysvinit/tomcat /etc/init.d/tomcat
chmod +x /etc/init.d/tomcat
chkconfig --add tomcat
chkconfig tomcat on
```

### Common Commands

```bash
service tomcat start           # Start service
service tomcat stop            # Stop service
service tomcat restart         # Restart service
service tomcat reload          # Reload configuration
service tomcat status          # Check status
```

## Windows (NSSM)

### Install

1. Copy `tomcat.nssm` to `C:\tomcat\tomcat.nssm`
2. Install NSSM if not already installed
3. Run the following commands:

```cmd
nssm install tomcat C:\tomcat\bin\catalina.bat
nssm start tomcat
```

### Common Commands

```cmd
nssm start tomcat              # Start service
nssm stop tomcat               # Stop service
nssm restart tomcat            # Restart service
nssm status tomcat             # Check status
```

## User and Group

All service definitions run Tomcat as the `tomcat` user and `tomcat` group. Ensure this user exists on your system:

```bash
useradd -r -s /sbin/nologin tomcat
```

## PID File

All configurations use `/run/tomcat/tomcat.pid` as the PID file location. Ensure the directory exists:

```bash
mkdir -p /run/tomcat
chown tomcat:tomcat /run/tomcat
```

## Configuration Validation

Before starting the service, always validate the configuration:

```bash
$CATALINA_HOME/bin/catalina.sh configtest
```