# syntax=docker/dockerfile:1
# Agent-ready Paseo daemon. Keep the upstream runtime and its pairing/state paths.
# The base tag and digest must be updated together.
FROM ghcr.io/getpaseo/paseo:0.12.0@sha256:0d17dd75a51c591907a4bbcd505013102048246a0cd6e824de3b38a6057ff862

ARG TARGETARCH
ARG MISE_VERSION=v2026.10.10
ARG CODEX_VERSION=0.163.0
ARG PI_VERSION=1.4.0

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git python3 python3-venv python3-pip \
    build-essential pkg-config ripgrep unzip xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Bundle agents at build time instead of installing them on the live PVC.
RUN npm install --global --no-fund --no-audit \
    "@openai/codex@${CODEX_VERSION}" \
    "@earendil-works/pi-coding-agent@${PI_VERSION}"

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) arch=linux-x64 ;; \
      arm64) arch=linux-arm64 ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/jdx/mise/releases/download/${MISE_VERSION}/mise-${MISE_VERSION}-${arch}.tar.xz" -o /tmp/mise.tar.xz; \
    mkdir -p /tmp/mise-unpack; \
    tar -xJf /tmp/mise.tar.xz -C /tmp/mise-unpack; \
    install -m 0755 /tmp/mise-unpack/mise /usr/local/bin/mise; \
    rm -rf /tmp/mise.tar.xz /tmp/mise-unpack

ENV PATH=/opt/mise/shims:/usr/local/bin:/usr/bin:/bin
COPY mise.toml /etc/mise/config.toml
RUN mkdir -p /opt/mise /tmp/mise-cache /tmp/mise-state \
    && cd /etc/mise \
    && MISE_DATA_DIR=/opt/mise MISE_CACHE_DIR=/tmp/mise-cache MISE_STATE_DIR=/tmp/mise-state mise trust \
    && MISE_DATA_DIR=/opt/mise MISE_CACHE_DIR=/tmp/mise-cache MISE_STATE_DIR=/tmp/mise-state mise install \
    && MISE_DATA_DIR=/opt/mise MISE_CACHE_DIR=/tmp/mise-cache MISE_STATE_DIR=/tmp/mise-state mise reshim \
    && rm -rf /tmp/mise-cache /tmp/mise-state

# Do not bake in secrets, GitHub tokens, kubeconfigs, or cluster credentials.
RUN chown -R 1000:1000 /home/paseo
USER 1000:1000
# Preserve the upstream image's entrypoint and command.
