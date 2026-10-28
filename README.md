# ResponsiBid plugins

Plugin marketplace for Claude Code and Codex. It connects the assistant to the ResponsiBid MCP server and adds skills for quoting and for setting up a company during onboarding.

| Plugin | For | Skills |
|---|---|---|
| `responsibid` | Everyone | `quote-intake`, `photo-quote`, `customer-quote-page` |
| `responsibid-coach` | Support and coaches, for company onboarding | `company-onboarding`, `pricing-setup`, `follow-up-rewrite` |

`photo-quote` and `customer-quote-page` build on `quote-intake`, so install the three together. On claude.ai, upload all three skill zips. `photo-quote` shows prices from a price check that saves nothing, then saves the quote and starts the follow-up on one Send tap. It reads the company's follow-up sequence to say in one line what that tap will set off. If a login can't read follow-ups, it says so before sending.

`responsibid` provides the ResponsiBid MCP server. `responsibid-coach` depends on it, so installing the coach plugin also installs `responsibid`, and both share one server and one sign-in. The server lists only the tools your login's scopes allow, so the pricing-setup tools appear only for coach accounts. Follow-up sequences and pricing are company-wide settings, so their skills live in the coach plugin.

## Skills

| Skill | Use it to | MCP tools |
|---|---|---|
| `quote-intake` | Find the service, find or create the customer, price a quote, record their package or bundle, sign, and book an appointment. Also answers questions about existing quotes. | `list_catalog_services`, `list_service_areas`, `list_lead_sources`, `list_house_sizes`, `find_contact_by_phone`, `create_contact`, `compute_pricing`, `create_bid`, `get_proposal`, `select_proposal_package`, `select_proposal_bundle`, `confirm_signature`, `request_scheduling_slots`, `confirm_appointment`, `list_bids`, `get_bid` |
| `photo-quote` | Build a quote from photos of a property in two replies: photos plus the customer, then one round of quick choices. Counts what the photos show, offers only the services they show a need for, asks only what changes the price, shows the prices from a price check that saves nothing, then saves and sends the quote on one more tap. Finds returning customers by phone, name, email, address or quote number. | `list_catalog_services`, `list_house_sizes`, `find_contact_by_phone`, `find_contact`, `list_bids`, `get_bid`, `list_follow_up_sequences`, `get_follow_up_sequence`, `compute_pricing`, `create_bid`, `get_proposal` |
| `customer-quote-page` | Build a one-file page for a saved quote: what the photos showed, packages with a running total, upsells, the customer's proposal link, links into ResponsiBid for staff, and a company-only "How this quote was built" section. | `get_proposal`, `get_bid` |
| `company-onboarding` | Take a newly signed company through setup in order: house sizes, prices, packages, bundles, then follow-ups | Uses the two skills below |
| `pricing-setup` | Change house sizes, house-size prices, option prices, packages, and bundle auto-add. Every write is previewed and needs the user's approval. | `list_catalog_services`, `list_house_sizes`, `get_service_pricing`, `manage_house_sizes`, `set_house_size_prices`, `set_option_price`, `set_packages`, `set_bundle_auto_add`, `compute_pricing` |
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

3. Run `/reload-plugins`, then `/mcp`. Choose the `responsibid` server and sign in. Your browser opens the ResponsiBid sign-in page. After you sign in, it returns to `http://localhost:<port>/callback` on a port Claude Code picks for that login.

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

Open this repo in Codex. It reads `.agents/plugins/marketplace.json`. Install `responsibid` or `responsibid-coach` from the plugin browser, then sign in to ResponsiBid when prompted. You can also install a plugin from its `codex-*.zip` on the [Releases](https://github.com/Symphosize/responsibid-plugins/releases) page.

Codex signs in with the `codex` client and returns to `http://127.0.0.1:29353/callback/v9Www2EoKsOh`, so keep port 29353 free during login. The last part of that path is derived from the server URL, so a different server needs its own registered callback. To use one, add the server by hand with `codex mcp add` instead of using the plugin.

### ChatGPT

A workspace admin uploads `chatgpt-responsibid.zip` (and `chatgpt-responsibid-coach.zip` for coaches) from the [Releases](https://github.com/Symphosize/responsibid-plugins/releases) page in the ChatGPT admin console, under **Plugins → Add → Upload plugin**. The zip includes the skills and the MCP server, already set up for the `chatgpt-v2` OAuth client. When ChatGPT asks for the **OAuth Client Secret** under **MCPs → Connect**, enter it from the team's password manager. The secret is never in the zip or this repo.

A plugin uploaded in ChatGPT also syncs to the Codex app, and current Codex versions drop its server because of the OpenAI auth block ([openai/codex#53658](https://github.com/openai/codex/issues/53658)). In Codex, install the Codex plugin instead.

### claude.ai

claude.ai doesn't install plugins, so add the connector and the skills separately.

Connector:

1. Go to **Customize → Connectors → Add custom connector**. On Team and Enterprise plans, an owner does this under **Organization settings → Connectors**.
2. Set the MCP server URL to `https://api-connect.bids.responsibid.com/mcp`.
3. Under **OAuth client**, choose **Use your own OAuth client** and enter the client ID `claude`. Leave the secret empty.
4. Save and sign in. ResponsiBid returns you to `https://claude.ai/api/mcp/auth_callback`. You can't change auth settings after adding the connector; remove it and add it again instead.

Skills: download each `claude-skill-*.zip` from the [Releases](https://github.com/Symphosize/responsibid-plugins/releases) page and upload it in **Customize → Skills → + → Create skill → Upload a skill**.

Uploaded skills are private to your account. Team and Enterprise owners can share them with the organization.

## MCP connection

| | Value |
|---|---|
| URL | `https://api-connect.bids.responsibid.com/mcp` (production, the default). Override it with `RESPONSIBID_MCP_URL`. |
| OAuth clients | Claude and claude.ai: `claude`. Codex: `codex`. ChatGPT: `chatgpt-v2`, whose secret is entered in ChatGPT and never committed. |
| Allowed redirect URIs | `https://claude.ai/api/mcp/auth_callback` (claude.ai), `http://localhost:<any port>/callback` (Claude Code), `http://127.0.0.1:29353/callback/v9Www2EoKsOh` (Codex), `https://chatgpt.com/connector/oauth/Cg9ws4-JyVGV` (ChatGPT) |

The Claude Code config is in `plugins/responsibid/.mcp.json`; in Claude Code, only that plugin declares the server. The Codex config is in `plugins/*/.codex.mcp.json`, and the ChatGPT config is in `plugins/*/.chatgpt.mcp.json`.

## Layout

Each plugin carries both Claude's and Codex's files. Keep them in sync when you change one.

| File | Read by |
|---|---|
| `.claude-plugin/marketplace.json` | Claude Code |
| `.agents/plugins/marketplace.json` | Codex |
| `plugins/*/.claude-plugin/plugin.json` | Claude Code |
| `plugins/*/.codex-plugin/plugin.json` | Codex |
| `plugins/responsibid/.mcp.json` | Claude Code (`type: http`, with `oauth`) |
| `plugins/*/.codex.mcp.json` | Codex (`type: http`, with the `codex` OAuth client) |
| `plugins/*/.chatgpt.mcp.json` | ChatGPT (becomes `mcp.json` in the ChatGPT zip; `plugin.json` is built from the Codex manifest) |
| `plugins/*/assets/` | Codex and ChatGPT icons |
| `plugins/*/skills/*/SKILL.md` | Claude, Codex and ChatGPT |
| `scripts/package.sh` | The release workflow, which builds the zips |
| `plugins/*/evals/` | `claude plugin eval` |

Write skills in neutral wording ("the assistant", not a product name). Codex and ChatGPT drop Claude-only features such as hooks. Skills should match the tool descriptions in the server's `apps/connect/src/app/mcp/tools`; when a tool changes, update the skill that uses it.

Bump `version` in both of a plugin's `plugin.json` files whenever you change it. Installed copies don't update until the version changes.

## Release

See [RELEASE.md](RELEASE.md).

## Evals

Each plugin has an eval suite under `evals/`. It runs the skills against mocked MCP tools, so it never calls the real server. Run it before you release a skill change:

```
cd plugins/responsibid && claude plugin eval .
claude plugin eval plugins --eval-dir responsibid-coach/evals
```

The coach suite runs from `plugins/` because its cases also load `responsibid`, which provides the server. Each case checks that the skill fired, plus one rule it must keep. For example, a price check must not create a bid, a vague "the middle one" must be confirmed first, and nothing is saved before the user approves. Shared mocks are in `evals/mocks/responsibid/`. Add a case whenever you add a rule to a skill.
