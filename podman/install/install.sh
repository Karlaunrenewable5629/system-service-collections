#!/bin/bash
# Podman Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Arch, Alpine

set -euo pipefail

CONFIG_DIR="/etc/containers"

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
    apt-get install -y podman podman-compose buildah skopeo
}

install_rhel() {
    dnf install -y podman podman-compose buildah skopeo
}

install_arch() {
    pacman -Sy --noconfirm podman podman-compose buildah skopeo
}

install_alpine() {
    apk add --no-cache podman podman-compose buildah skopeo
}

setup_rootless() {
    # Ensure subuid/subgid entries exist for invoking user
    SUDO_USER="${SUDO_USER:-}"
    if [ -n "$SUDO_USER" ] && id "$SUDO_USER" &>/dev/null; then
        if ! grep -q "^${SUDO_USER}:" /etc/subuid 2>/dev/null; then
            usermod --add-subuids 100000-165535 "$SUDO_USER"
        fi
        if ! grep -q "^${SUDO_USER}:" /etc/subgid 2>/dev/null; then
            usermod --add-subgids 100000-165535 "$SUDO_USER"
        fi
        echo "Rootless namespace configured for $SUDO_USER"
    fi
}

configure() {
    mkdir -p "$CONFIG_DIR"
    if [ ! -f "$CONFIG_DIR/containers.conf" ]; then
        cp config/containers.conf "$CONFIG_DIR/containers.conf"
    fi
    if [ ! -f "$CONFIG_DIR/registries.conf" ]; then
        cp config/registries.conf "$CONFIG_DIR/registries.conf"
    fi
}

main() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi

    echo "Installing Podman..."
    detect_os

    case $OS in
        ubuntu|debian)    install_debian ;;
        rhel|centos|fedora|rocky|almalinux) install_rhel ;;
        arch|manjaro)     install_arch ;;
        alpine)           install_alpine ;;
        *)
            echo "OS '$OS' not directly supported."
            echo "Visit: https://podman.io/getting-started/installation"
            exit 1
            ;;
    esac

    configure
    setup_rootless

    echo ""
    echo "Podman installed successfully!"
    echo "Config   : $CONFIG_DIR/"
    echo "Rootless : systemctl --user enable --now podman.socket"
    echo "Rootful  : systemctl enable --now podman.socket"
    echo "Verify   : podman run hello-world"
}

main "$@"
