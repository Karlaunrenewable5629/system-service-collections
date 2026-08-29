#!/bin/bash
# Keycloak Uninstallation Script
# Removes Keycloak binary, configuration, logs, service unit, and service user.
# WARNING: This will permanently delete all Keycloak data stored locally.

set -euo pipefail

KC_HOME="/opt/keycloak"
CONFIG_DIR="/etc/keycloak"
LOG_DIR="/var/log/keycloak"
USER="keycloak"

log()  { echo "[INFO]  $*"; }
warn() { echo "[WARN]  $*" >&2; }
die()  { echo "[ERROR] $*" >&2; exit 1; }

require_root() {
    [ "$(id -u)" -eq 0 ] || die "This script must be run as root or with sudo."
}

confirm() {
    echo ""
    echo "WARNING: This will permanently remove:"
    echo "  - Keycloak binary at ${KC_HOME} (and any versioned dirs in /opt/keycloak-*)"
    echo "  - Configuration at ${CONFIG_DIR}"
    echo "  - Logs at ${LOG_DIR}"
    echo "  - Keycloak realm data stored in ${KC_HOME}/data"
    echo "  - The '${USER}' system user"
    echo ""
    printf "Are you sure you want to continue? [y/N]: "
    read -r answer
    case "${answer}" in
        [yY]|[yY][eE][sS]) ;;
        *) echo "Aborted."; exit 0 ;;
    esac
}

stop_service_systemd() {
    if systemctl is-active --quiet keycloak 2>/dev/null; then
        log "Stopping keycloak service (systemd)..."
        systemctl stop keycloak
    fi
    if systemctl is-enabled --quiet keycloak 2>/dev/null; then
        log "Disabling keycloak service..."
        systemctl disable keycloak
    fi
    if [ -f /etc/systemd/system/keycloak.service ]; then
        log "Removing systemd unit..."
        rm -f /etc/systemd/system/keycloak.service
        systemctl daemon-reload
    fi
}

stop_service_openrc() {
    if command -v rc-service &>/dev/null; then
        rc-service keycloak stop 2>/dev/null || true
        rc-update del keycloak default 2>/dev/null || true
        rm -f /etc/init.d/keycloak
    fi
}

stop_service_sysvinit() {
    if [ -f /etc/init.d/keycloak ]; then
        /etc/init.d/keycloak stop 2>/dev/null || true
        if command -v update-rc.d &>/dev/null; then
            update-rc.d -f keycloak remove 2>/dev/null || true
        elif command -v chkconfig &>/dev/null; then
            chkconfig --del keycloak 2>/dev/null || true
        fi
        rm -f /etc/init.d/keycloak
    fi
}

remove_files() {
    log "Removing Keycloak home and versioned directories..."
    # Remove symlink first
    rm -f "${KC_HOME}"
    # Remove any versioned installs
    find /opt -maxdepth 1 -name "keycloak-*" -type d -exec rm -rf {} + 2>/dev/null || true

    log "Removing configuration directory..."
    rm -rf "${CONFIG_DIR}"

    log "Removing log directory..."
    rm -rf "${LOG_DIR}"

    log "Removing PID directory..."
    rm -rf /run/keycloak
}

remove_user() {
    if id "${USER}" &>/dev/null; then
        log "Removing system user '${USER}'..."
        userdel "${USER}" 2>/dev/null || warn "Could not remove user '${USER}'. Remove manually with: userdel ${USER}"
    fi
}

main() {
    require_root
    confirm

    log "=== Keycloak Uninstallation ==="

    stop_service_systemd
    stop_service_openrc
    stop_service_sysvinit
    remove_files
    remove_user

    log ""
    log "=== Keycloak Removed ==="
    log "Note: The database (if external) has NOT been removed."
    log "To drop the database manually:"
    log "  psql -U postgres -c 'DROP DATABASE keycloak;'"
    log "  psql -U postgres -c 'DROP USER keycloak;'"
}

main "$@"
