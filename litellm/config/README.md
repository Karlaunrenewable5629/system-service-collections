# LiteLLM Configuration Guide

## Configuration Files

- `/etc/litellm/config.yaml` - Main configuration
- `/etc/litellm/environment` - Environment variables (secrets)

## Main Configuration (config.yaml)

### Server Settings

```yaml
server:
  host: "0.0.0.0"        # Bind address
  port: 4000             # Port number
  workers: 4             # Worker processes
  timeout: 600           # Request timeout (seconds)
```

### Database

```yaml
database:
  type: "sqlite"         # sqlite, postgresql, mysql
  url: "sqlite:///var/lib/litellm/litellm.db"
  pool_size: 10
  max_overflow: 20
```

### Cache (Redis)

```yaml
cache:
  type: "redis"
  host: "localhost"
  port: 6379
  password: "${REDIS_PASSWORD}"
  db: 0
  ttl: 3600              # Cache TTL (seconds)
```

### Models

```yaml
models:
  - model_name: "gpt-3.5-turbo"
    litellm_params:
      model: "gpt-3.5-turbo"
      api_key: "${OPENAI_API_KEY}"
      temperature: 0.7
      max_tokens: 4096
  
  - model_name: "claude-3-sonnet"
    litellm_params:
      model: "anthropic/claude-3-sonnet-20240229"
      api_key: "${ANTHROPIC_API_KEY}"
```

### Router Settings

```yaml
router_settings:
  routing_strategy: "least-busy"  # least-busy, round-robin, latency
  fallbacks:
    - "gpt-3.5-turbo"
    - "claude-3-haiku"
  retry_policy:
    max_retries: 3
    retry_interval: 1
    retry_on_status: [429, 500, 502, 503, 504]
```

### Proxy Settings

```yaml
proxy_settings:
  admin_key: "${LITELLM_ADMIN_KEY}"
  ui_enabled: true
  docs_enabled: true
  allowed_ips: []  # Empty = all
```

### Logging

```yaml
logging:
  level: "INFO"          # DEBUG, INFO, WARNING, ERROR
  format: "json"         # json, text
  file: "/var/log/litellm/litellm.log"
  max_size: 100          # MB
  backup_count: 5
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| OPENAI_API_KEY | Yes* | OpenAI API key |
| ANTHROPIC_API_KEY | Yes* | Anthropic API key |
| LITELLM_ADMIN_KEY | Yes | Admin panel access |
| REDIS_PASSWORD | No | Redis password |
| DATABASE_URL | No | Override database URL |

*Required for respective models

## Model Providers

See [LiteLLM Providers](https://docs.litellm.ai/docs/providers) for complete list:

- OpenAI
- Azure OpenAI
- Anthropic
- Cohere
- Replicate
- HuggingFace
- Ollama (local)
- Vertex AI
- Bedrock
- WatsonX

## Example: Using Ollama Locally

```yaml
models:
  - model_name: "llama3"
    litellm_params:
      model: "ollama/llama3"
      api_base: "http://localhost:11434"
```

## Security Best Practices

1. Use strong admin key: `openssl rand -hex 32`
2. Restrict admin UI to VPN/localhost
3. Use environment file for secrets (chmod 600)
4. Enable HTTPS in production
5. Configure allowed IPs for admin access

## Validation

```bash
# Validate config
litellm --config /etc/litellm/config.yaml --validate

# Test connection
litellm --config /etc/litellm/config.yaml --test-connection
```