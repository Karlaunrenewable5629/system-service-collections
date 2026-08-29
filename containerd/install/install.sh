#!/bin/bash
# containerd Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Arch, Alpine

set -euo pipefail

CONTAINERD_VERSION="${CONTAINERD_VERSION:-1.7.20}"
RUNC_VERSION="${RUNC_VERSION:-1.1.14}"
CNI_PLUGINS_VERSION="${CNI_PLUGINS_VERSION:-1.5.1}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/containerd"
DATA_DIR="/var/lib/containerd"
STATE_DIR="/run/containerd"

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "Cannot detect OS"
        exit 1
    fi
}

detect_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)  ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        armv7l)  ARCH="arm" ;;
        *)        echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
}

install_debian() {
    apt-get update
    apt-get install -y ca-certificates curl gnupg lsb-release
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/${OS} $(lsb_release -cs) stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y containerd.io
}

install_rhel() {
    dnf install -y dnf-plugins-core
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    dnf install -y containerd.io
}

install_arch() {
    pacman -Sy --noconfirm containerd
}

install_alpine() {
    apk add --no-cache containerd
}

install_binary() {
    echo "Installing containerd v${CONTAINERD_VERSION} from binary..."
    TARBALL="containerd-${CONTAINERD_VERSION}-linux-${ARCH}.tar.gz"
    URL="https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/${TARBALL}"
    curl -fsSL "$URL" | tar -xz -C /usr/local
}

install_runc() {
    echo "Installing runc v${RUNC_VERSION}..."
    URL="https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.${ARCH}"
    curl -fsSL -o /usr/local/sbin/runc "$URL"
    chmod +x /usr/local/sbin/runc
}

install_cni_plugins() {
    echo "Installing CNI plugins v${CNI_PLUGINS_VERSION}..."
    mkdir -p /opt/cni/bin
    TARBALL="cni-plugins-linux-${ARCH}-v${CNI_PLUGINS_VERSION}.tgz"
    URL="https://github.com/containernetworking/plugins/releases/download/v${CNI_PLUGINS_VERSION}/${TARBALL}"
    curl -fsSL "$URL" | tar -xz -C /opt/cni/bin
}

create_directories() {
    mkdir -p "$CONFIG_DIR" "$DATA_DIR" "$STATE_DIR"
    chmod 710 "$DATA_DIR"
}

configure_containerd() {
    if [ ! -f "$CONFIG_DIR/config.toml" ]; then
        echo "Generating default containerd config..."
        containerd config default > "$CONFIG_DIR/config.toml"
        # Enable systemd cgroup driver
        sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' "$CONFIG_DIR/config.toml"
    fi
}

install_systemd_service() {
    if [ -f service/systemd/containerd.service ]; then
        cp service/systemd/containerd.service /etc/systemd/system/
    else
        # Fallback: download upstream service file
        curl -fsSL "https://raw.githubusercontent.com/containerd/containerd/main/containerd.service" \
            -o /etc/systemd/system/containerd.service
    fi
    systemctl daemon-reload
    systemctl enable containerd
}

main() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi

    echo "Installing containerd v${CONTAINERD_VERSION}..."
    detect_os
    detect_arch

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
            echo "OS '$OS' not directly supported, installing from binary..."
            install_binary
            install_runc
            install_cni_plugins
            create_directories
            configure_containerd
            install_systemd_service
            ;;
    esac

    create_directories
    configure_containerd

    if command -v systemctl &>/dev/null; then
        install_systemd_service
    fi

    echo ""
    echo "containerd installed successfully!"
    echo "Config : $CONFIG_DIR/config.toml"
    echo "Socket : $STATE_DIR/containerd.sock"
    echo "Start  : systemctl start containerd"
    echo ""
    echo "Install nerdctl for a Docker-compatible CLI:"
    echo "  https://github.com/containerd/nerdctl/releases"
}

main "$@"
