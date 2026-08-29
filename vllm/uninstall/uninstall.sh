#!/bin/bash
# vllm Uninstallation Script

set -euo pipefail

SERVICE_NAME="vllm"
INSTALL_DIR="/opt/${SERVICE_NAME}"
CONFIG_DIR="/etc/${SERVICE_NAME}"
DATA_DIR="/var/lib/${SERVICE_NAME}"
LOG_DIR="/var/log/${SERVICE_NAME}"
USER="vllm"

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }

stop_service() {
    if systemctl is-active --quiet ${SERVICE_NAME} 2>/dev/null; then
        log_info "Stopping ${SERVICE_NAME} service"
        systemctl stop ${SERVICE_NAME}
        systemctl disable ${SERVICE_NAME}
    fi
    if command -v rc-service &>/dev/null && rc-service ${SERVICE_NAME} status &>/dev/null; then
        rc-service ${SERVICE_NAME} stop
        rc-update del ${SERVICE_NAME} default
    fi
}

remove_files() {
    log_info "Removing files"
    rm -rf ${INSTALL_DIR} ${CONFIG_DIR}
    log_warn "Preserving data in ${DATA_DIR} and logs in ${LOG_DIR}. Remove manually if needed."
}

remove_user() {
    if id "${USER}" &>/dev/null; then
        log_info "Removing user ${USER}"
        userdel ${USER} 2>/dev/null || true
    fi
}

main() {
    log_info "Uninstalling ${SERVICE_NAME}..."
    stop_service
    remove_files
    remove_user
    log_info "Uninstallation complete"
}

main "$@"