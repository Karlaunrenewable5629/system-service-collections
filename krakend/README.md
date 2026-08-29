# Krakend

System service collection for [Krakend](https://www.krakend.io), the ultra-fast API Gateway built on Go.

## Features

- **Rate limiting** — Protect backends from excessive traffic
- **Caching** — Transparent response caching to reduce backend load
- **Circuit breaker** — Prevent cascading failures
- **Logging** — Structured logging for request tracing
- **Metrics** — Prometheus-compatible metrics endpoint
- **CORS** — Cross-origin resource sharing support
- **JWT validation** — Authentication and authorization via JSON Web Tokens

## Structure

- `install/` — Installation scripts and guides
- `config/` — Configuration files and templates
- `service/` — Service definitions for different init systems
  - `systemd/` — systemd service units
  - `openrc/` — OpenRC init scripts
  - `sysvinit/` — SysV init scripts
  - `windows/` — Windows service definitions (NSSM)
- `uninstall/` — Uninstallation scripts

## Quick Start

### systemd

```bash
cp config/krakend.json /etc/krakend/krakend.json
cp service/systemd/krakend.service /etc/systemd/system/krakend.service
systemctl daemon-reload
systemctl enable krakend
systemctl start krakend
```

### OpenRC (default)

```bash
cp config/krakend.json /etc/krakend/krakend.json
cp service/openrc/krakend /etc/init.d/krakend
rc-update add krakend default
rc-service krakend start
```

### SysVinit

```bash
cp config/krakend.json /etc/krakend/krakend.json
cp service/sysvinit/krakend /etc/init.d/krakend
update-rc.d krakend defaults
service krakend start
```

### Windows

```powershell
copy config\krakend.json C:\etc\krakend\krakend.json
nssm install krakend "C:\usr\local\bin\krakend" run -d -c C:\etc\krakend\krakend.json
nssm start krakend
```

## Configuration

See [config/README.md](config/README.md) for configuration options.

## Service Management

See [service/README.md](service/README.md) for service management across different init systems.

## Installation

See [install/README.md](install/README.md) for installation instructions.

## Uninstallation

See [uninstall/README.md](uninstall/README.md) for uninstallation instructions.
