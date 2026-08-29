# vLLM Service Management

## systemd (systemctl)

### Install Service

```bash
sudo cp service/systemd/vllm.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable vllm
sudo systemctl start vllm
```

### Common Commands

```bash
# Status
sudo systemctl status vllm

# Start/Stop/Restart
sudo systemctl start vllm
sudo systemctl stop vllm
sudo systemctl restart vllm

# Reload config
sudo systemctl reload vllm

# Logs
journalctl -u vllm -f
journalctl -u vllm --since "1 hour ago"

# Enable/Disable auto-start
sudo systemctl enable vllm
sudo systemctl disable vllm
```

### GPU Access Override

```bash
sudo systemctl edit vllm

# Add for GPU access:
# [Service]
# DeviceAllow=/dev/nvidiactl rw
# DeviceAllow=/dev/nvidia-uvm rw
# DeviceAllow=/dev/nvidia* rw
# Environment="CUDA_VISIBLE_DEVICES=0,1"
```

### Resource Limits Override

```bash
sudo systemctl edit vllm

# Add:
# [Service]
# MemoryLimit=24G
# CPUQuota=800%
# LimitMEMLOCK=infinity
```

## OpenRC (rc-service)

### Install Service

```bash
sudo cp service/openrc/vllm /etc/init.d/
sudo chmod +x /etc/init.d/vllm
sudo rc-update add vllm default
sudo rc-service vllm start
```

### Common Commands

```bash
sudo rc-service vllm status
sudo rc-service vllm start
sudo rc-service vllm stop
sudo rc-service vllm restart

# Logs
tail -f /var/log/vllm/vllm.log
```

## SysVinit (service)

### Install Service

```bash
sudo cp service/sysvinit/vllm /etc/init.d/
sudo chmod +x /etc/init.d/vllm
sudo update-rc.d vllm defaults
sudo service vllm start
```

### Common Commands

```bash
sudo service vllm status
sudo service vllm start
sudo service vllm stop
sudo service vllm restart
```

## Windows (WSL2 + systemd)

### Recommended Approach

```powershell
# Use WSL2 with systemd enabled
# /etc/wsl.conf:
# [boot]
# systemd=true

# Then inside WSL2:
sudo systemctl enable vllm
sudo systemctl start vllm
```

### Alternative: Direct Execution

```powershell
# Run in WSL2 terminal
wsl -d Ubuntu -u root systemctl start vllm

# Or run directly:
wsl -d Ubuntu vllm serve /etc/vllm/config.yaml --host 0.0.0.0 --port 8000
```

## Health Checks

```bash
# Health endpoint
curl -f http://localhost:8000/health

# Metrics (Prometheus)
curl http://localhost:8000/metrics

# Models
curl http://localhost:8000/v1/models
```

## Log Rotation

### logrotate (Linux)

```bash
# /etc/logrotate.d/vllm
/var/log/vllm/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 640 vllm vllm
    sharedscripts
    postrotate
        systemctl reload vllm > /dev/null 2>&1 || true
    endscript
}
```

## Troubleshooting

### Service Won't Start

```bash
# Check logs
journalctl -u vllm -n 100

# Check config
vllm serve /etc/vllm/config.yaml --validate

# Check GPU
nvidia-smi

# Check Python environment
python -c "import vllm; print(vllm.__version__)"
```

### CUDA Out of Memory

```bash
# Reduce memory utilization
# In config.yaml:
engine:
  gpu_memory_utilization: 0.85

# Use quantization
model:
  quantization: "awq"

# Reduce batch size
engine:
  max_num_batched_tokens: 4096
  max_num_seqs: 128
```

### Slow Startup

```bash
# Disable request logging
# In service file, add:
# Environment="VLLM_LOG_REQUESTS=0"

# Use local model cache
model:
  download_dir: "/var/lib/vllm/models"
```

### Multi-GPU Issues

```bash
# Check NCCL
export NCCL_DEBUG=INFO
export NCCL_P2P_DISABLE=1

# Check GPU topology
nvidia-smi topo -m
```

### Model Loading Errors

```bash
# Pre-download model
huggingface-cli download meta-llama/Llama-2-7b-chat-hf \
  --local-dir /var/lib/vllm/models/llama2-7b

# Use local path
model:
  name: "/var/lib/vllm/models/llama2-7b"
```

### High Memory Usage

```bash
# Monitor memory
watch -n 1 nvidia-smi

# Check system memory
free -h

# Adjust swap
engine:
  swap_space: 8
```