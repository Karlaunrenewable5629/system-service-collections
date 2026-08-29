#!/usr/bin/env bash
# ==============================================================================
# uninstall.sh — OpenLDAP (slapd) Uninstallation Script
# ==============================================================================
# Supports: Debian/Ubuntu, RHEL/CentOS/AlmaLinux/Rocky, Fedora, Alpine, Arch
#
# Usage:
#   chmod +x uninstall.sh
#   sudo ./uninstall.sh
#
# Options (environment variables):
#   REMOVE_DATA=true      - Also remove /var/lib/ldap (database). Default: false
#   REMOVE_CONFIG=true    - Also remove /etc/openldap or /etc/ldap. Default: false
#   REMOVE_LOGS=true      - Also remove log files. Default: false
#   REMOVE_USER=true      - Also remove the ldap system user/group. Default: false
#   BACKUP_DIR=/tmp/ldap  - Where to write the LDIF backup before removal.
#
# WARNING: Setting REMOVE_DATA=true permanently deletes all LDAP data.
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Defaults (override via environment)
# ------------------------------------------------------------------------------
REMOVE_DATA="${REMOVE_DATA:-false}"
REMOVE_CONFIG="${REMOVE_CONFIG:-false}"
REMOVE_LOGS="${REMOVE_LOGS:-false}"
REMOVE_USER="${REMOVE_USER:-false}"
BACKUP_DIR="${BACKUP_DIR:-/tmp/ldap-backup}"

SLAPD_USER="${SLAPD_USER:-ldap}"
SLAPD_GROUP="${SLAPD_GROUP:-ldap}"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ------------------------------------------------------------------------------
# Helpers
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

confirm() {
  local prompt="$1"
  local response
  read -r -p "${prompt} [y/N] " response
  [[ "${response,,}" == "y" || "${response,,}" == "yes" ]]
}

detect_distro() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO_ID_LIKE="${ID_LIKE:-}"
  else
    DISTRO_ID="unknown"
    DISTRO_ID_LIKE=""
  fi
}

# ------------------------------------------------------------------------------
# Backup LDAP data before removal
# ------------------------------------------------------------------------------
backup_data() {
  if ! command -v slapcat &>/dev/null; then
    warn "slapcat not found — skipping database backup."
    return
  fi

  # Only backup if slapd has data
  local db_dir="/var/lib/ldap"
  if [[ ! -d "${db_dir}" ]] || [[ -z "$(ls -A "${db_dir}" 2>/dev/null)" ]]; then
    info "No database files found in ${db_dir} — skipping backup."
    return
  fi

  mkdir -p "${BACKUP_DIR}"
  local backup_file="${BACKUP_DIR}/ldap-backup-$(date +%Y%m%d-%H%M%S).ldif"
  info "Backing up LDAP database to ${backup_file}..."

  if sudo -u "${SLAPD_USER}" slapcat -l "${backup_file}" 2>/dev/null; then
    success "Backup written to ${backup_file}"
  else
    # Try as root if ldap user fails
    if slapcat -l "${backup_file}" 2>/dev/null; then
      success "Backup written to ${backup_file}"
    else
      warn "Could not back up database. Proceeding anyway."
    fi
  fi
}

# ------------------------------------------------------------------------------
# Stop and disable the service
# ------------------------------------------------------------------------------
stop_service() {
  info "Stopping slapd service..."

  if command -v systemctl &>/dev/null && systemctl list-unit-files slapd.service &>/dev/null 2>&1; then
    systemctl stop slapd 2>/dev/null || true
    systemctl disable slapd 2>/dev/null || true
    rm -f /etc/systemd/system/slapd.service
    systemctl daemon-reload
    systemctl reset-failed 2>/dev/null || true
    success "slapd stopped and disabled (systemd)."

  elif command -v rc-update &>/dev/null; then
    rc-service slapd stop 2>/dev/null || true
    rc-update del slapd default 2>/dev/null || true
    rm -f /etc/init.d/slapd
    success "slapd stopped and disabled (OpenRC)."

  elif [[ -f /etc/init.d/slapd ]]; then
    service slapd stop 2>/dev/null || true
    if command -v update-rc.d &>/dev/null; then
      update-rc.d slapd remove 2>/dev/null || true
    elif command -v chkconfig &>/dev/null; then
      chkconfig slapd off 2>/dev/null || true
    fi
    rm -f /etc/init.d/slapd
    success "slapd stopped and disabled (SysVinit)."

  else
    # Fallback: kill by name
    if pkill -TERM slapd 2>/dev/null; then
      sleep 2
      pkill -KILL slapd 2>/dev/null || true
    fi
    warn "Init system not detected — killed slapd process directly."
  fi
}

# ------------------------------------------------------------------------------
# Remove packages
# ------------------------------------------------------------------------------
remove_packages() {
  info "Removing OpenLDAP packages..."

  case "${DISTRO_ID}" in
    debian|ubuntu|linuxmint|pop)
      DEBIAN_FRONTEND=noninteractive apt-get purge -y slapd ldap-utils 2>/dev/null || \
        DEBIAN_FRONTEND=noninteractive apt-get remove -y slapd ldap-utils 2>/dev/null || true
      apt-get autoremove -y 2>/dev/null || true
      success "OpenLDAP packages removed (Debian/Ubuntu)."
      ;;

    rhel|centos|almalinux|rocky|ol|scientific)
      if command -v dnf &>/dev/null; then
        dnf remove -y openldap-servers openldap-clients 2>/dev/null || true
      else
        yum remove -y openldap-servers openldap-clients 2>/dev/null || true
      fi
      success "OpenLDAP packages removed (RHEL/CentOS)."
      ;;

    fedora)
      dnf remove -y openldap-servers openldap-clients 2>/dev/null || true
      success "OpenLDAP packages removed (Fedora)."
      ;;

    alpine)
      apk del openldap openldap-back-mdb openldap-clients 2>/dev/null || true
      success "OpenLDAP packages removed (Alpine)."
      ;;

    arch|manjaro|endeavouros)
      pacman -Rns --noconfirm openldap 2>/dev/null || true
      success "OpenLDAP packages removed (Arch)."
      ;;

    *)
      if echo "${DISTRO_ID_LIKE}" | grep -qiE "debian|ubuntu"; then
        DEBIAN_FRONTEND=noninteractive apt-get purge -y slapd ldap-utils 2>/dev/null || true
        apt-get autoremove -y 2>/dev/null || true
      elif echo "${DISTRO_ID_LIKE}" | grep -qiE "rhel|fedora|centos"; then
        dnf remove -y openldap-servers openldap-clients 2>/dev/null || \
          yum remove -y openldap-servers openldap-clients 2>/dev/null || true
      else
        warn "Unknown distribution '${DISTRO_ID}'. Skipping package removal."
        warn "Remove OpenLDAP packages manually for your distribution."
      fi
      ;;
  esac
}

# ------------------------------------------------------------------------------
# Remove directories
# ------------------------------------------------------------------------------
remove_config() {
  info "Removing configuration directories..."
  rm -rf /etc/openldap/ 2>/dev/null || true
  rm -rf /etc/ldap/     2>/dev/null || true
  success "Configuration directories removed."
}

remove_data() {
  info "Removing database directories..."
  rm -rf /var/lib/ldap/       2>/dev/null || true
  rm -rf /var/lib/openldap/   2>/dev/null || true
  rm -rf /var/run/openldap/   2>/dev/null || true
  success "Database directories removed."
}

remove_logs() {
  info "Removing log files..."
  rm -f /var/log/slapd.log       2>/dev/null || true
  rm -f /var/log/slapd-error.log 2>/dev/null || true
  success "Log files removed."
}

remove_user() {
  info "Removing system user and group..."
  if getent passwd "${SLAPD_USER}" &>/dev/null; then
    userdel "${SLAPD_USER}" 2>/dev/null || true
    success "User '${SLAPD_USER}' removed."
  else
    info "User '${SLAPD_USER}' does not exist."
  fi
  if getent group "${SLAPD_GROUP}" &>/dev/null; then
    groupdel "${SLAPD_GROUP}" 2>/dev/null || true
    success "Group '${SLAPD_GROUP}' removed."
  else
    info "Group '${SLAPD_GROUP}' does not exist."
  fi
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
  require_root
  detect_distro

  echo ""
  echo -e "${RED}============================================================${NC}"
  echo -e "${RED} OpenLDAP Uninstallation${NC}"
  echo -e "${RED}============================================================${NC}"
  echo ""
  echo "  This script will:"
  echo "    - Stop and disable the slapd service"
  echo "    - Remove OpenLDAP packages"
  if [[ "${REMOVE_DATA}" == "true" ]]; then
    echo -e "    - ${RED}DELETE${NC} all LDAP database files (REMOVE_DATA=true)"
  fi
  if [[ "${REMOVE_CONFIG}" == "true" ]]; then
    echo -e "    - ${RED}DELETE${NC} all configuration files (REMOVE_CONFIG=true)"
  fi
  if [[ "${REMOVE_LOGS}" == "true" ]]; then
    echo "    - Remove log files (REMOVE_LOGS=true)"
  fi
  if [[ "${REMOVE_USER}" == "true" ]]; then
    echo "    - Remove the '${SLAPD_USER}' system user (REMOVE_USER=true)"
  fi
  echo ""

  if ! confirm "Continue with uninstallation?"; then
    echo "Uninstallation cancelled."
    exit 0
  fi

  # Backup before destroying anything
  if [[ "${REMOVE_DATA}" == "true" ]]; then
    if confirm "Back up LDAP data to ${BACKUP_DIR} before removal?"; then
      backup_data
    fi
  fi

  stop_service
  remove_packages

  if [[ "${REMOVE_CONFIG}" == "true" ]]; then
    remove_config
  else
    warn "Skipping config removal. Set REMOVE_CONFIG=true to remove /etc/openldap."
  fi

  if [[ "${REMOVE_DATA}" == "true" ]]; then
    remove_data
  else
    warn "Skipping data removal. Set REMOVE_DATA=true to remove /var/lib/ldap."
  fi

  if [[ "${REMOVE_LOGS}" == "true" ]]; then
    remove_logs
  fi

  if [[ "${REMOVE_USER}" == "true" ]]; then
    remove_user
  fi

  echo ""
  echo -e "${GREEN}============================================================${NC}"
  echo -e "${GREEN} OpenLDAP Uninstallation Complete${NC}"
  echo -e "${GREEN}============================================================${NC}"
  echo ""
  if [[ "${REMOVE_DATA}" != "true" ]]; then
    echo -e "  ${YELLOW}Note:${NC} Database files remain in /var/lib/ldap."
    echo "        Remove with: sudo rm -rf /var/lib/ldap"
  fi
  if [[ "${REMOVE_CONFIG}" != "true" ]]; then
    echo -e "  ${YELLOW}Note:${NC} Configuration files remain in /etc/openldap (or /etc/ldap)."
    echo "        Remove with: sudo rm -rf /etc/openldap"
  fi
  if [[ -d "${BACKUP_DIR}" ]]; then
    echo ""
    echo "  Backup location: ${BACKUP_DIR}"
  fi
  echo ""
}

main "$@"
