# CLAUDE.md

## Purpose

Container images built and published by `thanoslabs`, mostly for software whose upstream publishes no image. Each image lives in `images/<name>/`, is versioned on its own, and is pushed to `ghcr.io/thanoslabs/<name>`. Bootstrapped from `thanoslabs/template-repo`.

## Tech stack

- **Docker / BuildKit** (`docker/build-push-action`) for image builds, published to GHCR
- **Renovate** for dependency updates (managers: `asdf`, `dockerfile`, `github-actions`, plus a regex manager for pinned upstream commits)
- **GitHub Actions** for the CI, release, Renovate, and docs workflows
- **[nebula-md](https://github.com/thanoslabs/nebula-md)** for building `docs/` into a static markdown site
- **MIT License**

## Structure

```
.
├── .agents/                  # Agent instructions and skills
├── .github/
│   ├── CODEOWNERS            # @thanoslabs/reviewers
│   ├── renovate-config.js    # Renovate platform config
│   ├── scripts/
│   │   └── changed-images.sh # Which images/<name>/ a diff touched
│   └── workflows/
│       ├── ci.yml            # Validation + build-only of changed images on PRs
│       ├── docs.yaml         # nebula-md docs build + GitHub Pages deploy
│       ├── release.yaml      # Per-image, label-driven SemVer release + push
│       └── renovate.yaml     # Renovate workflow
├── docs/                     # Project documentation (markdown source for the docs site)
├── images/
│   └── <name>/               # One image per directory: Dockerfile + build context
├── .tool-versions            # Pinned language/tool versions (asdf/mise)
├── AGENTS.md                 # Operational expectations for humans and AI agents
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── SECURITY.md
└── renovate.json             # Renovate settings
```

## Conventions

- `.tool-versions` is the single source of truth for language and tool versions. Before building, testing, or running any tooling, check it and use the pinned versions (install via `asdf install` or `mise install`). When adding a new language or tool to the project, pin its version there first — never assume a globally installed version.
- Versioning: project artifacts (releases, tags, packages, images) follow [SemVer](https://semver.org/) as bare `X.Y.Z` — no `v` prefix (`1.4.2`, not `v1.4.2`). Bump MAJOR for breaking changes, MINOR for backwards-compatible features, PATCH for fixes.
- See `AGENTS.md` for full agent workflow, code style, testing, and git/PR guidance.
- Branch protection: never push directly to `main`; all changes via PR with review.
- An image is a directory `images/<name>/` containing a `Dockerfile`; the directory is the build context and `<name>` is the image name. Nothing outside `images/` triggers an image build or release.
- Pin everything an image depends on so a rebuild is reproducible: base images by tag **and** multi-arch index digest (`tag@sha256:...`), and upstream source by full commit SHA in an `ARG` preceded by a `# renovate: datasource=git-refs depName=<repo url> branch=<branch>` comment so Renovate can bump it.
- Images run as a non-root user and should work with a read-only root filesystem; set any writable paths (e.g. tmp dirs) to locations a deployment can mount.
- Images are built for `linux/amd64` only (set in `ci.yml` and `release.yaml`); add platforms there if a consumer needs them.
- Enable the repo in the Renovate GitHub App (or turn on the schedule in `renovate.yaml`) for dependency PRs.

## Releases

- Each image is versioned independently with [SemVer](https://semver.org/). Image tags are bare `X.Y.Z` (`ghcr.io/thanoslabs/<name>:1.4.2`); git tags and GitHub releases are namespaced `<name>/X.Y.Z` so images don't share a version line.
- **Only changed images release**: when a PR merges to `main`, `release.yaml` releases exactly the images whose `images/<name>/` directory the merge changed. A merge that touches nothing under `images/` releases nothing.
- **Automatic bumps**: the bump level comes from the merged PR's label, applied to every image it touched:
  - `major` — breaking changes
  - `minor` — backwards-compatible features
  - `patch` — fixes
  - No label — defaults to a `patch` bump
- **Manual releases**: run the **Release** workflow with an `image` and, optionally, an explicit `X.Y.Z` version. This bypasses the label-based bump and also re-releases an image with no changes.
- Per image, the workflow builds and pushes the image, then pushes the `<name>/X.Y.Z` tag and creates a GitHub release whose notes include the pushed `image:tag@sha256:digest`. Consumers should pin that digest. Tags are only created after a successful push, so a failed build can simply be re-run.
- Pull requests build (never push) the images they change, via `ci.yml`.

## Docs

- Project documentation lives in `docs/` as markdown and is the source for the project's docs site. Do not introduce another static site generator (MkDocs, Docusaurus, etc.) — docs are built with [nebula-md](https://github.com/thanoslabs/nebula-md).
- `.github/workflows/docs.yaml` calls nebula-md's reusable workflow (`thanoslabs/nebula-md/.github/workflows/deploy.yml`) on pushes to `main` that touch `docs/`. Generation happens in CI only — do not commit built HTML.
- Deployment to GitHub Pages runs only when the repository is **public**; private repos skip the job. Public repos must set **Settings → Pages → Source** to **GitHub Actions**.
- Pages are Obsidian-flavoured markdown: YAML frontmatter (`title`, `tags`, `date`), `[[wikilinks]]` between pages, and callouts. `docs/index.md` is the site's landing page.
