#!/usr/bin/env bash
# ==============================================================================
# install.sh — OpenLDAP (slapd) Installation Script
# ==============================================================================
# Supports: Debian/Ubuntu, RHEL/CentOS/AlmaLinux/Rocky, Fedora, Alpine, Arch
#
# Usage:
#   chmod +x install.sh
#   sudo ./install.sh
#
# What this script does:
#   1. Detects the Linux distribution
#   2. Installs OpenLDAP server and client packages
#   3. Creates the ldap system user and group (if not present)
#   4. Creates and secures the database directory (/var/lib/ldap)
#   5. Creates the runtime directory (/var/run/openldap)
#   6. Copies the configuration template if no config exists
#   7. Enables and starts the slapd service
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
SLAPD_USER="${SLAPD_USER:-ldap}"
SLAPD_GROUP="${SLAPD_GROUP:-ldap}"
DB_DIR="${DB_DIR:-/var/lib/ldap}"
RUN_DIR="${RUN_DIR:-/var/run/openldap}"
CONFIG_DIR="${CONFIG_DIR:-/etc/openldap}"
CONFIG_FILE="${CONFIG_FILE:-/etc/openldap/slapd.conf}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_TEMPLATE="${SCRIPT_DIR}/../config/slapd.conf"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

# ------------------------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------------------------
info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root. Use: sudo $0"
  fi
}

detect_distro() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO_ID_LIKE="${ID_LIKE:-}"
    DISTRO_VERSION="${VERSION_ID:-0}"
  elif command -v lsb_release &>/dev/null; then
    DISTRO_ID="$(lsb_release -si | tr '[:upper:]' '[:lower:]')"
    DISTRO_ID_LIKE=""
    DISTRO_VERSION="$(lsb_release -sr)"
  else
    error "Cannot detect Linux distribution."
  fi
  info "Detected distribution: ${DISTRO_ID} ${DISTRO_VERSION}"
}

# ------------------------------------------------------------------------------
# Package installation per distribution
# ------------------------------------------------------------------------------
install_debian() {
  info "Installing OpenLDAP on Debian/Ubuntu..."
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y slapd ldap-utils
  # Debian uses /etc/ldap for config dir
  CONFIG_DIR="/etc/ldap"
  CONFIG_FILE="/etc/ldap/slapd.conf"
  success "OpenLDAP packages installed."
}

install_rhel() {
  info "Installing OpenLDAP on RHEL/CentOS/AlmaLinux/Rocky/Fedora..."
  if command -v dnf &>/dev/null; then
    dnf install -y openldap openldap-servers openldap-clients
  else
    yum install -y openldap openldap-servers openldap-clients
  fi
  success "OpenLDAP packages installed."
}

install_alpine() {
  info "Installing OpenLDAP on Alpine Linux..."
  apk add --no-cache openldap openldap-back-mdb openldap-clients
  CONFIG_DIR="/etc/openldap"
  success "OpenLDAP packages installed."
}

install_arch() {
  info "Installing OpenLDAP on Arch Linux..."
  pacman -Sy --noconfirm openldap
  CONFIG_DIR="/etc/openldap"
  success "OpenLDAP packages installed."
}

install_packages() {
  case "${DISTRO_ID}" in
    debian|ubuntu|linuxmint|pop)
      install_debian
      ;;
    rhel|centos|almalinux|rocky|ol|scientific)
      install_rhel
      ;;
    fedora)
      install_rhel
      ;;
    alpine)
      install_alpine
      ;;
    arch|manjaro|endeavouros)
      install_arch
      ;;
    *)
      # Fall back to ID_LIKE if set
      if echo "${DISTRO_ID_LIKE}" | grep -qiE "debian|ubuntu"; then
        install_debian
      elif echo "${DISTRO_ID_LIKE}" | grep -qiE "rhel|fedora|centos"; then
        install_rhel
      else
        error "Unsupported distribution: ${DISTRO_ID}. Install openldap manually."
      fi
      ;;
  esac
}

# ------------------------------------------------------------------------------
# System user and group
# ------------------------------------------------------------------------------
create_user() {
  if ! getent group "${SLAPD_GROUP}" &>/dev/null; then
    info "Creating system group: ${SLAPD_GROUP}"
    groupadd --system "${SLAPD_GROUP}"
    success "Group '${SLAPD_GROUP}' created."
  else
    info "Group '${SLAPD_GROUP}' already exists."
  fi

  if ! getent passwd "${SLAPD_USER}" &>/dev/null; then
    info "Creating system user: ${SLAPD_USER}"
    useradd \
      --system \
      --gid "${SLAPD_GROUP}" \
      --no-create-home \
      --home-dir "${DB_DIR}" \
      --shell /sbin/nologin \
      --comment "OpenLDAP server" \
      "${SLAPD_USER}"
    success "User '${SLAPD_USER}' created."
  else
    info "User '${SLAPD_USER}' already exists."
  fi
}

# ------------------------------------------------------------------------------
# Directory setup
# ------------------------------------------------------------------------------
setup_directories() {
  info "Setting up directories..."

  # Database directory
  if [[ ! -d "${DB_DIR}" ]]; then
    mkdir -p "${DB_DIR}"
    info "Created database directory: ${DB_DIR}"
  fi
  chown "${SLAPD_USER}:${SLAPD_GROUP}" "${DB_DIR}"
  chmod 700 "${DB_DIR}"
  success "Database directory configured: ${DB_DIR}"

  # Runtime directory
  if [[ ! -d "${RUN_DIR}" ]]; then
    mkdir -p "${RUN_DIR}"
    info "Created runtime directory: ${RUN_DIR}"
  fi
  chown "${SLAPD_USER}:${SLAPD_GROUP}" "${RUN_DIR}"
  chmod 755 "${RUN_DIR}"
  success "Runtime directory configured: ${RUN_DIR}"

  # TLS directory
  if [[ ! -d "${CONFIG_DIR}/tls" ]]; then
    mkdir -p "${CONFIG_DIR}/tls"
    chown root:root "${CONFIG_DIR}/tls"
    chmod 750 "${CONFIG_DIR}/tls"
    info "Created TLS directory: ${CONFIG_DIR}/tls"
  fi
}

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
setup_config() {
  if [[ -f "${CONFIG_FILE}" ]]; then
    warn "Configuration file already exists: ${CONFIG_FILE}"
    warn "Skipping config copy. Edit it manually."
    return
  fi

  if [[ -f "${CONFIG_TEMPLATE}" ]]; then
    info "Copying configuration template to ${CONFIG_FILE}..."
    cp "${CONFIG_TEMPLATE}" "${CONFIG_FILE}"
    chown root:root "${CONFIG_FILE}"
    chmod 640 "${CONFIG_FILE}"
    success "Configuration template copied. Edit ${CONFIG_FILE} before starting slapd."
  else
    warn "Configuration template not found at: ${CONFIG_TEMPLATE}"
    warn "Please create ${CONFIG_FILE} manually."
  fi
}

# ------------------------------------------------------------------------------
# Service management
# ------------------------------------------------------------------------------
enable_service() {
  if command -v systemctl &>/dev/null && systemctl list-unit-files &>/dev/null 2>&1; then
    info "Enabling and starting slapd via systemd..."
    systemctl daemon-reload
    systemctl enable slapd
    systemctl start slapd || warn "slapd failed to start — check configuration."
    success "slapd enabled and started."

  elif command -v rc-update &>/dev/null; then
    info "Enabling slapd via OpenRC..."
    rc-update add slapd default
    rc-service slapd start || warn "slapd failed to start — check configuration."
    success "slapd enabled via OpenRC."

  elif [[ -f /etc/init.d/slapd ]]; then
    info "Enabling slapd via SysVinit..."
    if command -v update-rc.d &>/dev/null; then
      update-rc.d slapd defaults
    elif command -v chkconfig &>/dev/null; then
      chkconfig slapd on
    fi
    service slapd start || warn "slapd failed to start — check configuration."
    success "slapd enabled via SysVinit."

  else
    warn "Could not detect init system. Start slapd manually."
  fi
}

# ------------------------------------------------------------------------------
# Post-install instructions
# ------------------------------------------------------------------------------
print_summary() {
  echo ""
  echo -e "${GREEN}============================================================${NC}"
  echo -e "${GREEN} OpenLDAP Installation Complete${NC}"
  echo -e "${GREEN}============================================================${NC}"
  echo ""
  echo "  Service name   : slapd"
  echo "  Config file    : ${CONFIG_FILE}"
  echo "  Database dir   : ${DB_DIR}"
  echo "  Default ports  : 389 (LDAP), 636 (LDAPS)"
  echo "  Service user   : ${SLAPD_USER}"
  echo ""
  echo -e "${YELLOW}Next steps:${NC}"
  echo "  1. Edit the configuration file:"
  echo "       sudo nano ${CONFIG_FILE}"
  echo ""
  echo "  2. Set your suffix and rootdn, then generate a password:"
  echo "       slappasswd -h {SSHA}"
  echo ""
  echo "  3. Create and own the database directory:"
  echo "       sudo chown ${SLAPD_USER}:${SLAPD_GROUP} ${DB_DIR}"
  echo ""
  echo "  4. Restart slapd after configuration:"
  echo "       sudo systemctl restart slapd"
  echo ""
  echo "  5. Verify with:"
  echo "       ldapsearch -x -H ldap://localhost -b 'dc=example,dc=com' -s base"
  echo ""
  echo "  See install/README.md for full documentation."
  echo ""
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
  info "Starting OpenLDAP installation..."
  require_root
  detect_distro
  install_packages
  create_user
  setup_directories
  setup_config
  enable_service
  print_summary
}

main "$@"
