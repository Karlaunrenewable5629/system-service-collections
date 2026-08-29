# Jenkins Installation

## Quick Install

```bash
# Linux (systemd)
sudo ./install/install.sh

# Or manually on Debian/Ubuntu:
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list"
sudo apt update && sudo apt install jenkins
```

## Manual Installation

### From Package Manager

| Distribution | Command |
|--------------|---------|
| Ubuntu/Debian | `apt install jenkins` |
| RHEL/CentOS/Fedora | `dnf copr enable jenkins-lts && dnf install jenkins` |
| Alpine | `apk add openjdk11` then install Jenkins war manually |

### From Binary

```bash
VERSION="2.426.3"
ARCH="amd64"  # or arm64
curl -fsSL "https://repo.jenkins-ci.org/public/org/jenkins-ci/war/${VERSION}/jenkins-${VERSION}.war" -o /usr/local/bin/jenkins.war
```

## Post-Installation

1. Create data directory:
```bash
sudo mkdir -p /var/jenkins_home /var/log/jenkins /etc/jenkins
sudo chown -R jenkins:jenkins /var/jenkins_home /var/log/jenkins /etc/jenkins
```

2. Start service:
```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

3. Access Jenkins at `http://localhost:8080`

## Verify Installation

```bash
jenkins --version
systemctl status jenkins
curl http://localhost:8080
```

## Uninstall

```bash
sudo ./uninstall/uninstall.sh
```