# FreeIPA Installation Guide

This guide covers installing FreeIPA server on RHEL-compatible Linux distributions.

## Supported Platforms

| Distribution | Version | Notes |
|---|---|---|
| RHEL | 8, 9 | Officially supported |
| CentOS Stream | 8, 9 | Community supported |
| Rocky Linux | 8, 9 | Community supported |
| AlmaLinux | 8, 9 | Community supported |
| Fedora | 38+ | Latest features, shorter lifecycle |

> FreeIPA **cannot** be installed on Windows, macOS, or non-RHEL Linux distributions. Debian/Ubuntu support is unofficial and limited to client tools only.

## System Requirements

| Resource | Minimum | Recommended |
|---|---|---|
| CPU | 2 cores | 4 cores |
| RAM | 2 GB | 4 GB |
| Disk | 10 GB | 50 GB (for CA/logs) |
| OS | 64-bit only | RHEL 9 preferred |

## Prerequisites

Before running the installer:

1. **Set a fully qualified hostname** — Kerberos and TLS depend on a proper FQDN:
   ```bash
   sudo hostnamectl set-hostname ipa.example.com
   ```

2. **Verify the FQDN resolves correctly** — both forward and reverse DNS should work:
   ```bash
   hostname -f                         # should return the full FQDN
   dig +short ipa.example.com          # should return the server's IP
   dig +short -x <server-ip>           # should return ipa.example.com
   ```

3. **Synchronise the system clock** — Kerberos tolerates at most 5 minutes of clock skew:
   ```bash
   sudo dnf install -y chrony
   sudo systemctl enable --now chronyd
   chronyc tracking
   ```

4. **Disable or configure the firewall** — see [Firewall Configuration](#firewall-configuration).

5. **Ensure SELinux is enforcing or permissive** (not disabled):
   ```bash
   getenforce      # Enforcing or Permissive is fine
   ```

## Installation

### Interactive Installation (Recommended)

```bash
# Make the script executable
chmod +x install.sh

# Run as root
sudo bash install.sh
```

The script will:
- Verify the OS is supported
- Run pre-flight checks (RAM, hostname, ports, NTP)
- Install `freeipa-server` and `freeipa-server-dns`
- Configure firewall rules (firewalld or ufw)
- Launch `ipa-server-install` interactively

### Unattended Installation

Set environment variables then run with `--unattended`:

```bash
export IPA_REALM="EXAMPLE.COM"         # Kerberos realm (uppercase domain)
export IPA_DOMAIN="example.com"        # DNS domain
export IPA_HOSTNAME="ipa.example.com"  # FQDN of this server
export IPA_ADMIN_PASS="Admin1234!"     # IPA admin account password
export IPA_DM_PASS="DMpass1234!"       # Directory Manager (LDAP root) password
export IPA_SETUP_DNS="yes"             # Configure BIND DNS (yes/no)
export IPA_FORWARDER="8.8.8.8"        # Upstream DNS forwarder

sudo -E bash install.sh --unattended
```

### Manual Installation

If you prefer to run `ipa-server-install` directly:

```bash
# 1. Install packages
sudo dnf install -y freeipa-server freeipa-server-dns

# 2. Basic server setup (no DNS)
sudo ipa-server-install \
  --realm=EXAMPLE.COM \
  --domain=example.com \
  --ds-password="<directory-manager-password>" \
  --admin-password="<admin-password>" \
  --mkhomedir \
  --unattended

# 3. With integrated DNS
sudo ipa-server-install \
  --realm=EXAMPLE.COM \
  --domain=example.com \
  --ds-password="<directory-manager-password>" \
  --admin-password="<admin-password>" \
  --setup-dns \
  --forwarder=8.8.8.8 \
  --auto-reverse \
  --unattended
```

> The `ipa-server-install` command takes 5–15 minutes. Do not interrupt it.

## Firewall Configuration

### firewalld (RHEL 8/9 default)

```bash
sudo firewall-cmd --permanent --add-service=freeipa-ldap
sudo firewall-cmd --permanent --add-service=freeipa-ldaps
sudo firewall-cmd --permanent --add-service=freeipa-replication
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=88/tcp
sudo firewall-cmd --permanent --add-port=88/udp
sudo firewall-cmd --permanent --add-port=464/tcp
sudo firewall-cmd --permanent --add-port=464/udp
sudo firewall-cmd --reload
```

### iptables (manual)

```bash
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 389 -j ACCEPT
iptables -A INPUT -p tcp --dport 636 -j ACCEPT
iptables -A INPUT -p tcp --dport 88 -j ACCEPT
iptables -A INPUT -p udp --dport 88 -j ACCEPT
iptables -A INPUT -p tcp --dport 464 -j ACCEPT
iptables -A INPUT -p udp --dport 464 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
```

## Post-Installation

### Access the Web UI

Open a browser and navigate to:

```
https://ipa.example.com/ipa/ui
```

Log in with username `admin` and the admin password set during installation.

### Get a Kerberos Ticket

```bash
kinit admin
ipa user-find    # list all users
ipa host-find    # list all enrolled hosts
```

### Enable the Service at Boot

```bash
sudo systemctl enable ipa
sudo systemctl status ipa
```

### Enroll a Linux Client

On the client machine:

```bash
sudo dnf install -y freeipa-client
sudo ipa-client-install \
  --domain=example.com \
  --server=ipa.example.com \
  --mkhomedir \
  --principal=admin
```

## Installing a Replica

To add a second IPA server for high availability:

```bash
# On the replica host (after enrolling as an IPA client):
sudo dnf install -y freeipa-server freeipa-server-dns

# Promote the client to a replica
sudo ipa-replica-install \
  --setup-ca \
  --setup-dns \
  --forwarder=8.8.8.8 \
  --principal=admin
```

## Verifying the Installation

```bash
# Check all IPA services are running
sudo ipactl status

# Verify Kerberos authentication
kinit admin
klist

# Verify LDAP is reachable
ldapsearch -x -H ldap://localhost -b "dc=example,dc=com" -D "cn=Directory Manager" -W

# Check the CA
ipa-getcert list

# Run the IPA health check tool (RHEL 8+)
sudo ipa-healthcheck
```

## Troubleshooting

| Problem | Resolution |
|---|---|
| `ipa-server-install` fails with clock skew error | Run `chronyc makestep` and retry |
| Port 53 conflict with systemd-resolved | Disable `systemd-resolved` or configure stub listener |
| SELinux AVCs during installation | Run in permissive mode, collect AVCs, or check Bugzilla |
| `ipactl status` shows a service down | Check the specific service log under `/var/log/` |
| Web UI returns 503 | `httpd` or Dogtag CA not running; check `journalctl -u httpd` |

Log locations:

```
/var/log/ipaserver-install.log     # ipa-server-install output
/var/log/dirsrv/slapd-<REALM>/    # 389 Directory Server logs
/var/log/krb5kdc.log               # Kerberos KDC log
/var/log/httpd/                    # Apache log (Web UI)
/var/log/pki/pki-tomcat/           # Dogtag CA log
/var/log/named/                    # BIND DNS log (if DNS enabled)
```

## References

- [FreeIPA Quick Start Guide](https://www.freeipa.org/page/Quick_Start_Guide)
- [FreeIPA Installation Guide (Red Hat)](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/installing_identity_management/)
- [ipa-server-install(1) man page](https://www.freeipa.org/page/Man_pages)
- [FreeIPA GitHub](https://github.com/freeipa/freeipa)
