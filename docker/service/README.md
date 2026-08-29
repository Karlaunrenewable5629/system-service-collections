# Docker Service Management

## systemd (Linux)

```bash
# Start
sudo systemctl start docker

# Stop
sudo systemctl stop docker

# Restart
sudo systemctl restart docker

# Reload config (partial)
sudo systemctl reload docker

# Enable on boot
sudo systemctl enable docker

# Check status
sudo systemctl status docker

# View logs
journalctl -u docker -f
```

## OpenRC (BSD/Linux)

```bash
sudo rc-service docker start
sudo rc-service docker stop
sudo rc-service docker restart
sudo rc-update add docker default
sudo rc-service docker status
```

## SysVinit (Legacy Linux)

```bash
sudo service docker start
sudo service docker stop
sudo service docker restart
sudo update-rc.d docker defaults
sudo service docker status
```

## Windows (NSSM)

```powershell
nssm start docker
nssm stop docker
nssm restart docker
nssm status docker
nssm remove docker confirm
```

## Useful Commands

```bash
# Check Docker info
docker info

# List running containers
docker ps

# List all containers
docker ps -a

# List images
docker images

# Check Docker socket
ls -la /var/run/docker.sock

# Run test container
docker run --rm hello-world
```
