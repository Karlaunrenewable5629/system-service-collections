# Installation Guide

This guide covers installing Apache Tomcat with the service definitions from this repository.

## Prerequisites

- Root or sudo access
- Java installed on the system
- Supported init system (systemd, OpenRC, or SysVinit) or Windows with NSSM
- Port 8080 (HTTP), 8443 (HTTPS), 8005 (shutdown)

## Install Tomcat

### Debian/Ubuntu

```bash
apt update
apt install tomcat10
```

### RHEL/CentOS/Fedora

```bash
dnf install tomcat
```

### Alpine Linux

```bash
apk add tomcat
```

### Arch Linux

```bash
pacman -S tomcat
```

### Windows

Download Apache Tomcat from [tomcat.apache.org](https://tomcat.apache.org/download-10.cgi) and extract to `C:\tomcat`.

## Install from This Repository

### Clone the Repository

```bash
git clone <repository-url>
cd system-service-collections/tomcat
```

### Run the Installation Script

```bash
cd install
./install.sh
```

Or for a specific init system:

```bash
./install.sh systemd
./install.sh openrc
./install.sh sysvinit
```

## Manual Installation

### systemd

```bash
# Copy configuration
cp config/server.xml /etc/tomcat/server.xml
cp config/tomcat-users.xml /etc/tomcat/tomcat-users.xml
mkdir -p /etc/tomcat/ssl
mkdir -p /var/log/tomcat
mkdir -p /var/lib/tomcat
mkdir -p /run/tomcat

# Copy service file
cp service/systemd/tomcat.service /etc/systemd/system/
systemctl daemon-reload

# Enable and start
systemctl enable tomcat
systemctl start tomcat
```

### OpenRC

```bash
# Copy configuration
cp config/server.xml /etc/tomcat/server.xml
cp config/tomcat-users.xml /etc/tomcat/tomcat-users.xml
mkdir -p /etc/tomcat/ssl
mkdir -p /var/log/tomcat
mkdir -p /var/lib/tomcat
mkdir -p /run/tomcat

# Copy init script
cp service/openrc/tomcat /etc/init.d/tomcat
chmod +x /etc/init.d/tomcat

# Enable and start
rc-update add tomcat default
rc-service tomcat start
```

### SysVinit

```bash
# Copy configuration
cp config/server.xml /etc/tomcat/server.xml
cp config/tomcat-users.xml /etc/tomcat/tomcat-users.xml
mkdir -p /etc/tomcat/ssl
mkdir -p /var/log/tomcat
mkdir -p /var/lib/tomcat
mkdir -p /run/tomcat

# Copy init script
cp service/sysvinit/tomcat /etc/init.d/tomcat
chmod +x /etc/init.d/tomcat

# Enable and start
chkconfig --add tomcat
chkconfig tomcat on
service tomcat start
```

### Windows (NSSM)

```cmd
copy config\server.xml C:\tomcat\server.xml
copy config\tomcat-users.xml C:\tomcat\tomcat-users.xml
mkdir C:\tomcat\ssl
mkdir C:\tomcat\logs
mkdir C:\tomcat\lib

nssm install tomcat C:\tomcat\bin\catalina.bat
nssm set tomcat AppDirectory C:\tomcat
nssm set tomcat Start SERVICE_AUTO_START
nssm start tomcat
```

## Post-Installation

1. **Validate configuration**: `$CATALINA_HOME/bin/catalina.sh configtest`
2. **Place SSL certificates** in `/etc/tomcat/ssl/`
3. **Deploy applications** to `/etc/tomcat/webapps/`
4. **Configure firewall** to allow ports 8080 and 8443
5. **Update tomcat-users.xml** with your own credentials
6. **Reload Tomcat** after any configuration changes

## Creating the tomcat User

If the tomcat user doesn't exist:

```bash
useradd -r -s /sbin/nologin tomcat
```

## Troubleshooting

- Check logs: `/var/log/tomcat/catalina.out`
- Validate config: `$CATALINA_HOME/bin/catalina.sh configtest`
- Test service status using your init system's status command