# containerd Installation

## Quick Install

```bash
sudo ./install.sh
```

## Manual Installation

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt install containerd.io` (Docker repo) |
| RHEL/CentOS/Fedora | `dnf install containerd.io` (Docker repo) |
| Arch/Manjaro | `pacman -S containerd` |
| Alpine | `apk add containerd` |

### From Binary

```bash
VERSION="1.7.20"
ARCH="amd64"   # or arm64, arm
curl -fsSL "https://github.com/containerd/containerd/releases/download/v${VERSION}/containerd-${VERSION}-linux-${ARCH}.tar.gz" \
  | sudo tar -xz -C /usr/local
```

### Install runc (OCI runtime)

```bash
RUNC_VERSION="1.1.14"
sudo curl -fsSL -o /usr/local/sbin/runc \
  "https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64"
sudo chmod +x /usr/local/sbin/runc
```

### Install CNI plugins (for networking)

```bash
CNI_VERSION="1.5.1"
sudo mkdir -p /opt/cni/bin
curl -fsSL "https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-linux-amd64-v${CNI_VERSION}.tgz" \
  | sudo tar -xz -C /opt/cni/bin
```

### Windows

Download the containerd release zip from [GitHub Releases](https://github.com/containerd/containerd/releases) and extract to `C:\containerd\`.

```powershell
# Add to PATH
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\containerd\bin", "Machine")
```

## Post-Installation

1. Generate default configuration:
```bash
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
```

2. Enable systemd cgroup driver (recommended):
```bash
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
```

3. Start the service:
```bash
sudo systemctl start containerd
sudo systemctl enable containerd
```

## Verify Installation

```bash
containerd --version
runc --version
sudo systemctl status containerd

# Pull and run a test container (requires nerdctl)
sudo nerdctl run --rm hello-world
```

## Install nerdctl (Docker-compatible CLI)

```bash
NERDCTL_VERSION="1.7.6"
curl -fsSL "https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz" \
  | sudo tar -xz -C /usr/local/bin
```

## Uninstall

```bash
sudo ./uninstall/uninstall.sh
```
