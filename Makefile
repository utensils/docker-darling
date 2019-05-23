# !/usr/bin/make - f

SHELL					:= /usr/bin/env bash
DOCKER_NAMESPACE		?= jamesbrink/darling
DARLING_GIT_REF			:= master
OSXCROSS_GIT_REF		:= master
VERSION					:= $(shell git describe --tags --abbrev=0 2>/dev/null || git rev-parse --abbrev-ref HEAD)
VCS_REF					:= $(shell git rev-parse --short HEAD)
BUILD_DATE				:= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

.PHONY: default
default: build

# build the docker image
.PHONY: build test
build: 
	docker build \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VERSION=$(VERSION) \
		--tag $(DOCKER_NAMESPACE)/darling:latest \
		--tag $(DOCKER_NAMESPACE)/darling:$(VERSION) \
		--tag $(DOCKER_NAMESPACE)/darling:$(VCS_REF) \
		--file Dockerfile .

.PHONY: test
test:
	if [ "`docker run $(DOCKER_NAMESPACE)/darling cat /etc/debian_version`" != "buster/sid" ]; then exit 1;fi
