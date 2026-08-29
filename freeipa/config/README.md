# FreeIPA Configuration

This directory contains configuration templates and documentation for FreeIPA server.

## Configuration Files

| File | Description |
|------|-------------|
| `ipa-default.conf` | Default IPA client/server configuration template (`/etc/ipa/default.conf`) |

## Primary Configuration Locations

FreeIPA stores its configuration across several system paths after installation:

| Path | Description |
|------|-------------|
| `/etc/ipa/default.conf` | Main IPA client and server defaults |
| `/etc/ipa/server.conf` | Server-specific overrides |
| `/etc/ipa/ca.conf` | CA subsystem configuration |
| `/etc/dirsrv/slapd-<REALM>/` | 389 Directory Server instance config |
| `/etc/krb5.conf` | MIT Kerberos configuration |
| `/etc/named.conf` | BIND DNS configuration (if DNS is enabled) |
| `/etc/httpd/conf.d/ipa.conf` | Apache HTTPD configuration for the web UI |
| `/var/lib/ipa/` | IPA runtime data, CA certs, and LDIF files |

## Key Configuration Parameters

### `/etc/ipa/default.conf`

The primary client/server configuration file. The most important fields are:

| Parameter | Description | Example |
|-----------|-------------|---------|
| `basedn` | LDAP base DN derived from the domain | `dc=example,dc=com` |
| `realm` | Kerberos realm (uppercase domain) | `EXAMPLE.COM` |
| `domain` | DNS domain name | `example.com` |
| `server` | IPA server FQDN | `ipa.example.com` |
| `host` | This host's FQDN | `ipa.example.com` |
| `xmlrpc_uri` | XMLRPC API endpoint | `https://ipa.example.com/ipa/xml` |
| `enable_ra` | Whether to use the built-in CA | `True` |
| `ra_plugin` | CA plugin backend | `dogtag` |
| `mode` | IPA operational mode | `production` |

### Kerberos (`/etc/krb5.conf`)

Critical Kerberos settings managed by IPA:

```ini
[libdefaults]
 default_realm = EXAMPLE.COM
 dns_lookup_realm = true
 dns_lookup_kdc = true
 rdns = false
 ticket_lifetime = 24h
 forwardable = true
```

### Directory Server

The 389 DS instance is named after the realm (e.g., `slapd-EXAMPLE-COM`). Key tuning parameters are set in:

- `/etc/dirsrv/slapd-EXAMPLE-COM/dse.ldif` — main DS configuration
- `/etc/sysconfig/dirsrv` — startup environment variables

Important DS tuning variables:

```bash
# /etc/sysconfig/dirsrv
MEMLOCK=unlimited
KRB5CCNAME=/run/dirsrv/krb5cc_dirsrv
```

### DNS (`/etc/named.conf`)

If IPA manages DNS, BIND is configured automatically. Key options:

```ini
options {
    listen-on-v6 { any; };
    directory "/var/named";
    allow-recursion { 127.0.0.1; };
    tkey-gssapi-keytab "/etc/named.keytab";
};
```

## Environment Variables

These environment variables influence IPA behaviour at runtime:

| Variable | Description |
|----------|-------------|
| `KRB5_CONFIG` | Path to the Kerberos config file (default: `/etc/krb5.conf`) |
| `KRB5CCNAME` | Kerberos credentials cache location |
| `IPA_CONFDIR` | Override IPA config directory (default: `/etc/ipa`) |
| `LDAPTLS_CACERT` | CA certificate used for LDAP TLS connections |

## Port Reference

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 80   | TCP | HTTP | Web UI redirect and ACME |
| 443  | TCP | HTTPS | Web UI and API |
| 389  | TCP | LDAP | Directory server (plain/STARTTLS) |
| 636  | TCP | LDAPS | Directory server (TLS) |
| 88   | TCP/UDP | Kerberos | KDC authentication |
| 464  | TCP/UDP | kpasswd | Kerberos password change |
| 53   | TCP/UDP | DNS | Name resolution (if DNS enabled) |

## CA Certificate

The IPA CA certificate is installed at:

```
/etc/ipa/ca.crt
```

Distribute this certificate to all clients that need to trust the IPA CA:

```bash
# On a client, after enrollment:
certutil -L -d /etc/dirsrv/slapd-<REALM>/
```

## Configuration Reload

Most IPA configuration changes are applied through the `ipa` CLI or Web UI and do not require manual file edits. After editing low-level files:

```bash
# Restart all IPA services
sudo ipactl restart

# Or restart individual components
sudo systemctl restart dirsrv@EXAMPLE-COM
sudo systemctl restart krb5kdc
sudo systemctl restart httpd
```

## Security Hardening

- Restrict access to `/etc/ipa/` — it contains sensitive keytab references.
- Use strong passwords for the Directory Manager and admin accounts (minimum 8 characters, mixed case + digits + symbols).
- Enable audit logging in 389 DS for compliance environments.
- Rotate service keytabs regularly using `ipa-getkeytab`.
- Consider enabling FIPS mode on the host before installing FreeIPA for FIPS 140-2 compliance.

## References

- [FreeIPA Configuration Guide](https://www.freeipa.org/page/Documentation)
- [389 Directory Server Admin Guide](https://www.port389.org/docs/389ds/documentation.html)
- [MIT Kerberos Documentation](https://web.mit.edu/kerberos/krb5-latest/doc/)
