#!/bin/bash
# Keycloak Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Alpine
# Installs Keycloak as a system service managed by systemd

set -euo pipefail

KC_VERSION="${KC_VERSION:-25.0.6}"
KC_INSTALL_DIR="/opt"
KC_HOME="/opt/keycloak"
CONFIG_DIR="/etc/keycloak"
LOG_DIR="/var/log/keycloak"
USER="keycloak"
GROUP="keycloak"
TMP_DIR="$(mktemp -d)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { echo "[INFO]  $*"; }
warn() { echo "[WARN]  $*" >&2; }
die()  { echo "[ERROR] $*" >&2; exit 1; }

require_root() {
    [ "$(id -u)" -eq 0 ] || die "This script must be run as root or with sudo."
}

detect_os() {
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        OS="${ID}"
        VER="${VERSION_ID:-}"
    else
        die "Cannot detect OS. /etc/os-release not found."
    fi
}

# ---------------------------------------------------------------------------
# Java
# ---------------------------------------------------------------------------
install_java_debian() {
    log "Installing OpenJDK 21 (Debian/Ubuntu)..."
    apt-get update -qq
    apt-get install -y openjdk-21-jre-headless curl
}

install_java_rhel() {
    log "Installing OpenJDK 21 (RHEL/CentOS/Fedora)..."
    dnf install -y java-21-openjdk-headless curl
}

install_java_alpine() {
    log "Installing OpenJDK 21 (Alpine)..."
    apk add --no-cache openjdk21-jre-headless curl
}

install_java() {
    if java -version &>/dev/null 2>&1; then
        log "Java already installed: $(java -version 2>&1 | head -1)"
        return
    fi
    case "${OS}" in
        ubuntu|debian)    install_java_debian ;;
        rhel|centos|fedora|rocky|almalinux) install_java_rhel ;;
        alpine)           install_java_alpine ;;
        *)                die "Unsupported OS '${OS}'. Please install Java 17+ manually." ;;
    esac
}

# ---------------------------------------------------------------------------
# Keycloak binary
# ---------------------------------------------------------------------------
download_keycloak() {
    local archive="${TMP_DIR}/keycloak-${KC_VERSION}.tar.gz"
    local url="https://github.com/keycloak/keycloak/releases/download/${KC_VERSION}/keycloak-${KC_VERSION}.tar.gz"
    log "Downloading Keycloak ${KC_VERSION}..."
    curl -fsSL --retry 3 "${url}" -o "${archive}"
    echo "${archive}"
}

extract_keycloak() {
    local archive="$1"
    log "Extracting Keycloak to ${KC_INSTALL_DIR}..."
    tar -xzf "${archive}" -C "${KC_INSTALL_DIR}"
    ln -sfn "${KC_INSTALL_DIR}/keycloak-${KC_VERSION}" "${KC_HOME}"
}

# ---------------------------------------------------------------------------
# System user
# ---------------------------------------------------------------------------
create_user() {
    if id "${USER}" &>/dev/null; then
        log "User '${USER}' already exists."
    else
        log "Creating system user '${USER}'..."
        useradd --system --no-create-home --shell /usr/sbin/nologin "${USER}"
    fi
}

# ---------------------------------------------------------------------------
# Directories and configuration
# ---------------------------------------------------------------------------
create_directories() {
    log "Creating directories..."
    mkdir -p "${CONFIG_DIR}" "${LOG_DIR}" "${KC_HOME}/data"
    chown -R "${USER}:${GROUP}" "${KC_HOME}" "${CONFIG_DIR}" "${LOG_DIR}"
    chmod 750 "${CONFIG_DIR}" "${LOG_DIR}"
}

install_config() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local config_src="${script_dir}/../config/keycloak.conf"

    if [ -f "${config_src}" ]; then
        log "Installing configuration template..."
        cp "${config_src}" "${CONFIG_DIR}/keycloak.conf"
        chown "${USER}:${GROUP}" "${CONFIG_DIR}/keycloak.conf"
        chmod 640 "${CONFIG_DIR}/keycloak.conf"
    else
        warn "Config template not found at ${config_src}. Skipping."
    fi

    # Symlink into KC_HOME/conf so kc.sh finds it automatically
    mkdir -p "${KC_HOME}/conf"
    ln -sfn "${CONFIG_DIR}/keycloak.conf" "${KC_HOME}/conf/keycloak.conf"
    chown -h "${USER}:${GROUP}" "${KC_HOME}/conf/keycloak.conf"
}

# ---------------------------------------------------------------------------
# Build optimized image
# ---------------------------------------------------------------------------
build_keycloak() {
    log "Running 'kc.sh build' to generate optimized server image..."
    # Run as keycloak user; ignore failure (may fail without a DB at build time)
    sudo -u "${USER}" "${KC_HOME}/bin/kc.sh" build 2>&1 || \
        warn "'kc.sh build' exited non-zero. This is normal if the database is not yet reachable. Re-run 'kc.sh build' after configuring the database."
}

# ---------------------------------------------------------------------------
# Systemd service
# ---------------------------------------------------------------------------
install_service() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local unit_src="${script_dir}/../service/systemd/keycloak.service"

    if [ ! -f "${unit_src}" ]; then
        die "Systemd unit not found at ${unit_src}."
    fi

    log "Installing systemd service..."
    cp "${unit_src}" /etc/systemd/system/keycloak.service
    systemctl daemon-reload
    systemctl enable keycloak
}

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------
cleanup() {
    log "Cleaning up temporary files..."
    rm -rf "${TMP_DIR}"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    require_root
    detect_os

    log "=== Keycloak ${KC_VERSION} Installation ==="
    log "OS detected: ${OS} ${VER}"

    install_java
    download_keycloak | { read -r archive; extract_keycloak "${archive}"; }
    create_user
    create_directories
    install_config
    build_keycloak
    install_service
    cleanup

    log ""
    log "=== Installation Complete ==="
    log "Config:  ${CONFIG_DIR}/keycloak.conf"
    log "Home:    ${KC_HOME}"
    log "Logs:    ${LOG_DIR}"
    log ""
    log "Before starting, edit ${CONFIG_DIR}/keycloak.conf and set:"
    log "  - db, db-url-host, db-url-database, db-username, db-password"
    log "  - hostname"
    log "Then run:  sudo kc.sh build"
    log ""
    log "Set the initial admin credentials (first start only):"
    log "  export KEYCLOAK_ADMIN=admin"
    log "  export KEYCLOAK_ADMIN_PASSWORD=<secure-password>"
    log ""
    log "Start service:  sudo systemctl start keycloak"
    log "View logs:      journalctl -u keycloak -f"
    log "Admin console:  http://localhost:8080/admin"
}

main "$@"
