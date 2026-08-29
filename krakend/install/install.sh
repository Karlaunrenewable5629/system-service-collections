#!/bin/bash
set -euo pipefail

PREFIX="/usr/local"
BIN_DIR="${PREFIX}/bin"
CONFIG_DIR="/etc/krakend"
SERVICE_DIR="/etc/init.d"
USER="krakend"
GROUP="krakend"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Installing Krakend API Gateway ==="

# Create user and group if they don't exist
if ! id -u "${USER}" >/dev/null 2>&1; then
    echo "Creating user ${USER}..."
    useradd --system --shell /usr/sbin/nologin --home-dir /var/lib/krakend --create-home "${USER}"
fi

if ! getent group "${GROUP}" >/dev/null 2>&1; then
    echo "Creating group ${GROUP}..."
    groupadd "${GROUP}"
fi

usermod -aG "${GROUP}" "${USER}"

# Create directories
echo "Creating directories..."
mkdir -p "${CONFIG_DIR}"
mkdir -p "${BIN_DIR}"
mkdir -p /var/lib/krakend
mkdir -p /var/log/krakend

# Copy binary (if present)
if [ -f "${PROJECT_DIR}/krakend" ]; then
    echo "Installing binary..."
    cp "${PROJECT_DIR}/krakend" "${BIN_DIR}/krakend"
    chmod 755 "${BIN_DIR}/krakend"
fi

# Copy configuration
if [ -f "${PROJECT_DIR}/config/krakend.json" ]; then
    echo "Installing configuration..."
    cp "${PROJECT_DIR}/config/krakend.json" "${CONFIG_DIR}/krakend.json"
    chmod 644 "${CONFIG_DIR}/krakend.json"
    chown "${USER}:${GROUP}" "${CONFIG_DIR}/krakend.json"
fi

# Set ownership
chown -R "${USER}:${GROUP}" /var/lib/krakend /var/log/krakend

# Install service script based on init system
if command -v systemctl >/dev/null 2>&1; then
    echo "Installing systemd service..."
    cp "${PROJECT_DIR}/service/systemd/krakend.service" /etc/systemd/system/krakend.service
    systemctl daemon-reload
    systemctl enable krakend
    SYSTEMD_INSTALL=1
elif command -v rc-update >/dev/null 2>&1; then
    echo "Installing OpenRC service..."
    cp "${PROJECT_DIR}/service/openrc/krakend" /etc/init.d/krakend
    chmod +x /etc/init.d/krakend
    rc-update add krakend default
    OPENRC_INSTALL=1
elif [ -f /etc/init.d ] || [ -f /etc/rc.d/init.d ]; then
    echo "Installing SysVinit service..."
    cp "${PROJECT_DIR}/service/sysvinit/krakend" /etc/init.d/krakend
    chmod +x /etc/init.d/krakend
    update-rc.d krakend defaults 2>/dev/null || true
    SYSVINIT_INSTALL=1
else
    echo "Warning: No supported init system detected. Manual setup required."
fi

# Create log directory
mkdir -p /var/log/krakend
chown -R "${USER}:${GROUP}" /var/log/krakend

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Next steps:"
echo "  1. Edit ${CONFIG_DIR}/krakend.json to configure your backends"
echo "  2. Start the service:"
if [ "${SYSTEMD_INSTALL:-0}" = "1" ]; then
    echo "     systemctl start krakend"
elif [ "${OPENRC_INSTALL:-0}" = "1" ]; then
    echo "     rc-service krakend start"
elif [ "${SYSVINIT_INSTALL:-0}" = "1" ]; then
    echo "     service krakend start"
fi
echo "  3. Verify: curl http://localhost:8080"
