#!/bin/bash
# FreeIPA Server Installation Script
# ====================================
# Installs the freeipa-server package and runs ipa-server-install
# with interactive prompts (or unattended mode via environment variables).
#
# Supported distributions:
#   - RHEL 8 / 9
#   - CentOS Stream 8 / 9
#   - Fedora 38+
#   - Rocky Linux 8 / 9
#   - AlmaLinux 8 / 9
#
# Usage:
#   sudo bash install.sh              # interactive mode
#   sudo bash install.sh --unattended # unattended mode (set env vars first)
#
# Unattended mode environment variables:
#   IPA_REALM       Kerberos realm, e.g. EXAMPLE.COM
#   IPA_DOMAIN      DNS domain, e.g. example.com
#   IPA_HOSTNAME    FQDN of this server, e.g. ipa.example.com
#   IPA_ADMIN_PASS  Password for the 'admin' IPA account
#   IPA_DM_PASS     Directory Manager password (LDAP)
#   IPA_SETUP_DNS   Set to 'yes' to also configure DNS with BIND (default: no)
#   IPA_FORWARDER   DNS forwarder IP, e.g. 8.8.8.8 (used if IPA_SETUP_DNS=yes)
#
# Example (unattended):
#   export IPA_REALM="EXAMPLE.COM"
#   export IPA_DOMAIN="example.com"
#   export IPA_HOSTNAME="ipa.example.com"
#   export IPA_ADMIN_PASS="Admin1234!"
#   export IPA_DM_PASS="DMpass1234!"
#   export IPA_SETUP_DNS="yes"
#   export IPA_FORWARDER="8.8.8.8"
#   sudo -E bash install.sh --unattended

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
UNATTENDED=false
for arg in "$@"; do
    case "${arg}" in
        --unattended) UNATTENDED=true ;;
        --help|-h)
            grep '^#' "$0" | sed 's/^# \?//'
            exit 0
            ;;
        *) warn "Unknown argument: ${arg}" ;;
    esac
done

# ---------------------------------------------------------------------------
# Detect OS
# ---------------------------------------------------------------------------
detect_os() {
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        OS_ID="${ID}"
        OS_VERSION="${VERSION_ID%%.*}"
    else
        die "Cannot detect OS. /etc/os-release not found."
    fi

    case "${OS_ID}" in
        rhel|centos|rocky|almalinux|fedora) : ;;
        *)
            die "Unsupported OS: ${OS_ID}. FreeIPA server requires RHEL/CentOS/Fedora/Rocky/AlmaLinux."
            ;;
    esac

    info "Detected OS: ${OS_ID} ${OS_VERSION}"
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
preflight_checks() {
    info "Running pre-flight checks..."

    # Check FQDN
    local hostname
    hostname=$(hostname -f 2>/dev/null || true)
    if [[ -z "${hostname}" || "${hostname}" == *"."* ]]; then
        success "Hostname FQDN: ${hostname}"
    else
        warn "Hostname does not appear to be a FQDN: '${hostname}'"
        warn "Set a proper FQDN with: hostnamectl set-hostname ipa.example.com"
    fi

    # Check available RAM (recommend >= 2 GB)
    local mem_kb
    mem_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    local mem_mb=$(( mem_kb / 1024 ))
    if (( mem_mb < 1800 )); then
        warn "Available RAM: ${mem_mb} MB. FreeIPA recommends at least 2 GB."
    else
        success "Available RAM: ${mem_mb} MB"
    fi

    # Check that required ports are not already bound
    local ports=(80 443 389 636 88 464 53)
    for port in "${ports[@]}"; do
        if ss -tlnp 2>/dev/null | grep -q ":${port} "; then
            warn "Port ${port} appears to be already in use."
        fi
    done

    # Check SELinux (should be enforcing or permissive — not disabled)
    local selinux_mode
    selinux_mode=$(getenforce 2>/dev/null || echo "Unknown")
    if [[ "${selinux_mode}" == "Disabled" ]]; then
        warn "SELinux is disabled. FreeIPA works best with SELinux enforcing."
    else
        success "SELinux mode: ${selinux_mode}"
    fi

    # Check that chrony/ntpd is running for Kerberos time sync
    if systemctl is-active --quiet chronyd 2>/dev/null || systemctl is-active --quiet ntpd 2>/dev/null; then
        success "NTP service is active."
    else
        warn "No NTP daemon detected. Kerberos requires accurate time. Install chronyd."
    fi

    info "Pre-flight checks complete."
}

# ---------------------------------------------------------------------------
# Package installation
# ---------------------------------------------------------------------------
install_packages() {
    info "Updating package cache..."

    if command -v dnf &>/dev/null; then
        dnf makecache -q
        info "Installing freeipa-server and optional DNS support..."
        dnf install -y freeipa-server freeipa-server-dns
    elif command -v yum &>/dev/null; then
        yum makecache -q
        info "Installing freeipa-server and optional DNS support..."
        yum install -y freeipa-server freeipa-server-dns
    else
        die "Neither dnf nor yum found. Cannot install packages."
    fi

    success "FreeIPA packages installed."
}

# ---------------------------------------------------------------------------
# Firewall configuration
# ---------------------------------------------------------------------------
configure_firewall() {
    info "Configuring firewall..."

    if systemctl is-active --quiet firewalld 2>/dev/null; then
        info "firewalld detected — adding freeipa-ldap, freeipa-ldaps, freeipa-replication services..."
        firewall-cmd --permanent --add-service=freeipa-ldap
        firewall-cmd --permanent --add-service=freeipa-ldaps
        firewall-cmd --permanent --add-service=freeipa-replication
        firewall-cmd --permanent --add-service=dns
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        firewall-cmd --permanent --add-port=88/tcp
        firewall-cmd --permanent --add-port=88/udp
        firewall-cmd --permanent --add-port=464/tcp
        firewall-cmd --permanent --add-port=464/udp
        firewall-cmd --reload
        success "firewalld rules applied."
    elif command -v ufw &>/dev/null && ufw status | grep -q "active"; then
        warn "ufw detected. Opening required ports manually..."
        ufw allow 80/tcp
        ufw allow 443/tcp
        ufw allow 389/tcp
        ufw allow 636/tcp
        ufw allow 88/tcp
        ufw allow 88/udp
        ufw allow 464/tcp
        ufw allow 464/udp
        ufw allow 53/tcp
        ufw allow 53/udp
        success "ufw rules applied."
    else
        warn "No active firewall detected. Ensure ports 80, 443, 389, 636, 88, 464, 53 are reachable."
    fi
}

# ---------------------------------------------------------------------------
# IPA Server Setup
# ---------------------------------------------------------------------------
run_ipa_install() {
    if ${UNATTENDED}; then
        info "Running ipa-server-install in unattended mode..."

        # Validate required environment variables
        : "${IPA_REALM:?IPA_REALM environment variable is required}"
        : "${IPA_DOMAIN:?IPA_DOMAIN environment variable is required}"
        : "${IPA_HOSTNAME:?IPA_HOSTNAME environment variable is required}"
        : "${IPA_ADMIN_PASS:?IPA_ADMIN_PASS environment variable is required}"
        : "${IPA_DM_PASS:?IPA_DM_PASS environment variable is required}"

        IPA_SETUP_DNS="${IPA_SETUP_DNS:-no}"
        IPA_FORWARDER="${IPA_FORWARDER:-8.8.8.8}"

        local dns_args=()
        if [[ "${IPA_SETUP_DNS}" == "yes" ]]; then
            dns_args=(
                --setup-dns
                --forwarder="${IPA_FORWARDER}"
                --auto-reverse
            )
        else
            dns_args=(--no-ntp)
        fi

        ipa-server-install \
            --unattended \
            --realm="${IPA_REALM}" \
            --domain="${IPA_DOMAIN}" \
            --hostname="${IPA_HOSTNAME}" \
            --admin-password="${IPA_ADMIN_PASS}" \
            --ds-password="${IPA_DM_PASS}" \
            "${dns_args[@]}"

    else
        info "Running ipa-server-install in interactive mode..."
        info "You will be prompted for realm, domain, and passwords."
        info ""
        info "Tip: Run with --setup-dns to configure BIND DNS at the same time."
        info ""
        ipa-server-install
    fi

    success "ipa-server-install completed."
}

# ---------------------------------------------------------------------------
# Enable and start the service
# ---------------------------------------------------------------------------
enable_service() {
    info "Enabling and starting ipa.service..."
    systemctl daemon-reload
    systemctl enable ipa
    # ipa-server-install starts the services itself; avoid a double-start
    if ! ipactl status &>/dev/null; then
        systemctl start ipa
    fi
    success "FreeIPA service enabled and running."
}

# ---------------------------------------------------------------------------
# Post-install summary
# ---------------------------------------------------------------------------
post_install_info() {
    local hostname
    hostname=$(hostname -f 2>/dev/null || echo "<your-ipa-server>")

    echo ""
    echo -e "${GREEN}=====================================================${RESET}"
    echo -e "${GREEN}  FreeIPA Installation Complete${RESET}"
    echo -e "${GREEN}=====================================================${RESET}"
    echo ""
    echo "  Web UI:       https://${hostname}/ipa/ui"
    echo "  Admin user:   admin"
    echo "  Realm:        ${IPA_REALM:-<realm set during install>}"
    echo ""
    echo "  Get a Kerberos ticket:  kinit admin"
    echo "  Check service status:   sudo ipactl status"
    echo "  View logs:              journalctl -u ipa -f"
    echo ""
    echo "  Client enrollment:"
    echo "    sudo ipa-client-install --domain=${IPA_DOMAIN:-example.com} \\"
    echo "         --server=${hostname} --mkhomedir"
    echo ""
    echo -e "${GREEN}=====================================================${RESET}"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    info "Starting FreeIPA server installation..."
    detect_os
    preflight_checks
    install_packages
    configure_firewall
    run_ipa_install
    enable_service
    post_install_info
}

main "$@"
