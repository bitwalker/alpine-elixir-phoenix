ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION} AS build
ARG ALPINE_MIN_VERSION
ARG ERLANG_VERSION

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT=2021-12-10 \
	LANG=C.UTF-8 \
	HOME=/opt/app/ \
	TERM=xterm \
	ALPINE_MIN_VERSION=${ALPINE_MIN_VERSION} \
	ERLANG_VERSION=${ERLANG_VERSION}

# Add tagged repos as well as the edge repo so that we can selectively install edge packages
RUN \
	echo "@main http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_MIN_VERSION}/main" >> /etc/apk/repositories && \
	echo "@community http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_MIN_VERSION}/community" >> /etc/apk/repositories && \
	echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories

# Upgrade Alpine and base packages
RUN apk --no-cache --update-cache --available upgrade

# Install bash and Erlang/OTP deps
RUN \
	apk add --no-cache --update-cache \
	bash \
	curl \
	ca-certificates \
	libgcc \
	lksctp-tools \
	pcre \
	zlib-dev

# Install Erlang/OTP build deps
RUN \
	apk add --no-cache --virtual .erlang-build \
	dpkg-dev \
	dpkg \
	gcc \
	g++ \
	libc-dev \
	linux-headers \
	make \
	autoconf \
	ncurses-dev \
	openssl-dev \
	unixodbc-dev \
	lksctp-tools-dev \
	tar

WORKDIR /tmp/erlang-build

# Download OTP
RUN \
	curl -sSL "https://github.com/erlang/otp/releases/download/OTP-${ERLANG_VERSION}/otp_src_${ERLANG_VERSION}.tar.gz" | \
	tar --strip-components=1 -xzf -

# Configure & Build
RUN \
	export ERL_TOP=/tmp/erlang-build && \
	export CPPFLAGS="-D_BSD_SOURCE $CPPFLAGS" && \
	./otp_build autoconf && \
	./configure \
	--build="$(dpkg-architecture --query DEB_HOST_GNU_TYPE)" \
	--prefix=/usr/local \
	--sysconfdir=/etc \
	--mandir=/usr/share/man \
	--infodir=/usr/share/info \
	--without-javac \
	--without-wx \
	--without-debugger \
	--without-observer \
	--without-jinterface \
	--without-et \
	--without-megaco \
	--enable-threads \
	--enable-shared-zlib \
	--enable-ssl=dynamic-ssl-lib && \
	make -j$(getconf _NPROCESSORS_ONLN)

# Install to temporary location
RUN \
	make DESTDIR=/tmp install && \
	cd /tmp && rm -rf /tmp/erlang-build && \
	find /tmp/usr/local -regex '/tmp/usr/local/lib/erlang/\(lib/\|erts-\).*/\(man\|doc\|obj\|c_src\|emacs\|info\|examples\)' | xargs rm -rf && \
	find /tmp/usr/local -name src | xargs -r find | grep -v '\.hrl$' | xargs rm -v || true && \
	find /tmp/usr/local -name src | xargs -r find | xargs rmdir -vp || true && \
	# Strip install to reduce size
	scanelf --nobanner -E ET_EXEC -BF '%F' --recursive /tmp/usr/local | xargs -r strip --strip-all && \
	scanelf --nobanner -E ET_DYN -BF '%F' --recursive /tmp/usr/local | xargs -r strip --strip-unneeded && \
	runDeps="$( \
	scanelf --needed --nobanner --format '%n#p' --recursive /tmp/usr/local \
	| tr ',' '\n' \
	| sort -u \
	| awk 'system("[ -e /tmp/usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" && \
	ln -s /tmp/usr/local/lib/erlang /usr/local/lib/erlang && \
	/tmp/usr/local/bin/erl -eval "beam_lib:strip_release('/tmp/usr/local/lib/erlang/lib')" -s init stop > /dev/null && \
	(/usr/bin/strip /tmp/usr/local/lib/erlang/erts-*/bin/* || true) && \
	apk add --no-cache \
	$runDeps \
	lksctp-tools

### Final Image

ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION}
ARG ALPINE_MIN_VERSION

MAINTAINER Paul Schoenfelder <paulschoenfelder@gmail.com>

ENV LANG=C.UTF-8 \
	HOME=/opt/app/ \
	# Set this so that CTRL+G works properly
	TERM=xterm \
	ALPINE_MIN_VERSION=${ALPINE_MIN_VERSION}

# Copy Erlang/OTP installation
COPY --from=build /tmp/usr/local /usr/local

WORKDIR ${HOME}

RUN \
	# Create default user and home directory, set owner to default
	adduser -s /bin/sh -u 1001 -G root -h "${HOME}" -S -D default && \
	chown -R 1001:0 "${HOME}" && \
	# Add tagged repos as well as the edge repo so that we can selectively install edge packages
	echo "@main http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_MIN_VERSION}/main" >> /etc/apk/repositories && \
	echo "@community http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_MIN_VERSION}/community" >> /etc/apk/repositories && \
	echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
	# Upgrade Alpine and base packages
	apk --no-cache --update-cache --available upgrade && \
	# Install bash and Erlang/OTP deps
	apk add --no-cache --update-cache \
	bash \
	libstdc++ \
	ca-certificates \
	ncurses \
	openssl \
	pcre \
	unixodbc \
	zlib && \
	# Update ca certificates
	update-ca-certificates --fresh

CMD ["bash"]
