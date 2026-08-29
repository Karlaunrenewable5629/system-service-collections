#!/bin/bash
# Puppet Agent Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Alpine
# Installs Puppet Agent as a system service

set -euo pipefail

PUPPET_VERSION="${PUPPET_VERSION:-8.10.0}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/puppetlabs/puppet"
DATA_DIR="/var/lib/puppet"
LOG_DIR="/var/log/puppet"
USER="puppet"
GROUP="puppet"

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
    curl -1sLf https://apt.puppet.com/puppet6-release.deb | gpg --dearmor -o /usr/share/keyrings/puppet-archive-keyring.gpg
    gdebi -i https://apt.puppet.com/puppet6-release.deb
    apt-get update
    apt-get install -y puppet-agent
}

install_rhel() {
    dnf install -y dnf-command(copr)
    dnf copr enable -y puppet7/puppet
    dnf install -y puppet
}

install_binary() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    # Download Puppet Labs repo and install
    curl -1sLf https://downloads.puppet.com/yum/el/7/PC1/${ARCH}/puppet-release-8.10.0-1.el7.no.rpm -o /tmp/puppet.rpm
    dnf install -y /tmp/puppet.rpm
    rm -f /tmp/puppet.rpm
    dnf install -y puppet-agent
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
    cp service/systemd/puppet.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable puppet
}

main() {
    echo "Installing Puppet Agent v${PUPPET_VERSION}..."
    detect_os

    case $OS in
        ubuntu|debian) install_debian ;;
        rhel|centos|fedora) install_rhel ;;
        *) install_binary ;;
    esac

    create_user
    create_directories
    install_service

    echo "Puppet Agent installed successfully!"
    echo "Config: $CONFIG_DIR/puppet.conf"
    echo "Start: systemctl start puppet"
}

main "$@"