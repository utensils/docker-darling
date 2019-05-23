# Docker darling

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
$ docker run -i -t -v "$(pwd)/apps":"/mnt/apps" -v /lib/modules/$(uname -r)/build:/lib/modules/$(uname -r)/build:ro --rm --privileged jamesbrink/darling bash
```

