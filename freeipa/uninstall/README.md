# FreeIPA Uninstallation Guide

This guide covers removing the FreeIPA server from your system.

> **Warning:** Uninstalling FreeIPA is destructive and irreversible. All identity data — users, groups, Kerberos principals, certificates, DNS zones, and policies — will be permanently deleted.

## Before You Begin

1. **Unenroll all client machines first.** Client machines that remain enrolled will lose authentication once the server is removed.

   On each IPA client host:
   ```bash
   sudo ipa-client-install --uninstall
   ```

2. **Back up data you need to retain.** Export users and groups if you plan to migrate to another directory service:
   ```bash
   # Export all users to LDIF
   ldapsearch -x -H ldap://localhost \
     -D "cn=Directory Manager" -W \
     -b "cn=users,cn=accounts,dc=example,dc=com" \
     > users-backup.ldif

   # Back up the IPA CA certificate
   cp /etc/ipa/ca.crt ~/ipa-ca-backup.crt
   ```

3. **Document your configuration.** Note the realm, domain, admin password, and any custom HBAC or sudo rules you may want to recreate elsewhere.

## Uninstallation

### Using the Uninstall Script

```bash
# Standard uninstall (prompts for confirmation)
sudo bash uninstall.sh

# Skip confirmation prompt
sudo bash uninstall.sh --force

# Remove installed packages after uninstall
sudo bash uninstall.sh --remove-pkgs

# Full purge: uninstall + remove packages + delete residual data directories
sudo bash uninstall.sh --purge
```

### Manual Uninstallation

```bash
# Step 1: Stop all IPA services
sudo ipactl stop

# Step 2: Run the IPA server uninstaller
sudo ipa-server-install --uninstall --unattended

# Step 3: Disable the systemd unit
sudo systemctl disable ipa
sudo systemctl daemon-reload
```

### Remove Packages (Optional)

```bash
# RHEL/CentOS/Fedora (dnf)
sudo dnf remove freeipa-server freeipa-server-dns freeipa-common
sudo dnf autoremove

# RHEL 6 / CentOS 6 (yum)
sudo yum remove freeipa-server freeipa-server-dns freeipa-common
sudo yum autoremove
```

### Remove Residual Data (Optional)

After `ipa-server-install --uninstall`, some directories may remain:

```bash
# IPA configuration and data
sudo rm -rf /etc/ipa
sudo rm -rf /var/lib/ipa
sudo rm -rf /var/log/ipa

# 389 Directory Server data
sudo rm -rf /var/lib/dirsrv
sudo rm -rf /etc/dirsrv
sudo rm -rf /var/log/dirsrv

# Dogtag CA data
sudo rm -rf /etc/pki/pki-tomcat
sudo rm -rf /var/lib/pki
sudo rm -rf /var/log/pki
```

### Restore Firewall Rules

If you added firewall rules during installation, remove them:

```bash
# firewalld
sudo firewall-cmd --permanent --remove-service=freeipa-ldap
sudo firewall-cmd --permanent --remove-service=freeipa-ldaps
sudo firewall-cmd --permanent --remove-service=freeipa-replication
sudo firewall-cmd --permanent --remove-service=dns
sudo firewall-cmd --permanent --remove-port=88/tcp
sudo firewall-cmd --permanent --remove-port=88/udp
sudo firewall-cmd --permanent --remove-port=464/tcp
sudo firewall-cmd --permanent --remove-port=464/udp
sudo firewall-cmd --reload
```

## Verifying Removal

After uninstallation, confirm the server is no longer running:

```bash
# No IPA services should be active
sudo ipactl status 2>&1 || echo "ipactl not found — uninstall complete"

# Confirm the systemd unit is gone or disabled
systemctl status ipa 2>&1

# Confirm ports are no longer bound
ss -tlnp | grep -E ':389|:636|:88|:464|:53'
```

## Uninstalling IPA Replicas

If you have replica servers, uninstall them in reverse order (replicas first, primary last):

```bash
# On each replica server
sudo ipa-server-install --uninstall --unattended

# Remove the replica reference from other servers first (if the replica is still accessible)
kinit admin
ipa-replica-manage del replica.example.com --force
```

## Troubleshooting

| Problem | Resolution |
|---|---|
| `ipa-server-install --uninstall` hangs | Kill it and manually stop `ipactl stop` first |
| Dogtag CA removal fails | Run `pki-server remove --force pki-tomcat` before retrying |
| `dirsrv` instance not removed | `dsctl slapd-<REALM> remove --do-it` |
| Firewall rules remain | Remove manually via `firewall-cmd` as shown above |
| `/etc/krb5.conf` left with IPA settings | Restore from backup: `cp /etc/krb5.conf.ipa_backup /etc/krb5.conf` |

## References

- [FreeIPA Uninstall Documentation](https://www.freeipa.org/page/Uninstalling_a_replica)
- [ipa-server-install(1) man page](https://www.freeipa.org/page/Man_pages)
- [Red Hat Identity Management — Uninstalling an IPA server](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/installing_identity_management/uninstalling-an-ipa-server_installing-identity-management)
