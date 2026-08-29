#!/bin/bash
set -euo pipefail

BACKUP_DIR="/etc/php-fpm.backup.$(date +%Y%m%d%H%M%S)"

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
    if command -v systemctl &>/dev/null && systemctl list-unit-files | grep -q php-fpm; then
        SERVICE_TYPE="systemd"
    elif command -v rc-service &>/dev/null && rc-status | grep -q php-fpm; then
        SERVICE_TYPE="openrc"
    elif [ -f /etc/init.d/php-fpm ]; then
        SERVICE_TYPE="sysvinit"
    else
        SERVICE_TYPE="unknown"
    fi
}

stop_service() {
    log_info "Stopping php-fpm service"
    case "$SERVICE_TYPE" in
        systemd) systemctl stop php-fpm ;;
        openrc) rc-service php-fpm stop ;;
        sysvinit) service php-fpm stop ;;
    esac
}

disable_service() {
    log_info "Disabling php-fpm service"
    case "$SERVICE_TYPE" in
        systemd)
            systemctl disable php-fpm 2>/dev/null || true
            rm -f /etc/systemd/system/php-fpm.service
            systemctl daemon-reload
            ;;
        openrc)
            rc-update del php-fpm default 2>/dev/null || true
            rm -f /etc/init.d/php-fpm
            ;;
        sysvinit)
            chkconfig --del php-fpm 2>/dev/null || true
            rm -f /etc/init.d/php-fpm
            ;;
    esac
}

backup_config() {
    if [ -f "/etc/php-fpm/php-fpm.conf" ]; then
        log_warn "Backing up configuration to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp /etc/php-fpm/php-fpm.conf "$BACKUP_DIR/php-fpm.conf"
    fi
}

remove_config() {
    log_info "Removing PHP-FPM configuration"
    rm -rf /etc/php-fpm
}

remove_logs() {
    if [ -d "/var/log/php-fpm" ]; then
        log_info "Removing php-fpm logs"
        rm -rf /var/log/php-fpm
    fi
}

remove_run_dir() {
    if [ -d "/run/php-fpm" ]; then
        rm -f /run/php-fpm/php-fpm.pid 2>/dev/null || true
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
    echo "PHP-FPM has been removed from your system."
    if [ -d "$BACKUP_DIR" ]; then
        echo "Backup of configuration saved to: $BACKUP_DIR"
    fi
    echo ""
    echo "If you want to remove PHP-FPM itself, use your package manager:"
    echo "  Debian/Ubuntu: apt remove php-fpm"
    echo "  RHEL/CentOS: dnf remove php-fpm"
    echo "  Alpine: apk del php-fpm"
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
    remove_nginx_user
    print_summary
}

main "$@"