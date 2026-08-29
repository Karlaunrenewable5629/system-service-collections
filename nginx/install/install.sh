#!/bin/bash
set -euo pipefail

NGINX_VERSION="1.26.2"
INSTALL_DIR="/etc/nginx"
BACKUP_DIR="/etc/nginx.backup.$(date +%Y%m%d%H%M%S)"

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
    for cmd in nginx; do
        if ! command -v "$cmd" &>/dev/null; then
            log_warn "Command '$cmd' not found"
            missing=1
        fi
    done
    if [ "$missing" -eq 1 ]; then
        log_error "Please install nginx first"
        exit 1
    fi
}

create_nginx_user() {
    if ! id "nginx" &>/dev/null; then
        log_info "Creating nginx user and group"
        useradd -r -s /bin/false nginx
    else
        log_info "nginx user already exists"
    fi
}

create_directories() {
    log_info "Creating directories"
    mkdir -p /etc/nginx/ssl
    mkdir -p /var/log/nginx
    mkdir -p /var/www/html
    mkdir -p /run

    chown -R nginx:nginx /var/log/nginx
    chown -R nginx:nginx /var/www/html
    chown -R nginx:nginx /run
}

install_config() {
    log_info "Installing nginx configuration"
    if [ -f "/etc/nginx/nginx.conf" ]; then
        log_warn "Backing up existing configuration to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp /etc/nginx/nginx.conf "$BACKUP_DIR/nginx.conf"
    fi
    cp config/nginx.conf /etc/nginx/nginx.conf
    chown nginx:nginx /etc/nginx/nginx.conf
    chmod 644 /etc/nginx/nginx.conf
}

validate_config() {
    log_info "Validating nginx configuration"
    if nginx -t; then
        log_info "Configuration is valid"
    else
        log_error "Configuration validation failed"
        exit 1
    fi
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
            cp service/systemd/nginx.service /etc/systemd/system/
            systemctl daemon-reload
            systemctl enable nginx
            ;;
        openrc)
            cp service/openrc/nginx /etc/init.d/nginx
            chmod +x /etc/init.d/nginx
            rc-update add nginx default
            ;;
        sysvinit)
            cp service/sysvinit/nginx /etc/init.d/nginx
            chmod +x /etc/init.d/nginx
            chkconfig --add nginx
            chkconfig nginx on
            ;;
        *)
            log_error "Unknown service type: $service_type"
            exit 1
            ;;
    esac
}

start_service() {
    log_info "Starting nginx"
    case "$service_type" in
        systemd) systemctl start nginx ;;
        openrc) rc-service nginx start ;;
        sysvinit) service nginx start ;;
    esac
}

print_summary() {
    log_info "Installation complete!"
    echo ""
    echo "Nginx has been installed and configured."
    echo "Configuration: /etc/nginx/nginx.conf"
    echo "Logs: /var/log/nginx/"
    echo "Web root: /var/www/html/"
    echo ""
    echo "Useful commands:"
    case "$service_type" in
        systemd)
            echo "  systemctl status nginx"
            echo "  systemctl reload nginx"
            echo "  systemctl restart nginx"
            ;;
        openrc)
            echo "  rc-service nginx status"
            echo "  rc-service nginx reload"
            echo "  rc-service nginx restart"
            ;;
        sysvinit)
            echo "  service nginx status"
            echo "  service nginx reload"
            echo "  service nginx restart"
            ;;
    esac
}

main() {
    check_root
    check_dependencies
    create_nginx_user
    create_directories
    install_config
    validate_config
    install_service "${1:-auto}"
    start_service
    print_summary
}

main "$@"