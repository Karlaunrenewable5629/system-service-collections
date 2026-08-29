#!/bin/bash
# k3s Installation Script
# Supports: systemd-based Linux distributions

set -euo pipefail

K3S_VERSION="${K3S_VERSION:-}"          # Leave empty to install latest
K3S_MODE="${K3S_MODE:-server}"          # server | agent
K3S_SERVER_URL="${K3S_SERVER_URL:-}"    # Required for agent mode
K3S_TOKEN="${K3S_TOKEN:-}"              # Required for agent; auto-set for server
CONFIG_DIR="/etc/rancher/k3s"

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
}

install_dependencies() {
    if command -v apt-get &>/dev/null; then
        apt-get update
        apt-get install -y curl open-iscsi nfs-common
    elif command -v dnf &>/dev/null; then
        dnf install -y curl iscsi-initiator-utils nfs-utils
    elif command -v apk &>/dev/null; then
        apk add --no-cache curl open-iscsi nfs-utils
    fi
}

configure() {
    mkdir -p "$CONFIG_DIR"
    if [ ! -f "$CONFIG_DIR/config.yaml" ]; then
        echo "Copying k3s configuration..."
        cp config/config.yaml "$CONFIG_DIR/config.yaml"
    fi
}

install_server() {
    echo "Installing k3s server..."
    local install_args="INSTALL_K3S_EXEC=server"

    if [ -n "$K3S_VERSION" ]; then
        export INSTALL_K3S_VERSION="$K3S_VERSION"
    fi

    curl -sfL https://get.k3s.io | sh -
}

install_agent() {
    if [ -z "$K3S_SERVER_URL" ] || [ -z "$K3S_TOKEN" ]; then
        echo "ERROR: K3S_SERVER_URL and K3S_TOKEN must be set for agent mode."
        echo "  export K3S_SERVER_URL=https://<server-ip>:6443"
        echo "  export K3S_TOKEN=<token-from-server>"
        exit 1
    fi

    echo "Installing k3s agent..."
    if [ -n "$K3S_VERSION" ]; then
        export INSTALL_K3S_VERSION="$K3S_VERSION"
    fi

    curl -sfL https://get.k3s.io | \
        K3S_URL="$K3S_SERVER_URL" \
        K3S_TOKEN="$K3S_TOKEN" \
        sh -
}

post_install() {
    echo ""
    echo "k3s installed successfully!"
    echo ""
    if [ "$K3S_MODE" = "server" ]; then
        echo "Kubeconfig : /etc/rancher/k3s/k3s.yaml"
        echo "Node token : /var/lib/rancher/k3s/server/node-token"
        echo ""
        echo "To use kubectl without sudo:"
        echo "  sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config"
        echo "  sudo chown \$USER ~/.kube/config"
        echo ""
        echo "Check nodes:"
        echo "  sudo k3s kubectl get nodes"
    else
        echo "Agent joined cluster at $K3S_SERVER_URL"
        echo "Check from the server: kubectl get nodes"
    fi
}

main() {
    check_root
    install_dependencies
    configure

    if [ "$K3S_MODE" = "agent" ]; then
        install_agent
    else
        install_server
    fi

    post_install
}

main "$@"
