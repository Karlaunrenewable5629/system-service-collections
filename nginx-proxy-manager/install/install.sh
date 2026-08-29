#!/bin/bash
#
# nginx-proxy-manager Installation Script
#

set -euo pipefail

VERSION="2.9.9"
APP_NAME="nginx-proxy-manager"
INSTALL_DIR="/usr/lib/nginx-proxy-manager"
CONFIG_DIR="/etc/nginx-proxy-manager"
LOG_DIR="/var/log/nginx-proxy-manager"
DATA_DIR="/var/lib/nginx-proxy-manager"
USER="npm"
GROUP="npm"
NODE_BIN="/usr/bin/node"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log_error "This script must be run as root."
        exit 1
    fi
}

check_node() {
    if ! command -v node &>/dev/null; then
        log_error "Node.js is not installed. Please install Node.js 18+ first."
        exit 1
    fi
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        log_error "Node.js version 18 or higher is required (found $(node --version))."
        exit 1
    fi
    log_info "Node.js found: $(node --version)"
}

check_npm() {
    if ! command -v npm &>/dev/null; then
        log_error "npm is not installed. Please install npm first."
        exit 1
    fi
    log_info "npm found: $(npm --version)"
}

create_user() {
    if id "${USER}" &>/dev/null; then
        log_info "User '${USER}' already exists."
    else
        log_info "Creating user '${USER}'..."
        useradd -r -s /bin/false -g "${GROUP}" "${USER}" 2>/dev/null || \
            groupadd -f "${GROUP}" && useradd -r -s /bin/false -g "${GROUP}" "${USER}"
    fi
}

create_directories() {
    log_info "Creating directories..."
    mkdir -p "${INSTALL_DIR}"
    mkdir -p "${CONFIG_DIR}"
    mkdir -p "${LOG_DIR}"
    mkdir -p "${DATA_DIR}"

    chown -R "${USER}:${USER}" "${LOG_DIR}"
    chown -R "${USER}:${USER}" "${DATA_DIR}"
    chmod 755 "${LOG_DIR}"
    chmod 755 "${DATA_DIR}"
}

install_application() {
    log_info "Installing nginx-proxy-manager to ${INSTALL_DIR}..."

    if [ -d "${INSTALL_DIR}/node_modules" ]; then
        log_info "Application already installed. Skipping npm install."
        return 0
    fi

    # Copy application files
    cp -r ./* "${INSTALL_DIR}/" 2>/dev/null || true

    # Install Node.js dependencies
    log_info "Installing Node.js dependencies..."
    cd "${INSTALL_DIR}"
    npm install --production 2>&1 || log_warn "npm install had issues, continuing..."
}

install_service() {
    log_info "Installing service..."
    local service_file=""
    local service_name="${APP_NAME}"

    if command -v systemctl &>/dev/null; then
        service_file="service/systemd/nginx-proxy-manager.service"
        cp "${service_file}" /etc/systemd/system/
        systemctl daemon-reload
        systemctl enable "${service_name}"
        systemctl start "${service_name}"
        log_info "systemd service installed and started."
    elif command -v rc-service &>/dev/null; then
        service_file="service/openrc/nginx-proxy-manager"
        cp "${service_file}" /etc/init.d/
        chmod +x /etc/init.d/"${service_name}"
        rc-update add "${service_name}" default
        rc-service "${service_name}" start
        log_info "OpenRC service installed and started."
    elif [ -f /etc/init.d/ ] || [ -f /etc/rc.d/init.d ]; then
        service_file="service/sysvinit/nginx-proxy-manager"
        cp "${service_file}" /etc/init.d/
        chmod +x /etc/init.d/"${service_name}"
        update-rc.d "${service_name}" defaults 2>/dev/null || \
            chkconfig "${service_name}" on 2>/dev/null || true
        service "${service_name}" start
        log_info "SysVinit service installed and started."
    else
        log_warn "No supported init system found. Service was not installed."
        log_warn "You can manually install the service from the service/ directory."
    fi
}

install_config() {
    log_info "Installing configuration..."
    if [ ! -f "${CONFIG_DIR}/npm.yaml" ]; then
        cp config/npm.yaml "${CONFIG_DIR}/npm.yaml"
        chown "${USER}:${USER}" "${CONFIG_DIR}/npm.yaml"
        chmod 640 "${CONFIG_DIR}/npm.yaml"
        log_info "Configuration file installed to ${CONFIG_DIR}/npm.yaml"
    else
        log_warn "Configuration file already exists at ${CONFIG_DIR}/npm.yaml. Skipping."
    fi
}

setup_firewall() {
    log_info "Configuring firewall rules..."
    if command -v ufw &>/dev/null; then
        ufw allow 80/tcp comment "nginx-proxy-manager HTTP"
        ufw allow 443/tcp comment "nginx-proxy-manager HTTPS"
        ufw allow 81/tcp comment "nginx-proxy-manager Admin UI"
        log_info "Firewall rules added (ufw)."
    elif command -v firewall-cmd &>/dev/null; then
        firewall-cmd --permanent --add-port=80/tcp
        firewall-cmd --permanent --add-port=443/tcp
        firewall-cmd --permanent --add-port=81/tcp
        firewall-cmd --reload
        log_info "Firewall rules added (firewalld)."
    else
        log_warn "Firewall configuration skipped. Configure manually for ports 80, 443, 81."
    fi
}

verify_installation() {
    log_info "Verifying installation..."
    if command -v systemctl &>/dev/null; then
        systemctl status "${APP_NAME}" --no-pager 2>/dev/null || true
    elif command -v rc-service &>/dev/null; then
        rc-service "${APP_NAME}" status 2>/dev/null || true
    fi

    log_info ""
    log_info "Installation complete!"
    log_info "Admin UI: http://localhost:81"
    log_info "Default credentials: admin@example.com / changeme"
    log_info "Logs: ${LOG_DIR}/npm.log"
}

main() {
    log_info "Starting nginx-proxy-manager installation (v${VERSION})..."
    check_root
    check_node
    check_npm
    create_user
    create_directories
    install_application
    install_config
    install_service
    setup_firewall
    verify_installation
}

main "$@"
