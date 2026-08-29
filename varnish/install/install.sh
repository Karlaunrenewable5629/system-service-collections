#!/bin/bash
set -euo pipefail

VARNISH_VERSION="7.1.1"
INSTALL_DIR="/etc/varnish"
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

check_dependencies() {
    local missing=0
    for cmd in varnishd; do
        if ! command -v "$cmd" &>/dev/null; then
            log_warn "Command '$cmd' not found"
            missing=1
        fi
    done
    if [ "$missing" -eq 1 ]; then
        log_error "Please install varnish first"
        exit 1
    fi
}

create_varnish_user() {
    if ! id "varnish" &>/dev/null; then
        log_info "Creating varnish user and group"
        useradd -r -s /sbin/nologin varnish
    else
        log_info "varnish user already exists"
    fi
}

create_directories() {
    log_info "Creating directories"
    mkdir -p /etc/varnish
    mkdir -p /var/lib/varnish
    mkdir -p /var/log/varnish
    mkdir -p /run

    chown -R varnish:varnish /var/lib/varnish
    chown -R varnish:varnish /var/log/varnish
    chown -R varnish:varnish /run
    chown -R varnish:varnish /etc/varnish
}

install_config() {
    log_info "Installing Varnish configuration"
    if [ -f "/etc/varnish/default.vcl" ]; then
        log_warn "Backing up existing configuration to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp /etc/varnish/default.vcl "$BACKUP_DIR/default.vcl"
    fi
    cp config/default.vcl /etc/varnish/default.vcl
    chown varnish:varnish /etc/varnish/default.vcl
    chmod 644 /etc/varnish/default.vcl

    if [ ! -f /etc/varnish/secret ]; then
        log_info "Creating secret file"
        openssl rand -hex 32 > /etc/varnish/secret
        chown varnish:varnish /etc/varnish/secret
        chmod 600 /etc/varnish/secret
    fi
}

validate_config() {
    log_info "Validating VCL configuration"
    if varnishd -C -f /etc/varnish/default.vcl &>/dev/null; then
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
            cp service/systemd/varnish.service /etc/systemd/system/
            systemctl daemon-reload
            systemctl enable varnish
            ;;
        openrc)
            cp service/openrc/varnish /etc/init.d/varnish
            chmod +x /etc/init.d/varnish
            rc-update add varnish default
            ;;
        sysvinit)
            cp service/sysvinit/varnish /etc/init.d/varnish
            chmod +x /etc/init.d/varnish
            chkconfig --add varnish
            chkconfig varnish on
            ;;
        *)
            log_error "Unknown service type: $service_type"
            exit 1
            ;;
    esac
}

start_service() {
    log_info "Starting Varnish"
    case "$service_type" in
        systemd) systemctl start varnish ;;
        openrc) rc-service varnish start ;;
        sysvinit) service varnish start ;;
    esac
}

print_summary() {
    log_info "Installation complete!"
    echo ""
    echo "Varnish has been installed and configured."
    echo "Configuration: /etc/varnish/default.vcl"
    echo "Secret: /etc/varnish/secret"
    echo "Cache Storage: /var/lib/varnish"
    echo "Logs: /var/log/varnish/"
    echo ""
    echo "Useful commands:"
    case "$service_type" in
        systemd)
            echo "  systemctl status varnish"
            echo "  systemctl reload varnish"
            echo "  systemctl restart varnish"
            ;;
        openrc)
            echo "  rc-service varnish status"
            echo "  rc-service varnish reload"
            echo "  rc-service varnish restart"
            ;;
        sysvinit)
            echo "  service varnish status"
            echo "  service varnish reload"
            echo "  service varnish restart"
            ;;
    esac
    echo ""
    echo "Varnish Administration Console:"
    echo "  varnishadm -S /etc/varnish/secret -T 127.0.0.1:6082"
}

main() {
    check_root
    check_dependencies
    create_varnish_user
    create_directories
    install_config
    validate_config
    install_service "${1:-auto}"
    start_service
    print_summary
}

main "$@"
