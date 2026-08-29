# k3s Installation

## Quick Install

```bash
# Server node
sudo ./install.sh

# Agent node
K3S_MODE=agent K3S_SERVER_URL=https://<server-ip>:6443 K3S_TOKEN=<token> sudo -E ./install.sh
```

## Manual Installation

### One-line Install (latest)

```bash
curl -sfL https://get.k3s.io | sh -
```

### Specific Version

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.31.0+k3s1 sh -
```

### Agent Node

```bash
# Get the token from the server first
sudo cat /var/lib/rancher/k3s/server/node-token

# Install on agent
curl -sfL https://get.k3s.io | \
  K3S_URL=https://<server-ip>:6443 \
  K3S_TOKEN=<token> \
  sh -
```

### Disable Built-in Components

```bash
curl -sfL https://get.k3s.io | sh -s - server \
  --disable traefik \
  --disable servicelb
```

## Post-Installation

1. Place config file:
```bash
sudo mkdir -p /etc/rancher/k3s
sudo cp config/config.yaml /etc/rancher/k3s/config.yaml
```

2. Start the service:
```bash
sudo systemctl start k3s
sudo systemctl enable k3s
```

3. Export kubeconfig:
```bash
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config
chmod 600 ~/.kube/config
```

## Verify Installation

```bash
sudo k3s kubectl get nodes
sudo k3s kubectl get pods -A
k3s --version
```

## Uninstall

```bash
sudo ./uninstall/uninstall.sh
```
