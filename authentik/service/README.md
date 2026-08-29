# Authentik Service Management

Authentik runs as two separate processes that must both be running:

| Process | Purpose |
|---|---|
| **authentik-server** | HTTP/HTTPS server — serves the web UI, OAuth2, OIDC, SAML, and LDAP endpoints on ports 9000 / 9443 |
| **authentik-worker** | Background worker — handles async tasks, provisioning, event processing, and scheduled jobs |

Both processes read from the same `/etc/authentik/.env` configuration file and connect to the same PostgreSQL database and Redis instance.

## systemd

### Installation

```bash
sudo cp systemd/authentik-server.service /etc/systemd/system/
sudo cp systemd/authentik-worker.service /etc/systemd/system/
sudo systemctl daemon-reload
```

### Enable and Start

```bash
sudo systemctl enable --now authentik-server authentik-worker
```

### Common Commands

```bash
# Start
sudo systemctl start authentik-server authentik-worker

# Stop
sudo systemctl stop authentik-server authentik-worker

# Restart
sudo systemctl restart authentik-server authentik-worker

# Status
sudo systemctl status authentik-server
sudo systemctl status authentik-worker

# Live logs (server)
journalctl -u authentik-server -f

# Live logs (worker)
journalctl -u authentik-worker -f

# Logs since last boot
journalctl -u authentik-server -b
journalctl -u authentik-worker -b

# Disable auto-start
sudo systemctl disable authentik-server authentik-worker
```

### Service Dependencies

The `authentik-server.service` unit declares `Requires=authentik-worker.service`, so starting or stopping the server will also start or stop the worker. You can still manage them independently if needed.

## OpenRC

### Installation

```bash
sudo cp openrc/authentik-server /etc/init.d/
sudo cp openrc/authentik-worker /etc/init.d/
sudo chmod +x /etc/init.d/authentik-server
sudo chmod +x /etc/init.d/authentik-worker
```

### Enable and Start

```bash
sudo rc-update add authentik-server default
sudo rc-update add authentik-worker default
sudo rc-service authentik-server start
sudo rc-service authentik-worker start
```

### Common Commands

```bash
# Start
sudo rc-service authentik-server start
sudo rc-service authentik-worker start

# Stop
sudo rc-service authentik-server stop
sudo rc-service authentik-worker stop

# Restart
sudo rc-service authentik-server restart
sudo rc-service authentik-worker restart

# Status
sudo rc-service authentik-server status
sudo rc-service authentik-worker status

# Live logs
tail -f /var/log/authentik/server.log
tail -f /var/log/authentik/worker.log

# Remove from default runlevel
sudo rc-update del authentik-server default
sudo rc-update del authentik-worker default
```

## SysVinit

### Installation

```bash
sudo cp sysvinit/authentik-server /etc/init.d/
sudo cp sysvinit/authentik-worker /etc/init.d/
sudo chmod +x /etc/init.d/authentik-server
sudo chmod +x /etc/init.d/authentik-worker
```

### Enable and Start

```bash
sudo update-rc.d authentik-server defaults
sudo update-rc.d authentik-worker defaults
sudo service authentik-server start
sudo service authentik-worker start
```

### Common Commands

```bash
# Start
sudo service authentik-server start
sudo service authentik-worker start

# Stop
sudo service authentik-server stop
sudo service authentik-worker stop

# Restart
sudo service authentik-server restart
sudo service authentik-worker restart

# Status
sudo service authentik-server status
sudo service authentik-worker status

# Remove from startup
sudo update-rc.d authentik-server remove
sudo update-rc.d authentik-worker remove

# View logs
tail -f /var/log/authentik/server.log
tail -f /var/log/authentik/worker.log
```

## Windows (NSSM)

NSSM (Non-Sucking Service Manager) wraps Authentik as a native Windows service. Download NSSM from [https://nssm.cc/download](https://nssm.cc/download) and place `nssm.exe` in `C:\Windows\System32\`.

### Installation

Run **PowerShell as Administrator** or use the provided `authentik-server.nssm` batch script:

```batch
:: From an Administrator Command Prompt:
cd service\windows
authentik-server.nssm install
```

Or manually with NSSM:

```powershell
# Server
nssm install authentik-server "C:\authentik\venv\Scripts\python.exe" "-m authentik.manage server"
nssm set authentik-server AppDirectory "C:\authentik"
nssm set authentik-server AppEnvFile "C:\authentik\.env"
nssm set authentik-server AppStdout "C:\authentik\logs\server.log"
nssm set authentik-server AppStderr "C:\authentik\logs\server-error.log"
nssm set authentik-server Start SERVICE_AUTO_START
nssm set authentik-server Description "Authentik Identity Provider - Server"

# Worker
nssm install authentik-worker "C:\authentik\venv\Scripts\python.exe" "-m authentik.manage worker"
nssm set authentik-worker AppDirectory "C:\authentik"
nssm set authentik-worker AppEnvFile "C:\authentik\.env"
nssm set authentik-worker AppStdout "C:\authentik\logs\worker.log"
nssm set authentik-worker AppStderr "C:\authentik\logs\worker-error.log"
nssm set authentik-worker Start SERVICE_AUTO_START
nssm set authentik-worker Description "Authentik Identity Provider - Worker"
```

### Common Commands

```powershell
# Start
nssm start authentik-server
nssm start authentik-worker

# Stop
nssm stop authentik-worker
nssm stop authentik-server

# Restart
nssm restart authentik-server
nssm restart authentik-worker

# Status
nssm status authentik-server
nssm status authentik-worker

# Edit service settings interactively
nssm edit authentik-server

# Remove service
nssm stop authentik-server
nssm remove authentik-server confirm
nssm stop authentik-worker
nssm remove authentik-worker confirm
```

Logs are written to `C:\authentik\logs\` by default. You can also view events in **Windows Event Viewer** under `Windows Logs > Application`.

## Port Reference

| Port | Protocol | Purpose |
|---|---|---|
| 9000 | TCP | HTTP — Web UI and API |
| 9443 | TCP | HTTPS — Web UI and API (TLS) |
| 3389 | TCP | LDAP (embedded outpost, optional) |
| 6636 | TCP | LDAPS (embedded outpost, optional) |
| 9300 | TCP | Prometheus metrics (internal only) |

## Health Check

Authentik exposes a health endpoint for load balancers and uptime monitors:

```bash
curl http://localhost:9000/-/health/ready/
# Returns HTTP 200 when healthy

curl http://localhost:9000/-/health/live/
# Returns HTTP 200 when the server is alive
```

## Prometheus Metrics

If `AUTHENTIK_LISTEN__METRICS` is set (default `0.0.0.0:9300`), metrics are available at:

```
http://localhost:9300/metrics
```

Restrict this endpoint to internal/monitoring networks via firewall rules or reverse proxy ACLs.
