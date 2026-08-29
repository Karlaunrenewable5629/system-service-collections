# FreeIPA Service Management

This directory contains service definitions for managing FreeIPA under different init systems.

## Init System Support

| Init System | File | Support Level |
|-------------|------|---------------|
| systemd | `systemd/ipa.service` | **Primary** — officially supported |
| OpenRC | `openrc/ipa` | Community — not officially supported upstream |
| SysVinit | `sysvinit/ipa` | Legacy — for RHEL 6 / CentOS 6 only |
| Windows (NSSM) | `windows/ipa.nssm` | **Not applicable** — FreeIPA is Linux-only |

> FreeIPA is designed for and tested on RHEL/CentOS/Fedora with systemd. Use the systemd unit unless you have a specific requirement for another init system.

---

## systemd

### Installation

```bash
# The freeipa-server package ships a pre-installed unit; copy only if absent
sudo cp systemd/ipa.service /etc/systemd/system/
sudo systemctl daemon-reload
```

### Managing the Service

```bash
# Start
sudo systemctl start ipa

# Stop
sudo systemctl stop ipa

# Restart
sudo systemctl restart ipa

# Enable at boot
sudo systemctl enable ipa

# Disable at boot
sudo systemctl disable ipa

# Check unit status
sudo systemctl status ipa

# Check all IPA sub-services
sudo ipactl status
```

### Viewing Logs

```bash
# Live log stream
journalctl -u ipa -f

# Last 100 lines
journalctl -u ipa -n 100

# Logs since last boot
journalctl -u ipa -b

# Individual sub-service logs
journalctl -u dirsrv@EXAMPLE-COM -f
journalctl -u krb5kdc -f
journalctl -u httpd -f
```

### How `ipactl` Works

The `ipa.service` systemd unit delegates to `/usr/sbin/ipactl`, which starts and stops each IPA sub-service in the correct dependency order:

1. `dirsrv@<REALM>` — 389 Directory Server (LDAP backend)
2. `krb5kdc` — Kerberos Key Distribution Centre
3. `kadmin` — Kerberos admin service
4. `named` / `named-pkcs11` — BIND DNS (if DNS role is configured)
5. `pki-tomcatd@pki-tomcat` — Dogtag certificate authority
6. `httpd` — Apache web server (Web UI + REST API)
7. `ipa-custodia` — Secret distribution service
8. `ipa-otpd` — OTP/RADIUS proxy
9. `ipa-dnskeysyncd` — DNSSEC key synchronisation (if DNS enabled)

---

## OpenRC

### Installation

```bash
sudo cp openrc/ipa /etc/init.d/ipa
sudo chmod +x /etc/init.d/ipa
```

### Managing the Service

```bash
# Start
sudo rc-service ipa start

# Stop
sudo rc-service ipa stop

# Restart
sudo rc-service ipa restart

# Enable at boot
sudo rc-update add ipa default

# Disable at boot
sudo rc-update del ipa default

# Check status
sudo rc-service ipa status
```

### Viewing Logs

```bash
# OpenRC wrapper log
tail -f /var/log/ipa/openrc-ipa.log

# Individual component logs (if available)
tail -f /var/log/dirsrv/slapd-<REALM>/errors
tail -f /var/log/httpd/error_log
```

---

## SysVinit

### Installation

```bash
sudo cp sysvinit/ipa /etc/init.d/ipa
sudo chmod +x /etc/init.d/ipa

# RHEL/CentOS 6
sudo chkconfig --add ipa
sudo chkconfig ipa on

# Debian/Ubuntu (update-rc.d)
sudo update-rc.d ipa defaults
```

### Managing the Service

```bash
# Start
sudo service ipa start

# Stop
sudo service ipa stop

# Restart
sudo service ipa restart

# Status
sudo service ipa status

# Conditional restart (only if running)
sudo service ipa condrestart
```

### Viewing Logs

```bash
tail -f /var/log/ipa/sysvinit-ipa.log
tail -f /var/log/dirsrv/slapd-<REALM>/errors
```

---

## Windows

FreeIPA **cannot run on Windows**. It depends on Linux-specific daemons (389 Directory Server, MIT Kerberos KDC, BIND, Dogtag CA). See `windows/ipa.nssm` for integration options, including Active Directory trust and LDAP client connectivity.

---

## Useful `ipactl` and `ipa` Commands

```bash
# Check status of all sub-services
sudo ipactl status

# Restart all sub-services
sudo ipactl restart

# Force restart even if a component is not running
sudo ipactl restart --ignore-service-failures

# Get an admin Kerberos ticket
kinit admin

# List all users
ipa user-find

# List all hosts
ipa host-find

# Add a new user
ipa user-add jdoe --first=John --last=Doe --password

# Enroll a new client host
# (run on the client machine)
sudo ipa-client-install --domain=example.com --server=ipa.example.com

# Check replication status (on a replica)
ipa-replica-manage list
ipa-replica-manage status
```

---

## Common Service Issues

| Symptom | Likely Cause | Resolution |
|---------|-------------|------------|
| `ipactl start` fails silently | Clock skew > 5 minutes | Sync NTP: `chronyc makestep` |
| LDAP connection refused | `dirsrv` did not start | Check `/var/log/dirsrv/slapd-<REALM>/errors` |
| Kerberos auth fails | KDC not running | `systemctl status krb5kdc` |
| Web UI unavailable | `httpd` not running | `systemctl status httpd` |
| Certificate errors | CA expired or Dogtag down | Check `pki-tomcatd` status and CA certs |
| DNS resolution broken | `named` crashed | `systemctl status named` and check `/var/log/named/` |

---

## References

- [FreeIPA Service Administration](https://www.freeipa.org/page/Documentation)
- [ipactl(8) man page](https://www.freeipa.org/page/Ipactl)
- [FreeIPA Troubleshooting](https://www.freeipa.org/page/Troubleshooting)
