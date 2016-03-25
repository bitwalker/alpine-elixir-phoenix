.PHONY: help

VERSION ?= `cat VERSION`

help:
	@echo "alpine-elixir-phoenix:$(VERSION)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

test: ## Test the Docker image
	docker run --rm -it bitwalker/alpine-elixir-phoenix:$(VERSION) elixir --version

build: ## Rebuild the Docker image
	docker build --force-rm -t bitwalker/alpine-elixir-phoenix:$(VERSION) - < ./Dockerfile

release: build ## Rebuild and release the Docker image to Docker Hub
	docker push bitwalker/alpine-elixir-phoenix:$(VERSION)
