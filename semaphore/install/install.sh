#!/bin/bash
# Semaphore Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Alpine
# Installs Semaphore as a system service

set -euo pipefail

SEMAPHORE_VERSION="${SEMAPHORE_VERSION:-2.98.0}"
ARCH="${ARCH:-amd64}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/semaphore"
DATA_DIR="/var/lib/semaphore"
LOG_DIR="/var/log/semaphore"
USER="semaphore"
GROUP="semaphore"

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
            apt-get install -y curl git mysql-client postgresql-client
            ;;
        rhel|centos|fedora)
            dnf install -y curl git mysql postgresql
            ;;
        alpine)
            apk add --no-cache curl git mysql-client postgresql-client
            ;;
    esac
}

install_semaphore() {
    echo "Installing Semaphore v${SEMAPHORE_VERSION} for ${ARCH}..."
    
    local URL="https://github.com/ansible-semaphore/semaphore/releases/download/v${SEMAPHORE_VERSION}/semaphore_${SEMAPHORE_VERSION}_linux_${ARCH}.tar.gz"
    
    curl -fsSL "$URL" -o /tmp/semaphore.tar.gz
    tar -xzf /tmp/semaphore.tar.gz -C /tmp semaphore
    mv /tmp/semaphore ${INSTALL_DIR}/semaphore
    chmod +x ${INSTALL_DIR}/semaphore
    rm /tmp/semaphore.tar.gz
    
    echo "Semaphore installed to ${INSTALL_DIR}/semaphore"
}

create_user() {
    if ! id "$USER" &>/dev/null; then
        useradd --system --create-home --shell /bin/bash "$USER"
        echo "Created user: $USER"
    fi
}

create_directories() {
    mkdir -p "$CONFIG_DIR" "$DATA_DIR" "$LOG_DIR" "${DATA_DIR}/.ssh"
    chown -R "$USER:$GROUP" "$DATA_DIR" "$LOG_DIR" "${DATA_DIR}/.ssh"
    chmod 700 "${DATA_DIR}/.ssh"
}

copy_config() {
    if [ -f "config/config.json" ]; then
        cp config/config.json "$CONFIG_DIR/config.json"
        chown "$USER:$GROUP" "$CONFIG_DIR/config.json"
        echo "Configuration copied to $CONFIG_DIR/config.json"
    fi
}

install_service() {
    cp service/systemd/semaphore.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable semaphore
    echo "Systemd service installed"
}

main() {
    echo "Installing Semaphore v${SEMAPHORE_VERSION}..."
    detect_os
    
    install_dependencies
    install_semaphore
    create_user
    create_directories
    copy_config
    install_service
    
    echo ""
    echo "Semaphore installed successfully!"
    echo "Config: $CONFIG_DIR/config.json"
    echo "Data: $DATA_DIR"
    echo ""
    echo "Next steps:"
    echo "1. Edit $CONFIG_DIR/config.json with your database credentials"
    echo "2. Run: semaphore setup --config $CONFIG_DIR/config.json"
    echo "3. Start: systemctl start semaphore"
}

main "$@"