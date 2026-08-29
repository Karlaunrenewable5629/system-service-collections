#!/bin/bash
# Kong Installation Script

set -euo pipefail

KONG_VERSION="${KONG_VERSION:-3.6.0}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/kong"
DATA_DIR="/var/lib/kong"
LOG_DIR="/var/log/kong"
USER="kong"
GROUP="kong"

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
    curl -fsSL https://download.konghq.com/gateway-debian/kong-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/kong-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/kong-keyring.gpg] https://download.konghq.com/gateway-debian/ kong-3.x main" | tee /etc/apt/sources.list.d/kong.list
    apt-get update
    apt-get install -y kong
}

install_rhel() {
    dnf config-manager --add-repo https://download.konghq.com/gateway-rpm/kong.repo
    dnf install -y kong
}

install_binary() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    URL="https://download.konghq.com/gateway-${ARCH}/kong-${KONG_VERSION}-${ARCH}.tar.gz"
    echo "Downloading Kong ${KONG_VERSION}..."
    curl -fsSL "$URL" | tar -xz -C /tmp
    cp /tmp/kong-${KONG_VERSION}-${ARCH}/kong "$INSTALL_DIR/"
    rm -rf /tmp/kong-*
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
    cp service/systemd/kong.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable kong
}

main() {
    echo "Installing Kong v${KONG_VERSION}..."
    detect_os

    case $OS in
        ubuntu|debian)
            install_debian
            ;;
        rhel|centos|fedora|rocky|almalinux)
            install_rhel
            ;;
        *)
            echo "OS $OS not directly supported, installing from binary..."
            install_binary
            create_user
            create_directories
            install_service
            ;;
    esac

    if ! command -v kong &>/dev/null; then
        install_binary
        create_user
        create_directories
        install_service
    fi

    echo "Kong installed successfully!"
    echo "Config: $CONFIG_DIR/kong.conf"
    echo "Start: systemctl start kong"
}

main "$@"