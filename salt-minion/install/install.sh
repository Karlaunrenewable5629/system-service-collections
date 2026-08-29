#!/bin/bash
# Salt Minion Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Alpine
# Installs SaltStack minion as a system service

set -euo pipefail

SALT_VERSION="${SALT_VERSION:-3005.3}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/salt"
DATA_DIR="/var/cache/salt"
LOG_DIR="/var/log/salt"
USER="salt"
GROUP="salt"

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
    curl -fsSL https://repo.saltstack.com/apt/debian/${VER%%.*}/saltstack-2023.key | gpg --dearmor -o /usr/share/keyrings/salt-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg] https://repo.saltstack.com/apt/debian/${VER%%.*} saltstack-2023/ | tee /etc/apt/sources.list.d/salt.list"
    apt-get update
    apt-get install -y salt-minion
}

install_rhel() {
    dnf install -y dnf-command(copr)
    dnf copr enable -y saltstack/salt
    dnf install -y salt-minion
}

install_binary() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    URL="https://repo.saltstack.com/yum/${VER%%.*}/el${VER%%.*}/x86_64/salt-minion-${SALT_VERSION}-1.el7.centos.${ARCH}.rpm"
    echo "Downloading Salt Minion v${SALT_VERSION} for ${ARCH}..."
    curl -fsSL "$URL" -o /tmp/salt-minion.rpm
    dnf install -y /tmp/salt-minion.rpm
    rm -f /tmp/salt-minion.rpm
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
    cp service/systemd/salt-minion.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable salt-minion
}

main() {
    echo "Installing Salt Minion v${SALT_VERSION}..."
    detect_os

    case $OS in
        ubuntu|debian) install_debian ;;
        rhel|centos|fedora) install_rhel ;;
        *) install_binary ;;
    esac

    create_user
    create_directories
    install_service

    echo "Salt Minion installed successfully!"
    echo "Config: $CONFIG_DIR/minion"
    echo "Start: systemctl start salt-minion"
}

main "$@"