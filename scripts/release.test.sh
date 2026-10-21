#!/usr/bin/env bash
# Runs scripts/release.sh against a throwaway repo and bare remote.
set -euo pipefail
src=$(realpath "$(dirname "$0")/..")

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fail=0

setup() { # fresh repo with this checkout's plugins and scripts, pushed to a bare remote
  rm -rf "$tmp/remote.git" "$tmp/repo"
  git init -q --bare -b main "$tmp/remote.git"
  mkdir "$tmp/repo"
  cp -r "$src/plugins" "$src/scripts" "$tmp/repo/"
  git -C "$tmp/repo" init -q -b main
  git -C "$tmp/repo" -c user.name=t -c user.email=t@t add -A
  git -C "$tmp/repo" -c user.name=t -c user.email=t@t commit -qm init
  git -C "$tmp/repo" remote add origin "$tmp/remote.git"
  git -C "$tmp/repo" push -q origin main
}
run() { # run <stdin answers>
  (cd "$tmp/repo" && printf "$1" | GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t \
    scripts/release.sh >"$tmp/out" 2>&1)
}
versions() { jq -r .version "$tmp"/repo/plugins/*/.*-plugin/plugin.json | sort -u; }

old=$(jq -r .version "$src/plugins/responsibid/.claude-plugin/plugin.json")
IFS=. read -r major minor patch <<<"$old"
new="$major.$minor.$((patch + 1))"

# Patch bump: every manifest moves, the bump is pushed to main, and the tag is pushed.
setup
run '1\ny\n' || { echo "FAIL: patch release exited non-zero"; cat "$tmp/out"; fail=1; }
[ "$(versions)" = "$new" ] || { echo "FAIL: manifests are $(versions), want $new"; fail=1; }
git -C "$tmp/remote.git" rev-parse -q --verify "refs/tags/v$new" >/dev/null || { echo "FAIL: tag v$new not pushed"; fail=1; }
[ "$(git -C "$tmp/remote.git" rev-parse main)" = "$(git -C "$tmp/repo" rev-parse HEAD)" ] || { echo "FAIL: bump commit not pushed"; fail=1; }

# Saying no leaves everything alone.
setup
run '1\nn\n' || true
[ "$(versions)" = "$old" ] || { echo "FAIL: aborted run changed manifests"; fail=1; }
[ -z "$(git -C "$tmp/remote.git" tag)" ] || { echo "FAIL: aborted run pushed a tag"; fail=1; }

# Manifests that disagree are refused before anything changes.
setup
jq '.version="9.9.9"' "$tmp/repo/plugins/responsibid-coach/.codex-plugin/plugin.json" >"$tmp/m" \
  && mv "$tmp/m" "$tmp/repo/plugins/responsibid-coach/.codex-plugin/plugin.json"
git -C "$tmp/repo" -c user.name=t -c user.email=t@t commit -qam drift
git -C "$tmp/repo" push -q origin main
if run '1\ny\n' || ! grep -q "versions disagree" "$tmp/out"; then echo "FAIL: mismatched manifests were not refused"; fail=1; fi
[ -z "$(git -C "$tmp/remote.git" tag)" ] || { echo "FAIL: mismatched run pushed a tag"; fail=1; }

# An existing tag is refused.
setup
git -C "$tmp/repo" tag "v$new" && git -C "$tmp/repo" push -q origin "v$new"
if run '1\ny\n' || ! grep -q "already exists" "$tmp/out"; then echo "FAIL: existing tag was not refused"; fail=1; fi
[ "$(versions)" = "$old" ] || { echo "FAIL: existing-tag run changed manifests"; fail=1; }

[ "$fail" = 0 ] && echo "OK: release script behaves"
exit "$fail"
