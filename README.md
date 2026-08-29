<div align="center">

 <img src="./banner.svg" alt="System Service Collections" style="width: 100%; max-width: 1200px;" />

<a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>
<img src="https://img.shields.io/badge/init-systemd%20%7C%20openrc%20%7C%20sysvinit%20%7C%20windows-0db7ed" alt="Init Systems: systemd, OpenRC, SysVinit, Windows">

  <p><strong> Ready-to-use system service definitions for development and production services.</strong></p>
</div>

## Overview

This repository is a comprehensive collection of system service definitions for common infrastructure and developer tooling.  
Each folder contains a service structure supporting multiple init systems, allowing you to run services natively on Linux, BSD, and Windows.

## What You Will Find

- Pre-configured service definitions for popular services
- Support for systemd, OpenRC, SysVinit, and Windows (NSSM)
- Persistent configuration templates and environment files
- Service-specific README files with setup, usage, and operational notes
- Configurations that are easy to adapt for local labs and production deployments

## Available Services

### AI & Machine Learning

- [litellm](./litellm/) - LLM router and proxy supporting all major AI providers.
- [ollama](./ollama/) - Run LLMs locally with a simple API.
- [vllm](./vllm/) - High-throughput LLM serving engine.
- [open-webui](./open-webui/) - Self-hosted AI assistant interface.

### API Gateways & Proxies

- [caddy](./caddy/) - Powerful, enterprise-ready open source web server with automatic HTTPS and flexible configuration.
- [envoy](./envoy/) - High-performance C++ distributed edge middleware designed for service architectures.
- [haproxy](./haproxy/) - Reliable, high-performance TCP/HTTP load balancer supporting virtual hosting.
- [kong](./kong/) - Open-source API gateway built on NGINX, providing routing, transformations, and plugin architecture.
- [krakend](./krakend/) - Ultra-high-performance API gateway with built-in transformation and aggregation.
- [nginx](./nginx/) - High-performance web server and reverse proxy, known for its stability and rich feature set.
- [nginx-proxy-manager](./nginx-proxy-manager/) - Docker-based Nginx proxy manager with a simple web UI for managing reverse proxies.
- [traefik](./traefik/) - Modern HTTP reverse proxy and load balancer designed to deploy microservices easily.

### Application Servers

- [node](./node/) - Node.js runtime for building scalable network applications and server-side JavaScript.
- [php-fpm](./php-fpm/) - PHP FastCGI Process Manager for serving PHP applications with Nginx or Apache.
- [tomcat](./tomcat/) - Apache Tomcat servlet container for running Java-based web applications.

### Authentication & Identity

- [authentik](./authentik/) - Open-source identity provider for modern authentication and authorization.
- [freeipa](./freeipa/) - FreeIPA integrated identity management solution combining DNS, CA, LDAP, and Kerberos.
- [keycloak](./keycloak/) - Open-source identity and access management server for modern applications and services.
- [openldap](./openldap/) - Open Source implementation of Lightweight Directory Access Protocol (LDAP) directory server.
- [vault](./vault/) - HashiCorp secret management tool for securely accessing secrets at runtime.

### Automation & CI/CD

- [jenkins](./jenkins/) - Leading open source automation server for CI/CD, featuring pipeline as code, distributed builds, and a vast plugin ecosystem.
- [woodpecker-ci](./woodpecker-ci/) - Self-hosted continuous integration system written in Go, supporting Docker-based builds and pipeline as code.
- [semaphore](./semaphore/) - Continuous integration and delivery platform.

### Configuration Management

- [salt-minion](./salt-minion/) - SaltStack minion agent for remote node execution, configuration, and orchestration via Salt master.
- [puppet](./puppet/) - Puppet agent for configuration management, ensuring system state matches declared configuration.
- [chef](./chef/) - Chef client for configuration management using Ruby-based recipes and runlists.

### Caching & Content Delivery

- [memcached](./memcached/) - High-performance distributed memory caching system, optimized for small chunks of arbitrary data.
- [redis](./redis/) - In-memory data structure store, used as a database, cache, and message broker with persistence options.
- [varnish](./varnish/) - HTTP accelerator and reverse proxy, focused on content caching and improving web performance.
- [squid](./squid/) - Caching proxy for the web, commonly used to speed up delivery and reduce bandwidth.

### Communication & Message Queue

- [activemq](./activemq/) - Open source message broker for enterprise integration.
- [kafka](./kafka/) - Distributed publish-subscribe messaging system.
- [automq](./automq/) - Cloud-native Kafka with reduced operational complexity.
- [nats](./nats/) - High-performance messaging system for cloud-native applications.
- [pulsar](./pulsar/) - Distributed publish-subscribe messaging platform.
- [rabbitmq](./rabbitmq/) - Popular open source message broker using AMQP protocol.
- [redpanda](./redpanda/) - Streaming data platform compatible with Kafka API.
- [mosquitto](./mosquitto/) - Open source MQTT message broker.

### Team Chat & Collaboration

- [mattermost](./mattermost/) - Open source Slack alternative for team communication.
- [rocket-chat](./rocket-chat/) - Open source chat platform for team communication.

### Container & Orchestration

- [containerd](./containerd/) - Container runtime for Linux and Windows.
- [docker](./docker/) - Container platform for developing, shipping, and running applications.
- [podman](./podman/) - Container engine for developing, managing, and running OCI Containers on your system.

### Databases

- [cassandra](./cassandra/) - Distributed NoSQL database management system.
- [couchdb](./couchdb/) - Apache CouchDB document-oriented database server.
- [mariadb](./mariadb/) - Open source relational database management system.
- [mongodb](./mongodb/) - Source-available cross-platform document-oriented database program.
- [mysql](./mysql/) - Open source relational database management system.
- [neo4j](./neo4j/) - Native graph database platform.
- [postgresql](./postgresql/) - Open source object-relational database system.
- [scylladb](./scylladb/) - Distributed NoSQL database compatible with Apache Cassandra.
- [influxdb](./influxdb/) - Time series database for metrics and events.

### Registry

- [registry](./registry/) - Docker registry for storing and distributing container images.
- [verdaccio](./verdaccio/) - Lightweight private npm proxy registry.
- [devpi](./devpi/) - Software package testing and distribution system.

### DNS & Service Discovery

- [bind](./bind/) - Comprehensive implementation of the DNS protocol.
- [coredns](./coredns/) - Authoritative DNS server written in Go.
- [dnsmasq](./dnsmasq/) - Lightweight DNS forwarder and DHCP server.
- [consul](./consul/) - Service mesh solution with service discovery and configuration.
- [etcd](./etcd/) - Distributed reliable key-value store for the most critical data of a distributed system.
- [unbound](./unbound/) - Validating, recursive, and caching DNS resolver.

### Documentation & Knowledge

- [overleaf](./overleaf/) - Collaborative online LaTeX editor for writing and publishing documents.
- [backstage](./backstage/) - Developer portal for managing services, components, and documentation.

### File Sync & Storage

- [syncthing](./syncthing/) - Continuous file synchronization between devices.
- [filebrowser](./filebrowser/) - Web file browser written in Go.
- [minio](./minio/) - High-performance object storage server compatible with Amazon S3.

### Infrastructure & DevOps / Observability

- [prometheus](./prometheus/) - Leading open-source monitoring and alerting toolkit.
- [grafana](./grafana/) - Leading open-source platform for monitoring and observability.
- [grafana-alloy](./grafana-alloy/) - Lightweight configuration framework for Grafana.
- [loki](./loki/) - Horizontally-scalable, highly-available log aggregation system.
- [tempo](./tempo/) - High-scale distributed tracing backend.
- [alertmanager](./alertmanager/) - Handles routing alerts and silencing notifications.
- [opentelemetry-collector](./opentelemetry-collector/) - Components to process telemetry data.
- [node-exporter](./node-exporter/) - Collector for hardware and OS metrics.
- [fluent-bit](./fluent-bit/) - Fast and lightweight log processor and forwarder.
- [fluentd](./fluentd/) - Reliable log collector.
- [signoz](./signoz/) - Full-stack open-source observability platform.
- [victoriametrics](./victoriametrics/) - Time series database for monitoring.
- [localstack](./localstack/) - Local AWS cloud services development.
- [sentry](./sentry/) - Error tracking and monitoring platform.
- [uptime-kuma](./uptime-kuma/) - Uptime monitoring tool.

### Mail

- [dovecot](./dovecot/) - IMAP and POP3 email server for Unix-like systems.
- [postfix](./postfix/) - Mail transfer agent (MTA) and server for routing and delivering email.
- [mailpit](./mailpit/) - Debugging and development SMTP/IMAP server.
- [listmonk](./listmonk/) - Self-hosted newsletter and mailing list manager.

### Network & Security

- [clamav](./clamav/) - Open source antivirus software toolkit.
- [trivy](./trivy/) - Container vulnerability checker.
- [wireguard](./wireguard/) - Modern, secure VPN tunnel.
- [pihole](./pihole/) - Network-wide ad blocking via DNS.
- [cloudflare-tunnel](./cloudflare-tunnel/) - Securely exposes local services to the internet without opening inbound ports, via an outbound tunnel to Cloudflare's edge.

### Notifications

- [apprise](./apprise/) - Unified notification library/gateway that pushes alerts to 100+ services (Slack, Discord, email, SMS, etc.) from a single API.

### Project & Design Collaboration

- [plane](./plane/) - Project management and planning tool.
- [taiga](./taiga/) - Project management platform for agile development.
- [openproject](./openproject/) - Open source project management software.
- [penpot](./penpot/) - Design software for design teams.

### Search & Analytics

- [elasticsearch](./elasticsearch/) - Distributed RESTful search engine capable of solving a growing number of use cases.
- [meilisearch](./meilisearch/) - Lightning-fast, easy-to-use search API built on top of Lucene.

### Version Control & Source Code Management

- [gitea](./gitea/) - Git service with self-hosted focus.
- [gitlab](./gitlab/) - Complete DevOps platform.

### Workflow & Automation

- [n8n](./n8n/) - Workflow automation tool for connecting apps and services.
- [activepieces](./activepieces/) - Open source automation platform alternative to Zapier.

### WSO2 Stack

- [wso2-am](./wso2-am/) - Open source full lifecycle API management platform.
- [wso2-am-mi](./wso2-am-mi/) - API management micro-integration for on-premise deployments.
- [wso2-mi](./wso2-mi/) - Integration micro-bus for connecting applications and services.

### Other Services

- [code-server](./code-server/) - VS Code running in the browser.
- [wordpress](./wordpress/) - Popular content management system for building websites and blogs.
- [openssh-server](./openssh-server/) - OpenSSH server for remote login and file transfer.
- [parse-server](./parse-server/) - Backend framework for building applications.

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
