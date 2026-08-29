FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
    apt-get install -y sudo && \
    rm -rf /var/lib/apt/lists/*

RUN jenkins-plugin-manager --plugins "git:blueocean:1.25.0"

USER jenkins

EXPOSE 8080

ENV JENKINS_OPTS="--httpPort=8080"