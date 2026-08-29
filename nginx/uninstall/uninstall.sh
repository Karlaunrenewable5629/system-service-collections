#!/bin/bash
set -euo pipefail

BACKUP_DIR="/etc/nginx.backup.$(date +%Y%m%d%H%M%S)"

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
    if command -v systemctl &>/dev/null && systemctl list-unit-files | grep -q nginx; then
        SERVICE_TYPE="systemd"
    elif command -v rc-service &>/dev/null && rc-status | grep -q nginx; then
        SERVICE_TYPE="openrc"
    elif [ -f /etc/init.d/nginx ]; then
        SERVICE_TYPE="sysvinit"
    else
        SERVICE_TYPE="unknown"
    fi
}

stop_service() {
    log_info "Stopping nginx service"
    case "$SERVICE_TYPE" in
        systemd) systemctl stop nginx ;;
        openrc) rc-service nginx stop ;;
        sysvinit) service nginx stop ;;
    esac
}

disable_service() {
    log_info "Disabling nginx service"
    case "$SERVICE_TYPE" in
        systemd)
            systemctl disable nginx 2>/dev/null || true
            rm -f /etc/systemd/system/nginx.service
            systemctl daemon-reload
            ;;
        openrc)
            rc-update del nginx default 2>/dev/null || true
            rm -f /etc/init.d/nginx
            ;;
        sysvinit)
            chkconfig --del nginx 2>/dev/null || true
            rm -f /etc/init.d/nginx
            ;;
    esac
}

backup_config() {
    if [ -f "/etc/nginx/nginx.conf" ]; then
        log_warn "Backing up configuration to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp /etc/nginx/nginx.conf "$BACKUP_DIR/nginx.conf"
    fi
}

remove_config() {
    log_info "Removing nginx configuration"
    rm -rf /etc/nginx
}

remove_ssl() {
    if [ -d "/etc/nginx/ssl" ]; then
        log_info "Removing SSL certificates"
        rm -rf /etc/nginx/ssl
    fi
}

remove_logs() {
    if [ -d "/var/log/nginx" ]; then
        log_info "Removing nginx logs"
        rm -rf /var/log/nginx
    fi
}

remove_web_root() {
    if [ -d "/var/www/html" ]; then
        log_warn "Removing web root directory"
        rm -rf /var/www/html
    fi
}

remove_run_dir() {
    if [ -d "/run" ]; then
        rm -f /run/nginx.pid 2>/dev/null || true
    fi
}

remove_nginx_user() {
    if id "nginx" &>/dev/null; then
        log_warn "Removing nginx user"
        userdel nginx 2>/dev/null || true
    fi
}

print_summary() {
    log_info "Uninstallation complete!"
    echo ""
    echo "nginx has been removed from your system."
    if [ -d "$BACKUP_DIR" ]; then
        echo "Backup of configuration saved to: $BACKUP_DIR"
    fi
    echo ""
    echo "If you want to remove nginx itself, use your package manager:"
    echo "  Debian/Ubuntu: apt remove nginx"
    echo "  RHEL/CentOS: dnf remove nginx"
    echo "  Alpine: apk del nginx"
}

main() {
    check_root
    detect_init_system
    stop_service
    disable_service
    backup_config
    remove_config
    remove_ssl
    remove_logs
    remove_web_root
    remove_run_dir
    remove_nginx_user
    print_summary
}

main "$@"