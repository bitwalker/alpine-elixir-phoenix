ARG ELIXIR_VERSION
ARG USER
FROM ${USER}/alpine-elixir:${ELIXIR_VERSION}

WORKDIR ${HOME}

# Install NPM
RUN \
	apk update && \
	apk --no-cache --update add \
	make \
	g++ \
	wget \
	curl \
	inotify-tools \
	nodejs \
	npm && \
	npm install npm -g --no-progress && \
	update-ca-certificates --fresh && \
	rm -rf /var/cache/apk/*

# Add local node module binaries to PATH
ENV PATH=./node_modules/.bin:$PATH

# Ensure latest versions of Hex/Rebar are installed on build
ONBUILD RUN mix do local.hex --force, local.rebar --force

CMD ["bash"]
