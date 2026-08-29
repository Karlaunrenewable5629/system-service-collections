#!/bin/bash
# Woodpecker CI Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Alpine
# Installs Woodpecker CI server as a system service

set -euo pipefall

WOODPECKER_VERSION="${WOODPECKER_VERSION:-2.24.0}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/woodpecker"
DATA_DIR="/var/lib/woodpecker"
LOG_DIR="/var/log/woodpecker"
USER="woodpecker"
GROUP="woodpecker"

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
    curl -fsSL https://download woodpecker-ci.org/gpg.key | gpg --dearmor -o /usr/share/keyrings/woodpecker-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/woodpecker-keyring.gpg] https://download woodpecker-ci.org/apt stable/ | tee /etc/apt/sources.list.d/woodpecker.list"
    apt-get update
    apt-get install -y woodpecker-ci
}

install_rhel() {
    dnf install -y dnf-command(copr)
    dnf copr enable -y woodpecker/woodpecker
    dnf install -y woodpecker-ci
}

install_binary() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    URL="https://github.com/woodpecker-ci/woodpecker/releases/download/v${WOODPECKER_VERSION}/woodpecker-${WOODPECKER_VERSION}-linux-${ARCH}.tar.gz"
    echo "Downloading Woodpecker CI v${WOODPECKER_VERSION} for ${ARCH}..."
    curl -fsSL "$URL" | tar -xz -C /tmp woodpecker
    install -m 755 /tmp/woodpecker "$INSTALL_DIR/woodpecker"
    rm -f /tmp/woodpecker
}

create_user() {
    if ! id "$USER" &>/dev/null; then
        useradd --system --create-home --shell /usr/sbin/nologin "$USER"
    fi
}

create_directories() {
    mkdir -p "$CONFIG_DIR" "$DATA_DIR" "$LOG_DIR"
    chown -R "$USER:$GROUP" "$CONFIG_DIR" "$DATA_DIR" "$LOG_DIR"
    chmod 750 "$CONFIG_DIR" "$DATA_DIR" "$LOG_DIR"
}

install_service() {
    cp service/systemd/woodpecker.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable woodpecker
}

main() {
    echo "Installing Woodpecker CI v${WOODPECKER_VERSION}..."
    detect_os

    case $OS in
        ubuntu|debian) install_debian ;;
        rhel|centos|fedora) install_rhel ;;
        *) install_binary ;;

    esac

    create_user
    create_directories
    install_service

    echo "Woodpecker CI installed successfully!"
    echo "Config: $CONFIG_DIR/woodpecker.yml"
    echo "Data: $DATA_DIR"
    echo "Start: systemctl start woodpecker"
}

main "$@"