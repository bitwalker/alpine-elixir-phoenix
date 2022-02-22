.PHONY: help

ALPINE_VERSION ?= `cat VERSION | grep alpine | cut -d' ' -f2`
ELIXIR_VERSION ?= `cat VERSION | grep elixir | cut -d' ' -f2`
ERLANG_VERSION ?= `cat VERSION | grep erlang | cut -d' ' -f2`
ALPINE_MIN_VERSION := $(shell echo $(ALPINE_VERSION) | sed 's/\([0-9][0-9]*\)\.\([0-9][0-9]*\)\(\.[0-9][0-9]*\)*/\1.\2/')
XDG_CACHE_HOME ?= /tmp
BUILDX_CACHE_DIR ?= $(XDG_CACHE_HOME)/buildx

help:
	@echo "$(IMAGE_NAME):$(VERSION)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build-erlang:
	docker build --build-arg ERLANG_VERSION=$(VERSION) \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		--build-arg ALPINE_MIN_VERSION=$(ALPINE_MIN_VERSION) \
		--platform linux/amd64,linux/arm64 \
		-f erlang/Dockerfile \
		-t phathdt379/alpine-erlang:${ERLANG_VERSION}
