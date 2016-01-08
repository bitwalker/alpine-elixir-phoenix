# Elixir/Phoenix on Alpine Linux

This Dockerfile provides everything you need to run your Phoenix application in Docker out of the box. It is built
on the excellent `mhart/alpine-node` image, and borrows heavily from the `msaraiva/elixir` Dockerfile as well.

By default, it installs Erlang (18.1), Elixir (1.2.0), Node.js (4.2.x), Hex and Rebar. It can handle compiling
your Node and Elixir dependencies as part of it's build.

## Usage

To boot straight to a prompt in the image:

```
$ docker run --rm -it bitwalker/alpine-elixir-phoenix iex
Erlang/OTP 18 [erts-7.1] [source] [64-bit] [smp:2:2] [async-threads:10] [kernel-poll:false]

Interactive Elixir (1.2.0) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
BREAK: (a)bort (c)ontinue (p)roc info (i)nfo (l)oaded
       (v)ersion (k)ill (D)b-tables (d)istribution
a
```

Extending for your own application:

```dockerfile
FROM bitwalker/alpine-elixir-phoenix:1.0

# Set exposed ports
EXPOSE 5000
ENV PORT=5000 MIX_ENV=prod

# Set your project's working directory
WORKDIR /app

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

CMD ["mix", "phoenix.server"]
```

## License

MIT
