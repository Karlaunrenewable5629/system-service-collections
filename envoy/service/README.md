# Envoy Service Management

## systemd (Linux)

```bash
sudo systemctl start envoy
sudo systemctl stop envoy
sudo systemctl restart envoy
sudo systemctl reload envoy
sudo systemctl enable envoy
sudo systemctl status envoy
journalctl -u envoy -f
```

## OpenRC (BSD/Linux)

```bash
sudo rc-service envoy start
sudo rc-service envoy stop
sudo rc-service envoy restart
sudo rc-service envoy reload
sudo rc-update add envoy default
sudo rc-service envoy status
```

## SysVinit (Legacy Linux)

```bash
sudo service envoy start
sudo service envoy stop
sudo service envoy restart
sudo service envoy reload
sudo update-rc.d envoy defaults
sudo service envoy status
```

## Windows (NSSM)

```powershell
nssm start envoy
nssm stop envoy
nssm restart envoy
nssm status envoy
nssm remove envoy confirm
```

## Admin Interface

```bash
# View stats
curl http://localhost:19000/stats

# View clusters
curl http://localhost:19000/clusters

# View listeners
curl http://localhost:19000/listeners

# View routes
curl http://localhost:19000/routes
```