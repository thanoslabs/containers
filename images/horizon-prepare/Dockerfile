# syntax=docker/dockerfile:1
# Horizon resource preparer. No proprietary Minecraft files are bundled.
# Keep this revision in sync with images/horizon-server/Dockerfile.
# renovate: datasource=git-refs depName=https://github.com/horizon-rust/horizon branch=main
ARG HORIZON_REF=31f83499b6c2cff7a8e7bf45f8173a7a95c2767c

FROM rust:1.95-slim-bookworm AS build
ARG HORIZON_REF
WORKDIR /src
ADD https://github.com/horizon-rust/horizon.git#${HORIZON_REF} /src
RUN cargo build --release --locked -p horizon-prepare --bin horizon-prepare

FROM eclipse-temurin:25-jdk-noble
ARG HORIZON_REF
RUN groupadd --gid 10001 horizon \
 && useradd --uid 10001 --gid 10001 --home-dir /data --create-home --shell /usr/sbin/nologin horizon \
 && mkdir -p /opt/horizon /resources \
 && chown -R 10001:10001 /opt/horizon /resources /data
# The preparer needs research-lock.json and Java exporter sources as well as its binary.
COPY --from=build /src/research-lock.json /opt/horizon/research-lock.json
COPY --from=build /src/mods /opt/horizon/mods
COPY --from=build /src/target/release/horizon-prepare /usr/local/bin/horizon-prepare
LABEL org.opencontainers.image.source="https://github.com/horizon-rust/horizon" \
      org.opencontainers.image.revision.upstream="${HORIZON_REF}"
ENV HOME=/data
WORKDIR /opt/horizon
USER 10001:10001
ENTRYPOINT ["horizon-prepare"]
