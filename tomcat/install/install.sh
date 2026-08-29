#!/bin/bash
set -euo pipefail

TOMCAT_VERSION="10.1.24"
INSTALL_DIR="/etc/tomcat"
BACKUP_DIR="/etc/tomcat.backup.$(date +%Y%m%d%H%M%S)"

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
    for cmd in java; do
        if ! command -v "$cmd" &>/dev/null; then
            log_warn "Command '$cmd' not found"
            missing=1
        fi
    done
    if [ "$missing" -eq 1 ]; then
        log_error "Please install Java first"
        exit 1
    fi
}

create_tomcat_user() {
    if ! id "tomcat" &>/dev/null; then
        log_info "Creating tomcat user and group"
        useradd -r -s /bin/false tomcat
    else
        log_info "tomcat user already exists"
    fi
}

create_directories() {
    log_info "Creating directories"
    mkdir -p /etc/tomcat/ssl
    mkdir -p /var/log/tomcat
    mkdir -p /var/lib/tomcat
    mkdir -p /run/tomcat
    mkdir -p /etc/tomcat/webapps

    chown -R tomcat:tomcat /var/log/tomcat
    chown -R tomcat:tomcat /var/lib/tomcat
    chown -R tomcat:tomcat /run/tomcat
    chown -R tomcat:tomcat /etc/tomcat/ssl
}

install_config() {
    log_info "Installing Tomcat configuration"
    if [ -f "/etc/tomcat/server.xml" ]; then
        log_warn "Backing up existing configuration to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp /etc/tomcat/server.xml "$BACKUP_DIR/server.xml"
        cp /etc/tomcat/tomcat-users.xml "$BACKUP_DIR/tomcat-users.xml"
    fi
    cp config/server.xml /etc/tomcat/server.xml
    cp config/tomcat-users.xml /etc/tomcat/tomcat-users.xml
    chown tomcat:tomcat /etc/tomcat/server.xml
    chown tomcat:tomcat /etc/tomcat/tomcat-users.xml
    chmod 644 /etc/tomcat/server.xml
    chmod 644 /etc/tomcat/tomcat-users.xml
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
            cp service/systemd/tomcat.service /etc/systemd/system/
            systemctl daemon-reload
            systemctl enable tomcat
            ;;
        openrc)
            cp service/openrc/tomcat /etc/init.d/tomcat
            chmod +x /etc/init.d/tomcat
            rc-update add tomcat default
            ;;
        sysvinit)
            cp service/sysvinit/tomcat /etc/init.d/tomcat
            chmod +x /etc/init.d/tomcat
            chkconfig --add tomcat
            chkconfig tomcat on
            ;;
        *)
            log_error "Unknown service type: $service_type"
            exit 1
            ;;
    esac
}

start_service() {
    log_info "Starting Tomcat"
    case "$service_type" in
        systemd) systemctl start tomcat ;;
        openrc) rc-service tomcat start ;;
        sysvinit) service tomcat start ;;
    esac
}

print_summary() {
    log_info "Installation complete!"
    echo ""
    echo "Tomcat has been installed and configured."
    echo "Configuration: /etc/tomcat/server.xml"
    echo "Users Config: /etc/tomcat/tomcat-users.xml"
    echo "Logs: /var/log/tomcat/"
    echo ""
    echo "Useful commands:"
    case "$service_type" in
        systemd)
            echo "  systemctl status tomcat"
            echo "  systemctl reload tomcat"
            echo "  systemctl restart tomcat"
            ;;
        openrc)
            echo "  rc-service tomcat status"
            echo "  rc-service tomcat reload"
            echo "  rc-service tomcat restart"
            ;;
        sysvinit)
            echo "  service tomcat status"
            echo "  service tomcat reload"
            echo "  service tomcat restart"
            ;;
    esac
}

main() {
    check_root
    check_dependencies
    create_tomcat_user
    create_directories
    install_config
    install_service "${1:-auto}"
    start_service
    print_summary
}

main "$@"