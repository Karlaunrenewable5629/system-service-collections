# Docker Installation

## Quick Install

```bash
sudo ./install.sh
```

## Manual Installation

### From Package Manager (recommended)

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | See Docker repo setup below |
| RHEL/CentOS/Fedora | `dnf install docker-ce docker-ce-cli containerd.io` |
| Arch/Manjaro | `pacman -S docker docker-compose` |
| Alpine | `apk add docker docker-compose` |

### Ubuntu/Debian (Docker official repo)

```bash
curl -fsSL https://get.docker.com | sudo sh
```

### From Convenience Script

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Windows

Download [Docker Desktop](https://www.docker.com/products/docker-desktop/) for Windows.  
For headless/server use, install Docker Engine via the MSI or use the NSSM service definition.

## Post-Installation

1. Copy daemon config:
```bash
sudo mkdir -p /etc/docker
sudo cp config/daemon.json /etc/docker/daemon.json
```

2. Start the service:
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

3. Add your user to the docker group (optional, avoids sudo):
```bash
sudo usermod -aG docker $USER
newgrp docker
```

## Verify Installation

```bash
docker --version
docker compose version
sudo systemctl status docker
docker run hello-world
```

## Uninstall

```bash
sudo ./uninstall/uninstall.sh
```
