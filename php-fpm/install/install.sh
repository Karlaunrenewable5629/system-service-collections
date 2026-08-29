#!/bin/bash
set -euo pipefail

PHP_FPM_VERSION="8.2.15"
INSTALL_DIR="/etc/php-fpm"
BACKUP_DIR="/etc/php-fpm.backup.$(date +%Y%m%d%H%M%S)"

# Colors for output
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

check_dependencies() {
    local missing=0
    for cmd in php-fpm; do
        if ! command -v php-fpm &>/dev/null; then
            log_warn "Command 'php-fpm' not found"
            missing=1
        fi
    done
    if [ "$missing" -eq 1 ]; then
        log_error "Please install PHP-FPM first"
        exit 1
    fi
}

create_php_fpm_user() {
    if ! id "nginx" &>/dev/null; then
        log_info "Creating nginx user and group"
        useradd -r -s /bin/false nginx
    else
        log_info "nginx user already exists"
    fi
}

create_directories() {
    log_info "Creating directories"
    mkdir -p /etc/php-fpm/ssl
    mkdir -p /var/log/php-fpm
    mkdir -p /var/lib/php-fpm
    mkdir -p /run/php-fpm

    chown -R nginx:nginx /var/log/php-fpm
    chown -R nginx:nginx /var/lib/php-fpm
    chown -R nginx:nginx /run/php-fpm
}

install_config() {
    log_info "Installing PHP-FPM configuration"
    if [ -f "/etc/php-fpm/php-fpm.conf" ]; then
        log_warn "Backing up existing configuration to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp /etc/php-fpm/php-fpm.conf "$BACKUP_DIR/php-fpm.conf"
    fi
    cp config/php-fpm.conf /etc/php-fpm/php-fpm.conf
    chown nginx:nginx /etc/php-fpm/php-fpm.conf
    chmod 644 /etc/php-fpm/php-fpm.conf
}

install_service() {
    local service_type="${1:-auto}"

    if [ "$service_type" = "auto" ]; then
        if command -v systemctl &>/dev/null; then
            service_type="systemd"
        elif command -v rc-service &>/dev/null; then
            service_type="openrc"
        elif [ -f /etc/init.d ]; then
            service_type="sysvinit"
        else
            log_error "Unsupported init system"
            exit 1
        fi
    fi

    log_info "Installing service for $service_type"

    case "$service_type" in
        systemd)
            cp service/systemd/php-fpm.service /etc/systemd/system/
            systemctl daemon-reload
            systemctl enable php-fpm
            ;;
        openrc)
            cp service/openrc/php-fpm /etc/init.d/php-fpm
            chmod +x /etc/init.d/php-fpm
            rc-update add php-fpm default
            ;;
        sysvinit)
            cp service/sysvinit/php-fpm /etc/init.d/php-fpm
            chmod +x /etc/init.d/php-fpm
            chkconfig --add php-fpm
            chkconfig php-fpm on
            ;;
        *)
            log_error "Unknown service type: $service_type"
            exit 1
            ;;
    esac
}

start_service() {
    log_info "Starting PHP-FPM"
    case "$service_type" in
        systemd) systemctl start php-fpm ;;
        openrc) rc-service php-fpm start ;;
        sysvinit) service php-fpm start ;;
    esac
}

print_summary() {
    log_info "Installation complete!"
    echo ""
    echo "PHP-FPM has been installed and configured."
    echo "Configuration: /etc/php-fpm/php-fpm.conf"
    echo "Logs: /var/log/php-fpm/"
    echo ""
    echo "Useful commands:"
    case "$service_type" in
        systemd)
            echo "  systemctl status php-fpm"
            echo "  systemctl reload php-fpm"
            echo "  systemctl restart php-fpm"
            ;;
        openrc)
            echo "  rc-service php-fpm status"
            echo "  rc-service php-fpm reload"
            echo "  rc-service php-fpm restart"
            ;;
        sysvinit)
            echo "  service php-fpm status"
            echo "  service php-fpm reload"
            echo "  service php-fpm restart"
            ;;
    esac
}

main() {
    check_root
    check_dependencies
    create_php_fpm_user
    create_directories
    install_config
    install_service "${1:-auto}"
    start_service
    print_summary
}

main "$@"