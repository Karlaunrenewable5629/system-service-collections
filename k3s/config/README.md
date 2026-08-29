# k3s Configuration

## config.yaml

The main configuration file is `config.yaml`, located at `/etc/rancher/k3s/config.yaml`.  
Options can also be passed as CLI flags or environment variables.

## Key Options

| Option | Description | Default |
|--------|-------------|---------|
| `cluster-cidr` | Pod IP range | `10.42.0.0/16` |
| `service-cidr` | Service IP range | `10.43.0.0/16` |
| `cluster-dns` | Cluster DNS IP | `10.43.0.10` |
| `tls-san` | Extra SAN entries for TLS cert | — |
| `disable` | Disable built-in components | — |
| `write-kubeconfig-mode` | Permissions for kubeconfig | `0600` |
| `cluster-init` | Bootstrap embedded etcd HA | false |
| `datastore-endpoint` | External DB connection string | — |
| `token` | Shared secret for node join | auto-generated |

## File Locations

| Path | Description |
|------|-------------|
| `/etc/rancher/k3s/config.yaml` | Server/agent config |
| `/etc/rancher/k3s/k3s.yaml` | Kubeconfig (root-owned) |
| `/var/lib/rancher/k3s/` | Data directory |
| `/var/lib/rancher/k3s/server/node-token` | Node join token |
| `/var/log/k3s.log` | Log file (if not using journald) |
| `/run/k3s/containerd/` | containerd socket |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `K3S_URL` | Server URL (agent nodes) |
| `K3S_TOKEN` | Node join token |
| `K3S_KUBECONFIG_MODE` | Kubeconfig file mode |
| `K3S_DATASTORE_ENDPOINT` | External datastore URL |
| `INSTALL_K3S_VERSION` | Specific version to install |
| `INSTALL_K3S_EXEC` | Override install mode (`server`/`agent`) |

## Accessing the Cluster

```bash
# Using built-in kubectl
sudo k3s kubectl get nodes

# Export kubeconfig for standard kubectl
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config

# Or set KUBECONFIG
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes
```

## Embedded etcd HA (3-node)

```bash
# Node 1 — bootstrap
echo "cluster-init: true" >> /etc/rancher/k3s/config.yaml
systemctl restart k3s

# Nodes 2 & 3 — join with server role
echo "server: https://node1:6443" >> /etc/rancher/k3s/config.yaml
echo "token: $(cat /var/lib/rancher/k3s/server/node-token)" >> /etc/rancher/k3s/config.yaml
```

## Resources

- [k3s Configuration Reference](https://docs.k3s.io/installation/configuration)
- [Server Options](https://docs.k3s.io/cli/server)
- [Agent Options](https://docs.k3s.io/cli/agent)
