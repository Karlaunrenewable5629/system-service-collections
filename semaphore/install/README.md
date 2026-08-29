# Semaphore Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install/install.sh

# Or manually:
# 1. Download from https://github.com/ansible-semaphore/semaphore/releases
# 2. Extract and copy semaphore binary to /usr/local/bin
# 3. Create config at /etc/semaphore/config.json
# 4. Setup database
# 5. Run: semaphore setup --config /etc/semaphore/config.json
```

## Manual Installation

### From Binary

| Distribution | Command |
|--------------|---------|
| Linux (amd64) | `curl -L https://github.com/ansible-semaphore/semaphore/releases/download/v2.98.0/semaphore_2.98.0_linux_amd64.tar.gz -o /tmp/semaphore.tar.gz && tar -xzf /tmp/semaphore.tar.gz -C /usr/local/bin semaphore` |
| Linux (arm64) | `curl -L https://github.com/ansible-semaphore/semaphore/releases/download/v2.98.0/semaphore_2.98.0_linux_arm64.tar.gz -o /tmp/semaphore.tar.gz && tar -xzf /tmp/semaphore.tar.gz -C /usr/local/bin semaphore` |

### Prerequisites

1. **Database** (choose one):
   - MySQL 5.7+ or MariaDB 10.3+
   - PostgreSQL 10+

2. **Create database**:
   ```sql
   -- MySQL
   CREATE DATABASE semaphore;
   CREATE USER 'semaphore'@'localhost' IDENTIFIED BY 'your_password';
   GRANT ALL PRIVILEGES ON semaphore.* TO 'semaphore'@'localhost';
   FLUSH PRIVILEGES;

   -- PostgreSQL
   CREATE USER semaphore WITH PASSWORD 'your_password';
   CREATE DATABASE semaphore;
   GRANT ALL PRIVILEGES ON DATABASE semaphore TO semaphore;
   ```

3. **Dependencies** (for job execution):
   - Git
   - Ansible (for playbook jobs)
   - Terraform (for terraform jobs)
   - SSH client

### Post-Installation

1. Create configuration:
   ```bash
   sudo mkdir -p /etc/semaphore /var/lib/semaphore /var/log/semaphore
   sudo cp config/config.json /etc/semaphore/config.json
   sudo nano /etc/semaphore/config.json  # Edit database credentials
   ```

2. Setup the database:
   ```bash
   semaphore setup --config /etc/semaphore/config.json
   ```

3. Create service user (optional):
   ```bash
   sudo useradd --system --create-home --shell /bin/bash semaphore
   sudo chown -R semaphore:semaphore /var/lib/semaphore /var/log/semaphore
   ```

4. Start service:
   ```bash
   sudo systemctl start semaphore
   sudo systemctl enable semaphore
   ```

5. Access web UI at `http://localhost:3000`

## Verify Installation

```bash
semaphore --version
systemctl status semaphore
```