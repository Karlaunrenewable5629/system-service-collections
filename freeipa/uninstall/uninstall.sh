#!/bin/bash
# FreeIPA Server Uninstallation Script
# ======================================
# Removes the FreeIPA server installation using ipa-server-install --uninstall.
#
# This script will:
#   1. Stop all IPA services via ipactl
#   2. Run ipa-server-install --uninstall to remove configuration and data
#   3. Optionally remove installed packages (dnf/yum)
#   4. Optionally remove residual data directories
#   5. Restore firewall rules added during installation
#
# WARNING: This operation is DESTRUCTIVE and IRREVERSIBLE.
#   - All LDAP entries (users, groups, hosts, policies) will be deleted.
#   - All Kerberos principals and keytabs will be removed.
#   - All issued certificates will be revoked and the CA wiped.
#   - DNS zones managed by this server will be deleted (if DNS was enabled).
#
# Usage:
#   sudo bash uninstall.sh
#   sudo bash uninstall.sh --force        # skip confirmation prompts
#   sudo bash uninstall.sh --remove-pkgs  # also remove RPM packages
#   sudo bash uninstall.sh --purge        # remove packages + residual data
#
# Restore client machines first:
#   On each IPA client, run: sudo ipa-client-install --uninstall

set -euo pipefail

# ---------------------------------------------------------------------------
# Colour output helpers
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
die()     { error "$*"; exit 1; }

# ---------------------------------------------------------------------------
# Privilege check
# ---------------------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    die "This script must be run as root or with sudo."
fi

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
FORCE=false
REMOVE_PKGS=false
PURGE=false

for arg in "$@"; do
    case "${arg}" in
        --force)       FORCE=true ;;
        --remove-pkgs) REMOVE_PKGS=true ;;
        --purge)       REMOVE_PKGS=true; PURGE=true ;;
        --help|-h)
            grep '^#' "$0" | sed 's/^# \?//'
            exit 0
            ;;
        *) warn "Unknown argument: ${arg}" ;;
    esac
done

# ---------------------------------------------------------------------------
# Confirmation prompt
# ---------------------------------------------------------------------------
confirm_uninstall() {
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${RED}║           !! DESTRUCTIVE OPERATION WARNING !!            ║${RESET}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo "  This will PERMANENTLY remove the FreeIPA server and ALL data:"
    echo ""
    echo "   - All user accounts, groups, and host entries"
    echo "   - All Kerberos principals, keytabs, and tickets"
    echo "   - The PKI Certificate Authority and all issued certificates"
    echo "   - All HBAC rules, sudo rules, and DNS zones"
    echo "   - All FreeIPA configuration files"
    echo ""
    warn "Enrolled client machines MUST be unenrolled separately:"
    echo "  sudo ipa-client-install --uninstall   # run on each client"
    echo ""

    if ${FORCE}; then
        warn "--force flag set. Skipping confirmation."
        return 0
    fi

    read -r -p "Type 'yes' to confirm uninstallation: " CONFIRM
    if [[ "${CONFIRM}" != "yes" ]]; then
        info "Uninstallation cancelled."
        exit 0
    fi
}

# ---------------------------------------------------------------------------
# Check that ipa-server-install is available
# ---------------------------------------------------------------------------
check_ipa() {
    if [ ! -x /usr/sbin/ipa-server-install ]; then
        die "ipa-server-install not found. Is freeipa-server installed?"
    fi
}

# ---------------------------------------------------------------------------
# Stop IPA services gracefully before uninstall
# ---------------------------------------------------------------------------
stop_services() {
    info "Stopping IPA services..."
    if command -v ipactl &>/dev/null; then
        ipactl stop 2>/dev/null || warn "ipactl stop returned non-zero (may already be stopped)"
    fi

    # Ensure systemd unit is stopped too
    if systemctl is-active --quiet ipa 2>/dev/null; then
        systemctl stop ipa 2>/dev/null || true
    fi

    success "IPA services stopped."
}

# ---------------------------------------------------------------------------
# Run ipa-server-install --uninstall
# ---------------------------------------------------------------------------
run_uninstall() {
    info "Running ipa-server-install --uninstall..."
    info "This may take several minutes..."

    if ${FORCE}; then
        ipa-server-install --uninstall --unattended
    else
        ipa-server-install --uninstall --unattended
    fi

    success "ipa-server-install --uninstall completed."
}

# ---------------------------------------------------------------------------
# Disable the systemd unit
# ---------------------------------------------------------------------------
disable_service() {
    info "Disabling ipa.service..."
    systemctl disable ipa 2>/dev/null || true
    systemctl daemon-reload
    success "ipa.service disabled."
}

# ---------------------------------------------------------------------------
# Remove packages
# ---------------------------------------------------------------------------
remove_packages() {
    info "Removing freeipa-server packages..."

    if command -v dnf &>/dev/null; then
        dnf remove -y freeipa-server freeipa-server-dns freeipa-common 2>/dev/null || true
        dnf autoremove -y 2>/dev/null || true
    elif command -v yum &>/dev/null; then
        yum remove -y freeipa-server freeipa-server-dns freeipa-common 2>/dev/null || true
        yum autoremove -y 2>/dev/null || true
    else
        warn "Neither dnf nor yum found. Cannot remove packages automatically."
    fi

    success "FreeIPA packages removed."
}

# ---------------------------------------------------------------------------
# Purge residual data directories
# ---------------------------------------------------------------------------
purge_data() {
    warn "Purging residual FreeIPA data directories..."

    local dirs=(
        /etc/ipa
        /var/lib/ipa
        /var/log/ipa
        /var/lib/dirsrv
        /etc/dirsrv
        /var/log/dirsrv
        /etc/pki/pki-tomcat
        /var/lib/pki
        /var/log/pki
        /etc/named.conf.ipa_backup
    )

    for dir in "${dirs[@]}"; do
        if [ -e "${dir}" ]; then
            info "Removing ${dir}..."
            rm -rf "${dir}"
        fi
    done

    # Remove krb5 and named config modifications
    if [ -f /etc/krb5.conf.ipa_backup ]; then
        info "Restoring original /etc/krb5.conf..."
        mv /etc/krb5.conf.ipa_backup /etc/krb5.conf
    fi

    success "Residual data purged."
}

# ---------------------------------------------------------------------------
# Restore firewall rules
# ---------------------------------------------------------------------------
restore_firewall() {
    info "Removing FreeIPA firewall rules..."

    if systemctl is-active --quiet firewalld 2>/dev/null; then
        firewall-cmd --permanent --remove-service=freeipa-ldap 2>/dev/null || true
        firewall-cmd --permanent --remove-service=freeipa-ldaps 2>/dev/null || true
        firewall-cmd --permanent --remove-service=freeipa-replication 2>/dev/null || true
        firewall-cmd --permanent --remove-service=dns 2>/dev/null || true
        firewall-cmd --permanent --remove-port=88/tcp 2>/dev/null || true
        firewall-cmd --permanent --remove-port=88/udp 2>/dev/null || true
        firewall-cmd --permanent --remove-port=464/tcp 2>/dev/null || true
        firewall-cmd --permanent --remove-port=464/udp 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
        success "firewalld rules removed."
    else
        warn "firewalld not active. Skipping firewall cleanup."
    fi
}

# ---------------------------------------------------------------------------
# Post-uninstall summary
# ---------------------------------------------------------------------------
post_uninstall_info() {
    echo ""
    echo -e "${GREEN}=====================================================${RESET}"
    echo -e "${GREEN}  FreeIPA Uninstallation Complete${RESET}"
    echo -e "${GREEN}=====================================================${RESET}"
    echo ""
    echo "  The FreeIPA server has been removed from this host."
    echo ""

    if ! ${REMOVE_PKGS}; then
        echo "  Packages are still installed. To remove them:"
        echo "    sudo dnf remove freeipa-server freeipa-server-dns"
        echo ""
    fi

    if ! ${PURGE}; then
        echo "  Some data directories may remain under /etc/ipa, /var/lib/ipa."
        echo "  Run with --purge to remove them."
        echo ""
    fi

    echo "  Remember to unenroll any remaining client machines:"
    echo "    sudo ipa-client-install --uninstall    # run on each client"
    echo ""
    echo -e "${GREEN}=====================================================${RESET}"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    info "FreeIPA Server Uninstallation"
    check_ipa
    confirm_uninstall
    stop_services
    run_uninstall
    disable_service
    restore_firewall

    if ${REMOVE_PKGS}; then
        remove_packages
    fi

    if ${PURGE}; then
        purge_data
    fi

    post_uninstall_info
}

main "$@"
