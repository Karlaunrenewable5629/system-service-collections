# varnish

System service collection for Varnish Cache — a high-performance HTTP accelerator (reverse proxy cache).

## Features

- **HTTP Caching**: Stores content in memory for ultra-low latency responses
- **Content Acceleration**: Delivers static and dynamic content with minimal overhead
- **ESI Support**: Edge Side Includes for composable cacheable pages
- **VCL Scripting**: Highly customizable request/response processing via VCL
- **TLS Termination**: Supported via Hitch or STV
- **Health Checks**: Backend health monitoring and graceful handling
- **Graceful Handling**: Grace period and hit-for-pass for degraded backend responses
- **Varnish Administration Console (VAC)**: Real-time monitoring and management

## Structure

- `install/` - Installation scripts and guides
- `config/` - Configuration files and templates
- `service/` - Service definitions for different init systems
  - `systemd/` - systemd service units
  - `openrc/` - OpenRC init scripts
  - `sysvinit/` - SysV init scripts
  - `windows/` - Windows service definitions (NSSM)
- `uninstall/` - Uninstallation scripts

## Quick Start

### systemd

```bash
cp service/systemd/varnish.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable varnish
systemctl start varnish
```

### OpenRC

```bash
cp service/openrc/varnish /etc/init.d/varnish
chmod +x /etc/init.d/varnish
rc-update add varnish default
rc-service varnish start
```

### SysVinit

```bash
cp service/sysvinit/varnish /etc/init.d/varnish
chmod +x /etc/init.d/varnish
chkconfig --add varnish
chkconfig varnish on
service varnish start
```

### Windows (NSSM)

```cmd
nssm install varnish service\windows\varnish.nssm
nssm start varnish
```

## Configuration

- **Binary**: `/usr/sbin/varnishd`
- **Config**: `/etc/varnish/default.vcl` (VCL 4.0 format)
- **Secret**: `/etc/varnish/secret`
- **HTTP Listen Port**: `6081`
- **Backend Port**: `8080`
- **Storage**: `malloc,256m`
- **User/Group**: `varnish:varnish`

See [config/README.md](config/README.md) for detailed configuration documentation.

## Service Management

See [service/README.md](service/README.md) for service management across all supported init systems.

## Installation

See [install/README.md](install/README.md) for installation instructions.

## Uninstallation

See [uninstall/README.md](uninstall/README.md) for uninstallation instructions.

## Varnish Administration Console (VAC)

```bash
varnishadm -S /etc/varnish/secret -T 127.0.0.1:6082
```
