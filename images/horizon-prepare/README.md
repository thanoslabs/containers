# Horizon resource preparation image

`ghcr.io/thanoslabs/horizon-prepare` bundles the Horizon `horizon-prepare` binary and Java 25 (JDK) for running vanilla exporters during resource preparation. It uses the same pinned upstream revision as `horizon-server` and runs as UID/GID 10001.

This image does **not** bundle or download Minecraft game files. Supply a legally obtained Minecraft 26.3 server JAR and the matching official client inputs (version JSON, client JAR, libraries, and assets) using the `--server-jar`, `--client-jar`, `--version-json`, `--libraries-dir`, and `--assets-dir` arguments, or `--minecraft-dir`. Mount a writable preparation root and resources output.

Example (with prepared input mounts configured):

```sh
horizon-prepare --prepare --root /opt/horizon --server-jar /data/minecraft/server_26.3.jar --minecraft-dir /data/minecraft/client --output /resources
```

The `--check --root /opt/horizon --output /resources` command validates prepared resources before server startup. This is a preparation-only image; the server image has no Java dependency.
