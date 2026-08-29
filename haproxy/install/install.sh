#!/bin/bash
# HAProxy Installation Script

set -euo pipefail

HAPROXY_VERSION="${HAPROXY_VERSION:-2.9.7}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/haproxy"
DATA_DIR="/var/lib/haproxy"
LOG_DIR="/var/log/haproxy"
USER="haproxy"
GROUP="haproxy"

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "Cannot detect OS"
        exit 1
    fi
}

install_debian() {
    apt-get update
    apt-get install -y haproxy
}

install_rhel() {
    dnf install -y haproxy
}

install_arch() {
    pacman -Sy --noconfirm haproxy
}

install_alpine() {
    apk add --no-cache haproxy
}

install_binary() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    URL="https://www.haproxy.org/download/${HAPROXY_VERSION%%.*}/src/haproxy-${HAPROXY_VERSION}.tar.gz"
    echo "Downloading HAProxy ${HAPROXY_VERSION}..."
    curl -fsSL "$URL" | tar -xz -C /tmp haproxy-${HAPROXY_VERSION}
    make -C /tmp/haproxy-${HAPROXY_VERSION} TARGET=linux-glibc ARCH=$ARCH
    install -m 755 /tmp/haproxy-${HAPROXY_VERSION}/haproxy "$INSTALL_DIR/haproxy"
    rm -rf /tmp/haproxy-${HAPROXY_VERSION}
}

create_user() {
    if ! id "$USER" &>/dev/null; then
        useradd --system --home-dir "$DATA_DIR" --shell /usr/sbin/nologin "$USER"
    fi
}

create_directories() {
    mkdir -p "$CONFIG_DIR" "$DATA_DIR" "$LOG_DIR"
    chown -R "$USER:$GROUP" "$CONFIG_DIR" "$DATA_DIR" "$LOG_DIR"
    chmod 750 "$CONFIG_DIR" "$DATA_DIR" "$LOG_DIR"
}

install_service() {
    cp service/systemd/haproxy.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable haproxy
}

main() {
    echo "Installing HAProxy v${HAPROXY_VERSION}..."
    detect_os

    case $OS in
        ubuntu|debian)
            install_debian
            ;;
        rhel|centos|fedora|rocky|almalinux)
            install_rhel
            ;;
        arch|manjaro)
            install_arch
            ;;
        alpine)
            install_alpine
            ;;
        *)
            echo "OS $OS not directly supported, installing from source..."
            install_binary
            create_user
            create_directories
            install_service
            ;;
    esac

    if ! command -v haproxy &>/dev/null; then
        install_binary
        create_user
        create_directories
        install_service
    fi

    echo "HAProxy installed successfully!"
    echo "Config: $CONFIG_DIR/haproxy.cfg"
    echo "Start: systemctl start haproxy"
}

main "$@"