#!/usr/bin/env bash
# =============================================================================
# Authentik Uninstall Script
# =============================================================================
# Removes the Authentik identity provider installation from the system.
#
# Usage:
#   sudo ./uninstall.sh [--purge] [--keep-data]
#
# Options:
#   --purge       Remove configuration files in addition to binaries.
#                 WARNING: This cannot be undone.
#   --keep-data   Preserve /var/lib/authentik (media uploads, etc.).
#
# Without options, the script removes services and the installed application
# but leaves configuration and data directories intact.
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

AUTHENTIK_USER="authentik"
AUTHENTIK_GROUP="authentik"
INSTALL_DIR="/opt/authentik"
CONFIG_DIR="/etc/authentik"
DATA_DIR="/var/lib/authentik"
LOG_DIR="/var/log/authentik"
PURGE=false
KEEP_DATA=false

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

log_info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

die() {
    log_error "$*"
    exit 1
}

require_root() {
    [[ "${EUID}" -eq 0 ]] || die "This script must be run as root (use sudo)."
}

detect_init() {
    if command -v systemctl &>/dev/null && systemctl --version &>/dev/null 2>&1; then
        echo "systemd"
    elif command -v rc-service &>/dev/null; then
        echo "openrc"
    elif [[ -d /etc/init.d ]]; then
        echo "sysvinit"
    else
        echo "unknown"
    fi
}

# -----------------------------------------------------------------------------
# Argument Parsing
# -----------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        --purge)
            PURGE=true
            shift
            ;;
        --keep-data)
            KEEP_DATA=true
            shift
            ;;
        -h|--help)
            sed -n '/^# Usage:/,/^# ====/{ /^# ====/d; s/^# \?//; p }' "$0"
            exit 0
            ;;
        *)
            die "Unknown argument: $1"
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Pre-flight
# -----------------------------------------------------------------------------

require_root

INIT_SYSTEM="$(detect_init)"

log_info "Authentik Uninstall"
log_info "Init system : ${INIT_SYSTEM}"
log_info "Purge config: ${PURGE}"
log_info "Keep data   : ${KEEP_DATA}"

if [[ "${PURGE}" == "true" ]]; then
    echo ""
    log_warn "PURGE mode is enabled!"
    log_warn "This will permanently delete configuration files in ${CONFIG_DIR}."
    read -r -p "Are you sure? Type YES to continue: " CONFIRM
    [[ "${CONFIRM}" == "YES" ]] || { log_info "Aborted."; exit 0; }
fi

# -----------------------------------------------------------------------------
# Stop and Disable Services
# -----------------------------------------------------------------------------

log_info "Stopping and disabling services..."

case "${INIT_SYSTEM}" in
    systemd)
        for unit in authentik-server authentik-worker; do
            if systemctl is-active --quiet "${unit}" 2>/dev/null; then
                systemctl stop "${unit}"
                log_ok "Stopped: ${unit}"
            fi
            if systemctl is-enabled --quiet "${unit}" 2>/dev/null; then
                systemctl disable "${unit}"
                log_ok "Disabled: ${unit}"
            fi
            UNIT_FILE="/etc/systemd/system/${unit}.service"
            if [[ -f "${UNIT_FILE}" ]]; then
                rm -f "${UNIT_FILE}"
                log_ok "Removed unit file: ${UNIT_FILE}"
            fi
        done
        systemctl daemon-reload
        ;;

    openrc)
        for svc in authentik-server authentik-worker; do
            if rc-service "${svc}" status &>/dev/null; then
                rc-service "${svc}" stop
                log_ok "Stopped: ${svc}"
            fi
            rc-update del "${svc}" default 2>/dev/null || true
            INIT_SCRIPT="/etc/init.d/${svc}"
            if [[ -f "${INIT_SCRIPT}" ]]; then
                rm -f "${INIT_SCRIPT}"
                log_ok "Removed init script: ${INIT_SCRIPT}"
            fi
        done
        ;;

    sysvinit)
        for svc in authentik-server authentik-worker; do
            if service "${svc}" status &>/dev/null; then
                service "${svc}" stop
                log_ok "Stopped: ${svc}"
            fi
            INIT_SCRIPT="/etc/init.d/${svc}"
            if [[ -f "${INIT_SCRIPT}" ]]; then
                update-rc.d "${svc}" remove 2>/dev/null || true
                rm -f "${INIT_SCRIPT}"
                log_ok "Removed init script: ${INIT_SCRIPT}"
            fi
        done
        ;;

    *)
        log_warn "Unknown init system — skipping service removal."
        ;;
esac

# -----------------------------------------------------------------------------
# Remove Application Files
# -----------------------------------------------------------------------------

log_info "Removing application files..."

if [[ -d "${INSTALL_DIR}" ]]; then
    rm -rf "${INSTALL_DIR}"
    log_ok "Removed: ${INSTALL_DIR}"
else
    log_info "Not found (already removed): ${INSTALL_DIR}"
fi

# Remove PID directory
if [[ -d /run/authentik ]]; then
    rm -rf /run/authentik
    log_ok "Removed: /run/authentik"
fi

# -----------------------------------------------------------------------------
# Configuration Files
# -----------------------------------------------------------------------------

if [[ "${PURGE}" == "true" ]]; then
    log_info "Removing configuration files (--purge)..."
    if [[ -d "${CONFIG_DIR}" ]]; then
        rm -rf "${CONFIG_DIR}"
        log_ok "Removed: ${CONFIG_DIR}"
    fi
else
    log_info "Preserving configuration: ${CONFIG_DIR}"
    log_info "  To remove manually: sudo rm -rf ${CONFIG_DIR}"
fi

# -----------------------------------------------------------------------------
# Data Directory
# -----------------------------------------------------------------------------

if [[ "${KEEP_DATA}" == "true" ]]; then
    log_info "Preserving data directory: ${DATA_DIR}"
elif [[ "${PURGE}" == "true" ]]; then
    log_info "Removing data directory (--purge)..."
    if [[ -d "${DATA_DIR}" ]]; then
        rm -rf "${DATA_DIR}"
        log_ok "Removed: ${DATA_DIR}"
    fi
else
    log_info "Preserving data directory: ${DATA_DIR}"
    log_info "  To remove manually: sudo rm -rf ${DATA_DIR}"
fi

# Logs
if [[ "${PURGE}" == "true" ]]; then
    if [[ -d "${LOG_DIR}" ]]; then
        rm -rf "${LOG_DIR}"
        log_ok "Removed: ${LOG_DIR}"
    fi
else
    log_info "Preserving log directory: ${LOG_DIR}"
fi

# -----------------------------------------------------------------------------
# System User and Group
# -----------------------------------------------------------------------------

log_info "Removing system user and group..."

if id "${AUTHENTIK_USER}" &>/dev/null; then
    userdel "${AUTHENTIK_USER}"
    log_ok "Removed user: ${AUTHENTIK_USER}"
else
    log_info "User not found (already removed): ${AUTHENTIK_USER}"
fi

if getent group "${AUTHENTIK_GROUP}" &>/dev/null; then
    groupdel "${AUTHENTIK_GROUP}"
    log_ok "Removed group: ${AUTHENTIK_GROUP}"
else
    log_info "Group not found (already removed): ${AUTHENTIK_GROUP}"
fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------

echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN} Authentik uninstallation complete.${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
if [[ "${PURGE}" != "true" ]]; then
    echo "  The following were preserved:"
    [[ -d "${CONFIG_DIR}" ]] && echo "    Config : ${CONFIG_DIR}"
    [[ -d "${DATA_DIR}" ]]   && echo "    Data   : ${DATA_DIR}"
    [[ -d "${LOG_DIR}" ]]    && echo "    Logs   : ${LOG_DIR}"
    echo ""
    echo "  To remove all data, re-run with:  sudo ./uninstall.sh --purge"
fi
echo ""
