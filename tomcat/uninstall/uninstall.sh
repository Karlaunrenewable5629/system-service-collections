#!/bin/bash
set -euo pipefail

BACKUP_DIR="/etc/tomcat.backup.$(date +%Y%m%d%H%M%S)"

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
    if command -v systemctl &>/dev/null && systemctl list-unit-files | grep -q tomcat; then
        SERVICE_TYPE="systemd"
    elif command -v rc-service &>/dev/null && rc-status | grep -q tomcat; then
        SERVICE_TYPE="openrc"
    elif [ -f /etc/init.d/tomcat ]; then
        SERVICE_TYPE="sysvinit"
    else
        SERVICE_TYPE="unknown"
    fi
}

stop_service() {
    log_info "Stopping tomcat service"
    case "$SERVICE_TYPE" in
        systemd) systemctl stop tomcat ;;
        openrc) rc-service tomcat stop ;;
        sysvinit) service tomcat stop ;;
    esac
}

disable_service() {
    log_info "Disabling tomcat service"
    case "$SERVICE_TYPE" in
        systemd)
            systemctl disable tomcat 2>/dev/null || true
            rm -f /etc/systemd/system/tomcat.service
            systemctl daemon-reload
            ;;
        openrc)
            rc-update del tomcat default 2>/dev/null || true
            rm -f /etc/init.d/tomcat
            ;;
        sysvinit)
            chkconfig --del tomcat 2>/dev/null || true
            rm -f /etc/init.d/tomcat
            ;;
    esac
}

backup_config() {
    if [ -f "/etc/tomcat/server.xml" ]; then
        log_warn "Backing up configuration to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp /etc/tomcat/server.xml "$BACKUP_DIR/server.xml"
        cp /etc/tomcat/tomcat-users.xml "$BACKUP_DIR/tomcat-users.xml"
    fi
}

remove_config() {
    log_info "Removing Tomcat configuration"
    rm -rf /etc/tomcat
}

remove_logs() {
    if [ -d "/var/log/tomcat" ]; then
        log_info "Removing tomcat logs"
        rm -rf /var/log/tomcat
    fi
}

remove_run_dir() {
    if [ -d "/run/tomcat" ]; then
        rm -f /run/tomcat/tomcat.pid 2>/dev/null || true
    fi
}

remove_tomcat_user() {
    if id "tomcat" &>/dev/null; then
        log_warn "Removing tomcat user"
        userdel tomcat 2>/dev/null || true
    fi
}

print_summary() {
    log_info "Uninstallation complete!"
    echo ""
    echo "Tomcat has been removed from your system."
    if [ -d "$BACKUP_DIR" ]; then
        echo "Backup of configuration saved to: $BACKUP_DIR"
    fi
    echo ""
    echo "If you want to remove Tomcat itself, use your package manager:"
    echo "  Debian/Ubuntu: apt remove tomcat"
    echo "  RHEL/CentOS: dnf remove tomcat"
    echo "  Alpine: apk del tomcat"
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
    remove_tomcat_user
    print_summary
}

main "$@"