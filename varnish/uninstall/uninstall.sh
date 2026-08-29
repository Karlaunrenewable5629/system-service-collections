#!/bin/bash
set -euo pipefail

BACKUP_DIR="/etc/varnish.backup.$(date +%Y%m%d%H%M%S)"

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
    if command -v systemctl &>/dev/null && systemctl list-unit-files | grep -q varnish; then
        SERVICE_TYPE="systemd"
    elif command -v rc-service &>/dev/null && rc-status | grep -q varnish; then
        SERVICE_TYPE="openrc"
    elif [ -f /etc/init.d/varnish ]; then
        SERVICE_TYPE="sysvinit"
    else
        SERVICE_TYPE="unknown"
    fi
}

stop_service() {
    log_info "Stopping varnish service"
    case "$SERVICE_TYPE" in
        systemd) systemctl stop varnish ;;
        openrc) rc-service varnish stop ;;
        sysvinit) service varnish stop ;;
    esac
}

disable_service() {
    log_info "Disabling varnish service"
    case "$SERVICE_TYPE" in
        systemd)
            systemctl disable varnish 2>/dev/null || true
            rm -f /etc/systemd/system/varnish.service
            systemctl daemon-reload
            ;;
        openrc)
            rc-update del varnish default 2>/dev/null || true
            rm -f /etc/init.d/varnish
            ;;
        sysvinit)
            chkconfig --del varnish 2>/dev/null || true
            rm -f /etc/init.d/varnish
            ;;
    esac
}

backup_config() {
    if [ -f "/etc/varnish/default.vcl" ]; then
        log_warn "Backing up configuration to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp /etc/varnish/default.vcl "$BACKUP_DIR/default.vcl"
    fi
    if [ -f "/etc/varnish/secret" ]; then
        cp /etc/varnish/secret "$BACKUP_DIR/secret"
    fi
}

remove_config() {
    log_info "Removing Varnish configuration"
    rm -rf /etc/varnish
}

remove_cache() {
    if [ -d "/var/lib/varnish" ]; then
        log_info "Removing Varnish cache data"
        rm -rf /var/lib/varnish
    fi
}

remove_logs() {
    if [ -d "/var/log/varnish" ]; then
        log_info "Removing Varnish logs"
        rm -rf /var/log/varnish
    fi
}

remove_run_dir() {
    rm -f /run/varnishd.pid 2>/dev/null || true
}

remove_varnish_user() {
    if id "varnish" &>/dev/null; then
        log_warn "Removing varnish user"
        userdel varnish 2>/dev/null || true
    fi
}

print_summary() {
    log_info "Uninstallation complete!"
    echo ""
    echo "Varnish has been removed from your system."
    if [ -d "$BACKUP_DIR" ]; then
        echo "Backup of configuration saved to: $BACKUP_DIR"
    fi
    echo ""
    echo "If you want to remove Varnish itself, use your package manager:"
    echo "  Debian/Ubuntu: apt remove varnish"
    echo "  RHEL/CentOS: dnf remove varnish"
    echo "  Alpine: apk del varnish"
}

main() {
    check_root
    detect_init_system
    stop_service
    disable_service
    backup_config
    remove_config
    remove_cache
    remove_logs
    remove_run_dir
    remove_varnish_user
    print_summary
}

main "$@"
