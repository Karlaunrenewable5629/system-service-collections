# Uninstalling Krakend

This guide covers removing the Krakend API Gateway from your system.

## Quick Uninstall

```bash
sudo ./uninstall/uninstall.sh
```

## Step-by-Step

### 1. Stop and disable the service

#### OpenRC

```bash
sudo rc-service krakend stop
sudo rc-update del krakend default
sudo rm /etc/init.d/krakend
```

#### systemd

```bash
sudo systemctl stop krakend
sudo systemctl disable krakend
sudo rm /etc/systemd/system/krakend.service
sudo systemctl daemon-reload
```

#### SysVinit

```bash
sudo service krakend stop
sudo update-rc.d -f krakend remove
sudo rm /etc/init.d/krakend
```

#### Windows (NSSM)

```powershell
nssm stop krakend
nssm remove krakend confirm
```

### 2. Remove configuration

```bash
sudo rm -rf /etc/krakend
```

### 3. Remove the binary

```bash
sudo rm -f /usr/local/bin/krakend
```

### 4. Remove the service user

```bash
sudo userdel krakend 2>/dev/null || true
sudo groupdel krakend 2>/dev/null || true
```

### 5. Remove data and logs

```bash
sudo rm -rf /var/lib/krakend /var/log/krakend
```

## What Gets Removed

- Service definitions (`/etc/init.d/krakend`, `/etc/systemd/system/krakend.service`)
- Configuration (`/etc/krakend/`)
- Binary (`/usr/local/bin/krakend`)
- Service user and group (`krakend`)
- Data directory (`/var/lib/krakend`)
- Log directory (`/var/log/krakend`)

## Preserving Configuration

If you want to keep your configuration for a potential reinstall, back it up before uninstalling:

```bash
sudo cp -r /etc/krakend ~/krakend-config-backup
```
