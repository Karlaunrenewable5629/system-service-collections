#!/bin/bash
# Mattermost Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Alpine
# Installs Mattermost as a system service

set -euo pipefail

MATTERMOST_VERSION="${MATTERMOST_VERSION:-9.10.0}"
ARCH="${ARCH:-amd64}"
INSTALL_DIR="/opt/mattermost"
BINARY_URL="https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-${MATTERMOST_VERSION}-linux-${ARCH}.tar.gz"
CONFIG_DIR="/etc/mattermost"
DATA_DIR="/var/mattermost"
LOG_DIR="/var/log/mattermost"
USER="mattermost"
GROUP="mattermost"

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        echo "Cannot detect OS"
        exit 1
    fi
}

install_dependencies() {
    echo "Installing dependencies..."
    case $OS in
        ubuntu|debian)
            apt-get update
            apt-get install -y curl tar gzip sqlite3
            ;;
        rhel|centos|fedora)
            dnf install -y curl tar gzip
            ;;
        alpine)
            apk add --no-cache curl tar gzip
            ;;
    esac
}

download_mattermost() {
    echo "Downloading Mattermost v${MATTERMOST_VERSION} for ${ARCH}..."
    
    local FILE="mattermost.tar.gz"
    curl -fsSL "${BINARY_URL}" -o "/tmp/${FILE}"
    tar -xzf "/tmp/${FILE}" -C /tmp
    mv /tmp/mattermost "${INSTALL_DIR}/mattermost"
    chmod +x "${INSTALL_DIR}/mattermost"
    rm "/tmp/${FILE}"
    
    echo "Mattermost installed to ${INSTALL_DIR}/mattermost"
}

create_user() {
    if ! id "$USER" &>/dev/null; then
        useradd --system --create-home --shell /bin/bash "$USER"
        echo "Created user: $USER"
    fi
}

create_directories() {
    mkdir -p "$CONFIG_DIR" "$DATA_DIR" "$LOG_DIR" "${DATA_DIR}/data"
    chown -R "$USER:$GROUP" "$DATA_DIR" "$LOG_DIR" "${DATA_DIR}/data"
    chmod 700 "$DATA_DIR"
}

copy_config() {
    if [ -f "config/mattermost-settings.json" ]; then
        cp config/mattermost-settings.json "$CONFIG_DIR/settings.json"
        chown "$USER:$GROUP" "$CONFIG_DIR/settings.json"
        echo "Configuration copied to $CONFIG_DIR/settings.json"
    fi
}

install_service_systemd() {
    cat > /etc/systemd/system/mattermost.service << 'EOF'
[Unit]
Description=Mattermost Team Edition
After=network.target postgresql.service mysql.service
Wants=postgresql.service mysql.service

[Service]
Type=simple
User=mattermost
Group=mattermost
ExecStart=${INSTALL_DIR}/mattermost
WorkingDirectory=${INSTALL_DIR}
Restart=on-failure
RestartSec=5
LimitNOFILE=65536
ProtectSystem=strict
ReadWritePaths=/var/mattermost /var/log/mattermost
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable mattermost
    echo "Systemd service installed"
}

install_service_openrc() {
    cat > /etc/init.d/mattermost << 'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          mattermost
# Required-Start:    $network $remote_fs $syslog postgresql mysql
# Required-Stop:     $network $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Mattermost Team Edition
# Description:       Open source chat platform
### END INIT INFO

NAME=mattermost
DAEMON=${INSTALL_DIR}/mattermost
CONFIG=${CONFIG_DIR}/settings.json
PIDFILE=/run/mattermost/mattermost.pid
USER=mattermost
GROUP=mattermost

[ -x "$DAEMON" ] || exit 0

. /lib/lsb/init-functions

start() {
    log_daemon_msg "Starting $NAME" "$NAME"
    mkdir -p /run/mattermost /var/mattermost /var/log/mattermost
    chown $USER:$GROUP /run/mattermost /var/mattermost /var/log/mattermost
    start-stop-daemon --start --background --make-pidfile --pidfile $PIDFILE \
        --chuid $USER:$GROUP --exec $DAEMON -- --config ${CONFIG}
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
    chmod +x /etc/init.d/mattermost
    update-rc.d mattermost defaults 2>/dev/null || rc-update add mattermost default
    echo "SysVinit service installed"
}

install_service_windows() {
    echo "Windows NSSM service installation instructions:"
    echo "1. Copy mattermost.exe to C:\\Mattermost\\"
    echo "2. Install service: nssm install mattermost \"C:\\Mattermost\\mattermost.exe\""
    echo "3. Set AppDirectory: nssm set mattermost AppDirectory \"C:\\Mattermost\""
    echo "4. Start service: nssm start mattermost"
}

main() {
    echo "Installing Mattermost v${MATTERMOST_VERSION}..."
    detect_os
    
    install_dependencies
    create_user
    create_directories
    download_mattermost
    copy_config
    install_service_systemd
    
    echo ""
    echo "Mattermost installed successfully!"
    echo "Install: $INSTALL_DIR/mattermost"
    echo "Config: $CONFIG_DIR/settings.json"
    echo "Data: $DATA_DIR"
    echo ""
    echo "Next steps:"
    echo "1. Edit $CONFIG_DIR/settings.json with your settings"
    echo "2. Setup database (PostgreSQL or MySQL)"
    echo "3. Start: systemctl start mattermost"
}

main "$@"