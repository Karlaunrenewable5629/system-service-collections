# containerd Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start containerd

# Stop
sudo systemctl stop containerd

# Restart
sudo systemctl restart containerd

# Enable on boot
sudo systemctl enable containerd

# Disable on boot
sudo systemctl disable containerd

# Check status
sudo systemctl status containerd

# View logs
journalctl -u containerd -f
```

## OpenRC (BSD/Linux)

```bash
# Start
sudo rc-service containerd start

# Stop
sudo rc-service containerd stop

# Restart
sudo rc-service containerd restart

# Enable on boot
sudo rc-update add containerd default

# Check status
sudo rc-service containerd status
```

## SysVinit (Legacy Linux)

```bash
# Start
sudo service containerd start

# Stop
sudo service containerd stop

# Restart
sudo service containerd restart

# Enable on boot
sudo update-rc.d containerd defaults

# Check status
sudo service containerd status
```

## Windows (NSSM)

```powershell
# Install and start
containerd.nssm

# Start
nssm start containerd

# Stop
nssm stop containerd

# Restart
nssm restart containerd

# Check status
nssm status containerd

# Remove service
nssm remove containerd confirm
```

## Verify Socket

```bash
# Check containerd socket
ls -la /run/containerd/containerd.sock

# List namespaces
sudo ctr namespaces list

# List images
sudo ctr images list

# List containers
sudo ctr containers list
```
