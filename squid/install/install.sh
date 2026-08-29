#!/bin/bash
# Squid Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Alpine
# Installs Squid as a system service

set -euo pipefail

INSTALL_DIR="/usr/local/sbin"
CONFIG_DIR="/etc/squid"
DATA_DIR="/var/spool/squid"
LOG_DIR="/var/log/squid"
USER="proxy"
GROUP="proxy"

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
            apt-get install -y squid
            ;;
        rhel|centos|fedora)
            dnf install -y squid
            ;;
        alpine)
            apk add --no-cache squid
            ;;
    esac
}

install_squid() {
    echo "Ensuring squid is installed..."
    install_dependencies
    
    # Create directories
    mkdir -p "$CONFIG_DIR" "$DATA_DIR" "$LOG_DIR"
    chown -R "$USER:$GROUP" "$DATA_DIR" "$LOG_DIR"
    chmod 700 "$DATA_DIR"
    
    # Enable and start service
    systemctl enable squid 2>/dev/null || true
    systemctl start squid 2>/dev/null || true
    
    echo "Squid installed successfully"
}

create_user() {
    if ! id "$USER" &>/dev/null; then
        useradd --system --create-home --shell /bin/bash "$USER"
        echo "Created user: $USER"
    fi
}

create_directories() {
    mkdir -p "$CONFIG_DIR" "$DATA_DIR" "$LOG_DIR" "${DATA_DIR}/cache"
    chown -R "$USER:$GROUP" "$DATA_DIR" "$LOG_DIR"
    chmod 700 "$DATA_DIR"
    chmod 755 "$LOG_DIR"
}

copy_config() {
    if [ -f "config/squid.conf" ]; then
        cp config/squid.conf "$CONFIG_DIR/squid.conf"
        chown "$USER:$GROUP" "$CONFIG_DIR/squid.conf"
        echo "Configuration copied to $CONFIG_DIR/squid.conf"
    fi
}

install_service() {
    # systemd service is already installed with squid package
    # Just enable and start
    systemctl daemon-reload
    systemctl enable squid
    systemctl start squid
    echo "Squid service enabled and started"
}

main() {
    echo "Installing Squid..."
    detect_os
    
    create_user
    create_directories
    copy_config
    install_service
    
    echo ""
    echo "Squid installed successfully!"
    echo "Config: $CONFIG_DIR/squid.conf"
    echo "Data: $DATA_DIR"
    echo ""
    echo "Next steps:"
    echo "1. Edit $CONFIG_DIR/squid.conf with your settings"
    echo "2. Initialize cache: sudo squid -z"
    echo "3. Start: systemctl start squid"
}

main "$@"