# jenkins-slave

### About

Build Jenkins slave Docker image


### Build args

`DOCKER_VERSION`

Use latest docker client [version](https://download.docker.com/linux/static/stable/x86_64)

`DOCKER_GID`

GID for `docker` group has to be exactly the same as one on the host, otherwise docker client won't be able to communicate with dockerd (running on the host) over docker socket (`/var/run/docker.sock`)


### Build commands

Use local Dockerfile
```
docker build --no-cache --build-arg DOCKER_VERSION=17.06.0 --build-arg DOCKER_GID=997 -t psyhomb/jenkins-slave .
```

Use URL to access Dockerfile
```
docker build --no-cache --build-arg DOCKER_VERSION=17.06.0 --build-arg DOCKER_GID=997 -t psyhomb/jenkins-slave 'https://github.com/psyhomb/jenkins-slave/raw/master/Dockerfile'
```

### Run command (only for testing purposes, this command will be executed by Jenkins during the build process)
```
docker run -d -it --name jenkins-slave -v /var/run/docker.sock:/var/run/docker.sock -p 22 psyhomb/jenkins-slave
```
