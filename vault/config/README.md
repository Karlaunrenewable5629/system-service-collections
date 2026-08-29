# Vault Configuration

This directory contains configuration templates for HashiCorp Vault.

## Files

| File | Description |
|------|-------------|
| `vault.hcl` | Primary Vault configuration file |

## Configuration File Location

| Init System | Config Path |
|-------------|-------------|
| systemd | `/etc/vault.d/vault.hcl` |
| OpenRC | `/etc/vault.d/vault.hcl` |
| SysVinit | `/etc/vault.d/vault.hcl` |
| Windows | `C:\Vault\config\vault.hcl` |

## vault.hcl Options

### Listener Block

Defines the network interface Vault listens on.

| Option | Default | Description |
|--------|---------|-------------|
| `listener.tcp.address` | `"0.0.0.0:8200"` | Address and port Vault listens on |
| `listener.tcp.tls_disable` | `false` | Disable TLS (not recommended in production) |
| `listener.tcp.tls_cert_file` | `""` | Path to TLS certificate file |
| `listener.tcp.tls_key_file` | `""` | Path to TLS private key file |
| `listener.tcp.tls_min_version` | `"tls12"` | Minimum TLS version (`tls12`, `tls13`) |
| `listener.tcp.cluster_address` | `""` | Address used for Vault cluster communication |

### Storage Block (Raft)

Configures integrated Raft storage backend.

| Option | Default | Description |
|--------|---------|-------------|
| `storage.raft.path` | `""` | **Required.** Filesystem path where Raft data is stored |
| `storage.raft.node_id` | `""` | **Required.** Unique identifier for this Vault node |
| `storage.raft.performance_multiplier` | `1` | Raft timing multiplier (1–10); increase for slower systems |
| `storage.raft.trailing_logs` | `10000` | Number of log entries to keep in store |
| `storage.raft.snapshot_threshold` | `8192` | Minimum log entries between Raft snapshots |
| `storage.raft.retry_join` | `[]` | List of peers to join on startup (HA clusters) |

#### retry_join Sub-options

| Option | Description |
|--------|-------------|
| `leader_api_addr` | API address of the leader node to join |
| `leader_ca_cert_file` | CA certificate for verifying the leader |
| `leader_client_cert_file` | Client cert for mTLS to leader |
| `leader_client_key_file` | Client key for mTLS to leader |

### Top-Level Options

| Option | Default | Description |
|--------|---------|-------------|
| `api_addr` | `""` | Full URL Vault advertises for client redirects (e.g. `https://vault.example.com:8200`) |
| `cluster_addr` | `""` | Full URL for intra-cluster communication (e.g. `https://vault.example.com:8201`) |
| `cluster_name` | `""` | Human-readable name for the cluster |
| `log_level` | `"info"` | Log verbosity: `trace`, `debug`, `info`, `warn`, `error` |
| `log_format` | `"standard"` | Log format: `standard` or `json` |
| `log_file` | `""` | Path to write log output (leave empty for stderr) |
| `log_rotate_duration` | `"24h"` | How often to rotate log files |
| `log_rotate_max_files` | `0` | Maximum number of rotated log files (0 = unlimited) |
| `ui` | `false` | Enable the built-in web UI at `/ui` |
| `disable_mlock` | `false` | Disable memory locking (required in some container/cloud environments) |
| `pid_file` | `""` | Write Vault's PID to this file |
| `default_lease_ttl` | `"768h"` | Default TTL for leases |
| `max_lease_ttl` | `"768h"` | Maximum TTL for leases |

### Seal Block (Optional — Auto-Unseal)

Configures automatic unsealing via a cloud KMS.

| Option | Description |
|--------|-------------|
| `seal.awskms.region` | AWS region for KMS |
| `seal.awskms.kms_key_id` | ARN or alias of the KMS key |
| `seal.gcpckms.project` | GCP project ID |
| `seal.gcpckms.region` | GCP region |
| `seal.gcpckms.key_ring` | Key ring name |
| `seal.gcpckms.crypto_key` | Crypto key name |
| `seal.azurekeyvault.vault_name` | Azure Key Vault name |
| `seal.azurekeyvault.key_name` | Key name in the vault |

### Telemetry Block (Optional)

| Option | Default | Description |
|--------|---------|-------------|
| `telemetry.statsite_address` | `""` | Statsite server address |
| `telemetry.statsd_address` | `""` | StatsD server address |
| `telemetry.prometheus_retention_time` | `"24h"` | Retention window for Prometheus metrics |
| `telemetry.disable_hostname` | `false` | Remove hostname from metric names |
| `telemetry.enable_hostname_label` | `false` | Add hostname as a metric label |

## Environment Variables

Key environment variables that influence Vault behavior at runtime:

| Variable | Description |
|----------|-------------|
| `VAULT_ADDR` | Client address for CLI/API access (e.g. `http://127.0.0.1:8200`) |
| `VAULT_TOKEN` | Vault token used for authentication |
| `VAULT_CACERT` | Path to CA certificate for TLS verification |
| `VAULT_CLIENT_CERT` | Path to client certificate |
| `VAULT_CLIENT_KEY` | Path to client key |
| `VAULT_SKIP_VERIFY` | Skip TLS certificate verification (`true`/`false`) |
| `VAULT_FORMAT` | Output format for CLI (`table`, `json`, `yaml`) |
| `VAULT_LOG_LEVEL` | Override log level at runtime |
| `VAULT_CLUSTER_ADDR` | Override cluster address |
| `VAULT_API_ADDR` | Override API address |
| `VAULT_LICENSE` | Vault Enterprise license string |

## Post-Init Steps

After starting Vault for the first time:

```bash
# Initialize Vault (generates unseal keys and root token)
vault operator init

# Unseal Vault (repeat with different unseal keys until threshold met)
vault operator unseal <unseal-key>

# Log in with root token
vault login <root-token>
```

> **Security Note:** Store unseal keys and the root token securely (e.g., in a hardware security module or a separate secrets manager). Never store them in plaintext on the same server.

## TLS Recommendations

For production, always enable TLS:

```hcl
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/etc/vault.d/tls/vault.crt"
  tls_key_file  = "/etc/vault.d/tls/vault.key"
  tls_min_version = "tls12"
}
```

Generate a self-signed certificate for testing:

```bash
openssl req -x509 -newkey rsa:4096 -keyout vault.key -out vault.crt \
  -days 365 -nodes -subj "/CN=vault.example.com"
```

## Further Reading

- [Vault Configuration Reference](https://developer.hashicorp.com/vault/docs/configuration)
- [Integrated Storage (Raft)](https://developer.hashicorp.com/vault/docs/configuration/storage/raft)
- [Vault High Availability](https://developer.hashicorp.com/vault/docs/concepts/ha)
- [Auto-Unseal](https://developer.hashicorp.com/vault/docs/concepts/seal#auto-unseal)
