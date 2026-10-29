---
name: pricing-setup
description: Help a ResponsiBid company set up or change its pricing - house sizes, house-size prices, option prices, per-sq-ft measurement rates, packages, and bundle auto-add. Use when an admin, support person, or coach is configuring a company's prices.
---

# Pricing setup

If `get_service_pricing` and the other tools below aren't available, this connection wasn't given pricing access. Say so, tell the user to reconnect ResponsiBid and approve the pricing permissions or ask ResponsiBid support, and stop. Don't describe the change as if it were made.

Each tool's description explains its inputs and what the pricing terms mean. This skill sets the order and the approval rules.

## Read first

1. Get the `service_id` from `list_catalog_services`.
2. Call `get_service_pricing` and get every other ID from its reply.
3. Before changing anything, point out `unpricedHouseSizeIds`, `orphanedHouseSizeIds`, and any `suffixUnreadable` sub-service.

## Pick the tool

| Change | Tool |
|---|---|
| Add, rename, reorder, or remove house sizes | `manage_house_sizes`. A new size quotes $0 until you set its prices with `set_house_size_prices`. |
| Prices per house size | `set_house_size_prices` |
| Price of one answer | `set_option_price` |
| Rate per measured sq ft (a question whose `pricing` is `rate`) | `set_measurement_rate` |
| Packages | `set_packages`. Re-read the service right before saving, because name, enabled, and hourly rate overwrite whatever is stored. |
| Bundle auto-add | `set_bundle_auto_add` |

## Preview, approve, apply

1. Call the tool without `apply`. A `noChange` reply means the values already match, so stop there.
2. Show the user the before, the after, and the warnings, using dollars and package names.
3. Wait for approval. Then repeat the call with `apply: true` and the `preview_token` it returned.

If the apply returns `STORED_VALUE_CHANGED`, preview again and get a fresh approval. When the change is saved, call `get_service_pricing` again to confirm it.
