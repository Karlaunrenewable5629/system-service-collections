# Podman Installation

## Quick Install

```bash
sudo ./install.sh
```

## Manual Installation

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt install podman podman-compose buildah skopeo` |
| RHEL/CentOS/Fedora | `dnf install podman podman-compose buildah skopeo` |
| Arch/Manjaro | `pacman -S podman podman-compose buildah skopeo` |
| Alpine | `apk add podman podman-compose buildah skopeo` |
| macOS | `brew install podman` |

### Windows

Install [Podman Desktop](https://podman-desktop.io/) which includes the Podman CLI and a Linux VM.

## Post-Installation

1. Copy configuration files:
```bash
sudo mkdir -p /etc/containers
sudo cp config/containers.conf /etc/containers/
sudo cp config/registries.conf /etc/containers/
```

2. Configure rootless namespaces (for non-root usage):
```bash
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER
```

3. Enable the Podman socket (for Docker API compatibility):
```bash
# Rootless (per-user)
systemctl --user enable --now podman.socket

# Rootful (system-wide)
sudo systemctl enable --now podman.socket
```

4. Point Docker tools to Podman socket:
```bash
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
```

## Verify Installation

```bash
podman --version
podman info
podman run hello-world

# Check socket
systemctl --user status podman.socket
```

## Uninstall

```bash
sudo ./uninstall/uninstall.sh
```
