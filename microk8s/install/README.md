# MicroK8s Installation

## Quick Install

```bash
sudo ./install.sh
```

## Manual Installation

### From Snap (recommended)

```bash
# Latest stable
sudo snap install microk8s --classic

# Specific version channel
sudo snap install microk8s --classic --channel=1.31/stable
```

### Available Channels

```bash
snap info microk8s | grep channels
```

| Channel | Description |
|---------|-------------|
| `1.31/stable` | Latest stable 1.31 |
| `1.30/stable` | Latest stable 1.30 |
| `latest/edge` | Development build |

## Post-Installation

1. Add user to microk8s group:
```bash
sudo usermod -aG microk8s $USER
newgrp microk8s
```

2. Wait for ready:
```bash
microk8s status --wait-ready
```

3. Enable core add-ons:
```bash
microk8s enable dns ingress metrics-server
```

4. Export kubeconfig:
```bash
microk8s config > ~/.kube/config
chmod 600 ~/.kube/config
```

5. Convenient alias:
```bash
echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc
source ~/.bashrc
```

## Verify Installation

```bash
microk8s status
microk8s kubectl get nodes
microk8s kubectl get pods -A
```

## Uninstall

```bash
sudo ./uninstall/uninstall.sh
```
