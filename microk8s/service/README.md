# MicroK8s Service Management

MicroK8s manages its own snap services. Use the `microk8s` CLI for lifecycle management.

## microk8s CLI

```bash
# Start
microk8s start

# Stop
microk8s stop

# Restart
microk8s stop && microk8s start

# Check status
microk8s status

# Wait until ready
microk8s status --wait-ready
```

## Underlying snap services (systemd)

```bash
# API server / kubelet (kubelite)
sudo systemctl status snap.microk8s.daemon-kubelite
sudo systemctl restart snap.microk8s.daemon-kubelite

# containerd
sudo systemctl status snap.microk8s.daemon-containerd
sudo systemctl restart snap.microk8s.daemon-containerd

# Cluster agent
sudo systemctl status snap.microk8s.daemon-cluster-agent

# View logs
journalctl -u snap.microk8s.daemon-kubelite -f
journalctl -u snap.microk8s.daemon-containerd -f
```

## Add-on Management

```bash
# Enable add-ons
microk8s enable dns ingress metrics-server dashboard storage

# Disable an add-on
microk8s disable traefik

# List enabled add-ons
microk8s status
```

## Cluster Operations

```bash
# Get nodes
microk8s kubectl get nodes

# Get all pods
microk8s kubectl get pods -A

# Add a worker node (run on primary)
microk8s add-node

# Leave the cluster (run on worker)
microk8s leave

# Remove a node (run on primary)
microk8s remove-node <node-name>

# Cluster info
microk8s kubectl cluster-info
```
