FROM mhart/alpine-node:4.2
MAINTAINER Paul Schoenfelder <paulschoenfelder@gmail.com>

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT 2016-01-08
ENV ELIXIR_VERSION 1.2.0
ENV HOME /root

# Install Erlang/Elixir
RUN echo 'http://dl-4.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories && \
    echo 'http://dl-4.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories && \
    apk --update add ncurses-libs git make g++ wget python ca-certificates \
                     erlang erlang-dev erlang-kernel erlang-hipe erlang-compiler \
                     erlang-stdlib erlang-erts erlang-tools erlang-syntax-tools erlang-sasl \
                     erlang-crypto erlang-public-key erlang-ssl erlang-ssh erlang-asn1 erlang-inets \
                     erlang-inets erlang-mnesia erlang-odbc \
                     erlang-erl-interface erlang-parsetools erlang-eunit && \
    wget https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip && \
    mkdir -p /opt/elixir-${ELIXIR_VERSION}/ && \
    unzip Precompiled.zip -d /opt/elixir-${ELIXIR_VERSION}/ && \
    rm Precompiled.zip && \
    rm -rf /var/cache/apk/*

# Add local node module binaries to PATH
ENV PATH $PATH:node_modules/.bin:/opt/elixir-${ELIXIR_VERSION}/bin

# Install Hex+Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

CMD ["/bin/sh"]
