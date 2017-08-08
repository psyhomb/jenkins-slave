### Build commands
#   docker build --no-cache --build-arg DOCKER_VERSION=17.06.0 --build-arg DOCKER_GID=997 -t psyhomb/jenkins-slave .
# or (downloads Dockerfile directly from Git)
#   docker build --no-cache --build-arg DOCKER_VERSION=17.06.0 --build-arg DOCKER_GID=997 -t psyhomb/jenkins-slave 'https://github.com/psyhomb/jenkins-slave/raw/master/Dockerfile'
###
# Run container from the image
#   docker run -d -it --name jenkins-slave -v /var/run/docker.sock:/var/run/docker.sock -p 22 psyhomb/jenkins-slave

FROM ubuntu
MAINTAINER psyhomb


### Build time args and env vars
# Docker client version
# https://download.docker.com/linux/static/stable/x86_64
ARG DOCKER_VERSION
ENV DOCKER_VERSION=${DOCKER_VERSION}
ENV DOCKER_URL=https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}-ce.tgz

# GID for 'docker' group has to be exactly the same as one on the host
ARG DOCKER_GID
ENV DOCKER_GID=${DOCKER_GID}

# Public key that will be used by Jenkins master to make passwordless connection to Jenkins slave (agent)
ENV SSH_PUBLIC_KEY=""


### Install OpenJDK and its dependencies and configure ssh pam module
RUN apt-get update \
 && apt-get -y install --no-install-recommends openssh-server git curl ca-certificates openjdk-8-jre-headless \
 && sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd \
 && mkdir -p /var/run/sshd

### Install docker client
RUN cd /tmp \
 && curl -sSL -k -O ${DOCKER_URL} \
 && tar xzvf docker-${DOCKER_VERSION}-ce.tgz docker/docker \
 && mv docker/docker /usr/bin/ \
 && chmod +x /usr/bin/docker \
 && rm -rvf docker docker-${DOCKER_VERSION}-ce.tgz

### Create and configure 'jenkins' user
RUN useradd -m -d /home/jenkins -s /bin/bash jenkins \
 && echo "jenkins:jenkins" | chpasswd \
 && mkdir -p /home/jenkins/.ssh \
 && chmod 700 /home/jenkins/.ssh \
 && echo ${SSH_PUBLIC_KEY} >> /home/jenkins/.ssh/authorized_keys \
 && chmod 600 /home/jenkins/.ssh/authorized_keys \
 && chown -R jenkins:jenkins /home/jenkins/.ssh \
 && groupadd -g ${DOCKER_GID} docker \
 && usermod -aG docker jenkins

### Do some cleanup
RUN apt-get -y --purge autoremove curl \
 && apt-get clean \
 && rm -vrf /var/lib/apt/lists/*

### SSH port
EXPOSE 22

### Default command
CMD ["/usr/sbin/sshd", "-D"]
