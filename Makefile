# !/usr/bin/make - f

SHELL               := /usr/bin/env bash
DOCKER_NAMESPACE    ?= utensils
DARLING_GIT_REF	    ?= ab56f3209d75ad67a140e1f3e6baccfdca7a1c78
OSXCROSS_GIT_REF    ?= master
VERSION             := $(shell git describe --tags --abbrev=0 2>/dev/null || git rev-parse --abbrev-ref HEAD)
VCS_REF             := $(shell git rev-parse --short HEAD)
BUILD_DATE          := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

.PHONY: default
default: build

# build the docker image
.PHONY: build test
build: 
	docker build \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg DARLING_GIT_REF=$(DARLING_GIT_REF) \
		--build-arg OSXCROSS_GIT_REF=$(OSXCROSS_GIT_REF) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VERSION=$(VERSION) \
		--tag $(DOCKER_NAMESPACE)/darling:latest \
		--tag $(DOCKER_NAMESPACE)/darling:$(VERSION) \
		--tag $(DOCKER_NAMESPACE)/darling:$(VCS_REF) \
		--file Dockerfile .

# build the docker image using cache
.PHONY: cached-build test
cached-build: 
	docker build \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg DARLING_GIT_REF=$(DARLING_GIT_REF) \
		--build-arg OSXCROSS_GIT_REF=$(OSXCROSS_GIT_REF) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VERSION=$(VERSION) \
		--tag $(DOCKER_NAMESPACE)/darling:latest \
		--tag $(DOCKER_NAMESPACE)/darling:$(VERSION) \
		--tag $(DOCKER_NAMESPACE)/darling:$(VCS_REF) \
		--cache-from $(DOCKER_NAMESPACE)/darling:latest \
		--file Dockerfile .

.PHONY: test
test:
	if [ "`docker run --entrypoint=/bin/cat $(DOCKER_NAMESPACE)/darling /etc/debian_version`" != "buster/sid" ]; then exit 1;fi

.PHONY: push
push:
	docker push $(DOCKER_NAMESPACE)/darling