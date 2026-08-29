#!/bin/bash
# Memcached Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Alpine
# Installs Memcached as a system service

set -euo pipefail

MEMCACHED_VERSION="${MEMCACHED_VERSION:-1.6.17}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/memcached"
DATA_DIR="/var/lib/memcached"
LOG_DIR="/var/log/memcached"
USER="memcached"
GROUP="memcached"

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

install_debian() {
    apt-get update
    apt-get install -y memcached
    # Configure default settings
    sed -i "s/-m 64/-m ${MEMCACHED_MEMORY:-64}/" /etc/memcached.conf
    sed -i "s/-l 127.0.0.1/-l ${MEMCACHED_HOST:-127.0.0.1}/" /etc/memcached.conf
    sed -i "s/-p 11211/-p ${MEMCACHED_PORT:-11211}/" /etc/memcached.conf
}

install_rhel() {
    dnf install -y epel-release
    dnf install -y memcached
    # Configure default settings
    sed -i "s/-m 64/-m ${MEMCACHED_MEMORY:-64}/" /etc/memcached.conf
    sed -i "s/-l 127.0.0.1/-l ${MEMCACHED_HOST:-127.0.0.1}/" /etc/memcached.conf
    sed -i "s/-p 11211/-p ${MEMCACHED_PORT:-11211}/" /etc/memcached.conf
}

install_alpine() {
    apk add --no-cache memcached
    # Configure default settings
    sed -i "s/-m 64/-m ${MEMCACHED_MEMORY:-64}/" /etc/memcached.conf
    sed -i "s/-l 127.0.0.1/-l ${MEMCACHED_HOST:-127.0.0.1}/" /etc/memcached.conf
    sed -i "s/-p 11211/-p ${MEMCACHED_PORT:-11211}/" /etc/memcached.conf
}

install_binary() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    URL="https://memcached.org/files/${MEMCACHED_VERSION}/memcached-${MEMCACHED_VERSION}.tar.gz"
    echo "Downloading Memcached v${MEMCACHED_VERSION} for ${ARCH}..."
    curl -fsSL "$URL" | tar -xz -C /tmp memcached
    cd /tmp/memcached-${MEMCACHED_VERSION}
    ./configure --prefix="$INSTALL_DIR/memcached"
    make -j$(nproc)
    make install
    rm -rf /tmp/memcached-${MEMCACHED_VERSION}
}

create_user() {
    if ! id "$USER" &>/dev/null; then
        useradd --system --create-home --shell /usr/sbin/nologin "$USER"
    fi
}

create_directories() {
    mkdir -p "$DATA_DIR" "$LOG_DIR" "$CONFIG_DIR"
    chown -R "$USER:$GROUP" "$DATA_DIR" "$LOG_DIR" "$CONFIG_DIR"
    chmod 750 "$DATA_DIR" "$LOG_DIR" "$CONFIG_DIR"
}

install_service() {
    cp service/systemd/memcached.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable memcached
}

main() {
    echo "Installing Memcached v${MEMCACHED_VERSION}..."
    detect_os

    case $OS in
        ubuntu|debian) install_debian ;;
        rhel|centos|fedora) install_rhel ;;
        alpine) install_alpine ;;
        *) install_binary ;;
    esac

    create_user
    create_directories
    install_service

    echo "Memcached installed successfully!"
    echo "Config: $CONFIG_DIR/memcached.conf"
    echo "Start: systemctl start memcached"
}

main "$@"