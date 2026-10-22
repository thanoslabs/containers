# syntax=docker/dockerfile:1

# Paseo's distributed relay (https://github.com/getpaseo/paseo-relay).
# Upstream publishes no image; this follows upstream's own Dockerfile, built
# from a pinned commit, with a non-root, read-only-friendly runtime on top.

# renovate: datasource=git-refs depName=https://github.com/getpaseo/paseo-relay branch=main
ARG PASEO_RELAY_REF=3fc41c96c8c63f3a7109e832899cc57d473c4531

FROM hexpm/elixir:1.20.2-erlang-29.0.2-debian-bookworm-20260623-slim@sha256:2f7018f129c268e439a4e4054d9487a85ad4c2f05141e9347a4442e8a4b3712c AS build
ARG PASEO_RELAY_REF
WORKDIR /app
ENV MIX_ENV=prod
ADD https://github.com/getpaseo/paseo-relay.git#${PASEO_RELAY_REF} /app
RUN mix local.hex --force \
 && mix local.rebar --force \
 && mix deps.get --only prod \
 && mix compile \
 && mix release

# same Debian snapshot as the builder, so the release's linked libs match
FROM debian:bookworm-20260623-slim@sha256:60eac759739651111db372c07be67863818726f754804b8707c90979bda511df
ARG PASEO_RELAY_REF
RUN apt-get update \
 && apt-get install -y --no-install-recommends libstdc++6 libsctp1 openssl ca-certificates \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app/_build/prod/rel/paseo_relay ./
LABEL org.opencontainers.image.revision.upstream="${PASEO_RELAY_REF}"
ENV HOME=/app \
    PASEO_RELAY_HOST=0.0.0.0 \
    PASEO_RELAY_PORT=4000 \
    PASEO_RELAY_DRAIN=false \
    # the release writes its generated runtime config here; keeps / read-only
    RELEASE_TMP=/tmp \
    # the VM otherwise defaults to latin1 filename encoding
    ELIXIR_ERL_OPTIONS=+fnu
USER 65534:65534
EXPOSE 4000
ENTRYPOINT ["/app/bin/paseo_relay"]
CMD ["start"]
