# vLLM Configuration Guide

## Configuration Files

- `/etc/vllm/config.yaml` - Main configuration
- `/etc/vllm/environment` - Environment variables

## Main Configuration (config.yaml)

### Server Settings

```yaml
server:
  host: "0.0.0.0"
  port: 8000
  workers: 1
  timeout: 300
  max_concurrent_requests: 256
```

### Model Settings

```yaml
model:
  name: "meta-llama/Llama-2-7b-chat-hf"
  tensor_parallel_size: 1
  pipeline_parallel_size: 1
  trust_remote_code: false
  download_dir: "/var/lib/vllm/models"
  revision: "main"
  tokenizer: "auto"
  tokenizer_mode: "auto"
```

### Engine Settings

```yaml
engine:
  gpu_memory_utilization: 0.9
  swap_space: 4
  max_num_batched_tokens: 8192
  max_num_seqs: 256
  max_model_len: 4096
  block_size: 16
  enable_prefix_caching: true
  use_v2_block_manager: true
  enforce_eager: false
  max_seq_len_to_capture: 8192
```

### Scheduler Settings

```yaml
scheduler:
  policy: "priority"          # priority, fcfs
  max_waiting_tokens: 2048
```

### Speculative Decoding

```yaml
speculative:
  enabled: false
  model: ""
  num_speculative_tokens: 5
  acceptance_threshold: 0.5
```

### Logging

```yaml
logging:
  level: "INFO"
  format: "json"
  file: "/var/log/vllm/vllm.log"
  access_log: "/var/log/vllm/access.log"
```

### API Settings

```yaml
api:
  served_model_name: "vllm-model"
  response_role: "assistant"
  enable_auto_tool_choice: true
  enable_tool_use: true
  max_logprobs: 5
```

### Authentication

```yaml
auth:
  api_key: "${VLLM_API_KEY}"
  enabled: false
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| HF_TOKEN | - | HuggingFace token for gated models |
| CUDA_VISIBLE_DEVICES | all | GPU selection |
| VLLM_API_KEY | - | API key for authentication |
| NCCL_P2P_DISABLE | 0 | Disable P2P for multi-GPU |
| VLLM_WORKER_MULTIPROC_METHOD | spawn | Multiprocessing method |
| PYTORCH_CUDA_ALLOC_CONF | - | CUDA memory allocator config |

## Quantization

### AWQ (4-bit)

```yaml
model:
  name: "TheBloke/Llama-2-7B-Chat-AWQ"
  quantization: "awq"
```

### GPTQ (4-bit)

```yaml
model:
  name: "TheBloke/Llama-2-7B-Chat-GPTQ"
  quantization: "gptq"
```

### FP8 (E4M3)

```yaml
model:
  name: "meta-llama/Llama-2-7b-chat-hf"
  quantization: "fp8"
```

## Multi-GPU (Tensor Parallelism)

```yaml
model:
  name: "meta-llama/Llama-2-70b-chat-hf"
  tensor_parallel_size: 4  # Use 4 GPUs
```

### Environment for Multi-GPU

```bash
export CUDA_VISIBLE_DEVICES=0,1,2,3
export NCCL_P2P_DISABLE=1  # If no NVLink
```

## Performance Tuning

| Parameter | Low VRAM | High VRAM |
|-----------|----------|-----------|
| gpu_memory_utilization | 0.85 | 0.95 |
| max_num_batched_tokens | 4096 | 16384 |
| max_num_seqs | 128 | 512 |
| block_size | 16 | 32 |
| enable_prefix_caching | true | true |

## Model Sources

- **HuggingFace Hub**: `meta-llama/Llama-2-7b-chat-hf`
- **Local path**: `/var/lib/vllm/models/llama2-7b`
- **S3/GCS**: `s3://bucket/model`, `gs://bucket/model`

## Validation

```bash
# Validate config
vllm serve /etc/vllm/config.yaml --validate

# Dry run
vllm serve /etc/vllm/config.yaml --dry-run
```