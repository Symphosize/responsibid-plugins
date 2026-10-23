#!/usr/bin/env bash
# Builds the release zips into a temp dir and checks what each one contains.
set -euo pipefail
cd "$(dirname "$0")/.."

out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT
fail=0

check() { # check <zip> <path that must exist>
  unzip -Z1 "$out/$1" | grep -qx "$2" || { echo "FAIL: $1 is missing $2"; fail=1; }
}
refuse() { # refuse <zip> <regex that must not match any path>
  ! unzip -Z1 "$out/$1" | grep -qE "$2" || { echo "FAIL: $1 contains $2"; fail=1; }
}

# A tag that doesn't match the plugin versions must be rejected.
if scripts/package.sh "$out" v9.9.9 >/dev/null 2>&1; then
  echo "FAIL: mismatched tag was accepted"; fail=1
fi

version=$(jq -r .version plugins/responsibid/.claude-plugin/plugin.json)
scripts/package.sh "$out" "v$version" >/dev/null

expected=$(cat <<EOF
chatgpt-responsibid-coach.zip
chatgpt-responsibid.zip
claude-responsibid-coach.zip
claude-responsibid.zip
claude-skill-company-onboarding.zip
claude-skill-customer-quote-page.zip
claude-skill-follow-up-rewrite.zip
claude-skill-photo-quote.zip
claude-skill-pricing-setup.zip
claude-skill-quote-intake.zip
codex-responsibid-coach.zip
codex-responsibid.zip
EOF
)
actual=$(ls "$out" | sort)
[ "$actual" = "$expected" ] || { echo "FAIL: zip list differs"; diff <(echo "$expected") <(echo "$actual") || true; fail=1; }

for p in responsibid responsibid-coach; do
  check "claude-$p.zip" .claude-plugin/plugin.json
  refuse "claude-$p.zip" '^(evals/|\.codex|plugin\.json$|mcp\.json$)'
  check "codex-$p.zip" .codex-plugin/plugin.json
  check "codex-$p.zip" .codex.mcp.json
  check "codex-$p.zip" assets/icon.png
  refuse "codex-$p.zip" '^(evals/|\.claude-plugin/|\.mcp\.json$)'
  check "chatgpt-$p.zip" plugin.json
  check "chatgpt-$p.zip" mcp.json
  check "chatgpt-$p.zip" assets/icon.png
  refuse "chatgpt-$p.zip" '^(evals/|\.claude-plugin/|\.codex|\.chatgpt|\.mcp\.json$)'
  # ChatGPT reads the portable manifest, with the same listing details as Codex.
  unzip -p "$out/chatgpt-$p.zip" plugin.json | jq -e --arg p "$p" '
    ."$schema" == "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json"
    and .name == $p and .extensions["com.openai"].interface.displayName != null' >/dev/null \
    || { echo "FAIL: chatgpt-$p.zip plugin.json is not a portable manifest"; fail=1; }
  unzip -p "$out/chatgpt-$p.zip" mcp.json | jq -e '
    .mcpServers.responsibid.extensions["com.openai"].auth.client.clientId == "chatgpt-v2"' >/dev/null \
    || { echo "FAIL: chatgpt-$p.zip does not use the chatgpt-v2 client"; fail=1; }
  # The secret is entered in ChatGPT, never shipped.
  ! unzip -p "$out/chatgpt-$p.zip" mcp.json | grep -qi '"clientSecret"' \
    || { echo "FAIL: chatgpt-$p.zip mcp.json contains a client secret"; fail=1; }
done
check claude-responsibid.zip .mcp.json
check claude-responsibid.zip skills/quote-intake/SKILL.md
check claude-responsibid.zip skills/photo-quote/SKILL.md
check claude-responsibid.zip skills/customer-quote-page/SKILL.md
check codex-responsibid-coach.zip skills/pricing-setup/SKILL.md
check codex-responsibid.zip skills/photo-quote/SKILL.md
check chatgpt-responsibid.zip skills/customer-quote-page/SKILL.md

for s in quote-intake photo-quote customer-quote-page pricing-setup follow-up-rewrite company-onboarding; do
  check "claude-skill-$s.zip" "$s/SKILL.md"
done

# Codex must sign in with its own client, never Claude's.
unzip -p "$out/codex-responsibid.zip" .codex.mcp.json | jq -e '.mcpServers.responsibid.oauth.clientId == "codex"' >/dev/null \
  || { echo "FAIL: codex zip does not use the codex client"; fail=1; }

[ "$fail" = 0 ] && echo "OK: all release zips look right"
exit "$fail"
