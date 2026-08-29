# Ollama Service Management

## systemd (systemctl)

### Install Service

```bash
sudo cp service/systemd/ollama.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl start ollama
```

### Common Commands

```bash
# Status
sudo systemctl status ollama

# Start/Stop/Restart
sudo systemctl start ollama
sudo systemctl stop ollama
sudo systemctl restart ollama

# Logs
journalctl -u ollama -f
journalctl -u ollama --since "1 hour ago"

# Enable/Disable auto-start
sudo systemctl enable ollama
sudo systemctl disable ollama
```

### GPU Access (Override)

```bash
sudo systemctl edit ollama

# Add:
# [Service]
# DeviceAllow=/dev/nvidiactl rw
# DeviceAllow=/dev/nvidia-uvm rw
# DeviceAllow=/dev/nvidia* rw
```

## OpenRC (rc-service)

### Install Service

```bash
sudo cp service/openrc/ollama /etc/init.d/
sudo chmod +x /etc/init.d/ollama
sudo rc-update add ollama default
sudo rc-service ollama start
```

### Common Commands

```bash
sudo rc-service ollama status
sudo rc-service ollama start
sudo rc-service ollama stop
sudo rc-service ollama restart

# Logs
tail -f /var/log/ollama/ollama.log
```

## SysVinit (service)

### Install Service

```bash
sudo cp service/sysvinit/ollama /etc/init.d/
sudo chmod +x /etc/init.d/ollama
sudo update-rc.d ollama defaults
sudo service ollama start
```

### Common Commands

```bash
sudo service ollama status
sudo service ollama start
sudo service ollama stop
sudo service ollama restart
```

## Windows (NSSM)

### Install Service

```powershell
# Download NSSM from https://nssm.cc/download

nssm install ollama < service\windows\ollama.nssm

# Or manually:
nssm install ollama "C:\ollama\ollama.exe" "serve"
nssm set ollama AppDirectory "C:\opt\ollama"
nssm set ollama DisplayName "Ollama LLM Server"
nssm set ollama Description "Local LLM Server"
nssm set ollama Start SERVICE_AUTO_START
nssm set ollama Environment "OLLAMA_HOST=0.0.0.0:11434" "OLLAMA_MODELS=C:\var\lib\ollama\models"
```

### Common Commands

```powershell
nssm start ollama
nssm stop ollama
nssm restart ollama
nssm status ollama

# Logs
Get-Content C:\var\log\ollama\ollama-out.log -Wait

# Remove
nssm remove ollama confirm
```

## Health Checks

```bash
# HTTP health
curl -f http://localhost:11434/

# API version
curl http://localhost:11434/api/version

# List models
curl http://localhost:11434/api/tags
```

## Log Rotation

### logrotate (Linux)

```bash
# /etc/logrotate.d/ollama
/var/log/ollama/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 640 ollama ollama
}
```

## Troubleshooting

### Service Won't Start

```bash
# Check logs
journalctl -u ollama -n 50

# Check binary
which ollama
ollama --version

# Check directories
ls -la /var/lib/ollama/ /var/log/ollama/
```

### GPU Issues

```bash
# Check GPU visibility
nvidia-smi
rocm-smi

# Test GPU in container
docker run --gpus all ollama/ollama ollama run llama3
```

### Model Loading Errors

```bash
# Pull model first
ollama pull llama3

# Check model path
ollama list
ls -la /var/lib/ollama/models/
```

### High Memory Usage

```bash
# Reduce parallel requests
# In config.yaml:
performance:
  num_parallel: 2
  max_queue_size: 128
```