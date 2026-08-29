# Chef Client Configuration

## Main configuration file

The main configuration file is `/etc/chef/client.rb`. It uses Ruby hash format for chef settings.

### Default Configuration

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

# Log path
log_level :info
log_location STDOUT

# Environment
environment "production"

# API options
timeout 60
```

### Server Options

| Option | Description | Default |
|--------|-------------|---------|
| `server_url` | Chef server URL | - |
| `node_name` | Node name | - |
| `client_key` | Path to client key | - |
| `environment` | Environment name | "production" |
| `run_list` | Run list of roles/recipes | - |
| `interval` | Poll interval (seconds) | 1800 |

### File Locations

| System | Config Path |
|--------|-------------|
| Linux (systemd) | `/etc/chef/client.rb` |
| Windows | `C:\chef\client.rb` |

### Services Related

The chef client works alongside:
- `chef-server` - The Chef server (hosted or private)
- `chef-backend` - Chef Automate backend
- `manageiq` - ManageIQ (Red Hat)