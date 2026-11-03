# syntax=docker/dockerfile:1
# Horizon's dedicated Minecraft Java Edition server, based on upstream packaging/server/Dockerfile.
# The build deliberately contains no proprietary Minecraft game data.
# renovate: datasource=git-refs depName=https://github.com/horizon-rust/horizon branch=main
ARG HORIZON_REF=31f83499b6c2cff7a8e7bf45f8173a7a95c2767c

FROM rust:1.95-slim-bookworm AS build
ARG HORIZON_REF
WORKDIR /src
ADD https://github.com/horizon-rust/horizon.git#${HORIZON_REF} /src
RUN cargo build --release --locked -p horizon-client --no-default-features --bin horizon-client \
 && cargo build --release --locked -p horizon-server --bin horizon-server \
 && mkdir /out \
 && cp target/release/horizon-client /out/horizon-engine \
 && cp target/release/horizon-server /out/horizon-server

FROM debian:bookworm-slim
ARG HORIZON_REF
RUN useradd --system --uid 10001 --home-dir /data --shell /usr/sbin/nologin horizon \
 && mkdir -p /data /opt/horizon/.local/horizon-client \
 && chown -R 10001:10001 /data
COPY --from=build /out/ /opt/horizon/
LABEL org.opencontainers.image.source="https://github.com/horizon-rust/horizon" \
      org.opencontainers.image.revision.upstream="${HORIZON_REF}"
ENV PATH="/opt/horizon:${PATH}" HORIZON_NO_AUDIO=1 HOME=/data
WORKDIR /data
EXPOSE 25565/tcp
USER 10001:10001
# /data must be a writable volume; prepared Minecraft 26.3 resources must be mounted separately.
# Configure first-run EULA acceptance using HORIZON_EULA=true after reviewing the EULA.
CMD ["sh", "-c", "test -f server.toml || horizon-server init --yes || exit 1; exec horizon-server run"]
