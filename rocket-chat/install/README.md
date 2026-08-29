# Rocket.Chat Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install/install.sh

# Or manually:
# 1. Download from https://rocket.chat/download/
# 2. Extract and copy to /opt/rocketchat
# 3. Copy config to /etc/rocketchat/settings.json
# 4. Setup MongoDB database
# 5. Run: systemctl start rocketchat
```

## Manual Installation

### From Binary

| Distribution | Command |
|--------------|---------|
| Linux (amd64) | `curl -L https://releases.rocket.chat/9.0.0/rocket.chat-9.0.0-linux-amd64.tar.gz -o /tmp/rocketchat.tar.gz && tar -xzf /tmp/rocketchat.tar.gz -C /opt/rocketchat` |
| Linux (arm64) | `curl -L https://releases.rocket.chat/9.0.0/rocket.chat-9.0.0-linux-arm64.tar.gz -o /tmp/rocketchat.tar.gz && tar -xzf /tmp/rocketchat.tar.gz -C /opt/rocketchat` |

### Prerequisites

1. **MongoDB** (required):
   - MongoDB 5.0+ must be installed and running
   - Create database: `rocketchat` user with appropriate permissions
   
2. **Dependencies**:
   - curl, tar, gzip

### Post-Installation

1. **Create configuration**:
   ```bash
   sudo mkdir -p /etc/rocketchat /var/rocketchat /var/log/rocketchat
   sudo mkdir -p /var/rocketchat/uploads
   sudo cp config/rocket-chat-settings.json /etc/rocketchat/settings.json
   sudo nano /etc/rocketchat/settings.json  # Edit settings
   ```

2. **Setup MongoDB**:
   ```bash
   # Create rocketchat user
   mongosh --eval "
   db = db.getSiblingDB('rocketchat');
   db.createUser({
     user: 'rocketchat',
     pwd: 'your_password',
     roles: [
       {role: 'readWrite', db: 'rocketchat'},
       {role: 'dbAdmin', db: 'rocketchat'}
     ]
   });
   "
   ```

3. **Create service user** (optional):
   ```bash
   sudo useradd --system --create-home --shell /bin/bash rocketchat
   sudo chown -R rocketchat:rocketchat /var/rocketchat /var/log/rocketchat
   ```

4. **Start service**:
   ```bash
   sudo systemctl start rocketchat
   sudo systemctl enable rocketchat
   ```

5. **Access web UI** at `http://localhost:3000`

## Verify Installation

```bash
rocket.chat --version
systemctl status rocketchat
ps aux | grep rocketchat
```