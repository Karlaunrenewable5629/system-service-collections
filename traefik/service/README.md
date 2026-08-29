# Service Management

This guide covers managing the Traefik service across different init systems.

## Table of Contents

- [systemd](#systemd)
- [OpenRC](#openrc)
- [SysVinit](#sysvinit)
- [Windows (NSSM)](#windows-nssm)

## systemd

### Install

```bash
sudo cp service/systemd/traefik.service /etc/systemd/system/traefik.service
sudo systemctl daemon-reload
```

### Start / Stop / Restart

```bash
sudo systemctl start traefik
sudo systemctl stop traefik
sudo systemctl restart traefik
```

### Enable on Boot

```bash
sudo systemctl enable traefik
```

### Status

```bash
sudo systemctl status traefik
```

### Reload Configuration

```bash
sudo systemctl reload traefik
```

## OpenRC

### Install

```bash
sudo cp service/openrc/traefik /etc/init.d/traefik
chmod +x /etc/init.d/traefik
rc-update add traefik default
```

### Start / Stop / Restart

```bash
rc-service traefik start
rc-service traefik stop
rc-service traefik restart
```

### Enable on Boot

```bash
rc-update add traefik default
```

### Status

```bash
rc-service traefik status
```

## SysVinit

### Install

```bash
sudo cp service/sysvinit/traefik /etc/init.d/traefik
chmod +x /etc/init.d/traefik
update-rc.d traefik defaults
```

### Start / Stop / Restart

```bash
service traefik start
service traefik stop
service traefik restart
```

### Enable on Boot

```bash
update-rc.d traefik defaults
```

### Status

```bash
service traefik status
```

## Windows (NSSM)

### Install

```powershell
nssm install traefik "C:\usr\local\bin\traefik.exe" --configFile=C:\etc\traefik\traefik.yml
nssm set traefik AppDirectory C:\usr\local\bin
nssm set traefik AppStdout C:\var\log\traefik\access.log
nssm set traefik AppStderr C:\var\log\traefik\traefik.log
```

### Start / Stop / Restart

```powershell
nssm start traefik
nssm stop traefik
nssm restart traefik
```

### Remove Service

```powershell
nssm remove traefik confirm
```

### Check Status

```powershell
nssm status traefik
```

## Dashboard Access

The Traefik dashboard is available at [http://localhost:8080](http://localhost:8080) once the service is running.

## Troubleshooting

- Check logs at `/var/log/traefik/traefik.log` and `/var/log/traefik/access.log`
- Verify configuration validity: `/usr/local/bin/traefik check --configFile=/etc/traefik/traefik.yml`
- Ensure the `traefik` user has read access to the config file and write access to log directories
