# vLLM

vLLM is a high-throughput, memory-efficient inference engine for LLMs. It uses PagedAttention to achieve near-optimal memory usage and supports continuous batching for maximum throughput.

## Quick Links

- **Website**: https://vllm.ai/
- **GitHub**: https://github.com/vllm-project/vllm
- **Documentation**: https://docs.vllm.ai/
- **Models**: https://huggingface.co/models?library=vllm
- **Discord**: https://discord.gg/vllm

## Features

- PagedAttention for efficient memory management
- Continuous batching for high throughput
- OpenAI-compatible API server
- Tensor parallelism (multi-GPU)
- Pipeline parallelism
- Quantization (AWQ, GPTQ, SqueezeLLM, FP8)
- Prefix caching
- Chunked prefill
- Speculative decoding

## Installation

### Linux (with CUDA)

```bash
# Run install script
sudo ./install/install.sh

# Or manual install with CUDA 12.1
pip3 install vllm --index-url https://download.pytorch.org/whl/cu121

# For ROCm (AMD)
pip3 install vllm --index-url https://download.pytorch.org/whl/rocm6.0
```

### Windows (WSL2 Recommended)

```powershell
# Native Windows not fully supported, use WSL2
wsl --install
# Then follow Linux instructions inside WSL2
```

### Docker (Recommended for Production)

```bash
# NVIDIA GPU
docker run --gpus all -p 8000:8000 \
  -v $(pwd)/config:/etc/vllm \
  -v $(pwd)/data:/var/lib/vllm \
  --ipc=host \
  vllm/vllm-openai:latest \
  --model meta-llama/Llama-2-7b-chat-hf

# With specific model
docker run --gpus all -p 8000:8000 \
  vllm/vllm-openai:latest \
  --model meta-llama/Meta-Llama-3-8B-Instruct \
  --tensor-parallel-size 2
```

## Configuration

Edit `config/config.yaml`:

```yaml
server:
  host: "0.0.0.0"
  port: 8000

model:
  name: "meta-llama/Llama-2-7b-chat-hf"
  tensor_parallel_size: 1
  gpu_memory_utilization: 0.9

engine:
  max_num_batched_tokens: 8192
  max_num_seqs: 256
  enable_prefix_caching: true
```

Set environment variables in `/etc/vllm/environment`:

```bash
HF_TOKEN=hf_...  # For gated models
CUDA_VISIBLE_DEVICES=0,1
VLLM_API_KEY=your-api-key
```

## Service Management

### systemd (Linux)

```bash
sudo cp service/systemd/vllm.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now vllm

sudo systemctl status vllm
journalctl -u vllm -f
```

### OpenRC (Alpine/Gentoo)

```bash
sudo cp service/openrc/vllm /etc/init.d/
sudo chmod +x /etc/init.d/vllm
sudo rc-update add vllm default
sudo rc-service vllm start
```

### SysVinit (Debian/Ubuntu legacy)

```bash
sudo cp service/sysvinit/vllm /etc/init.d/
sudo chmod +x /etc/init.d/vllm
sudo update-rc.d vllm defaults
sudo service vllm start
```

### Windows (NSSM via WSL2)

```powershell
# Use WSL2 with systemd instead
# Or run directly in WSL2: sudo systemctl start vllm
```

## Model Deployment

```bash
# Serve a model
vllm serve meta-llama/Llama-2-7b-chat-hf --port 8000

# Multi-GPU (tensor parallel)
vllm serve meta-llama/Llama-2-70b-chat-hf --tensor-parallel-size 4

# With quantization
vllm serve TheBloke/Llama-2-7B-Chat-AWQ --quantization awq

# Custom config
vllm serve /etc/vllm/config.yaml
```

## API Usage

```bash
# List models
curl http://localhost:8000/v1/models

# Chat completion
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $VLLM_API_KEY" \
  -d '{
    "model": "meta-llama/Llama-2-7b-chat-hf",
    "messages": [{"role": "user", "content": "Hello!"}],
    "temperature": 0.7,
    "max_tokens": 512
  }'

# Completion
curl -X POST http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "meta-llama/Llama-2-7b-chat-hf", "prompt": "Once upon a time"}'

# Embeddings
curl -X POST http://localhost:8000/v1/embeddings \
  -H "Content-Type: application/json" \
  -d '{"model": "BAAI/bge-small-en-v1.5", "input": "Hello world"}'
```

## Performance Tuning

| Parameter | Recommendation |
|-----------|----------------|
| `gpu_memory_utilization` | 0.85-0.95 |
| `max_num_batched_tokens` | 8192-16384 |
| `max_num_seqs` | 128-512 |
| `enable_prefix_caching` | true |
| `tensor_parallel_size` | # GPUs |
| `quantization` | awq/gptq for 4-bit |

## Monitoring

- Metrics: `GET /metrics` (Prometheus)
- Health: `GET /health`
- Logs: `journalctl -u vllm -f` or `/var/log/vllm/`

## Uninstallation

```bash
sudo ./uninstall/uninstall.sh
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| CUDA OOM | Reduce `gpu_memory_utilization`, use quantization |
| Slow startup | Enable `--disable-log-requests`, use local model cache |
| Model not found | Set `HF_TOKEN`, check model name on HF Hub |
| Multi-GPU issues | Set `NCCL_P2P_DISABLE=1`, check NVLink |

## References

- [API Server](https://docs.vllm.ai/en/latest/serving/openai_compatible_server.html)
- [Deployment](https://docs.vllm.ai/en/latest/serving/deploying.html)
- [Performance](https://docs.vllm.ai/en/latest/performance/benchmarking.html)
- [Quantization](https://docs.vllm.ai/en/latest/quantization/quantization.html)
- [Tensor Parallelism](https://docs.vllm.ai/en/latest/serving/distributed_serving.html)
- [PagedAttention Paper](https://arxiv.org/abs/2309.06180)