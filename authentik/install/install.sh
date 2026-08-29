#!/usr/bin/env bash
# =============================================================================
# Authentik Install Script
# =============================================================================
# Installs Authentik identity provider as a native system service.
# Supports systemd, OpenRC, and SysVinit.
#
# Usage:
#   sudo ./install.sh [--version <version>] [--no-service]
#
# Options:
#   --version <version>   Authentik version to install (default: latest)
#   --no-service          Skip service installation (config + files only)
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

AUTHENTIK_VERSION="${AUTHENTIK_VERSION:-}"
AUTHENTIK_USER="authentik"
AUTHENTIK_GROUP="authentik"
INSTALL_DIR="/opt/authentik"
CONFIG_DIR="/etc/authentik"
DATA_DIR="/var/lib/authentik"
LOG_DIR="/var/log/authentik"
VENV_DIR="${INSTALL_DIR}/venv"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"
SKIP_SERVICE=false

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

log_info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()      { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

die() {
    log_error "$*"
    exit 1
}

require_root() {
    [[ "${EUID}" -eq 0 ]] || die "This script must be run as root (use sudo)."
}

detect_init() {
    if command -v systemctl &>/dev/null && systemctl --version &>/dev/null 2>&1; then
        echo "systemd"
    elif command -v rc-service &>/dev/null; then
        echo "openrc"
    elif [[ -d /etc/init.d ]]; then
        echo "sysvinit"
    else
        echo "unknown"
    fi
}

detect_os() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        echo "${ID}"
    else
        echo "unknown"
    fi
}

check_command() {
    command -v "$1" &>/dev/null
}

# -----------------------------------------------------------------------------
# Argument Parsing
# -----------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)
            AUTHENTIK_VERSION="$2"
            shift 2
            ;;
        --no-service)
            SKIP_SERVICE=true
            shift
            ;;
        -h|--help)
            sed -n '/^# Usage:/,/^# ====/{ /^# ====/d; s/^# \?//; p }' "$0"
            exit 0
            ;;
        *)
            die "Unknown argument: $1"
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Pre-flight Checks
# -----------------------------------------------------------------------------

require_root

INIT_SYSTEM="$(detect_init)"
OS_ID="$(detect_os)"

log_info "Starting Authentik installation"
log_info "Init system : ${INIT_SYSTEM}"
log_info "OS          : ${OS_ID}"
log_info "Install dir : ${INSTALL_DIR}"

# Check for required commands
for cmd in python3 pip3; do
    check_command "${cmd}" || die "Required command '${cmd}' not found. Install Python 3.12+ first."
done

PYTHON_VERSION="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
log_info "Python version: ${PYTHON_VERSION}"

# Require Python >= 3.11
if python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 11) else 1)' 2>/dev/null; then
    log_ok "Python version is sufficient."
else
    die "Python 3.11 or newer is required. Found ${PYTHON_VERSION}."
fi

# -----------------------------------------------------------------------------
# System User and Group
# -----------------------------------------------------------------------------

log_info "Creating system user and group: ${AUTHENTIK_USER}"

if ! getent group "${AUTHENTIK_GROUP}" &>/dev/null; then
    groupadd --system "${AUTHENTIK_GROUP}"
    log_ok "Group '${AUTHENTIK_GROUP}' created."
else
    log_info "Group '${AUTHENTIK_GROUP}' already exists."
fi

if ! id "${AUTHENTIK_USER}" &>/dev/null; then
    useradd \
        --system \
        --no-create-home \
        --shell /usr/sbin/nologin \
        --gid "${AUTHENTIK_GROUP}" \
        --comment "Authentik Identity Provider" \
        "${AUTHENTIK_USER}"
    log_ok "User '${AUTHENTIK_USER}' created."
else
    log_info "User '${AUTHENTIK_USER}' already exists."
fi

# -----------------------------------------------------------------------------
# Directory Setup
# -----------------------------------------------------------------------------

log_info "Creating directories..."

for dir in "${INSTALL_DIR}" "${CONFIG_DIR}" "${DATA_DIR}/media" "${LOG_DIR}"; do
    if [[ ! -d "${dir}" ]]; then
        mkdir -p "${dir}"
        log_ok "Created: ${dir}"
    else
        log_info "Exists:  ${dir}"
    fi
done

# Set ownership
chown -R "${AUTHENTIK_USER}:${AUTHENTIK_GROUP}" "${INSTALL_DIR}" "${DATA_DIR}" "${LOG_DIR}"
chown root:authentik "${CONFIG_DIR}"
chmod 750 "${CONFIG_DIR}"

# -----------------------------------------------------------------------------
# Install Authentik
# -----------------------------------------------------------------------------

log_info "Creating Python virtual environment at ${VENV_DIR}..."
if [[ ! -d "${VENV_DIR}" ]]; then
    sudo -u "${AUTHENTIK_USER}" python3 -m venv "${VENV_DIR}"
    log_ok "Virtual environment created."
else
    log_info "Virtual environment already exists."
fi

log_info "Installing Authentik${AUTHENTIK_VERSION:+ version ${AUTHENTIK_VERSION}}..."
if [[ -n "${AUTHENTIK_VERSION}" ]]; then
    sudo -u "${AUTHENTIK_USER}" "${VENV_DIR}/bin/pip" install --upgrade "authentik==${AUTHENTIK_VERSION}"
else
    sudo -u "${AUTHENTIK_USER}" "${VENV_DIR}/bin/pip" install --upgrade authentik
fi
log_ok "Authentik installed."

# -----------------------------------------------------------------------------
# Configuration File
# -----------------------------------------------------------------------------

if [[ ! -f "${CONFIG_DIR}/.env" ]]; then
    log_info "Installing default configuration to ${CONFIG_DIR}/.env ..."
    cp "${REPO_DIR}/config/.env" "${CONFIG_DIR}/.env"
    chown "${AUTHENTIK_USER}:${AUTHENTIK_GROUP}" "${CONFIG_DIR}/.env"
    chmod 640 "${CONFIG_DIR}/.env"
    log_ok "Configuration template installed."
    log_warn "Edit ${CONFIG_DIR}/.env before starting the service!"
    log_warn "At minimum, set AUTHENTIK_SECRET_KEY and AUTHENTIK_POSTGRESQL__PASSWORD."
else
    log_info "Configuration file already exists — not overwriting."
fi

# -----------------------------------------------------------------------------
# Service Installation
# -----------------------------------------------------------------------------

if [[ "${SKIP_SERVICE}" == "true" ]]; then
    log_info "Skipping service installation (--no-service)."
else
    log_info "Installing service files for init system: ${INIT_SYSTEM}"

    case "${INIT_SYSTEM}" in
        systemd)
            for unit in authentik-server authentik-worker; do
                SRC="${REPO_DIR}/service/systemd/${unit}.service"
                DST="/etc/systemd/system/${unit}.service"
                if [[ -f "${SRC}" ]]; then
                    cp "${SRC}" "${DST}"
                    chmod 644 "${DST}"
                    log_ok "Installed: ${DST}"
                else
                    log_warn "Service unit not found: ${SRC}"
                fi
            done
            systemctl daemon-reload
            log_info "Run the following to enable services on boot:"
            echo "    sudo systemctl enable --now authentik-server authentik-worker"
            ;;

        openrc)
            for svc in authentik-server authentik-worker; do
                SRC="${REPO_DIR}/service/openrc/${svc}"
                DST="/etc/init.d/${svc}"
                if [[ -f "${SRC}" ]]; then
                    cp "${SRC}" "${DST}"
                    chmod 755 "${DST}"
                    log_ok "Installed: ${DST}"
                else
                    log_warn "OpenRC script not found: ${SRC}"
                fi
            done
            log_info "Run the following to enable services on boot:"
            echo "    sudo rc-update add authentik-server default"
            echo "    sudo rc-update add authentik-worker default"
            echo "    sudo rc-service authentik-server start"
            echo "    sudo rc-service authentik-worker start"
            ;;

        sysvinit)
            for svc in authentik-server authentik-worker; do
                SRC="${REPO_DIR}/service/sysvinit/${svc}"
                DST="/etc/init.d/${svc}"
                if [[ -f "${SRC}" ]]; then
                    cp "${SRC}" "${DST}"
                    chmod 755 "${DST}"
                    log_ok "Installed: ${DST}"
                else
                    log_warn "SysVinit script not found: ${SRC}"
                fi
            done
            log_info "Run the following to enable services on boot:"
            echo "    sudo update-rc.d authentik-server defaults"
            echo "    sudo update-rc.d authentik-worker defaults"
            echo "    sudo service authentik-server start"
            echo "    sudo service authentik-worker start"
            ;;

        *)
            log_warn "Unrecognized init system '${INIT_SYSTEM}'. Skipping service installation."
            log_warn "Manually install from the service/ directory."
            ;;
    esac
fi

# -----------------------------------------------------------------------------
# Run Database Migrations
# -----------------------------------------------------------------------------

log_info "Checking if database migration should run..."
log_warn "Skipping automatic migration — configure ${CONFIG_DIR}/.env first, then run:"
echo "    sudo -u ${AUTHENTIK_USER} ${VENV_DIR}/bin/python -m authentik.manage migrate"

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------

echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN} Authentik installation complete!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo "  Config file  : ${CONFIG_DIR}/.env"
echo "  Install dir  : ${INSTALL_DIR}"
echo "  Data dir     : ${DATA_DIR}"
echo "  Log dir      : ${LOG_DIR}"
echo ""
echo "  Next steps:"
echo "    1. Edit   : sudo nano ${CONFIG_DIR}/.env"
echo "    2. Migrate: sudo -u ${AUTHENTIK_USER} ${VENV_DIR}/bin/python -m authentik.manage migrate"
echo "    3. Start  : sudo systemctl start authentik-server authentik-worker"
echo "    4. Access : http://\$(hostname):9000/if/flow/initial-setup/"
echo ""
