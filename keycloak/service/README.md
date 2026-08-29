# Keycloak Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start keycloak

# Stop
sudo systemctl stop keycloak

# Restart
sudo systemctl restart keycloak

# Enable on boot
sudo systemctl enable keycloak

# Disable on boot
sudo systemctl disable keycloak

# Check status
sudo systemctl status keycloak

# View logs (follow)
journalctl -u keycloak -f

# View logs (last 100 lines)
journalctl -u keycloak -n 100 --no-pager
```

---

## OpenRC (Alpine / Gentoo)

```bash
# Start
sudo rc-service keycloak start

# Stop
sudo rc-service keycloak stop

# Restart
sudo rc-service keycloak restart

# Enable on boot
sudo rc-update add keycloak default

# Disable on boot
sudo rc-update del keycloak default

# Check status
sudo rc-service keycloak status

# View logs
tail -f /var/log/keycloak/keycloak.log
```

---

## SysVinit (Legacy Linux)

```bash
# Start
sudo service keycloak start

# Stop
sudo service keycloak stop

# Restart
sudo service keycloak restart

# Check status
sudo service keycloak status

# View logs
tail -f /var/log/keycloak/keycloak.log
```

---

## Windows (NSSM)

```powershell
# Install (run keycloak.nssm script first)
# Then manage with:

# Start
nssm start keycloak

# Stop
nssm stop keycloak

# Restart
nssm restart keycloak

# Check status
nssm status keycloak

# Edit service settings
nssm edit keycloak

# Remove service
nssm remove keycloak confirm
```

---

## Health Checks

Keycloak exposes health endpoints when `health-enabled=true`:

```bash
# Overall health
curl http://localhost:8080/health

# Liveness probe
curl http://localhost:8080/health/live

# Readiness probe
curl http://localhost:8080/health/ready
```

Expected responses:

```json
{"status":"UP","checks":[]}
```

---

## Metrics

When `metrics-enabled=true`, Prometheus metrics are available at:

```bash
curl http://localhost:8080/metrics
```

---

## Admin CLI (kcadm.sh)

Keycloak ships with a CLI tool for administrative tasks:

```bash
# Login
/opt/keycloak/bin/kcadm.sh config credentials \
    --server http://localhost:8080 \
    --realm master \
    --user admin \
    --password <password>

# List realms
/opt/keycloak/bin/kcadm.sh get realms

# Create realm
/opt/keycloak/bin/kcadm.sh create realms \
    -s realm=myrealm \
    -s enabled=true

# Create user
/opt/keycloak/bin/kcadm.sh create users \
    -r myrealm \
    -s username=myuser \
    -s enabled=true

# Set user password
/opt/keycloak/bin/kcadm.sh set-password \
    -r myrealm \
    --username myuser \
    --new-password <password>
```

---

## Configuration Rebuild

Certain changes to `keycloak.conf` (database vendor, HTTP mode, features) are **build-time** options and require re-running the build step before they take effect:

```bash
sudo -u keycloak /opt/keycloak/bin/kc.sh build
sudo systemctl restart keycloak
```

Runtime options (log level, hostname) only require a service restart.

---

## Log Locations

| Init System | Log Location |
|-------------|-------------|
| systemd | `journalctl -u keycloak` |
| OpenRC | `/var/log/keycloak/keycloak.log` |
| SysVinit | `/var/log/keycloak/keycloak.log` |
| Windows | `C:\keycloak\logs\keycloak-out.log` |
