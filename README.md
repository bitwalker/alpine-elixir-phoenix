# Elixir/Phoenix on Alpine Linux

This Dockerfile provides everything you need to run your Phoenix application in Docker out of the box.

It is based on my `alpine-erlang` image, and installs Elixir (1.10.4), Node.js (12.18.x), Hex and Rebar. It can handle compiling
your Node and Elixir dependencies as part of it's build.

## Usage

NOTE: This image is intended to run in unprivileged environments, it sets the home directory to `/opt/app`, and makes it globally
read/writeable. If run with a random, high-index user account (say 1000001), the user can run an app, and that's about it. If run
with a user of your own creation, this doesn't apply (necessarily, you can of course implement the same behaviour yourself).
It is highly recommended that you add a `USER default` instruction to the end of your Dockerfile so that your app runs in a non-elevated context.

To boot straight to a prompt in the image:

```
$ docker run --rm -it --user=1000001 bitwalker/alpine-elixir-phoenix iex
Erlang/OTP 23 [erts-11.0.2] [source] [64-bit] [smp:2:2] [ds:2:2:10] [async-threads:1]

Interactive Elixir (1.10.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

Extending for your own application:

```dockerfile
FROM bitwalker/alpine-elixir-phoenix:latest

# Set exposed ports
EXPOSE 5000
ENV PORT=5000 MIX_ENV=prod

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# Same with npm deps
ADD assets/package.json assets/
RUN cd assets && \
    npm install

ADD . .

# Run frontend build, compile, and digest assets
RUN cd assets/ && \
    npm run deploy && \
    cd - && \
    mix do compile, phx.digest

USER default

CMD ["mix", "phx.server"]
```

It is recommended when using this that you have the following in `.dockerignore` when running `docker build`:

```
_build
deps
assets/node_modules
test
```

This will keep the payload smaller and will also avoid any issues when compiling dependencies.

### Multistage Docker Builds

You can also leverage [docker multistage build](https://docs.docker.com/develop/develop-images/multistage-build/) and [bitwalker/alpine-elixir](https://github.com/bitwalker/alpine-elixir) to lower your image size significantly.

An example is shown below:

```dockerfile
FROM bitwalker/alpine-elixir-phoenix:latest AS phx-builder

# Set exposed ports
ENV MIX_ENV=prod

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# Same with npm deps
ADD assets/package.json assets/
RUN cd assets && \
    npm install

ADD . .

# Run frontend build, compile, and digest assets
RUN cd assets/ && \
    npm run deploy && \
    cd - && \
    mix do compile, phx.digest

FROM bitwalker/alpine-elixir:latest

EXPOSE 5000
ENV PORT=5000 MIX_ENV=prod

COPY --from=phx-builder /opt/app/_build /opt/app/_build
COPY --from=phx-builder /opt/app/priv /opt/app/priv
COPY --from=phx-builder /opt/app/config /opt/app/config
COPY --from=phx-builder /opt/app/lib /opt/app/lib
COPY --from=phx-builder /opt/app/deps /opt/app/deps
COPY --from=phx-builder /opt/app/.mix /opt/app/.mix
COPY --from=phx-builder /opt/app/mix.* /opt/app/

# alternatively you can just copy the whole dir over with:
# COPY --from=phx-builder /opt/app /opt/app
# be warned, this will however copy over non-build files

USER default

CMD ["mix", "phx.server"]
```

## License

MIT
