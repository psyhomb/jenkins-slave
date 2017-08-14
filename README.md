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


### Run command 

*WARN:* Use this command only for testing, Jenkins will automatically start this container when build process starts
```
docker run -d -it --name jenkins-slave -v /var/run/docker.sock:/var/run/docker.sock -p 22 psyhomb/jenkins-slave
```


### Jenkins

You can use this custom shell code in the Jenkins job Build section => build type 'Execute shell'

```bash
### Custom and override environment vars
# override
export DOCKER_HOST="unix:///var/run/docker.sock"
# custom
export DOCKER_REGISTRY_URL="registry.example.com"
export DOCKER_IMAGE_NAME="${DOCKER_REGISTRY_URL}/${JOB_BASE_NAME}"

### This way you can discover all the environment vars injected by Jenkins during runtime
#env

### Build and push image
docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} .
docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest
docker push ${DOCKER_IMAGE_NAME}:latest

### Do some cleanup
#for BN in ${BUILD_NUMBER} latest; do
#  docker rmi -f ${DOCKER_IMAGE_NAME}:${BN}
#done

### Show all Docker images for the current project
docker images | grep ${DOCKER_IMAGE_NAME}
```
