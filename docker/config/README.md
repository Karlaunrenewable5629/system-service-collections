# Docker Configuration

## daemon.json

The Docker daemon configuration file is `daemon.json`, located at `/etc/docker/daemon.json` on Linux and `C:\ProgramData\docker\config\daemon.json` on Windows.

## Key Options

| Option | Description |
|--------|-------------|
| `data-root` | Root directory for Docker data (images, containers, volumes) |
| `log-driver` | Default logging driver (`json-file`, `syslog`, `journald`, `none`) |
| `log-opts` | Logging driver options (max size, file count) |
| `storage-driver` | Storage driver (`overlay2`, `devicemapper`, `aufs`, `btrfs`, `zfs`) |
| `dns` | DNS servers for containers |
| `live-restore` | Keep containers alive during daemon downtime |
| `registry-mirrors` | Fallback registry mirrors for Docker Hub |
| `insecure-registries` | Registries accessible over HTTP |
| `metrics-addr` | Prometheus metrics endpoint |
| `experimental` | Enable experimental features |

## Common Configurations

### Private registry mirror

```json
{
  "registry-mirrors": ["https://mirror.example.com"]
}
```

### Insecure private registry

```json
{
  "insecure-registries": ["registry.local:5000"]
}
```

### Use systemd cgroup driver

```json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
```

### Custom data directory

```json
{
  "data-root": "/data/docker"
}
```

### Enable remote API (TLS recommended)

```json
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2376"],
  "tls": true,
  "tlscert": "/etc/docker/server-cert.pem",
  "tlskey": "/etc/docker/server-key.pem",
  "tlscacert": "/etc/docker/ca.pem",
  "tlsverify": true
}
```

## File Locations

| System | Config Path |
|--------|-------------|
| Linux | `/etc/docker/daemon.json` |
| Windows | `C:\ProgramData\docker\config\daemon.json` |
| Socket | `/var/run/docker.sock` |
| Data root | `/var/lib/docker` |

## Reloading Configuration

```bash
# systemd (supports reload for some options)
sudo systemctl reload docker

# Full restart (required for most options)
sudo systemctl restart docker

# OpenRC
sudo rc-service docker restart
```

## Resources

- [Daemon configuration reference](https://docs.docker.com/engine/reference/commandline/dockerd/)
- [Storage drivers](https://docs.docker.com/storage/storagedriver/)
- [Logging drivers](https://docs.docker.com/config/containers/logging/configure/)
