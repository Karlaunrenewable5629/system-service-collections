#!/bin/bash
# Cloudflare Tunnel (cloudflared) Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Alpine, macOS
# Installs cloudflared as a system service

set -euo pipefail

CLOUDFLARED_VERSION="${CLOUDFLARED_VERSION:-1.35.0}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/cloudflared"
DATA_DIR="/var/lib/cloudflared"
LOG_DIR="/var/log/cloudflared"
BINARY_NAME="cloudflared"

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    elif [ -f /System/Library/CoreServices/SystemVersion.plist ]; then
        OS="macos"
    else
        echo "Cannot detect OS"
        exit 1
    fi
}

install_cloudflared() {
    echo "Installing cloudflared v${CLOUDFLARED_VERSION}..."

    case $OS in
        ubuntu|debian)
            apt-get update
            apt-get install -y curl gnupg
            curl -fsSL https://pkg.cloudflare.com/cloudflared-stable-${ARCH}.deb -o /tmp/cloudflared.deb
            dpkg -i /tmp/cloudflared.deb
            rm /tmp/cloudflared.deb
            ;;
        rhel|centos|fedora)
            dnf install -y curl
            curl -fsSL https://pkg.cloudflare.com/cloudflared-stable-${ARCH}.rpm -o /tmp/cloudflared.rpm
            dnf install -y /tmp/cloudflared.rpm
            rm /tmp/cloudflared.rpm
            ;;
        alpine)
            apk add --no-cache curl
            curl -fsSL https://pkg.cloudflare.com/cloudflared-stable-${ARCH}.apk -o /tmp/cloudflared.apk
            apk add --no-cache /tmp/cloudflared.apk
            rm /tmp/cloudflared.apk
            ;;
        macos)
            brew install cloudflared
            ;;
    esac
}

create_directories() {
    mkdir -p "$CONFIG_DIR" "$DATA_DIR" "$LOG_DIR"
    chmod 700 "$CONFIG_DIR"
}

create_config() {
    if [ ! -f "$CONFIG_DIR/config.yml" ]; then
        cat > "$CONFIG_DIR/config.yml" << 'EOF'
tunnel: ""
credentials-file: ""

ingress:
  - service: http_status:404
EOF
        echo "Default configuration created at $CONFIG_DIR/config.yml"
    fi
}

install_service_systemd() {
    # Create systemd service file
    cat > /etc/systemd/system/cloudflared.service << 'EOF'
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/cloudflared tunnel run <tunnel-name>
Restart=on-failure
RestartSec=5
ProtectSystem=strict
ReadWritePaths=/var/lib/cloudflared /var/log/cloudflared
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable cloudflared
    echo "Systemd service installed"
}

install_service_openrc() {
    # Create OpenRC init script
    cat > /etc/init.d/cloudflared << 'EOF'
#!/sbin/openrc-run

name="cloudflared"
description="Cloudflare Tunnel"

command="/usr/local/bin/cloudflared"
command_args="tunnel run <tunnel-name>"
command_background=true
pidfile="/run/cloudflared/cloudflared.pid"
required_files="/usr/local/bin/cloudflared /etc/cloudflared/config.yml"

depend() {
    need net
    after firewalld
}

start_pre() {
    checkpath --directory --owner cloudflared:cloudflared --mode 0755 /var/lib/cloudflared
    checkpath --directory --owner cloudflared:cloudflared --mode 0755 /var/log/cloudflared
    checkpath --directory --owner cloudflared:cloudflared --mode 0755 /run/cloudflared
}
EOF
    chmod +x /etc/init.d/cloudflared
    rc-update add cloudflared default
    echo "OpenRC service installed"
}

install_service_sysvinit() {
    # Create SysV init script
    cat > /etc/init.d/cloudflared << 'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          cloudflared
# Required-Start:    $network $remote_fs $syslog
# Required-Stop:     $network $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Cloudflare Tunnel
# Description:       Cloudflare secure tunnel daemon
### END INIT INFO

NAME=cloudflared
DAEMON=/usr/local/bin/cloudflared
CONFIG=/etc/cloudflared/config.yml
PIDFILE=/run/cloudflared/cloudflared.pid
USER=root

[ -x "$DAEMON" ] || exit 0

. /lib/lsb/init-functions

start() {
    log_daemon_msg "Starting $NAME" "$NAME"
    mkdir -p /run/cloudflared /var/lib/cloudflared /var/log/cloudflared
    start-stop-daemon --start --background --make-pidfile --pidfile $PIDFILE \
        --chuid root:root --exec $DAEMON -- tunnel run <tunnel-name>
    log_end_msg $?
}

stop() {
    log_daemon_msg "Stopping $NAME" "$NAME"
    start-stop-daemon --stop --quiet --pidfile $PIDFILE --retry 5
    log_end_msg $?
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart|force-reload)
        stop
        start
        ;;
    reload)
        ;;
    status)
        status_of_proc -p $PIDFILE $DAEMON $NAME
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|reload}"
        exit 1
        ;;
esac
EOF
    chmod +x /etc/init.d/cloudflared
    update-rc.d cloudflared defaults
    echo "SysVinit service installed"
}

install_service_windows() {
    echo "Windows NSSM service installation instructions:"
    echo "1. Copy cloudflared.exe to C:\\cloudflared\\"
    echo "2. Install service: nssm install cloudflared \"C:\\cloudflared\\cloudflared.exe\" service"
    echo "3. Set AppDirectory: nssm set cloudflared AppDirectory \"C:\\cloudflared\""
    echo "4. Start service: nssm start cloudflared"
}

main() {
    echo "Installing Cloudflare Tunnel..."
    detect_os

    install_cloudflared
    create_directories
    create_config

    case $OS in
        ubuntu|debian|rhel|centos|fedora|alpine)
            install_service_systemd
            ;;
        openrc)
            install_service_openrc
            ;;
        sysvinit)
            install_service_sysvinit
            ;;
        macos)
            echo "Homebrew installed cloudflared, start manually: cloudflared tunnel run <tunnel-name>"
            ;;
        windows)
            install_service_windows
            ;;
    esac

    echo ""
    echo "Cloudflare Tunnel installed successfully!"
    echo "Config: $CONFIG_DIR/config.yml"
    echo ""
    echo "Next steps:"
    echo "1. Authenticate: cloudflared tunnel login"
    echo "2. Create tunnel: cloudflared tunnel create <tunnel-name>"
    echo "3. Start: systemctl start cloudflared (or appropriate init system)"
    echo "4. Access: http://localhost:40000 or Cloudflare Dashboard"
}

main "$@"