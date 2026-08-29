# containerd Configuration

## config.toml

The main configuration file is `config.toml`, located at `/etc/containerd/config.toml` on Linux.  
Generate a default config with:

```bash
containerd config default > /etc/containerd/config.toml
```

## Key Sections

| Section | Description |
|---------|-------------|
| `[grpc]` | Unix socket address and message size limits |
| `[debug]` | Log level and format (`info`, `debug`, `warn`, `error`) |
| `[metrics]` | Prometheus metrics endpoint |
| `[plugins."io.containerd.grpc.v1.cri"]` | Kubernetes CRI settings |
| `[plugins."io.containerd.grpc.v1.cri".containerd]` | Snapshotter and runtime selection |
| `[plugins."io.containerd.grpc.v1.cri".cni]` | CNI plugin paths |
| `[plugins."io.containerd.grpc.v1.cri".registry]` | Registry mirrors and auth |

## Common Settings

### Enable systemd cgroup driver (recommended for Kubernetes)

```toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  SystemdCgroup = true
```

### Custom registry mirror

```toml
[plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
  endpoint = ["https://mirror.example.com"]
```

### Change snapshotter

```toml
[plugins."io.containerd.grpc.v1.cri".containerd]
  snapshotter = "overlayfs"   # overlayfs | btrfs | zfs | devmapper | native
```

### Change sandbox (pause) image

```toml
[plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "registry.k8s.io/pause:3.9"
```

## File Locations

| System | Config Path |
|--------|-------------|
| Linux (systemd) | `/etc/containerd/config.toml` |
| Windows | `C:\containerd\config.toml` |
| Socket | `/run/containerd/containerd.sock` |
| Data root | `/var/lib/containerd` |
| State | `/run/containerd` |

## Reloading Configuration

containerd requires a full restart to apply configuration changes:

```bash
# systemd
sudo systemctl restart containerd

# OpenRC
sudo rc-service containerd restart
```

## Resources

- [containerd config reference](https://github.com/containerd/containerd/blob/main/docs/man/containerd-config.toml.5.md)
- [CRI plugin configuration](https://github.com/containerd/containerd/blob/main/docs/cri/config.md)
- [Snapshotter documentation](https://github.com/containerd/containerd/blob/main/docs/snapshotters/)
