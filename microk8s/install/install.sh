#!/bin/bash
# MicroK8s Installation Script
# Requires: snap package manager

set -euo pipefail

MICROK8S_CHANNEL="${MICROK8S_CHANNEL:-1.31/stable}"
ADDONS="${ADDONS:-dns ingress metrics-server}"

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
}

install_snap() {
    if ! command -v snap &>/dev/null; then
        echo "snap not found. Installing..."
        if command -v apt-get &>/dev/null; then
            apt-get update && apt-get install -y snapd
        elif command -v dnf &>/dev/null; then
            dnf install -y snapd
            systemctl enable --now snapd.socket
            ln -sf /var/lib/snapd/snap /snap 2>/dev/null || true
        else
            echo "ERROR: Cannot install snap automatically on this system."
            echo "Please install snap manually: https://snapcraft.io/docs/installing-snapd"
            exit 1
        fi
        sleep 5
    fi
}

install_microk8s() {
    echo "Installing MicroK8s channel: $MICROK8S_CHANNEL ..."
    snap install microk8s --classic --channel="$MICROK8S_CHANNEL"
}

configure_groups() {
    SUDO_USER="${SUDO_USER:-}"
    if [ -n "$SUDO_USER" ]; then
        usermod -aG microk8s "$SUDO_USER"
        mkdir -p /home/"$SUDO_USER"/.kube
        chown -R "$SUDO_USER" /home/"$SUDO_USER"/.kube
        echo "Added $SUDO_USER to microk8s group."
        echo "Log out and back in for group changes to take effect."
    fi
}

wait_ready() {
    echo "Waiting for MicroK8s to be ready..."
    microk8s status --wait-ready --timeout 120
}

enable_addons() {
    if [ -n "$ADDONS" ]; then
        echo "Enabling add-ons: $ADDONS ..."
        # shellcheck disable=SC2086
        microk8s enable $ADDONS
    fi
}

export_kubeconfig() {
    SUDO_USER="${SUDO_USER:-}"
    if [ -n "$SUDO_USER" ]; then
        KUBECONFIG_PATH="/home/$SUDO_USER/.kube/config"
        microk8s config > "$KUBECONFIG_PATH"
        chown "$SUDO_USER" "$KUBECONFIG_PATH"
        chmod 600 "$KUBECONFIG_PATH"
        echo "Kubeconfig exported to $KUBECONFIG_PATH"
    fi
}

main() {
    check_root
    install_snap
    install_microk8s
    configure_groups
    wait_ready
    enable_addons
    export_kubeconfig

    echo ""
    echo "MicroK8s installed successfully!"
    echo ""
    echo "Check status : microk8s status"
    echo "Get nodes    : microk8s kubectl get nodes"
    echo "Add node     : microk8s add-node"
    echo ""
    echo "Tip: Add an alias for convenience:"
    echo "  alias kubectl='microk8s kubectl'"
}

main "$@"
