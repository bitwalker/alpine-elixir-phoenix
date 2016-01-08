.PHONY: all

VERSION ?= `cat VERSION`

all: build

test:
	docker run --rm -it bitwalker/alpine-elixir-phoenix:$(VERSION) elixir --version

build:
	docker build --force-rm -t bitwalker/alpine-elixir-phoenix:$(VERSION) - < ./Dockerfile

release: build
	docker push bitwalker/alpine-elixir-phoenix:$(VERSION)
