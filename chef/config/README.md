# Chef Client Configuration

## client.rb

The main configuration file is `client.rb`. It uses Ruby hash format for chef settings.

### Structure

```ruby
# Server configuration
server_url "https://api.chef.io/organizations/myorg"

# Node configuration
node_name "my-node"
client_key "/etc/chef/client.pem"

# Run configuration
chef_server_url "https://api.chef.io/organizations/myorg"
validation_key "/etc/chef/validator.pem"
validation_name "myorg-validator"

# Interval configuration
interval 1800  # 30 minutes in seconds

# Cache path
cache_path "/var/cache/chef/chef-client.cache"

# Log level
log_level :info
log_location STDOUT

# Environment
environment "production"
```

### Common Settings

| Setting | Description |
|---------|-------------|
| `node_name` | Node identifier |
| `client_key` | Path to PEM key file |
| `server_url` | Chef API server URL |
| `environment` | Node environment (production, development) |
| `run_list` | Array of roles and recipes to apply |
| `interval` | How often to check in with server (seconds) |

### File Locations

| System | Config Path |
|--------|-------------|
| Linux | `/etc/chef/client.rb` |
| Windows | `C:\chef\client.rb` |

### Reloading Configuration

```bash
# systemd
systemctl restart chef-client

# OpenRC
rc-service chef-client restart

# Windows (NSSM)
nssm restart chef-client
```