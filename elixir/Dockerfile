ARG ERLANG_VERSION
FROM phathdt379/alpine-erlang:${ERLANG_VERSION}
ARG ELIXIR_VERSION

ENV ELIXIR_VERSION=v${ELIXIR_VERSION} \
	MIX_HOME=/opt/mix \
	HEX_HOME=/opt/hex

WORKDIR /tmp/elixir-build

RUN \
	apk add --no-cache --update-cache \
	git \
	make && \
	git clone https://github.com/elixir-lang/elixir --depth 1 --branch $ELIXIR_VERSION && \
	cd elixir && \
	make && make install && \
	mkdir -p ${HEX_HOME} && \
	mix local.hex --force && \
	mix local.rebar --force && \
	cd $HOME && \
	rm -rf /tmp/elixir-build

WORKDIR ${HOME}

# Always install latest versions of Hex and Rebar
ONBUILD RUN mix do local.hex --force, local.rebar --force

CMD ["bash"]
