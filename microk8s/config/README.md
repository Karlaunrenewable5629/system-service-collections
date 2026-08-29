# MicroK8s Configuration

## Configuration Approach

MicroK8s is configured through three mechanisms:

1. **Snap configuration** — runtime options via `snap set microk8s`
2. **Args files** — component flags in `/var/snap/microk8s/current/args/`
3. **Add-on flags** — per-add-on configuration at enable time

## Args Files

| File | Component |
|------|-----------|
| `/var/snap/microk8s/current/args/kube-apiserver` | API server flags |
| `/var/snap/microk8s/current/args/kubelet` | kubelet flags |
| `/var/snap/microk8s/current/args/kube-proxy` | kube-proxy flags |
| `/var/snap/microk8s/current/args/kube-scheduler` | scheduler flags |
| `/var/snap/microk8s/current/args/kube-controller-manager` | controller manager flags |
| `/var/snap/microk8s/current/args/containerd-template.toml` | containerd config |

## Common Snap Settings

```bash
# Set HTTP proxy
sudo snap set microk8s proxy.http="http://proxy.example.com:3128"
sudo snap set microk8s proxy.https="http://proxy.example.com:3128"
sudo snap set microk8s proxy.no_proxy="localhost,127.0.0.1,10.0.0.0/8"

# View all snap config
sudo snap get microk8s -d
```

## Essential Add-ons

| Add-on | Description | Command |
|--------|-------------|---------|
| `dns` | CoreDNS | `microk8s enable dns` |
| `ingress` | NGINX Ingress | `microk8s enable ingress` |
| `metrics-server` | Resource metrics | `microk8s enable metrics-server` |
| `dashboard` | Kubernetes Dashboard | `microk8s enable dashboard` |
| `storage` | Local path provisioner | `microk8s enable storage` |
| `registry` | Private registry (:32000) | `microk8s enable registry` |
| `gpu` | NVIDIA GPU support | `microk8s enable gpu` |
| `prometheus` | Prometheus + Grafana | `microk8s enable prometheus` |
| `cert-manager` | Certificate management | `microk8s enable cert-manager` |
| `argocd` | GitOps CD | `microk8s enable argocd` |

## Kubeconfig

```bash
# Export to ~/.kube/config
microk8s config > ~/.kube/config

# Or use the built-in kubectl
microk8s kubectl get nodes

# Create an alias
alias kubectl='microk8s kubectl'
```

## File Locations

| Path | Description |
|------|-------------|
| `/var/snap/microk8s/current/args/` | Component argument files |
| `/var/snap/microk8s/current/credentials/` | Certificates and tokens |
| `/var/snap/microk8s/common/` | Persistent data |
| `/var/snap/microk8s/common/var/log/` | Logs |

## Resources

- [MicroK8s Configuration](https://microk8s.io/docs/configuring-services)
- [Add-ons Reference](https://microk8s.io/docs/addons)
- [Multi-node Clustering](https://microk8s.io/docs/clustering)
