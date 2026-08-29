#!/bin/bash
# vllm Installation Script
# Supports: Ubuntu/Debian, CentOS/RHEL/Fedora, Arch, Alpine

set -euo pipefail

SERVICE_NAME="vllm"
INSTALL_DIR="/opt/${SERVICE_NAME}"
CONFIG_DIR="/etc/${SERVICE_NAME}"
DATA_DIR="/var/lib/${SERVICE_NAME}"
LOG_DIR="/var/log/${SERVICE_NAME}"
USER="vllm"
GROUP="vllm"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        log_error "Cannot detect OS"
        exit 1
    fi
}

create_user() {
    if ! id "${USER}" &>/dev/null; then
        log_info "Creating user ${USER}"
        useradd -r -s /bin/false -d ${DATA_DIR} -M ${USER}
    fi
}

create_dirs() {
    log_info "Creating directories"
    mkdir -p ${INSTALL_DIR} ${CONFIG_DIR} ${DATA_DIR} ${LOG_DIR}
    chown -R ${USER}:${GROUP} ${DATA_DIR} ${LOG_DIR}
    chmod 750 ${DATA_DIR} ${LOG_DIR}
}

install_vllm() {
    log_info "Installing vLLM"
    pip3 install --upgrade vllm
}

main() {
    log_info "Installing ${SERVICE_NAME}..."
    detect_os
    create_user
    create_dirs
    install_vllm
    log_info "Installation complete. Configure ${CONFIG_DIR}/config.yaml and start service."
}

main "$@"