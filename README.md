# containers

[![CI](https://github.com/thanoslabs/containers/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/thanoslabs/containers/actions/workflows/ci.yml)
[![Release](https://github.com/thanoslabs/containers/actions/workflows/release.yaml/badge.svg?branch=main)](https://github.com/thanoslabs/containers/actions/workflows/release.yaml)
[![Docs](https://github.com/thanoslabs/containers/actions/workflows/docs.yaml/badge.svg?branch=main)](https://thanoslabs.github.io/containers/)
[![Docs site](https://img.shields.io/badge/docs-GitHub%20Pages-blue?logo=github)](https://thanoslabs.github.io/containers/)
[![Renovate](https://img.shields.io/badge/renovate-enabled-brightgreen?logo=renovatebot)](https://github.com/thanoslabs/containers/pulls?q=is%3Apr+author%3Aapp%2Frenovate)
[![SemVer](https://img.shields.io/badge/semver-2.0.0-blue)](https://semver.org/)
[![License: MIT](https://img.shields.io/github/license/thanoslabs/containers)](LICENSE)

Container images built and published by `thanoslabs`, mostly for software whose upstream publishes no image. Every image is pushed to `ghcr.io/thanoslabs/<name>` and versioned on its own.

## Images

| Image | Upstream | Description |
| ----- | -------- | ----------- |
| [`paseo-relay`](images/paseo-relay/Dockerfile) | [getpaseo/paseo-relay](https://github.com/getpaseo/paseo-relay) | End-to-end encrypted relay for Paseo clients and daemons. Non-root, read-only-root friendly. |

Find versions and digests on each image's [GitHub releases](https://github.com/thanoslabs/containers/releases) (tagged `<name>/X.Y.Z`). Pin by digest:

```
ghcr.io/thanoslabs/paseo-relay:X.Y.Z@sha256:<digest>
```

## Adding an image

1. Create `images/<name>/Dockerfile`. The directory is the build context and `<name>` becomes the image name.
2. Pin base images by tag and digest. Pin upstream source by full commit SHA in an `ARG`, with a `# renovate: datasource=git-refs depName=<repo url> branch=<branch>` comment on the line above so Renovate can bump it (see `images/paseo-relay/Dockerfile`).
3. Run as a non-root user.
4. Open a PR: CI builds the image without pushing. Merging releases it as `0.0.1` (or label the PR `minor`/`major`).

## Releases

Releases follow [SemVer](https://semver.org/) with bare `X.Y.Z` image tags (no `v` prefix), per image.

- **Automatic**: merging a PR to `main` releases only the images whose `images/<name>/` directory changed, bumped by the PR's `major`, `minor`, or `patch` label (no label means `patch`). Changes outside `images/` never trigger a build.
- **Manual**: run the **Release** workflow with an `image` and, optionally, an explicit `X.Y.Z` version.

Automation lives in `.github/workflows/release.yaml` (version, build and push, tag, GitHub release); change detection is `.github/scripts/changed-images.sh`.

## Renovate

Dependency updates are managed via Renovate. Configuration is in `renovate.json` and `.github/renovate-config.js`.

Enabled managers:
- `asdf` (keeps `.tool-versions` up to date)
- `dockerfile` (base images)
- `github-actions`
- `custom.regex` (upstream source commits pinned in Dockerfiles)

A Renovate PR that bumps an image's base or upstream commit changes `images/<name>/`, so merging it releases a new patch version of that image.

## Docs

Project documentation lives in `docs/` as Obsidian-flavoured markdown (frontmatter, `[[wikilinks]]`, callouts). On every push to `main` that touches `docs/`, `.github/workflows/docs.yaml` calls the reusable [nebula-md](https://github.com/thanoslabs/nebula-md) workflow to build a static site and deploy it to GitHub Pages.

## Files

```
.
├── .github/
│   ├── CODEOWNERS           # Auto-request review from @thanoslabs/reviewers
│   ├── renovate-config.js   # Renovate platform config
│   ├── scripts/
│   │   └── changed-images.sh  # Which images/<name>/ a diff touched
│   └── workflows/
│       ├── ci.yml           # Validation + build-only of changed images on PRs
│       ├── docs.yaml        # Build docs/ with nebula-md, deploy to GitHub Pages
│       ├── release.yaml     # Per-image SemVer release: build, push, tag, GitHub release
│       └── renovate.yaml    # Renovate GitHub Action workflow
├── docs/                   # Project documentation (markdown → nebula-md site)
├── images/
│   └── <name>/Dockerfile   # One image per directory
├── .gitignore
├── .tool-versions          # Pinned language/tool versions (asdf/mise)
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── renovate.json           # Renovate settings
└── SECURITY.md
```
