#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
INSTALL_PREFIX="${INSTALL_PREFIX:-/}"
TRAEFIK_USER="${TRAEFIK_USER:-traefik}"
TRAEFIK_GROUP="${TRAEFIK_GROUP:-traefik}"
TRAEFIK_BIN="/usr/local/bin/traefik"
TRAEFIK_CONF="/etc/traefik/traefik.yml"
TRAEFIK_DYNAMIC="/etc/traefik/dynamic"
TRAEFIK_LOG="/var/log/traefik"
TRAEFIK_ACME="/etc/traefik/acme.json"

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  INSTALL_PREFIX=<path>   Installation prefix (default: /)"
    echo "  TRAEFIK_USER=<user>     Traefik service user (default: traefik)"
    echo "  TRAEFIK_GROUP=<group>   Traefik service group (default: traefik)"
    echo "  -h, --help              Show this help message"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        INSTALL_PREFIX=*)
            INSTALL_PREFIX="${1#*=}"
            shift
            ;;
        TRAEFIK_USER=*)
            TRAEFIK_USER="${1#*=}"
            shift
            ;;
        TRAEFIK_GROUP=*)
            TRAEFIK_GROUP="${1#*=}"
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

echo "=== Traefik Installation ==="
echo "Prefix: $INSTALL_PREFIX"
echo "User: $TRAEFIK_USER"
echo "Group: $TRAEFIK_GROUP"

# Check for root
if [[ $(id -u) -ne 0 ]]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# Create traefik user and group
if ! id -u "$TRAEFIK_USER" &>/dev/null; then
    echo "Creating user: $TRAEFIK_USER"
    useradd --system --shell /usr/sbin/nologin --home-dir /nonexistent "$TRAEFIK_USER"
fi

if ! getent group "$TRAEFIK_GROUP" &>/dev/null; then
    echo "Creating group: $TRAEFIK_GROUP"
    groupadd "$TRAEFIK_GROUP"
fi

usermod -aG "$TRAEFIK_GROUP" "$TRAEFIK_USER"

# Create directories
echo "Creating directories..."
mkdir -p "$TRAEFIK_CONF"
mkdir -p "$TRAEFIK_DYNAMIC"
mkdir -p "$TRAEFIK_LOG"
mkdir -p "$(dirname "$TRAEFIK_ACME")"

# Set permissions
echo "Setting permissions..."
chown -R "$TRAEFIK_USER:$TRAEFIK_GROUP" /etc/traefik
chown -R "$TRAEFIK_USER:$TRAEFIK_GROUP" /var/log/traefik
chmod 750 /etc/traefik
chmod 750 /etc/traefik/dynamic
chmod 750 /var/log/traefik

# Copy configuration
echo "Installing configuration..."
cp "$BASE_DIR/config/traefik.yml" "$TRAEFIK_CONF/traefik.yml"
chown "$TRAEFIK_USER:$TRAEFIK_GROUP" "$TRAEFIK_CONF/traefik.yml"
chmod 640 "$TRAEFIK_CONF/traefik.yml"

touch "$TRAEFIK_ACME"
chown "$TRAEFIK_USER:$TRAEFIK_GROUP" "$TRAEFIK_ACME"
chmod 600 "$TRAEFIK_ACME"

# Copy service files
echo "Installing service files..."

# systemd
if command -v systemctl &>/dev/null; then
    cp "$BASE_DIR/service/systemd/traefik.service" /etc/systemd/system/traefik.service
    systemctl daemon-reload
    systemctl enable traefik
    echo "systemd service installed and enabled"
fi

# OpenRC
if command -v rc-service &>/dev/null; then
    cp "$BASE_DIR/service/openrc/traefik" /etc/init.d/traefik
    chmod +x /etc/init.d/traefik
    rc-update add traefik default 2>/dev/null || true
    echo "OpenRC service installed"
fi

# SysVinit
if command -v update-rc.d &>/dev/null; then
    cp "$BASE_DIR/service/sysvinit/traefik" /etc/init.d/traefik
    chmod +x /etc/init.d/traefik
    update-rc.d traefik defaults
    echo "SysVinit service installed"
fi

# Copy binary if present in the repo
if [[ -f "$BASE_DIR/bin/traefik" ]]; then
    cp "$BASE_DIR/bin/traefik" "$TRAEFIK_BIN"
    chmod +x "$TRAEFIK_BIN"
    chown root:root "$TRAEFIK_BIN"
    echo "Binary installed to $TRAEFIK_BIN"
fi

# Start the service
echo "Starting traefik..."
if command -v systemctl &>/dev/null; then
    systemctl start traefik
    systemctl status traefik --no-pager
elif command -v rc-service &>/dev/null; then
    rc-service traefik start
else
    service traefik start
fi

echo ""
echo "=== Installation Complete ==="
echo "Traefik is running at http://localhost:8080"
echo "Configuration: $TRAEFIK_CONF/traefik.yml"
echo "Logs: $TRAEFIK_LOG"
