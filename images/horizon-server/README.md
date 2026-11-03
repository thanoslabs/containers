# Horizon Minecraft server image

This image packages the open-source Horizon Minecraft Java Edition server and its native game engine.

- Image: `ghcr.io/thanoslabs/horizon-server`
- Port: TCP 25565
- Writable state: `/data` (mount a persistent volume)
- Runs as UID/GID 10001
- Graceful shutdown: configure Kubernetes `terminationGracePeriodSeconds: 180`
- Build source: pinned upstream Horizon commit; Renovate can update it

## Proprietary game files

This image **does not** distribute Minecraft game files. Prepare Minecraft Java Edition 26.3 resources on a machine with a legitimate installation using Horizon's `horizon-prepare` instructions, then mount the prepared folder read-only at `/opt/horizon/.local/horizon-client/26.3`. Consult [upstream hosting guidance](https://github.com/horizon-rust/horizon/blob/main/docs/hosting.md).

## First startup

After reviewing the [Minecraft EULA](https://aka.ms/MinecraftEULA), configure `HORIZON_EULA=true` on first startup and optionally `HORIZON_WHITELIST=true`, `HORIZON_PLAYERS`, and `HORIZON_OP`. The image initializes `/data/server.toml` once, then runs `horizon-server run` in the foreground.

The Horizon project is experimental. Back up worlds before upgrades. This image is built for linux/amd64 using this repository's existing CI and per-image SemVer release workflow.
