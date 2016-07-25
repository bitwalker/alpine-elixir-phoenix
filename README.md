# Elixir/Phoenix on Alpine Linux

This Dockerfile provides everything you need to run your Phoenix application in Docker out of the box.

It is based on my `alpine-erlang` image, and installs Elixir (1.3.1), Node.js (6.2.x), Hex and Rebar. It can handle compiling
your Node and Elixir dependencies as part of it's build.

## Usage

NOTE: This image sets up a `default` user, with home set to `/opt/app` and owned by that user. The working directory
is also set to `$HOME`. It is highly recommended that you add a `USER default` instruction to the end of your 
Dockerfile so that your app runs in a non-elevated context.

To boot straight to a prompt in the image:

```
$ docker run --rm -it --user=root bitwalker/alpine-elixir-phoenix iex
Erlang/OTP 18 [erts-7.3] [source] [64-bit] [smp:2:2] [async-threads:10] [kernel-poll:false]

Interactive Elixir (1.2.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
BREAK: (a)bort (c)ontinue (p)roc info (i)nfo (l)oaded
       (v)ersion (k)ill (D)b-tables (d)istribution
a
```

Extending for your own application:

```dockerfile
FROM bitwalker/alpine-elixir-phoenix:latest

# Set exposed ports
EXPOSE 5000
ENV PORT=5000 MIX_ENV=prod

# Cache npm deps
ADD package.json package.json
RUN npm install

# Same with elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

ADD . .

# Run frontend build, compile, and digest assets
RUN brunch build --production && \
    mix do compile, phoenix.digest

USER default

CMD ["mix", "phoenix.server"]
```

It is recommended when using this that you have the following in `.dockerignore` when running `docker build`:

```
_build
deps
node_modules
test
```

This will keep the payload smaller and will also avoid any issues when compiling dependencies.

## License

MIT
