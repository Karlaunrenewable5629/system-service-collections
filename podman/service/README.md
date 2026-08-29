# Podman Service Management

Podman is daemonless — the "service" is the Podman API socket, which enables Docker-compatible tool integration.

## systemd — Rootless (per-user, recommended)

```bash
# Enable and start socket
systemctl --user enable --now podman.socket

# Check status
systemctl --user status podman.socket

# Stop
systemctl --user stop podman.socket

# View logs
journalctl --user -u podman.socket -f
```

## systemd — Rootful (system-wide)

```bash
sudo systemctl enable --now podman.socket
sudo systemctl status podman.socket
sudo systemctl stop podman.socket
journalctl -u podman.socket -f
```

## OpenRC (BSD/Linux)

```bash
sudo rc-service podman start
sudo rc-service podman stop
sudo rc-service podman restart
sudo rc-update add podman default
sudo rc-service podman status
```

## SysVinit (Legacy Linux)

```bash
sudo service podman start
sudo service podman stop
sudo service podman restart
sudo update-rc.d podman defaults
sudo service podman status
```

## Windows (NSSM)

```powershell
nssm start podman
nssm stop podman
nssm restart podman
nssm status podman
nssm remove podman confirm
```

## Docker API Compatibility

Point Docker-compatible tools (docker CLI, Compose, etc.) at the Podman socket:

```bash
# Rootless
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock

# Rootful
export DOCKER_HOST=unix:///run/podman/podman.sock
```

## Useful Commands

```bash
podman ps                      # List running containers
podman ps -a                   # List all containers
podman images                  # List images
podman pod list                # List pods
podman system info             # System info
podman generate systemd <ctr>  # Generate systemd unit for a container
```
