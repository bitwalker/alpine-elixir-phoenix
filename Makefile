.PHONY: help

ALPINE_VERSION := 3.11
ELIXIR_VERSION := 1.12.3
ERLANG_VERSION := 24.0.5
ALPINE_MIN_VERSION := $(shell echo $(ALPINE_VERSION) | sed 's/\([0-9][0-9]*\)\.\([0-9][0-9]*\)\(\.[0-9][0-9]*\)*/\1.\2/')
XDG_CACHE_HOME ?= /tmp
BUILDX_CACHE_DIR ?= $(XDG_CACHE_HOME)/buildx

help:
	@echo "$(IMAGE_NAME):$(VERSION)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build-erlang:
	docker build --build-arg ERLANG_VERSION=$(ERLANG_VERSION) \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		--build-arg ALPINE_MIN_VERSION=$(ALPINE_MIN_VERSION) \
		-f erlang/Dockerfile \
		-t phathdt379/alpine-erlang:${ERLANG_VERSION} .
