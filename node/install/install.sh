#!/bin/bash
set -euo pipefail

NODE_VERSION="20.11.0"
INSTALL_DIR="/etc/node"
BACKUP_DIR="/etc/node.backup.$(date +%Y%m%d%H%M%S)"

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
    for cmd in node; do
        if ! command -v "$cmd" &>/dev/null; then
            log_warn "Command '$cmd' not found"
            missing=1
        fi
    done
    if [ "$missing" -eq 1 ]; then
        log_error "Please install Node.js first"
        exit 1
    fi
}

create_node_user() {
    if ! id "node" &>/dev/null; then
        log_info "Creating node user and group"
        useradd -r -s /bin/false node
    else
        log_info "node user already exists"
    fi
}

create_directories() {
    log_info "Creating directories"
    mkdir -p /etc/node/ssl
    mkdir -p /var/log/node
    mkdir -p /var/www/node
    mkdir -p /run/node

    chown -R node:node /var/log/node
    chown -R node:node /var/www/node
    chown -R node:node /run/node
}

install_config() {
    log_info "Installing Node.js configuration"
    if [ -f "/etc/node/config.yaml" ]; then
        log_warn "Backing up existing configuration to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        cp /etc/node/config.yaml "$BACKUP_DIR/config.yaml"
    fi
    cp config/node.conf /etc/node/config.yaml
    chown node:node /etc/node/config.yaml
    chmod 644 /etc/node/config.yaml
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
            cp service/systemd/node.service /etc/systemd/system/
            systemctl daemon-reload
            systemctl enable node
            ;;
        openrc)
            cp service/openrc/node /etc/init.d/node
            chmod +x /etc/init.d/node
            rc-update add node default
            ;;
        sysvinit)
            cp service/sysvinit/node /etc/init.d/node
            chmod +x /etc/init.d/node
            chkconfig --add node
            chkconfig node on
            ;;
        *)
            log_error "Unknown service type: $service_type"
            exit 1
            ;;
    esac
}

start_service() {
    log_info "Starting Node.js"
    case "$service_type" in
        systemd) systemctl start node ;;
        openrc) rc-service node start ;;
        sysvinit) service node start ;;
    esac
}

print_summary() {
    log_info "Installation complete!"
    echo ""
    echo "Node.js has been installed and configured."
    echo "Configuration: /etc/node/config.yaml"
    echo "App Entry Point: /etc/node/server.js"
    echo "Logs: /var/log/node/"
    echo ""
    echo "Useful commands:"
    case "$service_type" in
        systemd)
            echo "  systemctl status node"
            echo "  systemctl reload node"
            echo "  systemctl restart node"
            ;;
        openrc)
            echo "  rc-service node status"
            echo "  rc-service node reload"
            echo "  rc-service node restart"
            ;;
        sysvinit)
            echo "  service node status"
            echo "  service node reload"
            echo "  service node restart"
            ;;
    esac
}

main() {
    check_root
    check_dependencies
    create_node_user
    create_directories
    install_config
    install_service "${1:-auto}"
    start_service
    print_summary
}

main "$@"