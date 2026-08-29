#!/usr/bin/env bash
# =============================================================================
# HashiCorp Vault — Uninstall Script
# =============================================================================
# Stops the Vault service, removes the package, configuration, and related
# files. The Vault data directory is preserved by default.
#
# Usage:
#   sudo bash uninstall.sh [--remove-data]
#
# Options:
#   --remove-data   Also remove the Vault data directory.
#                   WARNING: This permanently destroys all stored secrets.
#                   Back up your data before using this option.
# =============================================================================

set -euo pipefail

# --- Configuration -----------------------------------------------------------
VAULT_USER="vault"
VAULT_CONFIG_DIR="/etc/vault.d"
VAULT_DATA_DIR="/opt/vault"
VAULT_LOG_DIR="/var/log/vault"
VAULT_RUN_DIR="/run/vault"
VAULT_LOCK_FILE="/var/lock/subsys/vault"
VAULT_SYSTEMD_UNIT="/etc/systemd/system/vault.service"
VAULT_OPENRC_SCRIPT="/etc/init.d/vault"
VAULT_SYSVINIT_SCRIPT="/etc/init.d/vault"
VAULT_APT_LIST="/etc/apt/sources.list.d/hashicorp.list"
VAULT_APT_KEY="/usr/share/keyrings/hashicorp-archive-keyring.gpg"
VAULT_YUM_REPO="/etc/yum.repos.d/hashicorp.repo"

REMOVE_DATA=false

# --- Colors ------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Helpers -----------------------------------------------------------------
info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

check_root() {
  if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root. Use: sudo bash uninstall.sh"
  fi
}

parse_args() {
  for arg in "$@"; do
    case "${arg}" in
      --remove-data)
        REMOVE_DATA=true
        ;;
      --help|-h)
        echo "Usage: sudo bash uninstall.sh [--remove-data]"
        echo ""
        echo "Options:"
        echo "  --remove-data   Also remove the Vault data directory (IRREVERSIBLE)."
        exit 0
        ;;
      *)
        warn "Unknown argument: ${arg}"
        ;;
    esac
  done
}

# --- Backup Prompt -----------------------------------------------------------
confirm_data_removal() {
  if [[ "${REMOVE_DATA}" == "true" ]]; then
    echo ""
    echo -e "${RED}========================================================"
    echo "  WARNING: --remove-data is set."
    echo "  The Vault data directory will be permanently deleted:"
    echo "    ${VAULT_DATA_DIR}"
    echo ""
    echo "  This action is IRREVERSIBLE."
    echo "  All stored secrets will be lost forever."
    echo -e "========================================================${NC}"
    echo ""
    read -rp "  Type 'yes' to confirm data removal: " confirmation
    if [[ "${confirmation}" != "yes" ]]; then
      warn "Data removal cancelled. Proceeding without --remove-data."
      REMOVE_DATA=false
    fi
  fi
}

# --- Stop & Disable Service --------------------------------------------------
stop_service() {
  info "Stopping and disabling Vault service..."

  # systemd
  if command -v systemctl &>/dev/null && systemctl list-units --full --all 2>/dev/null | grep -q "vault.service"; then
    systemctl stop vault 2>/dev/null && info "  Stopped vault (systemd)" || warn "  Could not stop vault (systemd)"
    systemctl disable vault 2>/dev/null && info "  Disabled vault (systemd)" || true
  fi

  # OpenRC
  if command -v rc-service &>/dev/null; then
    rc-service vault stop 2>/dev/null && info "  Stopped vault (OpenRC)" || true
    rc-update del vault default 2>/dev/null && info "  Removed vault from OpenRC default runlevel" || true
  fi

  # SysVinit
  if [[ -f /etc/init.d/vault ]] && command -v service &>/dev/null; then
    service vault stop 2>/dev/null && info "  Stopped vault (SysVinit)" || true
    if command -v update-rc.d &>/dev/null; then
      update-rc.d vault remove 2>/dev/null || true
    elif command -v chkconfig &>/dev/null; then
      chkconfig vault off 2>/dev/null || true
    fi
  fi
}

# --- Remove Service Files ----------------------------------------------------
remove_service_files() {
  info "Removing service files..."

  # systemd unit
  if [[ -f "${VAULT_SYSTEMD_UNIT}" ]]; then
    rm -f "${VAULT_SYSTEMD_UNIT}"
    info "  Removed: ${VAULT_SYSTEMD_UNIT}"
    systemctl daemon-reload
    systemctl reset-failed 2>/dev/null || true
  fi

  # OpenRC / SysVinit init script
  if [[ -f "${VAULT_OPENRC_SCRIPT}" ]]; then
    rm -f "${VAULT_OPENRC_SCRIPT}"
    info "  Removed: ${VAULT_OPENRC_SCRIPT}"
  fi

  # Lock file (SysVinit)
  if [[ -f "${VAULT_LOCK_FILE}" ]]; then
    rm -f "${VAULT_LOCK_FILE}"
  fi
}

# --- Remove Package ----------------------------------------------------------
remove_package() {
  if ! command -v vault &>/dev/null; then
    info "Vault binary not found — skipping package removal."
    return 0
  fi

  info "Removing Vault package..."

  if command -v apt-get &>/dev/null; then
    apt-get remove --purge -y vault 2>/dev/null && info "  Removed vault (APT)" || warn "  Could not remove via APT"
    apt-get autoremove -y 2>/dev/null || true
  elif command -v yum &>/dev/null; then
    yum remove -y vault 2>/dev/null && info "  Removed vault (YUM)" || warn "  Could not remove via YUM"
  elif command -v dnf &>/dev/null; then
    dnf remove -y vault 2>/dev/null && info "  Removed vault (DNF)" || warn "  Could not remove via DNF"
  else
    # Manual removal: remove binary directly
    VAULT_BIN="$(command -v vault 2>/dev/null || true)"
    if [[ -n "${VAULT_BIN}" ]]; then
      rm -f "${VAULT_BIN}"
      info "  Removed binary: ${VAULT_BIN}"
    fi
  fi
}

# --- Remove Repository -------------------------------------------------------
remove_repo() {
  info "Removing HashiCorp package repository..."

  # APT
  if [[ -f "${VAULT_APT_LIST}" ]]; then
    rm -f "${VAULT_APT_LIST}"
    info "  Removed: ${VAULT_APT_LIST}"
  fi
  if [[ -f "${VAULT_APT_KEY}" ]]; then
    rm -f "${VAULT_APT_KEY}"
    info "  Removed: ${VAULT_APT_KEY}"
  fi
  if command -v apt-get &>/dev/null; then
    apt-get update -qq 2>/dev/null || true
  fi

  # YUM / DNF
  if [[ -f "${VAULT_YUM_REPO}" ]]; then
    rm -f "${VAULT_YUM_REPO}"
    info "  Removed: ${VAULT_YUM_REPO}"
    if command -v yum &>/dev/null; then
      yum clean all -q 2>/dev/null || true
    fi
  fi
}

# --- Remove Config & Logs ----------------------------------------------------
remove_config_and_logs() {
  info "Removing configuration and log directories..."

  local dirs_to_remove=("${VAULT_CONFIG_DIR}" "${VAULT_LOG_DIR}" "${VAULT_RUN_DIR}")

  for dir in "${dirs_to_remove[@]}"; do
    if [[ -d "${dir}" ]]; then
      rm -rf "${dir}"
      info "  Removed: ${dir}"
    fi
  done
}

# --- Remove Data Directory ---------------------------------------------------
remove_data() {
  if [[ "${REMOVE_DATA}" == "true" ]]; then
    if [[ -d "${VAULT_DATA_DIR}" ]]; then
      info "Removing Vault data directory: ${VAULT_DATA_DIR}"
      rm -rf "${VAULT_DATA_DIR}"
      info "  Removed: ${VAULT_DATA_DIR}"
    else
      info "Data directory not found: ${VAULT_DATA_DIR} (already removed?)"
    fi
  else
    if [[ -d "${VAULT_DATA_DIR}" ]]; then
      warn "Skipping data directory: ${VAULT_DATA_DIR}"
      warn "Run with --remove-data to delete it (irreversible)."
    fi
  fi
}

# --- Remove Service User -----------------------------------------------------
remove_user() {
  if id "${VAULT_USER}" &>/dev/null; then
    info "Removing service user '${VAULT_USER}'..."
    userdel "${VAULT_USER}" 2>/dev/null && info "  Removed user: ${VAULT_USER}" || warn "  Could not remove user: ${VAULT_USER}"
    groupdel "${VAULT_USER}" 2>/dev/null || true
  else
    info "User '${VAULT_USER}' does not exist. Skipping."
  fi
}

# --- Summary -----------------------------------------------------------------
print_summary() {
  echo ""
  echo "========================================================================"
  echo "  HashiCorp Vault Uninstallation Complete"
  echo "========================================================================"
  echo ""
  echo "  Removed:"
  echo "    - Vault service (stopped and disabled)"
  echo "    - Vault package (binary)"
  echo "    - HashiCorp package repository"
  echo "    - Configuration: ${VAULT_CONFIG_DIR}"
  echo "    - Logs:          ${VAULT_LOG_DIR}"
  echo "    - Service user:  ${VAULT_USER}"
  echo ""
  if [[ "${REMOVE_DATA}" == "true" ]]; then
    echo "    - Data:          ${VAULT_DATA_DIR} (permanently deleted)"
  else
    echo "  Preserved:"
    echo "    - Data:          ${VAULT_DATA_DIR}"
    echo "      (run with --remove-data to delete)"
  fi
  echo "========================================================================"
}

# --- Main --------------------------------------------------------------------
main() {
  parse_args "$@"
  check_root
  confirm_data_removal
  info "Starting HashiCorp Vault uninstallation..."
  stop_service
  remove_service_files
  remove_package
  remove_repo
  remove_config_and_logs
  remove_data
  remove_user
  print_summary
}

main "$@"
