# Semaphore Configuration

## config.json

The main configuration file is `config.json`. It uses JSON format for Semaphore settings.

### Structure

```json
{
  "bind": ":3000",
  "mysql": {
    "host": "127.0.0.1",
    "port": 3306,
    "user": "semaphore",
    "pass": "yourpassword",
    "name": "semaphore"
  },
  "postgres": {
    "host": "127.0.0.1",
    "port": 5432,
    "user": "semaphore",
    "pass": "yourpassword",
    "name": "semaphore",
    "sslmode": "disable"
  },
  "max_parallel_tasks": 10,
  "tmp_path": "/tmp/semaphore",
  "ssh_key_path": "/var/lib/semaphore/.ssh",
  "ansible": {
    "playbook_path": "/usr/bin/ansible-playbook"
  },
  "email": {
    "host": "smtp.example.com",
    "port": 587,
    "user": "semaphore@example.com",
    "pass": "yourpassword",
    "from": "semaphore@example.com"
  }
}
```

### Common Settings

| Setting | Description |
|---------|-------------|
| `bind` | Interface and port to listen on (e.g., `:3000` or `0.0.0.0:3000`) |
| `mysql`/`postgres` | Database connection settings |
| `max_parallel_tasks` | Maximum concurrent job executions |
| `tmp_path` | Temporary directory for job artifacts |
| `ssh_key_path` | Directory for stored SSH keys |
| `ansible.playbook_path` | Path to ansible-playbook binary |

### Database Setup

| System | Commands |
|--------|----------|
| MySQL/MariaDB | `CREATE DATABASE semaphore; GRANT ALL ON semaphore.* TO 'semaphore'@'localhost' IDENTIFIED BY 'password';` |
| PostgreSQL | `CREATE DATABASE semaphore; CREATE USER semaphore WITH PASSWORD 'password'; GRANT ALL PRIVILEGES ON DATABASE semaphore TO semaphore;` |

### File Locations

| System | Config Path |
|--------|-------------|
| Linux | `/etc/semaphore/config.json` |
| Windows | `C:\Semaphore\config.json` |

### Reloading/Restarting

```bash
# systemd
systemctl restart semaphore

# OpenRC
rc-service semaphore restart

# Windows (NSSM)
nssm restart semaphore
```