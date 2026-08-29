# HAProxy Service Management

## systemd (Linux)

```bash
sudo systemctl start haproxy
sudo systemctl stop haproxy
sudo systemctl restart haproxy
sudo systemctl reload haproxy
sudo systemctl enable haproxy
sudo systemctl status haproxy
journalctl -u haproxy -f
```

## OpenRC (BSD/Linux)

```bash
sudo rc-service haproxy start
sudo rc-service haproxy stop
sudo rc-service haproxy restart
sudo rc-service haproxy reload
sudo rc-update add haproxy default
sudo rc-service haproxy status
```

## SysVinit (Legacy Linux)

```bash
sudo service haproxy start
sudo service haproxy stop
sudo service haproxy restart
sudo service haproxy reload
sudo update-rc.d haproxy defaults
sudo service haproxy status
```

## Windows (NSSM)

```powershell
nssm start haproxy
nssm stop haproxy
nssm restart haproxy
nssm status haproxy
nssm remove haproxy confirm
```

## Stats Dashboard

```bash
# View stats
curl http://localhost:8404/
```

## Reload Configuration

```bash
# Via stats socket
echo "reload" | sudo socat stdio /run/haproxy/admin.sock

# Or via systemd
sudo systemctl reload haproxy
```