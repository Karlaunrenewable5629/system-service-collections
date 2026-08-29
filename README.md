<div align="center">

 <img src="./banner.svg" alt="System Service Collections" style="width: 100%; max-width: 1200px;" />

<a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>
<img src="https://img.shields.io/badge/services-108+-informational" alt="108+ Services">
<img src="https://img.shields.io/badge/init-systemd%20%7C%20openrc%20%7C%20sysvinit%20%7C%20windows-0db7ed" alt="Init Systems: systemd, OpenRC, SysVinit, Windows">

  <p><strong> Ready-to-use system service definitions for development and production services.</strong></p>
</div>

## Overview

This repository is a comprehensive collection of system service definitions for common infrastructure and developer tooling.  
Each folder contains a service structure supporting multiple init systems, allowing you to run services natively on Linux, BSD, and Windows.

## What You Will Find

- Pre-configured service definitions for 108+ common services
- Support for systemd, OpenRC, SysVinit, and Windows (NSSM)
- Persistent configuration templates and environment files
- Service-specific README files with setup, usage, and operational notes
- Configurations that are easy to adapt for local labs and production deployments

## Available Services

### AI & Machine Learning

- [litellm](./litellm/)
- [ollama](./ollama/)
- [vllm](./vllm/)

### API Gateways & Proxies

- [caddy](./caddy/)
- [envoy](./envoy/)
- [haproxy](./haproxy/)
- [kong](./kong/)
- [krakend](./krakend/)
- [nginx](./nginx/)
- [nginx-proxy-manager](./nginx-proxy-manager/)
- [traefik](./traefik/)
- [varnish](./varnish/)

### Application Servers

- [node](./node/)
- [php-fpm](./php-fpm/)
- [tomcat](./tomcat/)

### Authentication & Identity

- [authentik](./authentik/)
- [freeipa](./freeipa/)
- [keycloak](./keycloak/)
- [openldap](./openldap/)
- [vault](./vault/)

### Automation & CI/CD

- [jenkins](./jenkins/)
- [woodpecker-ci](./woodpecker-ci/)
- [salt-minion](./salt-minion/)
- [puppet](./puppet/)
- [chef](./chef/)

### Caching

- [memcached](./memcached/)
- [redis](./redis/)
- [varnish](./varnish/)

### Communication & Messaging

- [activemq](./activemq/)
- [kafka](./kafka/)
- [automq](./automq/)
- [nats](./nats/)
- [pulsar](./pulsar/)
- [rabbitmq](./rabbitmq/)
- [redpanda](./redpanda/)
- [mosquitto](./mosquitto/)
- [postfix](./postfix/)
- [syncthing](./syncthing/)
- [wireguard](./wireguard/)

### Container & Orchestration

- [containerd](./containerd/)
- [docker](./docker/)
- [podman](./podman/)

### Databases & Storage

- [cassandra](./cassandra/)
- [couchdb](./couchdb/)
- [elasticsearch](./elasticsearch/)
- [mariadb](./mariadb/)
- [meilisearch](./meilisearch/)
- [mongodb](./mongodb/)
- [mysql](./mysql/)
- [neo4j](./neo4j/)
- [postgresql](./postgresql/)
- [scylladb](./scylladb/)
- [redis](./redis/)
- [minio](./minio/)
- [registry](./registry/)
- [verdaccio](./verdaccio/)

### DNS & Service Discovery

- [bind](./bind/)
- [coredns](./coredns/)
- [dnsmasq](./dnsmasq/)
- [consul](./consul/)
- [etcd](./etcd/)
- [unbound](./unbound/)

### Documentation & Knowledge

- [overleaf](./overleaf/)
- [wordpress](./wordpress/)
- [backstage](./backstage/)

### Infrastructure & DevOps

- [prometheus](./prometheus/)
- [grafana](./grafana/)
- [grafana-alloy](./grafana-alloy/)
- [loki](./loki/)
- [tempo](./tempo/)
- [alertmanager](./alertmanager/)
- [opentelemetry-collector](./opentelemetry-collector/)
- [node-exporter](./node-exporter/)
- [fluent-bit](./fluent-bit/)
- [fluentd](./fluentd/)
- [signoz](./signoz/)
- [victoriametrics](./victoriametrics/)

### Mail & Communication

- [dovecot](./dovecot/)
- [postfix](./postfix/)
- [mailpit](./mailpit/)
- [listmonk](./listmonk/)
- [mattermost](./mattermost/)
- [rocket-chat](./rocket-chat/)
- [plane](./plane/)
- [taiga](./taiga/)

### Network & Security

- [clamav](./clamav/)
- [trivy](./trivy/)
- [wireguard](./wireguard/)
- [pihole](./pihole/)
- [squid](./squid/)
- [unbound](./unbound/)

### Search & Analytics

- [elasticsearch](./elasticsearch/)
- [meilisearch](./meilisearch/)

### Workflow & Automation

- [n8n](./n8n/)
- [activepieces](./activepieces/)
- [backstage](./backstage/)
- [taiga](./taiga/)
- [plane](./plane/)

### WSO2 Stack

- [wso2-am](./wso2-am/)
- [wso2-am-mi](./wso2-am-mi/)
- [wso2-mi](./wso2-mi/)

### Other Services

- [activepieces](./activepieces/)
- [apprise](./apprise/)
- [backstage](./backstage/)
- [devpi](./devpi/)
- [filebrowser](./filebrowser/)
- [gitea](./gitea/)
- [gitlab](./gitlab/)
- [influxdb](./influxdb/)
- [openproject](./openproject/)
- [openssh-server](./openssh-server/)
- [open-webui](./open-webui/)
- [parse-server](./parse-server/)
- [penpot](./penpot/)
- [semaphore](./semaphore/)
- [sentry](./sentry/)
- [uptime-kuma](./uptime-kuma/)

## Quick Start

### Linux (systemd)

```bash
# Copy service file
sudo cp <service>/service/systemd/<service>.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now <service>

# Check status
sudo systemctl status <service>

# View logs
journalctl -u <service> -f
```

### Linux (OpenRC)

```bash
# Copy init script
sudo cp <service>/service/openrc/<service> /etc/init.d/
sudo chmod +x /etc/init.d/<service>
sudo rc-update add <service> default
sudo rc-service <service> start

# Check status
sudo rc-service <service> status

# View logs
tail -f /var/log/<service>.log
```

### Linux (SysVinit)

```bash
# Copy init script
sudo cp <service>/service/sysvinit/<service> /etc/init.d/
sudo chmod +x /etc/init.d/<service>
sudo update-rc.d <service> defaults
sudo service <service> start

# Check status
sudo service <service> status
```

### Windows (NSSM)

```powershell
# Install NSSM if not present
# Download from https://nssm.cc/download

# Install service
nssm install <service> "C:\path\to\<service>.exe" "<arguments>"
nssm set <service> Description "<service description>"
nssm set <service> AppDirectory "C:\path\to\working\dir"
nssm start <service>

# Manage service
nssm status <service>
nssm stop <service>
nssm restart <service>

# Remove service
nssm remove <service> confirm
```

## Configuration

Each service includes:
- **config/** - Default configuration files and templates
- **install/README.md** - Detailed installation guide
- **config/README.md** - Configuration options and environment variables
- **service/README.md** - Service management across init systems

## Requirements

- Linux with systemd, OpenRC, or SysVinit
- Windows 10/11 / Windows Server 2016+ with NSSM
- Appropriate privileges (root/sudo or Administrator)

## Contributing

Contributions are welcome.  
If you want to add or improve a service definition, open a pull request with a short description of the service and supported init systems.

Please ensure each service includes:
1. systemd service unit
2. OpenRC init script
3. SysVinit init script
4. Windows NSSM configuration
5. Configuration templates
6. Installation/uninstallation scripts
7. README.md documentation

## License

This project is licensed under the MIT License.