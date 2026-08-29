# LiteLLM Installation Guide

## Prerequisites

- Python 3.10+
- pip3
- SQLite3 (for default database)
- Redis (optional, for caching)

## Quick Install

```bash
# Automated installation
sudo ./install.sh

# Manual installation
pip3 install --upgrade litellm
```

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 2 cores | 4+ cores |
| RAM | 2 GB | 8+ GB |
| Disk | 1 GB | 10+ GB |
| Network | 100 Mbps | 1 Gbps |

## Installation Methods

### 1. Pip (Recommended)

```bash
# Create virtual environment
python3 -m venv /opt/litellm/venv
source /opt/litellm/venv/bin/activate
pip install --upgrade pip
pip install litellm
```

### 2. Docker

```bash
docker pull ghcr.io/berriai/litellm:main-latest
```

### 3. From Source

```bash
git clone https://github.com/BerriAI/litellm.git
cd litellm
pip install -e .
```

## Post-Installation

1. Create configuration:
```bash
mkdir -p /etc/litellm
cp config/config.yaml /etc/litellm/
```

2. Set environment variables:
```bash
cat > /etc/litellm/environment << EOF
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
LITELLM_ADMIN_KEY=secure-random-key
EOF
chmod 600 /etc/litellm/environment
```

3. Initialize database:
```bash
litellm --config /etc/litellm/config.yaml --init-db
```

4. Start service (see service/README.md)

## Verification

```bash
# Check installation
litellm --version

# Test API
curl http://localhost:4000/health
curl http://localhost:4000/v1/models
```

## Troubleshooting

- **ImportError**: Ensure Python 3.10+ and virtual environment activated
- **Port 4000 in use**: Change port in config.yaml
- **Database errors**: Run `--init-db` flag
- **API key errors**: Verify keys in /etc/litellm/environment

## Upgrading

```bash
pip3 install --upgrade litellm
# Restart service
sudo systemctl restart litellm
```