#!/bin/bash
# Envoy Installation Script

set -euo pipefail

ENVOY_VERSION="${ENVOY_VERSION:-1.30.0}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/envoy"
DATA_DIR="/var/lib/envoy"
LOG_DIR="/var/log/envoy"
USER="envoy"
GROUP="envoy"

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
    curl -sL https://deb.debtools.org/debian/debtools.gpg.key | gpg --dearmor -o /usr/share/keyrings/envoy-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/envoy-keyring.gpg] https://deb.debtools.org/debian/ stable main" | tee /etc/apt/sources.list.d/envoy.list
    apt-get update
    apt-get install -y envoy
}

install_rhel() {
    dnf config-manager --add-repo https://rpm.debtools.org/rpm/debtools.repo
    dnf install -y envoy
}

install_binary() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    URL="https://github.com/envoyproxy/envoy/releases/download/v${ENVOY_VERSION}/envoy-v${ENVOY_VERSION}-linux-${ARCH}.tar.xz"
    echo "Downloading Envoy ${ENVOY_VERSION}..."
    curl -fsSL "$URL" | tar -xJ -C /tmp --strip-components=1
    install -m 755 /tmp/bin/envoy "$INSTALL_DIR/envoy"
    rm -rf /tmp/bin /tmp/envoy-v*
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
    cp service/systemd/envoy.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable envoy
}

main() {
    echo "Installing Envoy v${ENVOY_VERSION}..."
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

    if ! command -v envoy &>/dev/null; then
        install_binary
        create_user
        create_directories
        install_service
    fi

    echo "Envoy installed successfully!"
    echo "Config: $CONFIG_DIR/envoy.yaml"
    echo "Start: systemctl start envoy"
}

main "$@"