# Kong Service Management

## systemd (Linux)

```bash
sudo systemctl start kong
sudo systemctl stop kong
sudo systemctl restart kong
sudo systemctl reload kong
sudo systemctl enable kong
sudo systemctl status kong
journalctl -u kong -f
```

## OpenRC (BSD/Linux)

```bash
sudo rc-service kong start
sudo rc-service kong stop
sudo rc-service kong restart
sudo rc-service kong reload
sudo rc-update add kong default
sudo rc-service kong status
```

## SysVinit (Legacy Linux)

```bash
sudo service kong start
sudo service kong stop
sudo service kong restart
sudo service kong reload
sudo update-rc.d kong defaults
sudo service kong status
```

## Windows (NSSM)

```powershell
nssm start kong
nssm stop kong
nssm restart kong
nssm status kong
nssm remove kong confirm
```

## Kong Admin API

```bash
# Check Kong status
curl http://localhost:8001/status

# List services
curl http://localhost:8001/services

# List routes
curl http://localhost:8001/routes

# List consumers
curl http://localhost:8001/consumers
```