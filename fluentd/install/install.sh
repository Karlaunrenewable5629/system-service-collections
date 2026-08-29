#!/bin/bash
# Fluentd Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Arch, Alpine

set -euo pipefail

FLUENTD_VERSION="${FLUENTD_VERSION:-1.17.3}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/fluentd"
DATA_DIR="/var/lib/fluentd"
LOG_DIR="/var/log/fluentd"
USER="fluentd"
GROUP="fluent-detect"

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
    curl -1sLf 'https://packages.treasuredata.com/GPG-KEY-yum' | gpg --dearmor -o /usr/share/keyrings/treasuredata-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/treasuredata-archive-keyring.gpg] https://packages.treasuredata.com/debian ${CODENAME} stable-2" | tee /etc/apt/sources.list.d/treasuredata.list
    apt-get update
    apt-get install -y fluentd
}

install_rhel() {
    dnf install -y https://packages.fluentd.org/fluentd.rpm/fluentd.repo
    dnf install -y fluentd
}

install_arch() {
    pacman -Sy --noconfirm fluentd
}

install_alpine() {
    apk add --no-cache fluentd
}

install_gem() {
    gem install fluentd -v "${FLUENTD_VERSION}" --no-document
    fluentd --setup
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
    cp service/systemd/fluentd.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable fluentd
}

main() {
    echo "Installing Fluentd v${FLUENTD_VERSION}..."
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
            echo "OS $OS not directly supported, installing from gem..."
            install_gem
            create_user
            create_directories
            install_service
            ;;
    esac

    if ! command -v fluentd &>/dev/null; then
        install_gem
        create_user
        create_directories
        install_service
    fi

    echo "Fluentd installed successfully!"
    echo "Config: $CONFIG_DIR/fluentd.conf"
    echo "Start: systemctl start fluentd"
}

main "$@"