# Service Management

This guide covers managing the Krakend API Gateway service across different init systems.

## Supported Init Systems

- **OpenRC** (default) — Krakend's native approach
- **systemd** — Standard on most modern Linux distributions
- **SysVinit** — Legacy init system compatibility
- **Windows NSSM** — Windows service via Non-Sucking Service Manager

## OpenRC

### Install and enable

```bash
cp service/openrc/krakend /etc/init.d/krakend
chmod +x /etc/init.d/krakend
rc-update add krakend default
```

### Start / stop / restart

```bash
rc-service krakend start
rc-service krakend stop
rc-service krakend restart
```

### Check status

```bash
rc-service krakend status
```

### View logs

```bash
rc-service krakend --log
# or
logread | grep krakend
```

## systemd

### Install and enable

```bash
cp service/systemd/krakend.service /etc/systemd/system/krakend.service
systemctl daemon-reload
systemctl enable krakend
```

### Start / stop / restart

```bash
systemctl start krakend
systemctl stop krakend
systemctl restart krakend
```

### Check status

```bash
systemctl status krakend
```

### View logs

```bash
journalctl -u krakend -f
```

## SysVinit

### Install and enable

```bash
cp service/sysvinit/krakend /etc/init.d/krakend
chmod +x /etc/init.d/krakend
update-rc.d krakend defaults
```

### Start / stop / restart

```bash
service krakend start
service krakend stop
service krakend restart
```

### Check status

```bash
service krakend status
```

## Windows (NSSM)

### Install

```powershell
nssm install krakend "C:\usr\local\bin\krakend.exe" run -d -c C:\etc\krakend\krakend.json
nssm set krakend Start SERVICE_AUTO_START
nssm set krakend AppDirectory C:\usr\local\bin
```

### Start / stop / restart

```powershell
nssm start krakend
nssm stop krakend
nssm restart krakend
```

### Check status

```powershell
nssm status krakend
```

### Remove service

```powershell
nssm stop krakend
nssm remove krakend confirm
```

## Troubleshooting

- **Port already in use**: Ensure no other service is using port 8080 or 8081
- **Permission denied**: Verify the `krakend` user and group exist
- **Config not found**: Confirm `/etc/krakend/krakend.json` exists and is readable
- **Service fails to start**: Check logs for details (`journalctl`, `rc-service`, or Event Viewer)
