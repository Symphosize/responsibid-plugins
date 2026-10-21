#!/usr/bin/env bash
# Builds the release zips: one plugin zip per client (Claude, Codex) and one
# zip per skill for the claude.ai and ChatGPT skill uploads.
# Usage: scripts/package.sh <out-dir> <tag, e.g. v0.2.0>
set -euo pipefail
out=$(realpath -m "${1:?out dir}")
tag=${2:?tag}
cd "$(dirname "$0")/../plugins"

for manifest in */.claude-plugin/plugin.json */.codex-plugin/plugin.json; do
  version=$(jq -r .version "$manifest")
  [ "v$version" = "$tag" ] || { echo "$manifest is $version, tag is $tag" >&2; exit 1; }
done

mkdir -p "$out"
for plugin in */; do
  plugin=${plugin%/}
  (cd "$plugin" && zip -qrX "$out/claude-$plugin.zip" .claude-plugin skills $(ls -A | grep -x '.mcp.json' || true))
  (cd "$plugin" && zip -qrX "$out/codex-$plugin.zip" .codex-plugin .codex.mcp.json assets skills)

  # ChatGPT reads the portable layout at the zip root. It's built here rather than kept in
  # the plugin folder, because Codex would pick up a root plugin.json and drop the server.
  stage=$(mktemp -d)
  jq '{"$schema": "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json",
       name, version, description, author, homepage,
       extensions: {"com.openai": {interface}}}' "$plugin/.codex-plugin/plugin.json" > "$stage/plugin.json"
  cp "$plugin/.chatgpt.mcp.json" "$stage/mcp.json"
  cp -r "$plugin/assets" "$plugin/skills" "$stage/"
  (cd "$stage" && zip -qrX "$out/chatgpt-$plugin.zip" plugin.json mcp.json assets skills)
  rm -rf "$stage"

  for skill in "$plugin"/skills/*/; do
    skill=$(basename "$skill")
    (cd "$plugin/skills" && zip -qrX "$out/claude-skill-$skill.zip" "$skill")
  done
done
ls "$out"
