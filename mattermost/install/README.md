# Mattermost Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install/install.sh

# Or manually:
# 1. Download from https://mattermost.com/download/
# 2. Extract and copy to /opt/mattermost
# 3. Copy config to /etc/mattermost/settings.json
# 4. Setup database (PostgreSQL or MySQL)
# 5. Run: systemctl start mattermost
```

## Manual Installation

### From Binary

| Distribution | Command |
|--------------|---------|
| Linux (amd64) | `curl -L https://releases.mattermost.com/v9.10.0/mattermost-9.10.0-linux-amd64.tar.gz -o /tmp/mattermost.tar.gz && tar -xzf /tmp/mattermost.tar.gz -C /opt/mattermost` |
| Linux (arm64) | `curl -L https://releases.mattermost.com/v9.10.0/mattermost-9.10.0-linux-arm64.tar.gz -o /tmp/mattermost.tar.gz && tar -xzf /tmp/mattermost.tar.gz -C /opt/mattermost` |

### Prerequisites

1. **Database** (choose one):
   - PostgreSQL 12+ or MySQL 5.7+
   
2. **Create database**:
   ```sql
   -- PostgreSQL
   CREATE DATABASE mattermost;
   CREATE USER mattermost WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE mattermost TO mattermost;
   
   -- MySQL
   CREATE DATABASE mattermost;
   CREATE USER 'mattermost'@'localhost' IDENTIFIED BY 'your_password';
   GRANT ALL PRIVILEGES ON mattermost.* TO 'mattermost'@'localhost';
   FLUSH PRIVILEGES;
   ```

3. **Dependencies** (for job execution):
   - Git
   - Ansible (for playbook jobs if applicable)

### Post-Installation

1. **Create configuration**:
   ```bash
   sudo mkdir -p /etc/mattermost /var/mattermost /var/log/mattermost
   sudo mkdir -p /var/mattermost/data
   sudo cp config/mattermost-settings.json /etc/mattermost/settings.json
   sudo nano /etc/mattermost/settings.json  # Edit settings
   ```

2. **Setup the database**:
   Configure database connection in settings.json

3. **Create service user** (optional):
   ```bash
   sudo useradd --system --create-home --shell /bin/bash mattermost
   sudo chown -R mattermost:mattermost /var/mattermost /var/log/mattermost
   ```

4. **Start service**:
   ```bash
   sudo systemctl start mattermost
   sudo systemctl enable mattermost
   ```

5. **Access web UI** at `http://localhost:8065`

## Verify Installation

```bash
mattermost --version
systemctl status mattermost
ps aux | grep mattermost
```