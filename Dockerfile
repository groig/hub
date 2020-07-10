FROM elixir:alpine

WORKDIR /app

COPY . /app

RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix release --path hub-release

EXPOSE 4000/tcp

CMD ["./hub-release/bin/hub", "start"]
