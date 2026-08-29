#!/bin/bash
#
# nginx-proxy-manager Uninstallation Script
#

set -euo pipefail

APP_NAME="nginx-proxy-manager"
INSTALL_DIR="/usr/lib/nginx-proxy-manager"
CONFIG_DIR="/etc/nginx-proxy-manager"
LOG_DIR="/var/log/nginx-proxy-manager"
DATA_DIR="/var/lib/nginx-proxy-manager"
USER="npm"
GROUP="npm"

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

confirm() {
    echo ""
    echo "=============================================="
    echo "  WARNING: This will completely remove"
    echo "  nginx-proxy-manager and all its data."
    echo "=============================================="
    echo ""
    read -rp "Are you sure you want to continue? [yes/no] " ANSWER
    if [ "${ANSWER}" != "yes" ]; then
        log_info "Uninstallation cancelled."
        exit 0
    fi
}

stop_service() {
    log_info "Stopping ${APP_NAME} service..."
    if command -v systemctl &>/dev/null; then
        systemctl stop "${APP_NAME}" 2>/dev/null || true
        systemctl disable "${APP_NAME}" 2>/dev/null || true
        systemctl daemon-reload 2>/dev/null || true
    elif command -v rc-service &>/dev/null; then
        rc-service "${APP_NAME}" stop 2>/dev/null || true
        rc-update del "${APP_NAME}" default 2>/dev/null || true
    elif [ -f /etc/init.d/"${APP_NAME}" ]; then
        service "${APP_NAME}" stop 2>/dev/null || true
        update-rc.d -f "${APP_NAME}" remove 2>/dev/null || true
        chkconfig "${APP_NAME}" off 2>/dev/null || true
    elif command -v nssm &>/dev/null; then
        nssm stop "${APP_NAME}" 2>/dev/null || true
        nssm remove "${APP_NAME}" confirm 2>/dev/null || true
    else
        log_warn "No recognized service manager found. Attempting to kill process..."
        pkill -f "nginx-proxy-manager" 2>/dev/null || true
    fi
    log_info "Service stopped."
}

remove_service_files() {
    log_info "Removing service files..."
    rm -f /etc/systemd/system/${APP_NAME}.service 2>/dev/null || true
    rm -f /etc/init.d/${APP_NAME} 2>/dev/null || true
    rm -f /etc/init.d/nginx-proxy-manager 2>/dev/null || true
    if command -v systemctl &>/dev/null; then
        systemctl daemon-reload 2>/dev/null || true
    fi
    log_info "Service files removed."
}

remove_application() {
    log_info "Removing application from ${INSTALL_DIR}..."
    if [ -d "${INSTALL_DIR}" ]; then
        rm -rf "${INSTALL_DIR:?}/"*
        log_info "Application files removed."
    else
        log_warn "Installation directory not found: ${INSTALL_DIR}"
    fi
}

remove_config() {
    log_info "Removing configuration files..."
    rm -rf "${CONFIG_DIR}" 2>/dev/null || true
    log_info "Configuration files removed."
}

remove_logs() {
    log_info "Removing log files..."
    rm -rf "${LOG_DIR}" 2>/dev/null || true
    log_info "Log files removed."
}

remove_data() {
    log_info "Removing data (database, certificates)..."
    rm -rf "${DATA_DIR}" 2>/dev/null || true
    log_info "Data removed."
}

remove_user() {
    log_info "Removing '${USER}' user and group..."
    userdel "${USER}" 2>/dev/null || true
    groupdel "${GROUP}" 2>/dev/null || true
    log_info "User and group removed."
}

clean_ports() {
    log_info "Cleaning up firewall rules..."
    if command -v ufw &>/dev/null; then
        ufw delete allow 80/tcp 2>/dev/null || true
        ufw delete allow 443/tcp 2>/dev/null || true
        ufw delete allow 81/tcp 2>/dev/null || true
        log_info "UFW rules removed."
    elif command -v firewall-cmd &>/dev/null; then
        firewall-cmd --permanent --remove-port=80/tcp 2>/dev/null || true
        firewall-cmd --permanent --remove-port=443/tcp 2>/dev/null || true
        firewall-cmd --permanent --remove-port=81/tcp 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
        log_info "Firewall-cmd rules removed."
    else
        log_warn "Firewall rules could not be removed automatically."
    fi
}

verify_uninstallation() {
    log_info ""
    log_info "Verification:"
    if [ -d "${INSTALL_DIR}" ] && [ "$(ls -A ${INSTALL_DIR})" ]; then
        log_warn "Application directory is not empty. You may need to remove it manually."
    else
        log_info "Application directory cleaned."
    fi

    if command -v systemctl &>/dev/null; then
        if systemctl list-unit-files | grep -q "${APP_NAME}"; then
            log_warn "Service may still be registered. Run: systemctl disable ${APP_NAME}"
        else
            log_info "Service unit removed."
        fi
    fi

    log_info ""
    log_info "Uninstallation complete!"
    log_info "You may need to remove any remaining files manually."
}

main() {
    check_root
    confirm
    stop_service
    remove_service_files
    remove_application
    remove_config
    remove_logs
    remove_data
    remove_user
    clean_ports
    verify_uninstallation
}

main "$@"
