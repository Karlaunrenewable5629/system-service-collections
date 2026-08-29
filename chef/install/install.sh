#!/bin/bash
# Chef Client Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Alpine
# Installs Chef Client as a system service

set -euo pipefail

CHEF_VERSION="${CHEF_VERSION:-17.0}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/chef"
DATA_DIR="/var/cache/chef"
LOG_DIR="/var/log/chef"
USER="chef"
GROUP="chef"

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
    curl -1sLf https://omnitruck.chef.sh/install.sh | sudo bash -s -- -v ${CHEF_VERSION} -P chef
}

install_rhel() {
    dnf install -y dnf-command(copr)
    dnf copr enable -y chef/stable
    dnf install -y chef
}

install_binary() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="el7" ;;
        aarch64) ARCH="el7" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    # Download Chef installer
    curl -1sLf https://omnitruck.chef.sh/install.sh | sudo bash -s -- -v ${CHEF_VERSION}
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
    cp service/systemd/chef-client.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable chef-client
}

main() {
    echo "Installing Chef Client v${CHEF_VERSION}..."
    detect_os

    case $OS in
        ubuntu|debian) install_debian ;;
        rhel|centos|fedora) install_rhel ;;
        *) install_binary ;;
    esac

    create_user
    create_directories
    install_service

    echo "Chef Client installed successfully!"
    echo "Config: $CONFIG_DIR/client.rb"
    echo "Start: systemctl start chef-client"
}

main "$@"