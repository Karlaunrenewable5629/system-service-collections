# k3s Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start k3s

# Stop
sudo systemctl stop k3s

# Restart
sudo systemctl restart k3s

# Enable on boot
sudo systemctl enable k3s

# Check status
sudo systemctl status k3s

# View logs
journalctl -u k3s -f

# View logs since last boot
journalctl -u k3s -b
```

## OpenRC (BSD/Linux)

```bash
sudo rc-service k3s start
sudo rc-service k3s stop
sudo rc-service k3s restart
sudo rc-update add k3s default
sudo rc-service k3s status
```

## SysVinit (Legacy Linux)

```bash
sudo service k3s start
sudo service k3s stop
sudo service k3s restart
sudo update-rc.d k3s defaults
sudo service k3s status
```

## Windows

k3s does not run natively on Windows. See `windows/k3s.nssm` for alternatives.

## Cluster Operations

```bash
# Get nodes
sudo k3s kubectl get nodes

# Get all pods
sudo k3s kubectl get pods -A

# Get node token (for joining agents)
sudo cat /var/lib/rancher/k3s/server/node-token

# Check cluster info
sudo k3s kubectl cluster-info

# Drain a node before maintenance
sudo k3s kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Uncordon after maintenance
sudo k3s kubectl uncordon <node-name>
```
