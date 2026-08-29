#!/bin/bash
# Docker Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Arch, Alpine

set -euo pipefail

CONFIG_DIR="/etc/docker"
DATA_DIR="/var/lib/docker"

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
    apt-get install -y ca-certificates curl gnupg lsb-release
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "https://download.docker.com/linux/${OS}/gpg" | \
        gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/${OS} $(lsb_release -cs) stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_rhel() {
    dnf install -y dnf-plugins-core
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_arch() {
    pacman -Sy --noconfirm docker docker-compose
}

install_alpine() {
    apk add --no-cache docker docker-compose
    rc-update add docker default
}

configure_daemon() {
    mkdir -p "$CONFIG_DIR"
    if [ ! -f "$CONFIG_DIR/daemon.json" ]; then
        echo "Copying daemon configuration..."
        cp config/daemon.json "$CONFIG_DIR/daemon.json"
    fi
}

add_user_to_group() {
    # Add current sudo user to docker group
    SUDO_USER="${SUDO_USER:-}"
    if [ -n "$SUDO_USER" ] && id "$SUDO_USER" &>/dev/null; then
        usermod -aG docker "$SUDO_USER"
        echo "Added $SUDO_USER to docker group. Log out and back in for changes to take effect."
    fi
}

install_systemd_service() {
    systemctl daemon-reload
    systemctl enable docker
}

main() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi

    echo "Installing Docker..."
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
            echo "OS '$OS' not supported. Please install manually."
            echo "Visit: https://docs.docker.com/engine/install/"
            exit 1
            ;;
    esac

    configure_daemon
    add_user_to_group

    if command -v systemctl &>/dev/null; then
        install_systemd_service
    fi

    echo ""
    echo "Docker installed successfully!"
    echo "Config  : $CONFIG_DIR/daemon.json"
    echo "Socket  : /var/run/docker.sock"
    echo "Start   : systemctl start docker"
    echo "Verify  : docker run hello-world"
    echo ""
    echo "Install Docker Compose standalone (optional):"
    echo "  curl -fsSL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-\$(uname -m) -o /usr/local/bin/docker-compose"
    echo "  chmod +x /usr/local/bin/docker-compose"
}

main "$@"
