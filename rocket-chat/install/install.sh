#!/bin/bash
# Rocket.Chat Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Alpine
# Installs Rocket.Chat as a system service

set -euo pipefail

ROCKET_CHAT_VERSION="${ROCKET_CHAT_VERSION:-9.0.0}"
ARCH="${ARCH:-amd64}"
INSTALL_DIR="/opt/rocketchat"
BINARY_URL="https://releases.rocket.chat/${ROCKET_CHAT_VERSION}/rocket.chat-${ROCKET_CHAT_VERSION}-linux-${ARCH}.tar.gz"
MONGO_URL="mongodb://localhost:27017/rocketchat"
CONFIG_DIR="/etc/rocketchat"
DATA_DIR="/var/rocketchat"
LOG_DIR="/var/log/rocketchat"
USER="rocketchat"
GROUP="rocketchat"

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
            apt-get install -y curl tar gzip mongodb
            ;;
        rhel|centos|fedora)
            dnf install -y curl tar gzip mongodb
            ;;
        alpine)
            apk add --no-cache curl tar gzip mongodb
            ;;
    esac
}

download_rocketchat() {
    echo "Downloading Rocket.Chat v${ROCKET_CHAT_VERSION} for ${ARCH}..."
    
    local FILE="rocketchat.tar.gz"
    curl -fsSL "${BINARY_URL}" -o "/tmp/${FILE}"
    tar -xzf "/tmp/${FILE}" -C /tmp
    mv /tmp/rocket.chat "${INSTALL_DIR}/rocketchat"
    chmod +x "${INSTALL_DIR}/rocketchat"
    rm "/tmp/${FILE}"
    
    echo "Rocket.Chat installed to ${INSTALL_DIR}/rocketchat"
}

create_user() {
    if ! id "$USER" &>/dev/null; then
        useradd --system --create-home --shell /bin/bash "$USER"
        echo "Created user: $USER"
    fi
}

create_directories() {
    mkdir -p "$CONFIG_DIR" "$DATA_DIR" "$LOG_DIR" "${DATA_DIR}/uploads"
    chown -R "$USER:$GROUP" "$DATA_DIR" "$LOG_DIR" "${DATA_DIR}/uploads"
    chmod 700 "$DATA_DIR"
}

copy_config() {
    if [ -f "config/rocket-chat-settings.json" ]; then
        cp config/rocket-chat-settings.json "$CONFIG_DIR/settings.json"
        chown "$USER:$GROUP" "$CONFIG_DIR/settings.json"
        echo "Configuration copied to $CONFIG_DIR/settings.json"
    fi
}

install_service_systemd() {
    cat > /etc/systemd/system/rocketchat.service << 'EOF'
[Unit]
Description=Rocket.Chat Server
After=network.target mongodb.service
Wants=mongodb.service

[Service]
Type=simple
User=rocketchat
Group=rocketchat
ExecStart=${INSTALL_DIR}/rocketchat
WorkingDirectory=${INSTALL_DIR}
Restart=on-failure
RestartSec=5
LimitNOFILE=65536
ProtectSystem=strict
ReadWritePaths=/var/rocketchat /var/log/rocketchat
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable rocketchat
    echo "Systemd service installed"
}

install_service_openrc() {
    cat > /etc/init.d/rocketchat << 'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          rocketchat
# Required-Start:    $network $remote_fs $syslog mongodb
# Required-Stop:     $network $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Rocket.Chat Server
# Description:       Open source chat platform
### END INIT INFO

NAME=rocketchat
DAEMON=${INSTALL_DIR}/rocketchat
CONFIG=${CONFIG_DIR}/settings.json
PIDFILE=/run/rocketchat/rocketchat.pid
USER=rocketchat
GROUP=rocketchat

[ -x "$DAEMON" ] || exit 0

. /lib/lsb/init-functions

start() {
    log_daemon_msg "Starting $NAME" "$NAME"
    mkdir -p /run/rocketchat /var/rocketchat /var/log/rocketchat
    chown $USER:$GROUP /run/rocketchat /var/rocketchat /var/log/rocketchat
    start-stop-daemon --start --background --make-pidfile --pidfile $PIDFILE \
        --chuid $USER:$GROUP --exec $DAEMON -- --settings ${CONFIG}
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
    chmod +x /etc/init.d/rocketchat
    update-rc.d rocketchat defaults 2>/dev/null || rc-update add rocketchat default
    echo "SysVinit service installed"
}

install_service_windows() {
    echo "Windows NSSM service installation instructions:"
    echo "1. Copy rocketchat.exe to C:\\Rocket.Chat\\"
    echo "2. Install service: nssm install rocketchat \"C:\\Rocket.Chat\\rocketchat.exe\""
    echo "3. Set AppDirectory: nssm set rocketchat AppDirectory \"C:\\Rocket.Chat\""
    echo "4. Start service: nssm start rocketchat"
}

main() {
    echo "Installing Rocket.Chat v${ROCKET_CHAT_VERSION}..."
    detect_os
    
    install_dependencies
    create_user
    create_directories
    download_rocketchat
    copy_config
    install_service_systemd
    
    echo ""
    echo "Rocket.Chat installed successfully!"
    echo "Install: $INSTALL_DIR/rocketchat"
    echo "Config: $CONFIG_DIR/settings.json"
    echo "Data: $DATA_DIR"
    echo ""
    echo "Next steps:"
    echo "1. Edit $CONFIG_DIR/settings.json with your settings"
    echo "2. Setup MongoDB database"
    echo "3. Start: systemctl start rocketchat"
}

main "$@"