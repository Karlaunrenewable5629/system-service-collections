#!/bin/bash
set -euo pipefail

TRAEFIK_USER="${TRAEFIK_USER:-traefik}"
TRAEFIK_GROUP="${TRAEFIK_GROUP:-traefik}"
TRAEFIK_CONF="/etc/traefik"
TRAEFIK_LOG="/var/log/traefik"
TRAEFIK_BIN="/usr/local/bin/traefik"
TRAEFIK_PID="/var/run/traefik.pid"

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  TRAEFIK_USER=<user>     Traefik service user (default: traefik)"
    echo "  TRAEFIK_GROUP=<group>   Traefik service group (default: traefik)"
    echo "  -h, --help              Show this help message"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
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

echo "=== Traefik Uninstallation ==="

# Check for root
if [[ $(id -u) -ne 0 ]]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# Stop and disable the service
echo "Stopping traefik service..."
if command -v systemctl &>/dev/null; then
    systemctl stop traefik 2>/dev/null || true
    systemctl disable traefik 2>/dev/null || true
    rm -f /etc/systemd/system/traefik.service
    systemctl daemon-reload
elif command -v rc-service &>/dev/null; then
    rc-service traefik stop 2>/dev/null || true
    rc-update del traefik default 2>/dev/null || true
    rm -f /etc/init.d/traefik
elif command -v service &>/dev/null; then
    service traefik stop 2>/dev/null || true
    update-rc.d -f traefik remove 2>/dev/null || true
    rm -f /etc/init.d/traefik
fi

# Remove Windows NSSM service if present
if command -v nssm &>/dev/null; then
    nssm remove traefik confirm 2>/dev/null || true
fi

# Remove configuration files
echo "Removing configuration..."
rm -rf "$TRAEFIK_CONF"

# Remove log files
echo "Removing logs..."
rm -rf "$TRAEFIK_LOG"

# Remove binary
echo "Removing binary..."
if [[ -f "$TRAEFIK_BIN" ]]; then
    rm -f "$TRAEFIK_BIN"
fi

# Remove PID file
if [[ -f "$TRAEFIK_PID" ]]; then
    rm -f "$TRAEFIK_PID"
fi

# Remove user and group
echo "Removing traefik user and group..."
userdel "$TRAEFIK_USER" 2>/dev/null || true
groupdel "$TRAEFIK_GROUP" 2>/dev/null || true

echo ""
echo "=== Uninstallation Complete ==="
echo "Traefik has been removed from the system."
