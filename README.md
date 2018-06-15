# Docker wine

[![Build Status](https://travis-ci.org/jamesbrink/docker-wine.svg?branch=master)](https://travis-ci.org/jamesbrink/docker-wine) [![Docker Automated build](https://img.shields.io/docker/automated/jamesbrink/wine.svg)](https://hub.docker.com/r/jamesbrink/wine/) [![Docker Pulls](https://img.shields.io/docker/pulls/jamesbrink/wine.svg)](https://hub.docker.com/r/jamesbrink/wine/) [![Docker Stars](https://img.shields.io/docker/stars/jamesbrink/wine.svg)](https://hub.docker.com/r/jamesbrink/wine/) [![](https://images.microbadger.com/badges/image/jamesbrink/wine.svg)](https://microbadger.com/images/jamesbrink/wine "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/jamesbrink/wine.svg)](https://microbadger.com/images/jamesbrink/wine "Get your own version badge on microbadger.com")  


## About

This is a just a simple container with wine.

## Usage

Extending from this image. 

```Dockerfile
FROM jamesbrink/wine
COPY ./MyApp /MyApp
RUN apk add --update my-deps...
```

Running a simple glxgears test. 

```shell
$ docker run -i -t --rm jamesbrink/wine bash
```

## Environment Variables


| Variable                | Default Value  | Description                                                    |
| ----------------------- | -------------- | -------------------------------------------------------------- |
| `ENV`              | `DEFAULT_VALUE` | Description |

