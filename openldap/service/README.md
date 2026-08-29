# OpenLDAP Service Management

This document describes how to manage the OpenLDAP (`slapd`) service across supported init systems.

---

## Service Files

| Init System | File | Target Path |
|-------------|------|-------------|
| systemd | `systemd/slapd.service` | `/etc/systemd/system/slapd.service` |
| OpenRC | `openrc/slapd` | `/etc/init.d/slapd` |
| SysVinit | `sysvinit/slapd` | `/etc/init.d/slapd` |
| Windows (NSSM) | `windows/slapd.nssm` | Reference script for `nssm` commands |

---

## systemd

### Install

```bash
sudo cp service/systemd/slapd.service /etc/systemd/system/slapd.service
sudo systemctl daemon-reload
sudo systemctl enable --now slapd
```

### Commands

```bash
# Start / stop / restart
sudo systemctl start slapd
sudo systemctl stop slapd
sudo systemctl restart slapd
sudo systemctl reload slapd      # Re-reads slapd.conf (HUP signal)

# Enable / disable at boot
sudo systemctl enable slapd
sudo systemctl disable slapd

# Status and logs
sudo systemctl status slapd
journalctl -u slapd -f           # Follow live logs
journalctl -u slapd --since today
journalctl -u slapd -n 100       # Last 100 lines
```

### Environment Override

The systemd unit reads environment variables from `/etc/default/slapd` (Debian) or `/etc/sysconfig/slapd` (RHEL). Create the file if it does not exist:

```bash
# /etc/default/slapd or /etc/sysconfig/slapd
SLAPD_CONF=/etc/openldap/slapd.conf
SLAPD_URLS="ldap:/// ldaps:///"
SLAPD_OPTIONS=""
```

To apply changes without modifying the unit file:

```bash
sudo systemctl edit slapd   # Creates /etc/systemd/system/slapd.service.d/override.conf
```

---

## OpenRC

### Install

```bash
sudo cp service/openrc/slapd /etc/init.d/slapd
sudo chmod +x /etc/init.d/slapd
sudo rc-update add slapd default
sudo rc-service slapd start
```

### Commands

```bash
# Start / stop / restart
sudo rc-service slapd start
sudo rc-service slapd stop
sudo rc-service slapd restart

# Enable / disable at boot
sudo rc-update add slapd default
sudo rc-update del slapd default

# Status
sudo rc-service slapd status

# Logs
tail -f /var/log/slapd.log
```

---

## SysVinit

### Install

```bash
sudo cp service/sysvinit/slapd /etc/init.d/slapd
sudo chmod +x /etc/init.d/slapd

# Debian/Ubuntu
sudo update-rc.d slapd defaults

# RHEL/CentOS
sudo chkconfig slapd on

sudo service slapd start
```

### Commands

```bash
# Start / stop / restart
sudo service slapd start
sudo service slapd stop
sudo service slapd restart

# Status
sudo service slapd status

# Logs
tail -f /var/log/slapd.log
```

---

## Windows (NSSM)

NSSM (Non-Sucking Service Manager) is required to run slapd as a Windows service.  
Download from [https://nssm.cc/download](https://nssm.cc/download).

### Install

```powershell
# Run the commands in slapd.nssm or execute manually:
nssm install slapd "C:\openldap\libexec\slapd.exe" "-f C:\openldap\etc\openldap\slapd.conf -h ldap:///"
nssm set slapd AppDirectory "C:\openldap"
nssm set slapd Description "OpenLDAP Directory Service (slapd)"
nssm set slapd Start SERVICE_AUTO_START
nssm set slapd AppStdout "C:\openldap\logs\slapd.log"
nssm set slapd AppStderr "C:\openldap\logs\slapd-error.log"
nssm start slapd
```

### Commands

```powershell
# Start / stop / restart
nssm start slapd
nssm stop slapd
nssm restart slapd

# Status
nssm status slapd
sc query slapd

# Logs
Get-Content "C:\openldap\logs\slapd.log" -Wait

# Remove service
nssm stop slapd
nssm remove slapd confirm
```

---

## Testing the Service

After starting slapd, verify it is running and accepting connections:

```bash
# Check listening ports (Linux)
ss -tlnp | grep ':389\|:636'

# Anonymous bind — should return the base object
ldapsearch -x -H ldap://localhost -b "dc=example,dc=com" -s base

# Authenticated bind
ldapsearch -x -D "cn=Manager,dc=example,dc=com" -W \
  -H ldap://localhost -b "dc=example,dc=com" "(objectClass=*)"

# Test LDAPS
ldapsearch -x -H ldaps://localhost -b "dc=example,dc=com" -s base \
  -o TLS_REQCERT=never

# Test with ldapwhoami
ldapwhoami -x -H ldap://localhost
ldapwhoami -x -D "cn=Manager,dc=example,dc=com" -W -H ldap://localhost
```

---

## Common Operational Tasks

### Reload Configuration (without restart)

```bash
# systemd (sends SIGHUP)
sudo systemctl reload slapd

# Or directly
sudo kill -HUP $(cat /var/run/openldap/slapd.pid)
```

Note: OLC (cn=config) changes are applied live; `slapd.conf` changes require a restart.

### Backup the Database

```bash
# Dump to LDIF
sudo -u ldap slapcat -l /tmp/backup-$(date +%Y%m%d).ldif

# With database index
sudo -u ldap slapcat -n 1 -l /tmp/backup-$(date +%Y%m%d).ldif
```

### Restore the Database

```bash
# Stop slapd first
sudo systemctl stop slapd

# Clear existing data (destructive!)
sudo rm -rf /var/lib/ldap/*.mdb

# Restore from LDIF
sudo -u ldap slapadd -n 1 -l /tmp/backup.ldif

# Restart slapd
sudo systemctl start slapd
```

### Check Configuration Syntax

```bash
# Test slapd.conf for syntax errors
sudo slaptest -f /etc/openldap/slapd.conf

# Test OLC configuration
sudo slaptest -F /etc/openldap/slapd.d
```

### Change Root Password

```bash
# Generate new hash
slappasswd -h {SSHA}

# Update slapd.conf rootpw directive, then restart:
sudo systemctl restart slapd

# Or via ldappasswd (live, no restart):
ldappasswd -H ldap://localhost -x -D "cn=Manager,dc=example,dc=com" \
  -W -S "cn=Manager,dc=example,dc=com"
```

### View Active Connections / Monitor

```bash
# Query the monitor backend (if enabled in slapd.conf)
ldapsearch -x -D "cn=Manager,dc=example,dc=com" -W \
  -H ldap://localhost -b "cn=Monitor" "(objectClass=*)"
```

---

## Troubleshooting

| Symptom | Likely Cause | Resolution |
|---------|-------------|------------|
| `slapd` fails to start | Config syntax error | Run `slaptest -f /etc/openldap/slapd.conf` |
| `Connection refused` on port 389 | slapd not running or wrong URLS | Check `SLAPD_URLS`, check `systemctl status slapd` |
| `Invalid credentials (49)` | Wrong rootpw or bind DN | Re-generate with `slappasswd`, check rootdn |
| `Insufficient access (50)` | ACL denying access | Review ACL rules in `slapd.conf` |
| Database corruption | Unclean shutdown | Run `sudo -u ldap slapindex -n 1` to rebuild indexes |
| TLS handshake failure | Cert mismatch or wrong CA | Verify cert paths, check with `openssl s_client -connect localhost:636` |
| `No such object (32)` | Base DN not found in database | Load base LDIF with `ldapadd` |

---

## Resources

- [OpenLDAP Administrator's Guide](https://www.openldap.org/doc/admin26/)
- [slapd(8)](https://www.openldap.org/software/man.cgi?query=slapd)
- [ldapsearch(1)](https://www.openldap.org/software/man.cgi?query=ldapsearch)
- [slapcat(8)](https://www.openldap.org/software/man.cgi?query=slapcat)
- [NSSM](https://nssm.cc/)
