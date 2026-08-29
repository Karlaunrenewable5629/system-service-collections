# Ollama

Ollama is a local LLM server that allows you to run large language models locally on your machine. It supports models like Llama 3, Mistral, CodeLlama, Phi, and many more.

## Quick Links

- **Website**: https://ollama.com/
- **GitHub**: https://github.com/ollama/ollama
- **Documentation**: https://github.com/ollama/ollama/blob/main/docs/README.md
- **Models Library**: https://ollama.com/library
- **Discord**: https://discord.gg/ollama

## Features

- Run LLMs locally (no cloud required)
- OpenAI-compatible API
- Model library with 100+ models
- GPU acceleration (CUDA, Metal, ROCm)
- Model quantization (4-bit, 8-bit)
- Custom Modelfiles
- Streaming responses

## Installation

### Linux (Official Script)

```bash
# Run install script
sudo ./install/install.sh

# Or manual install
curl -fsSL https://ollama.com/install.sh | sh
```

### Windows

```powershell
# Download installer from https://ollama.com/download/windows
# Or use winget
winget install Ollama.Ollama

# Install as service
nssm install ollama < service\windows\ollama.nssm
nssm start ollama
```

### macOS

```bash
brew install ollama
```

### Docker (Alternative)

```bash
docker run -d -p 11434:11434 \
  -v $(pwd)/data:/root/.ollama \
  --gpus all \
  ollama/ollama:latest
```

## Configuration

Edit `config/config.yaml`:

```yaml
server:
  host: "0.0.0.0"
  port: 11434

models:
  path: "/var/lib/ollama/models"

gpu:
  enabled: true
  layers: -1
```

Set environment variables in `/etc/ollama/environment`:

```bash
OLLAMA_HOST=0.0.0.0:11434
OLLAMA_MODELS=/var/lib/ollama/models
OLLAMA_KEEP_ALIVE=5m
```

## Service Management

### systemd (Linux)

```bash
sudo cp service/systemd/ollama.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now ollama

sudo systemctl status ollama
journalctl -u ollama -f
```

### OpenRC (Alpine/Gentoo)

```bash
sudo cp service/openrc/ollama /etc/init.d/
sudo chmod +x /etc/init.d/ollama
sudo rc-update add ollama default
sudo rc-service ollama start
```

### SysVinit (Debian/Ubuntu legacy)

```bash
sudo cp service/sysvinit/ollama /etc/init.d/
sudo chmod +x /etc/init.d/ollama
sudo update-rc.d ollama defaults
sudo service ollama start
```

### Windows (NSSM)

```powershell
nssm install ollama < service\windows\ollama.nssm
nssm start ollama
```

## Model Management

```bash
# List available models
ollama list

# Pull a model
ollama pull llama3
ollama pull mistral:7b
ollama pull codellama:13b

# Run a model
ollama run llama3

# Remove a model
ollama rm llama3

# Create custom model
ollama create mymodel -f Modelfile
```

## API Usage

```bash
# Generate completion
curl -X POST http://localhost:11434/api/generate \
  -d '{"model": "llama3", "prompt": "Why is the sky blue?"}'

# Chat completion (OpenAI compatible)
curl -X POST http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'

# Embeddings
curl -X POST http://localhost:11434/api/embeddings \
  -d '{"model": "nomic-embed-text", "prompt": "Hello world"}'
```

## Monitoring

- Health: `GET /`
- Version: `GET /api/version`
- Models: `GET /api/tags`
- Logs: `journalctl -u ollama -f` or `/var/log/ollama/`

## GPU Support

```bash
# NVIDIA (CUDA)
# Requires: nvidia-container-toolkit
docker run --gpus all ollama/ollama

# AMD (ROCm)
# Set: HSA_OVERRIDE_GFX_VERSION=10.3.0

# Apple Silicon (Metal)
# Automatic on macOS
```

## Uninstallation

```bash
sudo ./uninstall/uninstall.sh
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Out of memory | Use smaller quantized model (q4_0) |
| Slow inference | Enable GPU layers: `OLLAMA_NUM_GPU=999` |
| Model not found | Run `ollama pull <model>` first |
| Port conflict | Change port in config.yaml |

## References

- [API Documentation](https://github.com/ollama/ollama/blob/main/docs/api.md)
- [Modelfile Reference](https://github.com/ollama/ollama/blob/main/docs/modelfile.md)
- [GPU Support](https://github.com/ollama/ollama/blob/main/docs/gpu.md)
- [Custom Models](https://github.com/ollama/ollama/blob/main/docs/custom-models.md)
- [Windows Install](https://ollama.com/download/windows)