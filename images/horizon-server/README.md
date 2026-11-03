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

## Kubernetes security context

Mount `/data` as a writable persistent volume and the prepared Minecraft resources as a read-only volume. The container itself requires no root privileges. Use a read-only root filesystem and restrict privileges:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 10001
  runAsGroup: 10001
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop: [ALL]
  seccompProfile:
    type: RuntimeDefault
```

Apply the `seccompProfile` at pod scope if required by your Kubernetes version, and configure volume ownership/permissions for UID 10001. Do not expose Horizon's administrative panel or API publicly. Prefer an authenticated private endpoint for administration.

Base-image digest pinning is required before production release; the initial Dockerfile uses explicit tags pending digest verification.
