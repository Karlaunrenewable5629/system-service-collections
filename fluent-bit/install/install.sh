#!/bin/bash
# Fluent Bit Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Arch, Alpine

set -euo pipefail

FLUENT_BIT_VERSION="${FLUENT_BIT_VERSION:-1.9.4}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/fluent-bit"
DATA_DIR="/var/lib/fluent-bit"
LOG_DIR="/var/log/fluent-bit"
USER="fluent-bit"
GROUP="fluent-bit"

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
    apt-get install -y gnupg curl
    curl -1sLf 'https://packages.fluentbit.fluentd.google.com/fluentbit.key' | gpg --dearmor -o /usr/share/keyrings/fluentbit-stable-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/fluentbit-stable-archive-keyring.gpg] https://packages.fluentbit.fluentd.google.com/debian ${CODENAME} main" | tee /etc/apt/sources.list.d/fluentbit-stable.list
    apt-get update
    apt-get install -y fluent-bit
}

install_rhel() {
    dnf install -y https://packages.fluentbit.fluentd.rpm/yum.repo/fluentbit-1.9.repo
    dnf install -y fluent-bit
}

install_arch() {
    pacman -Sy --noconfirm fluent-bit
}

install_alpine() {
    apk add --no-cache fluent-bit
}

install_binary() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        armv7l) ARCH="armv7" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    URL="https://github.com/fluent/fluent-bit/releases/download/v${FLUENT_BIT_VERSION}/fluent-bit-${FLUENT_BIT_VERSION}-linux-${ARCH}.tar.gz"
    echo "Downloading Fluent Bit ${FLUENT_BIT_VERSION} for ${ARCH}..."
    curl -fsSL "$URL" | tar -xz -C /tmp fluent-bit/sbin/fluent-bit
    install -m 755 /tmp/fluent-bit/sbin/fluent-bit "$INSTALL_DIR/fluent-bit"
    rm -rf /tmp/fluent-bit
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
    cp service/systemd/fluent-bit.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable fluent-bit
}

main() {
    echo "Installing Fluent Bit v${FLUENT_BIT_VERSION}..."
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

    if ! command -v fluent-bit &>/dev/null; then
        install_binary
        create_user
        create_directories
        install_service
    fi

    echo "Fluent Bit installed successfully!"
    echo "Config: $CONFIG_DIR/fluent-bit.conf"
    echo "Start: systemctl start fluent-bit"
}

main "$@"