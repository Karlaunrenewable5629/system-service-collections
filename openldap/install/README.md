# OpenLDAP Installation Guide

This guide covers installing OpenLDAP (`slapd`) on Linux distributions and Windows.

---

## Prerequisites

- Root or sudo privileges
- Ports `389` (LDAP) and `636` (LDAPS) available
- Sufficient disk space for the database directory (default: `/var/lib/ldap`)

---

## Automated Installation (Linux)

The `install.sh` script handles package installation, user/directory setup, and service configuration.

```bash
# Clone or copy the openldap service directory, then:
cd openldap/install
chmod +x install.sh
sudo ./install.sh
```

After installation, copy and edit the configuration:

```bash
sudo cp ../config/slapd.conf /etc/openldap/slapd.conf
# Edit the suffix, rootdn, rootpw, and TLS settings
sudo nano /etc/openldap/slapd.conf
```

---

## Manual Installation

### Debian / Ubuntu

```bash
# Install packages
sudo apt-get update
sudo apt-get install -y slapd ldap-utils

# During install, you are prompted to set an admin password.
# To reconfigure later:
sudo dpkg-reconfigure slapd

# Install additional schema tools (optional)
sudo apt-get install -y schema2ldif

# Verify installation
slapd -VV
```

On Debian/Ubuntu, the default configuration uses OLC (`cn=config`) located at `/etc/ldap/slapd.d/`.

### RHEL / CentOS / AlmaLinux / Rocky Linux

```bash
# Enable required repos (RHEL 8+ uses openldap-servers from extras/powertools)
# For RHEL/CentOS 8+:
sudo dnf install -y openldap openldap-servers openldap-clients

# For RHEL/CentOS 7:
sudo yum install -y openldap openldap-servers openldap-clients

# Start and enable slapd
sudo systemctl enable --now slapd

# Verify
slapd -VV
```

On RHEL-based distros, the default config file is `/etc/openldap/slapd.conf` or OLC at `/etc/openldap/slapd.d/`.

### Alpine Linux

```bash
apk add openldap openldap-back-mdb openldap-clients
addgroup -S ldap
adduser -S -G ldap -H -h /var/lib/openldap ldap
mkdir -p /var/lib/openldap/openldap-data /var/run/openldap
chown ldap:ldap /var/lib/openldap/openldap-data /var/run/openldap
```

### Arch Linux

```bash
sudo pacman -S openldap
sudo systemctl enable --now slapd
```

---

## Initial Directory Setup

After installing and configuring `slapd.conf`, populate the base structure using LDIF files.

### Generate the Root Password

```bash
slappasswd -h {SSHA}
# Copy the output into the rootpw directive in slapd.conf
```

### Create a Base LDIF

```ldif
# base.ldif
dn: dc=example,dc=com
objectClass: top
objectClass: dcObject
objectClass: organization
o: Example Organization
dc: example

dn: ou=users,dc=example,dc=com
objectClass: top
objectClass: organizationalUnit
ou: users

dn: ou=groups,dc=example,dc=com
objectClass: top
objectClass: organizationalUnit
ou: groups
```

### Load the Base LDIF

```bash
# After slapd is running:
ldapadd -x -D "cn=Manager,dc=example,dc=com" -W -f base.ldif
```

---

## TLS / LDAPS Setup

### Generate a Self-Signed Certificate (for testing)

```bash
sudo mkdir -p /etc/openldap/tls
sudo openssl req -x509 -nodes -newkey rsa:4096 -keyout /etc/openldap/tls/slapd.key \
  -out /etc/openldap/tls/slapd.crt -days 365 \
  -subj "/CN=ldap.example.com/O=Example Org/C=US"
sudo cp /etc/openldap/tls/slapd.crt /etc/openldap/tls/ca.crt
sudo chown -R ldap:ldap /etc/openldap/tls
sudo chmod 600 /etc/openldap/tls/slapd.key
```

Then uncomment the TLS directives in `slapd.conf` and restart slapd.

### Start slapd Listening on Both Ports

```bash
# In /etc/sysconfig/slapd or /etc/default/slapd:
SLAPD_URLS="ldap:/// ldaps:///"
```

---

## Firewall Configuration

### firewalld (RHEL / Fedora)

```bash
sudo firewall-cmd --add-service=ldap --permanent
sudo firewall-cmd --add-service=ldaps --permanent
sudo firewall-cmd --reload
```

### UFW (Debian / Ubuntu)

```bash
sudo ufw allow 389/tcp
sudo ufw allow 636/tcp
```

### iptables

```bash
sudo iptables -A INPUT -p tcp --dport 389 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 636 -j ACCEPT
```

---

## Windows Installation

OpenLDAP is primarily a Linux/Unix tool. For Windows, the recommended approach is to use the OpenLDAP port maintained by the community:

1. Download the OpenLDAP for Windows build from [https://openldap.org/](https://openldap.org/) or a trusted distribution.
2. Extract to `C:\openldap\`.
3. Edit `C:\openldap\etc\openldap\slapd.conf`.
4. Install as a Windows service using NSSM:

```powershell
# Install NSSM from https://nssm.cc/download
nssm install slapd "C:\openldap\libexec\slapd.exe" "-f C:\openldap\etc\openldap\slapd.conf -h ldap:///"
nssm set slapd AppDirectory "C:\openldap"
nssm set slapd Description "OpenLDAP Directory Service"
nssm set slapd Start SERVICE_AUTO_START
nssm start slapd
```

For production Windows directory services, consider **Active Directory** or **Windows Server ADLDS**.

---

## Verifying the Installation

```bash
# Check slapd is running
sudo systemctl status slapd

# Test an anonymous bind (should return the base DN)
ldapsearch -x -H ldap://localhost -b "dc=example,dc=com" -s base

# Test authenticated bind
ldapsearch -x -D "cn=Manager,dc=example,dc=com" -W -H ldap://localhost \
  -b "dc=example,dc=com" "(objectClass=*)"

# Test LDAPS (TLS)
ldapsearch -x -H ldaps://localhost -b "dc=example,dc=com" -s base

# Check listening ports
ss -tlnp | grep slapd
```

---

## Post-Installation

1. Edit `/etc/openldap/slapd.conf` — set your `suffix`, `rootdn`, and `rootpw`.
2. Ensure the database directory exists and is owned by the `ldap` user:
   ```bash
   sudo mkdir -p /var/lib/ldap
   sudo chown ldap:ldap /var/lib/ldap
   sudo chmod 700 /var/lib/ldap
   ```
3. Enable and start the service:
   ```bash
   sudo systemctl enable --now slapd
   ```
4. Load your initial LDIF data.
5. Configure client tools in `/etc/openldap/ldap.conf`.

---

## Resources

- [OpenLDAP Administrator's Guide](https://www.openldap.org/doc/admin26/)
- [slapd(8) man page](https://www.openldap.org/software/man.cgi?query=slapd)
- [slapadd(8) — Bulk import](https://www.openldap.org/software/man.cgi?query=slapadd)
- [ldapadd(1)](https://www.openldap.org/software/man.cgi?query=ldapadd)
