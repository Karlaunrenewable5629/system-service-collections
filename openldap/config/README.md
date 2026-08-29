# OpenLDAP Configuration

This directory contains the OpenLDAP (`slapd`) configuration template and documentation.

OpenLDAP supports two configuration methods:

- **slapd.conf** — Classic flat-file configuration (static, requires restart on changes).
- **OLC (Online Configuration / cn=config)** — LDAP-based dynamic configuration (live changes, no restart needed). Recommended for production.

The template provided here uses `slapd.conf` for simplicity and portability.

---

## Files

| File | Description |
|------|-------------|
| `slapd.conf` | Template slapd configuration file |

---

## slapd.conf Configuration Reference

### Global Settings

| Directive | Default | Description |
|-----------|---------|-------------|
| `include` | — | Path to schema file to include (repeat for each schema). |
| `pidfile` | `/var/run/openldap/slapd.pid` | Path to the PID file written on startup. |
| `argsfile` | `/var/run/openldap/slapd.args` | Path to the args file written on startup. |
| `loglevel` | `0` | Logging verbosity. `0` = none, `256` = stats, `32768` = debug (see table below). |
| `modulepath` | `/usr/lib/openldap` | Directory containing loadable modules. |
| `modulload` | — | Name of a module to load (e.g., `back_mdb`). |

### TLS / SSL Settings

| Directive | Default | Description |
|-----------|---------|-------------|
| `TLSCACertificateFile` | — | Path to PEM-encoded CA certificate. |
| `TLSCertificateFile` | — | Path to PEM-encoded server certificate. |
| `TLSCertificateKeyFile` | — | Path to PEM-encoded private key. |
| `TLSCipherSuite` | — | OpenSSL cipher string (e.g., `HIGH:MEDIUM:+SSLv3`). |
| `TLSVerifyClient` | `never` | Client certificate verification: `never`, `allow`, `try`, `demand`. |

### Database (Backend) Settings

| Directive | Default | Description |
|-----------|---------|-------------|
| `database` | `mdb` | Storage backend type. `mdb` (LMDB) is the recommended modern backend. |
| `suffix` | — | DN suffix for this database (e.g., `dc=example,dc=com`). |
| `rootdn` | — | Distinguished name of the database administrator. |
| `rootpw` | — | Password for the rootdn. Use a hashed value (see below). |
| `directory` | `/var/lib/ldap` | Filesystem directory where the database files are stored. |
| `maxsize` | `1073741824` | Maximum LMDB database size in bytes (default 1 GB). |
| `index` | — | Defines indexes on attributes (e.g., `index objectClass eq`). |
| `readonly` | `off` | Set to `on` to make the database read-only. |
| `checkpoint` | — | Checkpoint interval: `<kbytes> <minutes>` (MDB ignores kbytes). |

### Access Control (ACL)

| Directive | Example | Description |
|-----------|---------|-------------|
| `access to` | `access to * by * read` | Defines access rules. Evaluated top-to-bottom; first match wins. |

ACL syntax:

```
access to <what>
  by <who> <access> [control]
```

Common `<access>` levels: `none`, `disclose`, `auth`, `compare`, `search`, `read`, `write`, `manage`.

### Logging Levels

| Level (decimal) | Keyword | Description |
|-----------------|---------|-------------|
| `0` | — | No logging |
| `1` | `trace` | Trace function calls |
| `2` | `packets` | Debug packet handling |
| `4` | `args` | Heavy trace debugging |
| `32` | `filter` | Search filter processing |
| `64` | `config` | Configuration file processing |
| `128` | `acl` | Access control list processing |
| `256` | `stats` | Connection, operation, and result statistics (recommended) |
| `512` | `stats2` | Also log entries sent |
| `32768` | `none` | Log only messages with loglevel set |
| `-1` | — | Enable all logging |

### Overlay Directives

Overlays extend slapd functionality and are configured within a `database` block.

| Overlay | Description |
|---------|-------------|
| `ppolicy` | Password policy enforcement (expiry, lockout, quality). |
| `memberof` | Automatically maintains `memberOf` attribute on entries. |
| `auditlog` | Logs all write operations to a file. |
| `unique` | Enforces attribute uniqueness within a subtree. |
| `refint` | Maintains referential integrity between attributes. |
| `syncprov` | Sync Provider — required on the provider side for replication. |
| `accesslog` | Logs LDAP operations to a secondary database. |

Example:

```
overlay memberof
memberof-dangling ignore
memberof-refint TRUE
memberof-group-oc groupOfNames
memberof-member-ad member
memberof-memberof-ad memberOf
```

### Replication (Syncrepl)

Consumer-side replication directive placed inside the `database` block:

```
syncrepl rid=001
  provider=ldap://provider.example.com:389
  type=refreshAndPersist
  retry="5 5 300 5"
  searchbase="dc=example,dc=com"
  attrs="*,+"
  bindmethod=simple
  binddn="cn=replicator,dc=example,dc=com"
  credentials=secret
  tls_reqcert=demand
```

---

## Generating a Password Hash

Use `slappasswd` to generate a hashed password for `rootpw`:

```bash
slappasswd -h {SSHA}
# Enter password at prompt — outputs: {SSHA}...
```

Supported schemes: `{SSHA}`, `{SHA}`, `{MD5}`, `{CRYPT}`, `{CLEARTEXT}`.

---

## OLC (cn=config) vs slapd.conf

| Feature | slapd.conf | OLC (cn=config) |
|---------|-----------|-----------------|
| Format | Plain text file | LDIF entries in LDAP |
| Changes | Require restart | Applied live |
| Tooling | Text editor | `ldapmodify`, `ldapadd` |
| Migration | `slaptest -f slapd.conf -F /etc/ldap/slapd.d` | — |
| Recommended for | Testing / simple setups | Production |

To convert `slapd.conf` to OLC:

```bash
sudo mkdir -p /etc/ldap/slapd.d
sudo slaptest -f /etc/openldap/slapd.conf -F /etc/ldap/slapd.d
sudo chown -R ldap:ldap /etc/ldap/slapd.d
```

---

## Environment Variables (systemd / OpenRC)

When using the service unit, these environment variables can be set in the environment file (e.g., `/etc/default/slapd` or `/etc/sysconfig/slapd`):

| Variable | Default | Description |
|----------|---------|-------------|
| `SLAPD_CONF` | `/etc/openldap/slapd.conf` | Path to configuration file or OLC directory. |
| `SLAPD_URLS` | `ldap:/// ldaps:///` | Space-separated list of URLs slapd should listen on. |
| `SLAPD_OPTIONS` | — | Additional command-line options passed to slapd. |
| `SLAPD_USER` | `ldap` | System user to run slapd as. |
| `SLAPD_GROUP` | `ldap` | System group to run slapd as. |

---

## Resources

- [OpenLDAP Administrator's Guide](https://www.openldap.org/doc/admin26/)
- [slapd.conf(5) man page](https://www.openldap.org/software/man.cgi?query=slapd.conf)
- [slapd-mdb(5) man page](https://www.openldap.org/software/man.cgi?query=slapd-mdb)
- [Access Control](https://www.openldap.org/doc/admin26/access-control.html)
