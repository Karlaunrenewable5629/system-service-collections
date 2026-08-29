#!/bin/bash
# Jenkins Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Alpine
# Installs Jenkins LTS as a system service

set -euo pipefail

JENKINS_VERSION="${JENKINS_VERSION:-2.426.3}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/jenkins"
DATA_DIR="/var/jenkins_home"
LOG_DIR="/var/log/jenkins"
USER="jenkins"
GROUP="jenkins"

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
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list"
    apt-get update
    apt-get install -y jenkins
}

install_rhel() {
    dnf install -y dnf-command(copr)
    dnf copr enable -y jenkins-lts
    dnf install -y jenkins
}

install_alpine() {
    apk add --no-cache openjdk11 git
    # Install Jenkins war manually
    JENKINS_URL="https://repo.jenkins-ci.org/public/org/jenkins-ci/war/${JENKINS_VERSION}/jenkins-${JENKINS_VERSION}.war"
    curl -fL "$JENKINS_URL" -o "$INSTALL_DIR/jenkins.war"
}

install_binary() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    case $OS in
        ubuntu|debian) install_debian ;;
        rhel|centos|fedora) install_rhel ;;
        alpine) install_alpine ;;
        *) echo "OS $OS not directly supported, installing from binary..."; install_binary_fallback ;;
    esac
}

install_binary_fallback() {
    JENKINS_URL="https://repo.jenkins-ci.org/public/org/jenkins-ci/war/${JENKINS_VERSION}/jenkins-${JENKINS_VERSION}.war"
    echo "Downloading Jenkins ${JENKINS_VERSION}..."
    curl -fsSL "$JENKINS_URL" -o "$INSTALL_DIR/jenkins.war"
    chmod +x "$INSTALL_DIR/jenkins.war"
}

create_user() {
    if ! id "$USER" &>/dev/null; then
        useradd --system --create-home --shell /usr/sbin/nologin "$USER"
    fi
}

create_directories() {
    mkdir -p "$DATA_DIR" "$LOG_DIR" "$CONFIG_DIR"
    chown -R "$USER:$GROUP" "$DATA_DIR" "$LOG_DIR" "$CONFIG_DIR"
    chmod 750 "$DATA_DIR" "$LOG_DIR" "$CONFIG_DIR"
}

install_service() {
    cp service/systemd/jenkins.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable jenkins
}

main() {
    echo "Installing Jenkins v${JENKINS_VERSION}..."
    detect_os
    create_user
    create_directories

    case $OS in
        ubuntu|debian) install_debian ;;
        rhel|centos|fedora) install_rhel ;;
        alpine) install_alpine ;;
        *) install_binary_fallback ;;
    esac

    install_service

    echo "Jenkins installed successfully!"
    echo "Config: $CONFIG_DIR"
    echo "Data: $DATA_DIR"
    echo "Start: systemctl start jenkins"
}

main "$@"