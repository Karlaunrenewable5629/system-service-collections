# Ollama Configuration Guide

## Configuration Files

- `/etc/ollama/config.yaml` - Main configuration
- `/etc/ollama/environment` - Environment variables

## Main Configuration (config.yaml)

### Server Settings

```yaml
server:
  host: "0.0.0.0"
  port: 11434
  origins: ["*"]           # CORS origins
  keep_alive: "5m"         # Model keep-alive time
```

### Models

```yaml
models:
  path: "/var/lib/ollama/models"
  cache_size: "10GB"       # Model cache limit
```

### GPU Settings

```yaml
gpu:
  enabled: true
  layers: -1               # -1 = all layers on GPU
  main_gpu: 0              # Primary GPU index
  split_mode: "layer"      # layer, row
```

### Logging

```yaml
logging:
  level: "info"            # debug, info, warn, error
  format: "text"           # text, json
  file: "/var/log/ollama/ollama.log"
```

### API Settings

```yaml
api:
  cors_enabled: true
  max_request_size: "100MB"
```

### Performance

```yaml
performance:
  num_parallel: 4
  max_queue_size: 512
  flash_attention: true
  kv_cache_type: "f16"
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| OLLAMA_HOST | 127.0.0.1:11434 | Bind address |
| OLLAMA_MODELS | ~/.ollama/models | Model directory |
| OLLAMA_KEEP_ALIVE | 5m | Model unload timeout |
| OLLAMA_NUM_PARALLEL | 4 | Parallel requests |
| OLLAMA_MAX_QUEUE | 512 | Request queue size |
| OLLAMA_FLASH_ATTENTION | 1 | Enable flash attention |
| CUDA_VISIBLE_DEVICES | all | GPU selection |
| HSA_OVERRIDE_GFX_VERSION | - | AMD GPU override |

## Model Configuration (Modelfile)

Create custom models with Modelfile:

```dockerfile
FROM llama3
PARAMETER temperature 0.7
PARAMETER top_p 0.9
SYSTEM "You are a helpful assistant."
```

```bash
ollama create mymodel -f Modelfile
```

## GPU Configuration

### NVIDIA (CUDA)

```bash
# Install NVIDIA drivers + CUDA
# Automatic detection
```

### AMD (ROCm)

```bash
# Set for specific GPUs
export HSA_OVERRIDE_GFX_VERSION=10.3.0
export ROCR_VISIBLE_DEVICES=0,1
```

### Apple Silicon (Metal)

```bash
# Automatic on macOS 12+
# No configuration needed
```

## Security

- Bind to localhost only in production: `host: "127.0.0.1"`
- Use reverse proxy (nginx/Caddy) with TLS
- Restrict CORS origins
- Use firewall rules

## Validation

```bash
# Test config
ollama serve --config /etc/ollama/config.yaml --validate

# Check GPU
ollama run llama3 --verbose
```