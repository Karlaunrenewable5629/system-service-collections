# vLLM Installation Guide

## Prerequisites

- Python 3.10-3.12
- PyTorch 2.1+ with CUDA 11.8/12.1/12.4
- NVIDIA GPU (Compute Capability 7.0+)
- 16+ GB RAM, 24+ GB VRAM recommended

## Quick Install

```bash
# Automated installation
sudo ./install.sh

# Manual with CUDA 12.1
pip3 install vllm --index-url https://download.pytorch.org/whl/cu121
```

## System Requirements

| Component | Minimum | Recommended (7B) | Recommended (70B) |
|-----------|---------|------------------|-------------------|
| CPU | 8 cores | 16 cores | 32 cores |
| RAM | 16 GB | 32 GB | 128 GB |
| GPU VRAM | 8 GB | 16 GB | 80 GB (x4) |
| Disk | 50 GB | 100 GB | 500 GB |

## Installation Methods

### 1. Pip with CUDA (Linux)

```bash
# CUDA 12.1 (recommended)
pip3 install vllm --index-url https://download.pytorch.org/whl/cu121

# CUDA 11.8
pip3 install vllm --index-url https://download.pytorch.org/whl/cu118

# CUDA 12.4
pip3 install vllm --index-url https://download.pytorch.org/whl/cu124
```

### 2. AMD ROCm

```bash
pip3 install vllm --index-url https://download.pytorch.org/whl/rocm6.0
```

### 3. From Source

```bash
git clone https://github.com/vllm-project/vllm.git
cd vllm
pip install -e . --no-build-isolation
```

### 4. Docker (Recommended)

```bash
# Latest stable
docker pull vllm/vllm-openai:latest

# Specific version + CUDA
docker pull vllm/vllm-openai:v0.5.3-cu121
```

### 5. Windows (WSL2 Only)

```powershell
# Native Windows not supported
# Use WSL2 with Ubuntu:
wsl --install -d Ubuntu
# Then follow Linux instructions inside WSL2
```

## Post-Installation

1. Configure:
```bash
mkdir -p /etc/vllm
cp config/config.yaml /etc/vllm/
```

2. Set HuggingFace token (for gated models):
```bash
echo "HF_TOKEN=hf_..." > /etc/vllm/environment
chmod 600 /etc/vllm/environment
```

3. Download model:
```bash
# First run will auto-download, or pre-download:
huggingface-cli download meta-llama/Llama-2-7b-chat-hf --local-dir /var/lib/vllm/models/llama2-7b
```

4. Start service (see service/README.md)

## Verification

```bash
# Check version
python -c "import vllm; print(vllm.__version__)"

# Test server
vllm serve meta-llama/Llama-2-7b-chat-hf --port 8000 &
curl http://localhost:8000/v1/models
```

## Troubleshooting

- **CUDA not found**: Install NVIDIA drivers + CUDA toolkit
- **Torch version mismatch**: Reinstall with correct index-url
- **Out of memory**: Use quantization (AWQ/GPTQ), reduce batch size
- **ImportError**: Ensure Python 3.10-3.12, reinstall

## Upgrading

```bash
pip3 install --upgrade vllm --index-url https://download.pytorch.org/whl/cu121

# Docker
docker pull vllm/vllm-openai:latest

# Restart service
sudo systemctl restart vllm
```