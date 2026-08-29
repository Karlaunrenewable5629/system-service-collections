# LiteLLM

LiteLLM is a unified API proxy that provides OpenAI-compatible access to 100+ LLMs including OpenAI, Azure, Anthropic, Cohere, Replicate, HuggingFace, and local models via Ollama.

## Quick Links

- **Documentation**: https://docs.litellm.ai/
- **GitHub**: https://github.com/BerriAI/litellm
- **PyPI**: https://pypi.org/project/litellm/
- **Discord**: https://discord.gg/litellm

## Features

- Single API for 100+ LLM providers
- Load balancing & fallbacks
- Cost tracking & budgeting
- Rate limiting & caching
- Admin UI & logging
- Proxy & gateway modes

## Installation

### From Source (Linux/macOS)

```bash
# Run install script
sudo ./install/install.sh

# Or manual install
pip3 install --upgrade litellm
```

### Windows

```powershell
# Install Python dependencies
pip install litellm

# Install as Windows service using NSSM
nssm install litellm < service\windows\litellm.nssm
nssm start litellm
```

### Docker (Alternative)

```bash
docker run -d -p 4000:4000 \
  -v $(pwd)/config:/etc/litellm \
  -v $(pwd)/data:/var/lib/litellm \
  ghcr.io/berriai/litellm:main-latest
```

## Configuration

Edit `config/config.yaml`:

```yaml
server:
  host: "0.0.0.0"
  port: 4000

models:
  - model_name: "gpt-3.5-turbo"
    litellm_params:
      model: "gpt-3.5-turbo"
      api_key: "${OPENAI_API_KEY}"

database:
  url: "sqlite:///var/lib/litellm/litellm.db"
```

Set environment variables in `/etc/litellm/environment`:

```bash
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
LITELLM_ADMIN_KEY=secure-admin-key
```

## Service Management

### systemd (Linux)

```bash
# Install service
sudo cp service/systemd/litellm.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now litellm

# Manage
sudo systemctl status litellm
sudo systemctl restart litellm
journalctl -u litellm -f
```

### OpenRC (Alpine/Gentoo)

```bash
sudo cp service/openrc/litellm /etc/init.d/
sudo chmod +x /etc/init.d/litellm
sudo rc-update add litellm default
sudo rc-service litellm start
```

### SysVinit (Debian/Ubuntu legacy)

```bash
sudo cp service/sysvinit/litellm /etc/init.d/
sudo chmod +x /etc/init.d/litellm
sudo update-rc.d litellm defaults
sudo service litellm start
```

### Windows (NSSM)

```powershell
nssm install litellm < service\windows\litellm.nssm
nssm start litellm
nssm status litellm
```

## API Usage

```bash
# List models
curl http://localhost:4000/v1/models

# Chat completion
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $LITELLM_ADMIN_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'

# Admin UI
open http://localhost:4000/ui
```

## Monitoring

- Health: `GET /health`
- Metrics: `GET /metrics` (Prometheus format)
- Logs: `journalctl -u litellm -f` or `/var/log/litellm/`

## Uninstallation

```bash
sudo ./uninstall/uninstall.sh
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Port 4000 in use | Change port in config.yaml |
| API key errors | Verify keys in environment file |
| High memory | Reduce workers, enable caching |
| Model not found | Check model name in config |

## References

- [Configuration Guide](https://docs.litellm.ai/docs/configuration)
- [Proxy Server](https://docs.litellm.ai/docs/proxy_server)
- [Load Balancing](https://docs.litellm.ai/docs/load_balancing)
- [Cost Tracking](https://docs.litellm.ai/docs/cost_tracking)
- [Admin UI](https://docs.litellm.ai/docs/admin_ui)