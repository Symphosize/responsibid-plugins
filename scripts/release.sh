#!/usr/bin/env bash
# Bumps every plugin.json, pushes the bump to main, then pushes the tag.
# The Release workflow builds the zips and creates the GitHub release from that tag.
set -euo pipefail
cd "$(dirname "$0")/.."

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

MANIFESTS=(plugins/*/.claude-plugin/plugin.json plugins/*/.codex-plugin/plugin.json)

bump() {
  local version="$1" part="$2"
  IFS='.' read -r major minor patch <<< "$version"
  case "$part" in
    major) echo "$((major + 1)).0.0" ;;
    minor) echo "${major}.$((minor + 1)).0" ;;
    patch) echo "${major}.${minor}.$((patch + 1))" ;;
  esac
}

echo -e "${BOLD}🚀 ResponsiBid Plugins Release${NC}"
echo ""

if [[ -n "$(git status --porcelain)" ]]; then
  echo -e "${YELLOW}Warning: You have uncommitted changes. Only the version bump will be committed.${NC}"
  read -rp "Continue anyway? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
fi

echo -e "Fetching from remote..."
git fetch --tags --quiet origin

BRANCH=$(git rev-parse --abbrev-ref HEAD)
REMOTE=$(git rev-parse "origin/${BRANCH}" 2>/dev/null || echo "")
if [[ -n "$REMOTE" && "$(git rev-parse HEAD)" != "$REMOTE" ]]; then
  echo -e "${RED}Local branch '${BRANCH}' is not up-to-date with origin.${NC}"
  echo -e "Run ${CYAN}git pull${NC} (or push your commits) first to avoid tagging a stale commit."
  exit 1
fi

# The workflow refuses a tag that doesn't match every manifest, so they must agree first.
CURRENT=$(jq -r .version "${MANIFESTS[@]}" | sort -u)
if [[ $(wc -l <<< "$CURRENT") -ne 1 ]]; then
  echo -e "${RED}plugin.json versions disagree:${NC}"
  for m in "${MANIFESTS[@]}"; do echo "  $(jq -r .version "$m")  $m"; done
  exit 1
fi
echo -e "Current version: ${CYAN}v${CURRENT}${NC}"
echo ""

PATCH=$(bump "$CURRENT" patch)
MINOR=$(bump "$CURRENT" minor)
MAJOR=$(bump "$CURRENT" major)

echo -e "${BOLD}Version bump:${NC}"
echo "  1) patch  → v${PATCH}"
echo "  2) minor  → v${MINOR}"
echo "  3) major  → v${MAJOR}"
echo "  4) custom (enter ${CURRENT} to release the current version as is)"
echo ""
read -rp "Select version [1/2/3/4]: " ver_choice

case "$ver_choice" in
  1) VERSION="$PATCH" ;;
  2) VERSION="$MINOR" ;;
  3) VERSION="$MAJOR" ;;
  4)
    read -rp "Enter version (without v prefix): " VERSION
    if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo -e "${RED}Invalid semver format. Use X.Y.Z${NC}"; exit 1
    fi
    ;;
  *) echo -e "${RED}Invalid choice${NC}"; exit 1 ;;
esac

TAG="v${VERSION}"
echo ""

if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  echo -e "${RED}Tag ${TAG} already exists.${NC}"; exit 1
fi

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
CHANGELOG=$(git log ${LAST_TAG:+"${LAST_TAG}..HEAD"} --pretty=format:"- %s" --no-merges)
echo -e "${BOLD}Changes since ${LAST_TAG:-the first commit}:${NC}"
echo "${CHANGELOG:-  (none)}"
echo ""

echo -e "${BOLD}Summary:${NC}"
echo -e "  Tag:     ${CYAN}${TAG}${NC}"
echo -e "  Branch:  ${CYAN}${BRANCH}${NC}"
echo -e "  Commit:  ${CYAN}$(git log -1 --format='%h %s')${NC}"
echo ""
read -rp "Bump manifests, push and release? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

if [[ "$VERSION" != "$CURRENT" ]]; then
  for m in "${MANIFESTS[@]}"; do
    jq --arg v "$VERSION" '.version = $v' "$m" > "$m.tmp" && mv "$m.tmp" "$m"
  done
  git commit -q -m "Release ${TAG}" -- "${MANIFESTS[@]}"
  git push -q origin "$BRANCH"
fi

git tag -a "$TAG" -m "$TAG"
git push -q origin "$TAG"

echo ""
echo -e "${GREEN}Done!${NC} Pushed ${BOLD}${TAG}${NC}. The Release workflow will build the zips and publish the release."
if command -v gh &>/dev/null && gh auth status &>/dev/null; then
  echo -e "Monitor: ${CYAN}gh run list --workflow=release.yml${NC}"
fi
