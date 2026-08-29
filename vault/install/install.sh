#!/usr/bin/env bash
# =============================================================================
# HashiCorp Vault — Install Script
# =============================================================================
# Installs Vault from the official HashiCorp package repository.
# Supports: Debian/Ubuntu, RHEL/CentOS/Fedora, Amazon Linux 2
#
# Usage:
#   sudo bash install.sh
#
# Environment variables (optional overrides):
#   VAULT_USER        Service user to create (default: vault)
#   VAULT_DATA_DIR    Raft storage directory   (default: /opt/vault/data)
#   VAULT_CONFIG_DIR  Configuration directory  (default: /etc/vault.d)
#   VAULT_LOG_DIR     Log directory            (default: /var/log/vault)
# =============================================================================

set -euo pipefail

# --- Configuration -----------------------------------------------------------
VAULT_USER="${VAULT_USER:-vault}"
VAULT_DATA_DIR="${VAULT_DATA_DIR:-/opt/vault/data}"
VAULT_CONFIG_DIR="${VAULT_CONFIG_DIR:-/etc/vault.d}"
VAULT_LOG_DIR="${VAULT_LOG_DIR:-/var/log/vault}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SOURCE="${SCRIPT_DIR}/../config/vault.hcl"

# --- Colors ------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Helpers -----------------------------------------------------------------
info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

check_root() {
  if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root. Use: sudo bash install.sh"
  fi
}

detect_os() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    OS_ID="${ID}"
    OS_ID_LIKE="${ID_LIKE:-}"
    OS_VERSION_ID="${VERSION_ID:-}"
  else
    error "Cannot detect OS. /etc/os-release not found."
  fi

  case "${OS_ID}" in
    ubuntu|debian|linuxmint|pop)
      PKG_MANAGER="apt"
      ;;
    rhel|centos|rocky|almalinux|fedora|ol)
      PKG_MANAGER="yum"
      ;;
    amzn)
      PKG_MANAGER="yum"
      ;;
    *)
      # Check ID_LIKE as fallback
      if [[ "${OS_ID_LIKE}" == *"debian"* ]]; then
        PKG_MANAGER="apt"
      elif [[ "${OS_ID_LIKE}" == *"rhel"* ]] || [[ "${OS_ID_LIKE}" == *"fedora"* ]]; then
        PKG_MANAGER="yum"
      else
        error "Unsupported OS: ${OS_ID}. Please install Vault manually."
      fi
      ;;
  esac

  info "Detected OS: ${OS_ID} ${OS_VERSION_ID} (package manager: ${PKG_MANAGER})"
}

# --- Install Functions -------------------------------------------------------
install_apt() {
  info "Adding HashiCorp APT repository..."

  apt-get update -qq
  apt-get install -y -qq curl gnupg apt-transport-https lsb-release ca-certificates

  # Import GPG key
  curl -fsSL https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

  # Add repository
  DISTRO_CODENAME="$(lsb_release -cs)"
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com ${DISTRO_CODENAME} main" \
    > /etc/apt/sources.list.d/hashicorp.list

  apt-get update -qq

  info "Installing Vault..."
  apt-get install -y vault

  info "Vault installed via APT."
}

install_yum() {
  info "Adding HashiCorp YUM repository..."

  # Install yum-utils if needed
  if ! command -v yum-config-manager &>/dev/null; then
    yum install -y -q yum-utils
  fi

  yum-config-manager --add-repo \
    https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

  info "Installing Vault..."
  yum install -y vault

  info "Vault installed via YUM."
}

install_vault_package() {
  if command -v vault &>/dev/null; then
    CURRENT_VERSION="$(vault version | awk '{print $2}')"
    warn "Vault is already installed (${CURRENT_VERSION}). Skipping package install."
    return 0
  fi

  case "${PKG_MANAGER}" in
    apt) install_apt ;;
    yum) install_yum ;;
    *)   error "Unsupported package manager: ${PKG_MANAGER}" ;;
  esac
}

setup_user() {
  if id "${VAULT_USER}" &>/dev/null; then
    info "User '${VAULT_USER}' already exists. Skipping."
  else
    info "Creating system user '${VAULT_USER}'..."
    useradd \
      --system \
      --home "${VAULT_CONFIG_DIR}" \
      --shell /bin/false \
      --comment "HashiCorp Vault service account" \
      "${VAULT_USER}"
  fi
}

setup_directories() {
  info "Creating directories..."

  local dirs=("${VAULT_CONFIG_DIR}" "${VAULT_CONFIG_DIR}/tls" "${VAULT_DATA_DIR}" "${VAULT_LOG_DIR}")

  for dir in "${dirs[@]}"; do
    if [[ ! -d "${dir}" ]]; then
      mkdir -p "${dir}"
      info "  Created: ${dir}"
    else
      info "  Exists:  ${dir}"
    fi
  done

  # Apply ownership and permissions
  chown -R "${VAULT_USER}:${VAULT_USER}" "${VAULT_CONFIG_DIR}" "${VAULT_DATA_DIR}" "${VAULT_LOG_DIR}"
  chmod 750 "${VAULT_CONFIG_DIR}" "${VAULT_DATA_DIR}"
  chmod 755 "${VAULT_LOG_DIR}"
}

install_config() {
  local dest="${VAULT_CONFIG_DIR}/vault.hcl"

  if [[ -f "${dest}" ]]; then
    warn "Config already exists at ${dest}. Creating backup..."
    cp "${dest}" "${dest}.bak.$(date +%Y%m%d%H%M%S)"
  fi

  if [[ -f "${CONFIG_SOURCE}" ]]; then
    info "Installing configuration file to ${dest}..."
    cp "${CONFIG_SOURCE}" "${dest}"
    # Update data path in config to match configured VAULT_DATA_DIR
    sed -i "s|/opt/vault/data|${VAULT_DATA_DIR}|g" "${dest}"
  else
    warn "Config template not found at ${CONFIG_SOURCE}. Creating minimal config..."
    cat > "${dest}" <<EOF
ui = true
log_level = "info"
disable_mlock = false
api_addr = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}

storage "raft" {
  path    = "${VAULT_DATA_DIR}"
  node_id = "vault-node-01"
}
EOF
  fi

  chown "${VAULT_USER}:${VAULT_USER}" "${dest}"
  chmod 640 "${dest}"
  info "Configuration installed: ${dest}"
}

set_capabilities() {
  # Grant mlock capability so Vault can lock memory without running as root
  VAULT_BIN="$(command -v vault)"
  if [[ -n "${VAULT_BIN}" ]]; then
    info "Setting IPC_LOCK capability on vault binary..."
    if setcap cap_ipc_lock=+ep "${VAULT_BIN}"; then
      info "  cap_ipc_lock granted to ${VAULT_BIN}"
    else
      warn "  Could not set cap_ipc_lock. Vault may need disable_mlock = true in config."
    fi
  fi
}

install_service() {
  local service_dir="${SCRIPT_DIR}/../service"

  if command -v systemctl &>/dev/null; then
    local unit_src="${service_dir}/systemd/vault.service"
    if [[ -f "${unit_src}" ]]; then
      info "Installing systemd unit file..."
      cp "${unit_src}" /etc/systemd/system/vault.service
      systemctl daemon-reload
      systemctl enable vault
      info "systemd service enabled. Start with: sudo systemctl start vault"
    else
      warn "systemd unit not found at ${unit_src}. Skipping service install."
    fi
  elif command -v rc-update &>/dev/null; then
    local openrc_src="${service_dir}/openrc/vault"
    if [[ -f "${openrc_src}" ]]; then
      info "Installing OpenRC init script..."
      cp "${openrc_src}" /etc/init.d/vault
      chmod +x /etc/init.d/vault
      rc-update add vault default
      info "OpenRC service enabled. Start with: sudo rc-service vault start"
    else
      warn "OpenRC init script not found at ${openrc_src}. Skipping service install."
    fi
  elif [[ -d /etc/init.d ]]; then
    local sysvinit_src="${service_dir}/sysvinit/vault"
    if [[ -f "${sysvinit_src}" ]]; then
      info "Installing SysVinit init script..."
      cp "${sysvinit_src}" /etc/init.d/vault
      chmod +x /etc/init.d/vault
      update-rc.d vault defaults || chkconfig vault on
      info "SysVinit service enabled. Start with: sudo service vault start"
    else
      warn "SysVinit init script not found at ${sysvinit_src}. Skipping service install."
    fi
  else
    warn "No supported init system detected. Install the service manually."
  fi
}

print_next_steps() {
  echo ""
  echo "========================================================================"
  echo "  HashiCorp Vault Installation Complete"
  echo "========================================================================"
  echo ""
  echo "  Config file : ${VAULT_CONFIG_DIR}/vault.hcl"
  echo "  Data dir    : ${VAULT_DATA_DIR}"
  echo "  Log dir     : ${VAULT_LOG_DIR}"
  echo ""
  echo "  Next steps:"
  echo ""
  echo "  1. Review the configuration file:"
  echo "       sudo nano ${VAULT_CONFIG_DIR}/vault.hcl"
  echo ""
  echo "  2. Start Vault:"
  echo "       sudo systemctl start vault   # systemd"
  echo "       sudo rc-service vault start  # OpenRC"
  echo ""
  echo "  3. Initialize Vault (first time only):"
  echo "       export VAULT_ADDR='http://127.0.0.1:8200'"
  echo "       vault operator init"
  echo ""
  echo "  4. Unseal Vault using the generated keys:"
  echo "       vault operator unseal <key>"
  echo ""
  echo "  5. Log in:"
  echo "       vault login <root-token>"
  echo ""
  echo "  See install/README.md for full documentation."
  echo "========================================================================"
}

# --- Main --------------------------------------------------------------------
main() {
  info "Starting HashiCorp Vault installation..."
  check_root
  detect_os
  install_vault_package
  setup_user
  setup_directories
  install_config
  set_capabilities
  install_service
  print_next_steps
}

main "$@"
