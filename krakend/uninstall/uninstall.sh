#!/bin/bash
set -euo pipefail

CONFIG_DIR="/etc/krakend"
BIN_DIR="/usr/local/bin"
USER="krakend"
GROUP="krakend"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Uninstalling Krakend API Gateway ==="

# Stop and disable the service
if command -v systemctl >/dev/null 2>&1; then
    echo "Stopping systemd service..."
    systemctl stop krakend 2>/dev/null || true
    systemctl disable krakend 2>/dev/null || true
    rm -f /etc/systemd/system/krakend.service
    systemctl daemon-reload
    SYSTEMD_UNINSTALLED=1
elif command -v rc-update >/dev/null 2>&1; then
    echo "Stopping OpenRC service..."
    rc-service krakend stop 2>/dev/null || true
    rc-update del krakend default 2>/dev/null || true
    rm -f /etc/init.d/krakend
    OPENRC_UNINSTALLED=1
elif [ -f /etc/init.d/krakend ]; then
    echo "Stopping SysVinit service..."
    service krakend stop 2>/dev/null || true
    update-rc.d -f krakend remove 2>/dev/null || true
    rm -f /etc/init.d/krakend
    SYSVINIT_UNINSTALLED=1
else
    echo "No recognized init system service found."
fi

# Remove NSSM service on Windows (WSL)
if command -v nssm >/dev/null 2>&1; then
    echo "Removing NSSM service..."
    nssm stop krakend 2>/dev/null || true
    nssm remove krakend confirm 2>/dev/null || true
fi

# Remove configuration
if [ -d "${CONFIG_DIR}" ]; then
    echo "Removing configuration..."
    rm -rf "${CONFIG_DIR}"
fi

# Remove binary
if [ -f "${BIN_DIR}/krakend" ]; then
    echo "Removing binary..."
    rm -f "${BIN_DIR}/krakend"
fi

# Remove service user and group
if id -u "${USER}" >/dev/null 2>&1; then
    echo "Removing user ${USER}..."
    userdel "${USER}" 2>/dev/null || true
fi

if getent group "${GROUP}" >/dev/null 2>&1; then
    echo "Removing group ${GROUP}..."
    groupdel "${GROUP}" 2>/dev/null || true
fi

# Remove data and log directories
rm -rf /var/lib/krakend /var/log/krakend

echo ""
echo "=== Uninstallation Complete ==="
echo ""
echo "Krakend and all associated files have been removed."
