---
name: pricing-setup
description: Help a ResponsiBid company set up or change its pricing - house sizes, house-size prices, option prices, per-sq-ft measurement rates, packages, and bundle auto-add. Use when an admin, support person, or coach is configuring a company's prices.
---

# Pricing setup

If `get_service_pricing` and the other tools below aren't available, this connection wasn't given pricing access. Say so, tell the user to reconnect ResponsiBid and approve the pricing permissions or ask ResponsiBid support, and stop. Don't describe the change as if it were made.

Each tool's description explains its inputs and what the pricing terms mean. This skill sets the order and the approval rules.

## Read first

1. Get the `service_id` from `list_catalog_services`. A service whose sub-services are all switched off is listed only with `include_disabled: true`. If the tool has no `include_disabled` input, tell the user that service is switched off and must be turned on in the app first, and stop for that service.
2. Call `get_service_pricing` and get every other ID from its reply. Each question's `pricing` says where its price lives. When several services need reading, read them one at a time.
3. A switched-off sub-service has no readable pricing. Turning it on is a change like any other: preview `set_service_settings` with `enabled: true`, get approval, then apply, before reading its prices.
4. Before changing anything, point out `unpricedHouseSizeIds`, `orphanedHouseSizeIds`, and any `suffixUnreadable` sub-service.

## Pick the tool

| Change | Tool |
|---|---|
| Add, rename, reorder, or remove house sizes | `manage_house_sizes`. A new size quotes $0 until you set its prices with `set_house_size_prices`. |
| Prices per house size (a question whose `pricing` is `band` or `access`) | `set_house_size_prices` |
| Price of one answer (a question whose `pricing` is `options`) | `set_option_price`. Answers of other questions carry no price. |
| Rate per measured sq ft (a question whose `pricing` is `rate`) | `set_measurement_rate`. The rate is on the question, not its answers. Use `side: "mirrored"` for the mirrored side. |
| Packages | `set_packages`. Re-read the service right before saving, because name, enabled, and hourly rate overwrite whatever is stored. |
| Bundle auto-add | `set_bundle_auto_add` |
| Turn a sub-service on or off, its trip charge on or off, minimums per package | `set_service_settings`. It works on one sub-service; a service has no switch of its own. |

Prices in hours or minutes need the package's hourly rate. If the package has none, set it with `set_packages` first; the price tools refuse otherwise.

## Preview, approve, apply

1. Call the tool without `apply`. A reply with `preview: true` saved nothing. A `noChange` reply means the values already match, so stop there.
2. Show the user the before, the after, and the warnings, using dollars and package names (the preview's `context` has the names).
3. Wait for approval. It must be a message the user sends after seeing this preview; an earlier "go ahead" on a plan does not count. One approval may cover several previews if all of them were shown before it.
4. Then repeat the same call with `apply: true` and the `previewToken` the preview returned as `preview_token`.

Report a change as saved only when the reply says `applied: true`. If the apply returns `STORED_VALUE_CHANGED` or `PREVIEW_EXPIRED`, preview again and get a fresh approval. When the change is saved, call `get_service_pricing` again to confirm it.
