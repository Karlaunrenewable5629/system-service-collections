# Ollama Installation Guide

## Prerequisites

- Linux: glibc 2.34+, systemd/OpenRC/SysVinit
- Windows: Windows 10/11, WSL2 recommended
- macOS: 11+ (Intel/Apple Silicon)
- GPU: NVIDIA (CUDA), AMD (ROCm), Apple (Metal)

## Quick Install

```bash
# Automated installation
sudo ./install.sh

# Official script
curl -fsSL https://ollama.com/install.sh | sh
```

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 4 cores | 8+ cores |
| RAM | 8 GB | 16+ GB |
| Disk | 20 GB | 100+ GB (SSD) |
| GPU VRAM | 4 GB | 16+ GB |

## Installation Methods

### 1. Official Installer (Linux)

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### 2. Package Managers

```bash
# Arch/Manjaro
pacman -S ollama

# NixOS
nix-env -iA nixpkgs.ollama

# Homebrew (macOS/Linux)
brew install ollama
```

### 3. Manual Binary

```bash
# Download from https://ollama.com/download
tar -xzf ollama-linux-amd64.tgz
sudo mv ollama /usr/local/bin/
```

### 4. Windows

```powershell
# Download installer from https://ollama.com/download/windows
# Or use winget
winget install Ollama.Ollama

# Or Scoop
scoop install ollama
```

### 5. Docker

```bash
# CPU only
docker run -d -p 11434:11434 -v ollama:/root/.ollama ollama/ollama

# GPU (NVIDIA)
docker run -d --gpus all -p 11434:11434 -v ollama:/root/.ollama ollama/ollama
```

## Post-Installation

1. Start service (see service/README.md)

2. Pull models:
```bash
ollama pull llama3
ollama pull mistral
ollama pull codellama
```

3. Test:
```bash
ollama run llama3 "Hello, world!"
```

## Verification

```bash
# Check version
ollama --version

# List models
ollama list

# Test API
curl http://localhost:11434/api/version
curl http://localhost:11434/api/tags
```

## Troubleshooting

- **Command not found**: Add /usr/local/bin to PATH
- **GPU not detected**: Install NVIDIA drivers + CUDA toolkit
- **Permission denied**: Check user/group permissions on /var/lib/ollama
- **Port 11434 in use**: Change in config.yaml or stop existing service

## Upgrading

```bash
# Re-run installer
curl -fsSL https://ollama.com/install.sh | sh

# Or package manager
pacman -Syu ollama
brew upgrade ollama

# Restart service
sudo systemctl restart ollama
```