# Podman Configuration

## Configuration Files

Podman uses the `containers/common` library. Config can be set system-wide or per-user.

| File | System path | User path |
|------|-------------|-----------|
| `containers.conf` | `/etc/containers/containers.conf` | `~/.config/containers/containers.conf` |
| `registries.conf` | `/etc/containers/registries.conf` | `~/.config/containers/registries.conf` |
| `storage.conf` | `/etc/containers/storage.conf` | `~/.config/containers/storage.conf` |
| `policy.json` | `/etc/containers/policy.json` | `~/.config/containers/policy.json` |

## Key Sections in containers.conf

| Section | Description |
|---------|-------------|
| `[containers]` | Default container settings (capabilities, env, ulimits) |
| `[engine]` | Runtime, cgroup manager, events logger |
| `[network]` | Default network, subnet, DNS settings |
| `[machine]` | Podman Machine (VM) settings for macOS/Windows |

## Common Settings

### Switch OCI runtime to crun (faster)

```toml
[engine]
runtime = "crun"
```

### Enable systemd cgroup manager

```toml
[engine]
cgroup_manager = "systemd"
```

### Add registry mirror

```toml
[[registry]]
location = "docker.io"

[[registry.mirror]]
location = "mirror.example.com"
```

### Add insecure private registry

```toml
[[registry]]
location = "registry.local:5000"
insecure = true
```

## Storage Configuration

Default storage driver is `overlay`. View current config:

```bash
podman info --format '{{.Store.GraphDriverName}}'
```

## Rootless Setup

For rootless containers, ensure `/etc/subuid` and `/etc/subgid` have entries for your user:

```bash
# Check entries
grep $USER /etc/subuid /etc/subgid

# Add if missing
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER
```

## Resources

- [containers.conf reference](https://github.com/containers/common/blob/main/docs/containers.conf.5.md)
- [registries.conf reference](https://github.com/containers/image/blob/main/docs/containers-registries.conf.5.md)
- [storage.conf reference](https://github.com/containers/storage/blob/main/docs/containers-storage.conf.5.md)
