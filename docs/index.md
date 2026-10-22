---
title: Home
---

Container images built and published by `thanoslabs` to `ghcr.io/thanoslabs/<name>`, mostly for software whose upstream publishes no image.

- Each image lives in `images/<name>/` and is versioned on its own (`<name>/X.Y.Z` releases, bare `X.Y.Z` image tags).
- Merging a PR releases only the images whose directory it changed; nothing else triggers a build.
- Consumers should pin the `tag@sha256:digest` printed in each image's GitHub release.

See the repository `README.md` for the image list and how to add one.

Every markdown file under `docs/` is built into a static site by [nebula-md](https://github.com/thanoslabs/nebula-md) and published to GitHub Pages on merge to `main`. Link between pages with Obsidian-style `[[wikilinks]]`.
