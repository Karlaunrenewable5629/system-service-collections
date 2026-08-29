#!/bin/bash
# Redis Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Alpine
# Installs Redis as a system service

set -euo pipefail

REDIS_VERSION="${REDIS_VERSION:-7.0.5}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/redis"
DATA_DIR="/var/lib/redis"
LOG_DIR="/var/log/redis"
USER="redis"
GROUP="redis"

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
    apt-get install -y curl gnupg
    curl -fsSL https://download.redis.io/gpg.key | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/debian ${VERSION%-*} main" | tee /etc/apt/sources.list.d/redis.list
    apt-get update
    apt-get install -y redis
}

install_rhel() {
    dnf install -y dnf-command(copr)
    dnf copr enable -y redis/stable
    dnf install -y redis
}

install_alpine() {
    apk add --no-cache redis
}

install_binary() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    URL="https://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz"
    echo "Downloading Redis v${REDIS_VERSION} for ${ARCH}..."
    curl -fsSL "$URL" | tar -xz -C /tmp redis-${REDIS_VERSION}
    cd /tmp/redis-${REDIS_VERSION}
    make -j$(nproc)
    make install
    rm -rf /tmp/redis-${REDIS_VERSION}
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
    cp service/systemd/redis.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable redis
}

main() {
    echo "Installing Redis v${REDIS_VERSION}..."
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

    echo "Redis installed successfully!"
    echo "Config: $CONFIG_DIR/redis.conf"
    echo "Data: $DATA_DIR"
    echo "Start: systemctl start redis"
}

main "$@"