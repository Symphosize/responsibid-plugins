# ResponsiBid plugins

Plugin marketplace for Claude Code and Codex. It connects the assistant to the ResponsiBid MCP server and adds skills for quoting and for setting up a company during onboarding.

| Plugin | For | Skills |
|---|---|---|
| `responsibid` | Everyone | `quote-intake` |
| `responsibid-coach` | Support and coaches, for company onboarding | `company-onboarding`, `pricing-setup`, `follow-up-rewrite` |

`responsibid` provides the ResponsiBid MCP server. `responsibid-coach` depends on it, so installing the coach plugin also installs `responsibid`, and both share one server and one sign-in. The server lists only the tools your login's scopes allow, so the pricing-setup tools appear only for coach accounts. Follow-up sequences and pricing are company-wide settings, so their skills live in the coach plugin.

## Skills

| Skill | Use it to | MCP tools |
|---|---|---|
| `quote-intake` | Find the service, find or create the customer, price a quote, record their package or bundle, sign, and book an appointment. Also answers questions about existing quotes. | `get_catalog`, `find_contact_by_phone`, `create_contact`, `compute_pricing`, `create_bid`, `get_proposal`, `select_proposal_package`, `select_proposal_bundle`, `confirm_signature`, `request_scheduling_slots`, `confirm_appointment`, `list_bids`, `get_bid` |
| `company-onboarding` | Take a newly signed company through setup in order: house sizes, prices, packages, bundles, then follow-ups | Uses the two skills below |
| `pricing-setup` | Change house sizes, house-size prices, option prices, packages, and bundle auto-add. Every write is previewed and needs the user's approval. | `get_catalog`, `get_service_pricing`, `manage_house_sizes`, `set_house_size_prices`, `set_option_price`, `set_packages`, `set_bundle_auto_add`, `compute_pricing` |
| `follow-up-rewrite` | Review and rewrite the automated emails and texts sent after a quote or job | `list_follow_up_sequences`, `get_follow_up_sequence`, `list_follow_up_steps`, `update_follow_up_step` |

## Install

### Claude Code

1. Add the marketplace:

   ```
   /plugin marketplace add Symphosize/responsibid-plugins
   ```

2. Install one plugin. Coaches install `responsibid-coach`, which brings `responsibid` with it:

   ```
   /plugin install responsibid@responsibid
   /plugin install responsibid-coach@responsibid
   ```

3. Run `/reload-plugins`, then `/mcp`. Choose the `responsibid` server and sign in. Your browser opens the ResponsiBid sign-in page. After you sign in, it returns to `http://localhost:8976/callback`, so keep port 8976 free during login.

Updates: third-party marketplaces don't auto-update by default. Run `claude plugin update responsibid` (or `responsibid-coach`), then `/reload-plugins`.

To point at another server, set `RESPONSIBID_MCP_URL` before you start Claude Code:

```
RESPONSIBID_MCP_URL=https://<host>/mcp claude
```

To test local changes, add a local checkout instead of the GitHub repo:

```
/plugin marketplace add ./path/to/responsibid-plugins
```

### Codex

Open this repo in Codex. It reads `.agents/plugins/marketplace.json`. Install `responsibid` or `responsibid-coach` from the plugin browser, then sign in to ResponsiBid when prompted.

### claude.ai

claude.ai doesn't install plugins, so add the connector and the skills separately.

Connector:

1. Go to **Customize → Connectors → Add custom connector**. On Team and Enterprise plans, an owner does this under **Organization settings → Connectors**.
2. Set the MCP server URL to `https://api-connect.bids.responsibid.com/mcp`.
3. Under **OAuth client**, choose **Use your own OAuth client** and enter the client ID `ec0efc64-4415-4758-b912-4f7cede1b9c1`. Leave the secret empty.
4. Save and sign in. ResponsiBid returns you to `https://claude.ai/api/mcp/auth_callback`. You can't change auth settings after adding the connector; remove it and add it again instead.

Skills: zip each skill folder, then upload each zip in **Customize → Skills → + → Create skill → Upload a skill**.

```
cd plugins/responsibid/skills && zip -r ~/quote-intake.zip quote-intake
cd plugins/responsibid-coach/skills && for s in */; do zip -r ~/"${s%/}".zip "$s"; done
```

Uploaded skills are private to your account. Team and Enterprise owners can share them with the organization.

## MCP connection

| | Value |
|---|---|
| URL | `https://api-connect.bids.responsibid.com/mcp` (production, the default). Override it with `RESPONSIBID_MCP_URL`. |
| OAuth client ID | `ec0efc64-4415-4758-b912-4f7cede1b9c1` |
| Allowed redirect URIs | `https://claude.ai/api/mcp/auth_callback` (claude.ai), `http://localhost:8976/callback` (Claude Code) |

The Claude Code config is in `plugins/responsibid/.mcp.json`, the only plugin that declares the server.

## Layout

Each plugin carries both clients' files. Keep them in sync when you change one.

| File | Read by |
|---|---|
| `.claude-plugin/marketplace.json` | Claude Code |
| `.agents/plugins/marketplace.json` | Codex |
| `plugins/*/.claude-plugin/plugin.json` | Claude Code |
| `plugins/*/plugin.json` | Codex / ChatGPT |
| `plugins/responsibid/.mcp.json` | Claude Code (`type: http`, with `oauth`) |
| `plugins/*/mcp.json` | Codex / ChatGPT (`type: streamable-http`) |
| `plugins/*/skills/*/SKILL.md` | Both |
| `plugins/*/evals/` | `claude plugin eval` |

Write skills in neutral wording ("the assistant", not a product name). Codex and ChatGPT drop Claude-only features such as hooks. Skills should match the tool descriptions in the server's `apps/connect/src/app/mcp/tools`; when a tool changes, update the skill that uses it.

Bump `version` in both of a plugin's `plugin.json` files whenever you change it. Installed copies don't update until the version changes.

## Evals

Each plugin has an eval suite under `evals/`. It runs the skills against mocked MCP tools, so it never calls the real server. Run it before you release a skill change:

```
cd plugins/responsibid && claude plugin eval .
claude plugin eval plugins --eval-dir responsibid-coach/evals
```

The coach suite runs from `plugins/` because its cases also load `responsibid`, which provides the server. Each case checks that the skill fired, plus one rule it must keep. For example, a price check must not create a bid, a vague "the middle one" must be confirmed first, and nothing is saved before the user approves. Shared mocks are in `evals/mocks/responsibid/`. Add a case whenever you add a rule to a skill.
