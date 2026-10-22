#!/usr/bin/env bash
# Print, as a JSON array, the images under images/ whose files changed between
# two commits. An image is a directory images/<name>/ holding a Dockerfile;
# changes anywhere else in the repo never select an image.
#
# Usage: changed-images.sh <base-sha> <head-sha>
set -euo pipefail

BASE="$1"
HEAD="$2"

# First push to a branch (or a force-push) reports an all-zero base.
if [[ -z "${BASE}" || "${BASE}" =~ ^0+$ ]]; then
  BASE="$(git rev-parse "${HEAD}^")"
fi

# three-dot: only what HEAD added since it diverged from BASE, so a PR
# branch behind main does not pick up images changed on main
git diff --name-only "${BASE}...${HEAD}" -- images/ \
  | cut -d/ -f2 \
  | sort -u \
  | while read -r name; do
      # skip deleted images
      if [[ -f "images/${name}/Dockerfile" ]]; then echo "${name}"; fi
    done \
  | jq -R . | jq -sc .
