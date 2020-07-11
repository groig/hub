FROM elixir:alpine as builder

ENV MIX_ENV=prod

WORKDIR /app

COPY ./mix.exs /app
COPY ./mix.lock /app
COPY ./lib /app/lib

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix release --path hub-release

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/hub-release .

RUN apk add --no-cache --update bash openssl

EXPOSE 4000/tcp

CMD ["./bin/hub", "start"]
