# Docker darling

[![CircleCI](https://circleci.com/gh/utensils/docker-darling.svg?style=svg)](https://circleci.com/gh/utensils/docker-darling) [![Docker Pulls](https://img.shields.io/docker/pulls/utensils/darling.svg)](https://hub.docker.com/r/utensils/darling/) [![Docker Stars](https://img.shields.io/docker/stars/utensils/darling.svg)](https://hub.docker.com/r/utensils/darling/) [![](https://images.microbadger.com/badges/image/utensils/darling.svg)](https://microbadger.com/images/utensils/darling "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/utensils/darling.svg)](https://microbadger.com/images/utensils/darling "Get your own version badge on microbadger.com")  

## About

This is a containerized version of darling (macOS translation layer). This is an experiemental project with the goal to eventually cross compile both iOS and macOS projects in a docker container.

## Usage

Ensure you have kernel sources installed on your host, this is needed to build the darling 
kernel module against the running system. We run the container in privileged mode and inject the module into the host`s kernel. 

To build the docker image run  
```shell
make
```

Then to run the actual container you will need to mount your systems kernel sources (read only) into the container so the darling module can
be built at container startup.

```shell
$ docker run -i -t \
    -v /lib/modules/$(uname -r)/build:/lib/modules/$(uname -r)/build:ro \
    --privileged utensils/darling
```

