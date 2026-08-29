# Puppet Configuration

## puppet.conf

The main configuration file is `puppet.conf`. It uses INI-style format for puppet agent and server settings.

### Structure

```ini
[main]
    loglevel = info
    server = puppet
    runinterval = 1h

[agent]
    certname = $(hostname -f)
    classfile = /etc/puppetlabs/code/environments/production/classes.txt
    outside_shell = /bin/bash
```

### Common Sections

| Section | Description |
|---------|-------------|
| `[main]` | Global configuration options |
| `[agent]` | Agent-specific settings |
| `[master]` | Master server settings |
| `[values]` | Evalled parameter values |

### Log Configuration

| Option | Description |
|--------|-------------|
| `loglevel` | Debug verbosity (info, debug, trace) |
| `logfile` | Path to log file |
| `trappermode` | Run in trapper mode (yes/no) |

### File Locations

| System | Config Path |
|--------|-------------|
| Linux (systemd) | `/etc/puppetlabs/puppet/puppet.conf` |
| Windows | `C:\ProgramData\PuppetLabs\puppet\conf\puppet.conf` |

### Reloading Configuration

```bash
# systemd
systemctl restart puppet

# OpenRC
rc-service puppet restart

# Windows (NSSM)
nssm restart puppet
```