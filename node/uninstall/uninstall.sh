#!/bin/bash
set -euo pipefail

BACKUP_DIR="/etc/node.backup.$(date +%Y%m%d%H%M%S)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

detect_init_system() {
    if command -v systemctl &>/dev/null && systemctl list-unit-files | grep -q node; then
        SERVICE_TYPE="systemd"
    elif command -v rc-service &>/dev/null && rc-status | grep -q node; then
        SERVICE_TYPE="openrc"
    elif [ -f /etc/init.d/node ]; then
        SERVICE_TYPE="sysvinit"
    else
        SERVICE_TYPE="unknown"
    fi
}

stop_service() {
    log_info "Stopping node service"
    case "$SERVICE_TYPE" in
        systemd) systemctl stop node ;;
        openrc) rc-service node stop ;;
        sysvinit) service node stop ;;
    esac
}

disable_service() {
    log_info "Disabling node service"
    case "$SERVICE_TYPE" in
        systemd)
            systemctl disable node 2>/dev/null || true
            rm -f /etc/systemd/system/node.service
            systemctl daemon-reload
            ;;
        openrc)
            rc-update del node default 2>/dev/null || true
            rm -f /etc/init.d/node
            ;;
        sysvinit)
            chkconfig --del node 2>/dev/null || true
            rm -f /etc/init.d/node
            ;;
    esac
}

backup_config() {
    if [ -f "/etc/node/config.yaml" ]; then
        log_warn "Backing up configuration to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp /etc/node/config.yaml "$BACKUP_DIR/config.yaml"
    fi
}

remove_config() {
    log_info "Removing Node.js configuration"
    rm -rf /etc/node
}

remove_logs() {
    if [ -d "/var/log/node" ]; then
        log_info "Removing node logs"
        rm -rf /var/log/node
    fi
}

remove_run_dir() {
    if [ -d "/run/node" ]; then
        rm -f /run/node/node.pid 2>/dev/null || true
    fi
}

remove_node_user() {
    if id "node" &>/dev/null; then
        log_warn "Removing node user"
        userdel node 2>/dev/null || true
    fi
}

print_summary() {
    log_info "Uninstallation complete!"
    echo ""
    echo "Node.js has been removed from your system."
    if [ -d "$BACKUP_DIR" ]; then
        echo "Backup of configuration saved to: $BACKUP_DIR"
    fi
    echo ""
    echo "If you want to remove Node.js itself, use your package manager:"
    echo "  Debian/Ubuntu: apt remove nodejs"
    echo "  RHEL/CentOS: dnf remove nodejs"
    echo "  Alpine: apk del nodejs"
}

main() {
    check_root
    detect_init_system
    stop_service
    disable_service
    backup_config
    remove_config
    remove_logs
    remove_run_dir
    remove_node_user
    print_summary
}

main "$@"