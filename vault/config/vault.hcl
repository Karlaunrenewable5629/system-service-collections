# =============================================================================
# HashiCorp Vault - Configuration File
# =============================================================================
# Location: /etc/vault.d/vault.hcl
# Owner:    vault:vault  (chmod 640)
# Docs:     https://developer.hashicorp.com/vault/docs/configuration
# =============================================================================

# -----------------------------------------------------------------------------
# UI
# Enable the built-in web UI accessible at http(s)://<host>:8200/ui
# -----------------------------------------------------------------------------
ui = true

# -----------------------------------------------------------------------------
# Logging
# -----------------------------------------------------------------------------
log_level  = "info"    # trace | debug | info | warn | error
log_format = "standard" # standard | json

# Uncomment to write logs to a file instead of stderr:
# log_file             = "/var/log/vault/vault.log"
# log_rotate_duration  = "24h"
# log_rotate_max_files = 7

# -----------------------------------------------------------------------------
# Memory Locking
# Prevents secrets from being swapped to disk.
# Set to true only in environments where mlock is unavailable (e.g. containers).
# -----------------------------------------------------------------------------
disable_mlock = false

# -----------------------------------------------------------------------------
# PID File
# -----------------------------------------------------------------------------
# pid_file = "/run/vault/vault.pid"

# -----------------------------------------------------------------------------
# Lease TTL Defaults
# -----------------------------------------------------------------------------
default_lease_ttl = "768h"  # 32 days
max_lease_ttl     = "768h"  # 32 days

# -----------------------------------------------------------------------------
# API Address
# The full URL Vault advertises to clients for redirects.
# Set this to the externally reachable address of this node.
# -----------------------------------------------------------------------------
api_addr = "http://127.0.0.1:8200"

# -----------------------------------------------------------------------------
# Cluster Address
# Used for intra-cluster (Raft) communication.
# Typically the same host on port 8201.
# -----------------------------------------------------------------------------
cluster_addr = "http://127.0.0.1:8201"

# cluster_name = "vault-cluster-01"

# -----------------------------------------------------------------------------
# TCP Listener
# -----------------------------------------------------------------------------
listener "tcp" {
  address = "0.0.0.0:8200"

  # ---- TLS (recommended in production) ----
  # tls_cert_file    = "/etc/vault.d/tls/vault.crt"
  # tls_key_file     = "/etc/vault.d/tls/vault.key"
  # tls_min_version  = "tls12"

  # ---- Disable TLS (for local/development only) ----
  tls_disable = true

  # ---- Cluster listener (Raft peer communication) ----
  # cluster_address = "0.0.0.0:8201"
}

# -----------------------------------------------------------------------------
# Storage — Integrated Raft
# Vault manages its own storage using the Raft consensus algorithm.
# No external storage backend required.
# -----------------------------------------------------------------------------
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-node-01"

  # ---- Performance Tuning ----
  # performance_multiplier = 1   # Increase (1-10) on slow/shared systems
  # trailing_logs          = 10000
  # snapshot_threshold     = 8192

  # ---- HA Cluster: Join peers on startup ----
  # Repeat this block for each peer node in the cluster.
  # retry_join {
  #   leader_api_addr         = "http://vault-node-02:8200"
  #   leader_ca_cert_file     = "/etc/vault.d/tls/ca.crt"
  #   leader_client_cert_file = "/etc/vault.d/tls/client.crt"
  #   leader_client_key_file  = "/etc/vault.d/tls/client.key"
  # }

  # retry_join {
  #   leader_api_addr = "http://vault-node-03:8200"
  # }
}

# -----------------------------------------------------------------------------
# Auto-Unseal (optional)
# Automatically unseal Vault using a cloud KMS.
# Comment out the manual unseal section above and uncomment one block below.
# -----------------------------------------------------------------------------

# -- AWS KMS --
# seal "awskms" {
#   region     = "us-east-1"
#   kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/your-kms-key-id"
# }

# -- GCP Cloud KMS --
# seal "gcpckms" {
#   project    = "my-gcp-project"
#   region     = "global"
#   key_ring   = "vault-key-ring"
#   crypto_key = "vault-unseal-key"
# }

# -- Azure Key Vault --
# seal "azurekeyvault" {
#   vault_name = "my-key-vault"
#   key_name   = "vault-unseal-key"
# }

# -----------------------------------------------------------------------------
# Telemetry (optional)
# -----------------------------------------------------------------------------
# telemetry {
#   prometheus_retention_time = "30s"
#   disable_hostname          = false
#   enable_hostname_label     = true
# }
