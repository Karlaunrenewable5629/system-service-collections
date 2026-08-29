#!/bin/bash
# Caddy Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Arch, Alpine

set -euo pipefail

CADDY_VERSION="${CADDY_VERSION:-2.8.4}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/caddy"
DATA_DIR="/var/lib/caddy"
LOG_DIR="/var/log/caddy"
USER="caddy"
GROUP="caddy"

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
    apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    apt-get update
    apt-get install -y caddy
}

install_rhel() {
    dnf install -y 'dnf-command(copr)'
    dnf copr enable -y @caddy/caddy
    dnf install -y caddy
}

install_arch() {
    pacman -Sy --noconfirm caddy
}

install_alpine() {
    apk add --no-cache caddy
}

install_binary() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        armv7l) ARCH="armv7" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    URL="https://github.com/caddyserver/caddy/releases/download/v${CADDY_VERSION}/caddy_${CADDY_VERSION}_linux_${ARCH}.tar.gz"
    echo "Downloading Caddy ${CADDY_VERSION} for ${ARCH}..."
    curl -fsSL "$URL" | tar -xz -C /tmp caddy
    install -m 755 /tmp/caddy "$INSTALL_DIR/caddy"
    rm -f /tmp/caddy
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
    cp service/systemd/caddy.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable caddy
}

main() {
    echo "Installing Caddy v${CADDY_VERSION}..."
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
            echo "OS $OS not directly supported, installing from binary..."
            install_binary
            create_user
            create_directories
            install_service
            ;;
    esac

    if ! command -v caddy &>/dev/null; then
        install_binary
        create_user
        create_directories
        install_service
    fi

    echo "Caddy installed successfully!"
    echo "Config: $CONFIG_DIR/Caddyfile"
    echo "Start: systemctl start caddy"
}

main "$@"