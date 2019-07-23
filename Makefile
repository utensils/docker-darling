# !/usr/bin/make - f

SHELL               := /usr/bin/env bash
DOCKER_NAMESPACE    ?= utensils
DARLING_GIT_REF	    ?= 4b120631eaebdadf7b77a4bf5c4eeecfe2ea594b
OSXCROSS_GIT_REF    ?= master
VERSION             := $(shell git describe --tags --abbrev=0 2>/dev/null || git rev-parse --abbrev-ref HEAD)
VCS_REF             := $(shell git rev-parse --short HEAD)
BUILD_DATE          := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

.PHONY: default
default: build

# build the docker image
.PHONY: build
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


# build the lite docker image
.PHONY: build-lite
build-lite: 
	docker build \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg DARLING_GIT_REF=$(DARLING_GIT_REF) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VERSION=$(VERSION) \
		--tag $(DOCKER_NAMESPACE)/darling:lite \
		--tag $(DOCKER_NAMESPACE)/darling:lite-$(VERSION) \
		--tag $(DOCKER_NAMESPACE)/darling:lite-$(VCS_REF) \
		--file Dockerfile.lite .

# build the lite-builder docker image which can be used for cached 
# Builds later on
.PHONY: lite-builder
lite-builder: 
	docker build \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg DARLING_GIT_REF=$(DARLING_GIT_REF) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VERSION=$(VERSION) \
		--tag $(DOCKER_NAMESPACE)/darling:lite-builder \
		--tag $(DOCKER_NAMESPACE)/darling:lite-builder-$(VERSION) \
		--tag $(DOCKER_NAMESPACE)/darling:lite-builder-$(VCS_REF) \
		--cache-from $(DOCKER_NAMESPACE)/darling:lite-builder \
		--target builder \
		--file Dockerfile.lite .

# build the lite docker image using cache
.PHONY: cached-build-lite
cached-build-lite: lite-builder 
	docker build \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg DARLING_GIT_REF=$(DARLING_GIT_REF) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VERSION=$(VERSION) \
		--tag $(DOCKER_NAMESPACE)/darling:lite \
		--tag $(DOCKER_NAMESPACE)/darling:lite-$(VERSION) \
		--tag $(DOCKER_NAMESPACE)/darling:lite-$(VCS_REF) \
		--cache-from $(DOCKER_NAMESPACE)/darling:lite-builder \
		--file Dockerfile.lite .

# build the docker image using cache
.PHONY: cached-build
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