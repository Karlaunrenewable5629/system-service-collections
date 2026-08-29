# Installing Krakend

This guide covers installing the Krakend API Gateway on your system.

## Prerequisites

- Go 1.21+ (if building from source) or the pre-built binary
- Root or sudo access
- One of the following init systems: OpenRC, systemd, or SysVinit
- Linux/macOS: standard POSIX utilities
- Windows: NSSM (Non-Sucking Service Manager)

## Quick Install (Linux/OpenRC)

```bash
cd krakend
sudo ./install/install.sh
```

## Step-by-Step

### 1. Get the binary

Download the latest release from [GitHub](https://github.com/krakendio/krakend-gateway/releases) or build from source:

```bash
go build -o krakend ./...
```

### 2. Install the binary

```bash
sudo cp krakend /usr/local/bin/
sudo chmod +x /usr/local/bin/krakend
```

### 3. Create the service user

```bash
sudo useradd --system --shell /usr/sbin/nologin --home-dir /var/lib/krakend --create-home krakend
sudo groupadd krakend
sudo usermod -aG krakend krakend
```

### 4. Install configuration

```bash
sudo mkdir -p /etc/krakend
sudo cp config/krakend.json /etc/krakend/krakend.json
sudo chown krakend:krakend /etc/krakend/krakend.json
```

Edit `/etc/krakend/krakend.json` to point to your backend services.

### 5. Install and start the service

#### OpenRC

```bash
sudo cp service/openrc/krakend /etc/init.d/krakend
sudo chmod +x /etc/init.d/krakend
sudo rc-update add krakend default
sudo rc-service krakend start
```

#### systemd

```bash
sudo cp service/systemd/krakend.service /etc/systemd/system/krakend.service
sudo systemctl daemon-reload
sudo systemctl enable krakend
sudo systemctl start krakend
```

#### SysVinit

```bash
sudo cp service/sysvinit/krakend /etc/init.d/krakend
sudo chmod +x /etc/init.d/krakend
sudo update-rc.d krakend defaults
sudo service krakend start
```

#### Windows

Use NSSM or the included `krakend.nssm` configuration to install as a Windows service.

### 6. Verify

```bash
curl http://localhost:8080
```

### 7. Check metrics

```bash
curl http://localhost:8081/metrics
```

## Customization

- **Binary path**: Edit the `command` / `Executable` lines in service files
- **Config path**: Edit the `config` / `AppParameters` paths in service files
- **Ports**: Modify `port` and `metrics_port` in `krakend.json`
- **User/group**: Change `User` and `Group` in systemd, or `krakend_user` / `krakend_group` in OpenRC

## Uninstallation

See [uninstall/README.md](../uninstall/README.md) for removal instructions.
