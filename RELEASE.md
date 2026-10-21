# Release

Run `scripts/release.sh` from an up-to-date `main`. It asks for a patch, minor, major or custom version, sets it in every `plugin.json`, commits and pushes that bump, then pushes the matching tag. To release the current version without bumping it, choose custom and enter the current version.

The tag must equal `v` plus the version in every `plugin.json`, or the build fails. `scripts/release.test.sh` checks the script against a throwaway repo.

The `Release` workflow runs `scripts/package.test.sh`, then builds the zips and attaches them to a GitHub release:

| Zip | Upload it to |
|---|---|
| `claude-<plugin>.zip` | Claude, as a plugin |
| `claude-skill-<skill>.zip` | claude.ai, **Customize → Skills** |
| `codex-<plugin>.zip` | Codex, as a plugin |
| `chatgpt-<plugin>.zip` | ChatGPT admin console, **Plugins → Add → Upload plugin** (includes the MCP server) |

To build them locally, run `scripts/package.sh dist v0.2.0`.

