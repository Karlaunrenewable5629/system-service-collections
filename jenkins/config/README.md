# Jenkins Configuration

## Docker

The main configuration is via the `Dockerfile`. This builds a custom Jenkins LTS image with essential plugins pre-installed.

### Build

```bash
docker build -t my-jenkins .
```

### Run

```bash
docker run -d \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  my-jenkins
```

### Plugins

Default plugins included:
- `git` - Git plugin for source code management
- `blueocean` - Modern UI experience

To customize plugins, modify the `JENKINS_PLUGINS` environment variable or the Dockerfile.

### Volume Mounts

| Path | Description |
|------|-------------|
| `/var/jenkins_home` | Jenkins home directory with jobs, configurations, and plugins |
| `/var/run/docker.sock` | Docker socket for container integration (optional) |

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `JENKINS_OPTS` | `--httpPort=8080` | Jenkins startup options |
| `JAVA_OPTS` | `-Xmx800m` | JVM memory options |

### Resources

- [Jenkins Docker Documentation](https://www.jenkins.io/doc/book/installing/docker/)
- [Jenkins Plugin Manager](https://github.com/jenkinsci/docker-jenkins/blob/master/jenkins-plugin-manager)