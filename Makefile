.PHONY: help

VERSION ?= `cat VERSION | grep elixir | cut -d' ' -f2`
MAJ_VERSION := $(shell echo $(VERSION) | sed 's/\([0-9][0-9]*\)\.\([0-9][0-9]*\)\(\.[0-9][0-9]*\)*/\1/')
MIN_VERSION := $(shell echo $(VERSION) | sed 's/\([0-9][0-9]*\)\.\([0-9][0-9]*\)\(\.[0-9][0-9]*\)*/\1.\2/')
IMAGE_NAME ?= bitwalker/alpine-elixir-phoenix
XDG_CACHE_HOME ?= /tmp
BUILDX_CACHE_DIR ?= $(XDG_CACHE_HOME)/buildx

help:
	@echo "$(IMAGE_NAME):$(VERSION)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

test: ## Test the Docker image
	docker run --rm -it $(IMAGE_NAME):$(VERSION) elixir --version

shell: ## Run an Elixir shell in the image
	docker run --rm -it $(IMAGE_NAME):$(VERSION) iex

sh: ## Boot to a shell prompt
	docker run --rm -it $(IMAGE_NAME):$(VERSION) /bin/bash

setup-buildx: ## Setup a Buildx builder
	@mkdir -p "$(BUILDX_CACHE_DIR)"
	@if ! docker buildx ls | grep buildx-builder >/dev/null; then \
		docker buildx create --append --name buildx-builder --driver docker-container --use && \
		docker buildx inspect --bootstrap --builder buildx-builder; \
	fi

build: setup-buildx ## Build the Docker image
	docker buildx build --output "type=image,push=false" \
		--build-arg ELIXIR_VERSION=$(VERSION) \
		--platform linux/amd64,linux/arm64 \
		--cache-from "type=local,src=$(BUILDX_CACHE_DIR)" \
		--cache-to "type=local,dest=$(BUILDX_CACHE_DIR)" \
		-t $(IMAGE_NAME):$(VERSION) \
		-t $(IMAGE_NAME):$(MIN_VERSION) \
		-t $(IMAGE_NAME):$(MAJ_VERSION) \
		-t $(IMAGE_NAME):latest .


clean: ## Clean up generated images
	@docker rmi --force $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):$(MIN_VERSION) $(IMAGE_NAME):$(MAJ_VERSION) $(IMAGE_NAME):latest

rebuild: clean build ## Rebuild the Docker image

release: setup-buildx ## Build and release the Docker image to Docker Hub
	docker buildx build --push \
		--build-arg ELIXIR_VERSION=$(VERSION) \
		--platform linux/amd64,linux/arm64 \
		--cache-from "type=local,src=$(BUILDX_CACHE_DIR)" \
		--cache-to "type=local,dest=$(BUILDX_CACHE_DIR)" \
		-t $(IMAGE_NAME):$(VERSION) \
		-t $(IMAGE_NAME):$(MIN_VERSION) \
		-t $(IMAGE_NAME):$(MAJ_VERSION) \
		-t $(IMAGE_NAME):latest .
