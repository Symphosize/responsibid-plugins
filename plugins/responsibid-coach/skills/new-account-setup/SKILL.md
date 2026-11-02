---
name: new-account-setup
description: Set up a newly signed ResponsiBid company from its setup brief — turn on the right services, set prices, minimums, trip charge, service areas, then follow-ups — for a coach on a setup call now, and for the company owner later. Trigger on "set up this account", "new account setup", or a pasted brief starting "Use the new-account-setup skill".
---

# New account setup

Set up a newly signed company from its setup brief. The brief comes from the Biz App and lists the company, ResponsiBid company id, coach, form status, services with pricing method/minimum/drivers/add-ons/prices, top services, package count, house sizes, ZIP + radius, trip charge, hourly rate, website, lead sources, asset links, and "Open items".

## Input

If the user pastes a brief or says "set up this account" or "new account setup", use it. If no brief is given, ask for the few facts needed (which services, prices) as short plain questions with typed dollar amounts, not multiple choice.

If `set_service_settings` or `add_service_areas` aren't available, this connection has no setup access. Say so, tell the user to reconnect ResponsiBid and approve the setup permissions or ask ResponsiBid support, and stop. Don't describe the change as if it were made.

## Read and confirm the account

Call `list_catalog_services` once with `include_disabled: true`. Its reply gives the connected company (`company.id` and `company.name`) and all services (enabled and disabled). Tell the coach the connected company's id and name. Get an explicit "yes, that's the company" before any write.

If the brief's id does not match (or brief has id "unknown" or no id and names don't match), stop with no writes at all. If the brief has no id or id "unknown", ask the coach to confirm the company by name.

Also call `list_house_sizes`, `list_service_areas`, and for each service the brief names, call `get_service_pricing` one at a time before drafting prices.

Show a brief-service → sub-service mapping table and get confirmation. Never call `set_service_settings` with `enabled: false` unless the coach asks; leave enabled sub-services not in the brief alone.

When a service the brief names is not listed, the include_disabled call surfaces it.

## Draft the plan (plan approval is not write approval)

Prepare the complete draft and show it as one plan the user can approve or edit. This plan approval only confirms the intent; every write still needs its own preview + approval.

- Only plan what the brief states. If "Form: in progress", plan only stated items; if "not started", plan nothing priced. Everything missing goes to homework.
- Never invent a price, size, minimum or city that isn't in the brief or confirmed by the coach.
- Show the mapping table (confirmed).
- For each service: show the one minimum from brief proposed for every enabled package, with minimum_enabled true.
- Trip charge: the tool only turns it on/off; it cannot set a dollar amount. If brief specifies an amount, put "set the trip charge amount to $X in the app" on homework.
- Service areas: any city list from ZIP+radius is a draft the coach must check (no tool converts it). Never >50 per call.
- Follow-ups: read-only here — list sequences, show their wording, ask whether to change anything (then use follow-up-rewrite skill); otherwise add "review follow-up wording" to homework.
- Packages come before prices/minimums: state count, which enabled, set hourly via set_packages after re-reading the service.

## Apply in order (every write is previewed, shown, approved, then applied)

Every write tool call is previewed first (call without apply), the preview shown to the user in dollars and package names, approved, then applied with the preview_token. One approval message may cover several previews that were all shown.

Apply a service's enable step (`set_service_settings` with enabled:true) before previewing its prices or minimums.

On PREVIEW_EXPIRED or STORED_VALUE_CHANGED, re-preview and get fresh approval before applying.

Order:
1. Turn services on (set_service_settings enabled:true for brief's services)
2. House sizes (manage_house_sizes, set_house_size_prices — follow pricing-setup)
3. Packages (set_packages: count, enabled which, hourly rate; re-read service right before)
4. Prices (set_house_size_prices etc — follow pricing-setup; after packages)
5. Minimums + trip charge on/off (set_service_settings: one min per enabled package, minimum_enabled:true, show per-package table; trip_charge_enabled only — ask if unclear)
6. Service areas (add_service_areas with confirmed cities <=50; after apply report created / already_present / failed counts; failures go to homework. Never call remove_service_area unless coach asks, and then preview it first.)
7. Bundle auto-add (set_bundle_auto_add)
8. Follow-ups: read-only (see above); if changing, follow follow-up-rewrite skill (preview each step separately, its own token, re-preview on expired)
9. Test quote: call compute_pricing with an inline property (a ZIP inside a confirmed service area, a house size from the brief) and the top service's enabled sub-service. This is a price check only — never create a contact or a bid.

If a write tool is missing, say so and stop; don't describe changes as made.

## Finish with homework

The final homework list and the draft message must always include the four things the tools cannot do:
- Copy a service from the master template
- Trip charge or minimum per area
- Logo and email images
- Send a test email

Plus the brief's open items, anything skipped or failed, and "review follow-up wording" if not changed.

The homework message goes to the company owner (the coach sends it). When the owner is running the skill themself, address them directly and give them the list instead.

The skill never sends the message, never creates a bid, never starts a follow-up, never creates a contact.