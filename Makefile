.PHONY: help

USER := 295819810554.dkr.ecr.ap-southeast-1.amazonaws.com/onpointvn
ALPINE_VERSION := 3.11
ELIXIR_VERSION := 1.15.4
ERLANG_VERSION := 25.3.2.4
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
		-t ${USER}/alpine-erlang:${ERLANG_VERSION} .

build-elixir:
	docker build --build-arg ERLANG_VERSION=$(ERLANG_VERSION) \
		--build-arg ELIXIR_VERSION=$(ELIXIR_VERSION) \
		--build-arg USER=$(USER) \
		-f elixir/Dockerfile \
		-t ${USER}/alpine-elixir:${ELIXIR_VERSION} .

build-phoenix:
	docker build --build-arg ELIXIR_VERSION=$(ELIXIR_VERSION) \
		--build-arg USER=$(USER) \
		-f phoenix/Dockerfile \
		-t ${USER}/alpine-elixir-phoenix:${ELIXIR_VERSION} .
