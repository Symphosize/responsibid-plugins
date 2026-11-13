---
name: new-account-setup
description: Set up a newly signed ResponsiBid company from its setup brief — turn on the right services, set prices, minimums, trip charge, service areas, then follow-ups — for a coach on a setup call now, and for the company owner later. Trigger on "set up this account", "new account setup", or a pasted brief starting "Use the new-account-setup skill".
---

# New account setup

Set up a newly signed company from its setup brief. The brief comes from the Biz App and lists the company, ResponsiBid company id, coach, form status, services with pricing method/minimum/drivers/add-ons/prices, top services, package count, house sizes, ZIP + radius, trip charge, hourly rate, website, lead sources, asset links, and "Open items".

## Input

If the user pastes a brief or says "set up this account" or "new account setup", use it. If no brief is given, ask for the few facts needed (which services, prices) as short plain questions with typed dollar amounts, not multiple choice.

If `set_service_settings`, `add_service_areas` or any write tool a step below needs isn't available, setup can't run on this connection. Either ResponsiBid hasn't been updated yet, or the connection didn't approve the setup permissions. If `list_catalog_services` also has no `include_disabled` input, it's the older version: tell the coach to try again after the update. Otherwise tell the coach to reconnect ResponsiBid and approve the setup permissions, or ask ResponsiBid support. Stop either way, and don't describe any change as made.

## Coach connection

A coach connection reaches one customer, lasts 8 hours, is limited to setup permissions, and replaces the coach's normal connection in that app. When it ends, ask the coach to reconnect.

## Read and confirm the account

Call `list_catalog_services` once with `include_disabled: true`. Its reply gives the connected company's ResponsiBid company id (`company.id`) and every sub-service, switched on or off. Tell the coach the connected company id and the brief's company name. Get an explicit "yes, that's the company" before any write.

Stop with no writes at all when:
- the brief's id and `company.id` differ. Tell the coach to reconnect ResponsiBid and, on the consent page, choose "a customer's company" and pick the customer named in the brief, then start again;
- the reply has no `company.id`, or `list_catalog_services` has no `include_disabled` input. The connection is on an older ResponsiBid version: tell the coach to try again after the update;
- `list_catalog_services` refuses `include_disabled` for lack of a permission. Tell the coach to reconnect ResponsiBid and approve the setup permissions;
- the brief has no id, or id "unknown", and the coach has not checked the connected company id in ResponsiBid and said it is this customer.

Also call `list_house_sizes` and `list_service_areas`, and call `get_service_pricing` one service at a time for each service the brief names that already has a sub-service on. A sub-service that is off has no readable pricing. Draft its prices from the brief now; read its pricing after it is turned on in step 1 below.

Show a brief-service → sub-service mapping table and get confirmation. Never turn a sub-service off unless the coach asks; leave sub-services that are on and not in the brief alone.

## Draft the plan (plan approval is not write approval)

Prepare the complete draft and show it as one plan the user can approve or edit. Approving the plan only confirms the intent. Every write still needs its own preview and approval.

- Only plan what the brief states. If "Form: in progress", plan only stated items; if "not started", plan nothing priced. Everything missing goes to homework.
- Never invent a price, size, minimum or city that isn't in the brief or confirmed by the coach.
- Show the mapping table (confirmed).
- For each sub-service: the brief's one minimum for every enabled package, with `minimum_enabled: true`. A minimum has no effect on quotes while `minimum_enabled` is off.
- Trip charge: the tool only turns it on or off; it cannot set a dollar amount. If the brief gives an amount, put "set the trip charge amount to $X in the app" on homework.
- Read every service's Notes for a fee or minimum tied to a place (a town, county, ZIP or distance), such as "Jobs in Towns County incur a $25 fee". That is a trip charge or minimum per area, which the tools cannot set: show it to the coach, ask whether it replaces the company-wide trip charge, and put it on homework with the place and amount. Do this even when the brief says the trip charge was not answered.
- Service areas: any city list from ZIP + radius is a draft the coach must check (no tool converts it). Send at most 50 cities per call. For more, split the list into batches of up to 50, each with its own preview and approval. Any city not added goes on homework.
- This skill doesn't change follow-ups itself. List the sequences, show their wording, and ask whether to change anything. If yes, use the follow-up-rewrite skill; if not, add "review follow-up wording" to homework.

## Apply in order

Every write follows the preview, approve, apply rules in the pricing-setup skill. In short: preview first by calling the write tool without `apply` and showing its reply (a description of the change is not a preview), and apply only after the coach approves in a message sent after seeing that preview (approving the plan does not count). Report a change as saved only when the reply says `applied: true`.

This is a live customer account, and every change is live at once. To keep a change from landing in the wrong account:
- Name the customer in every approval request, with the brief's company name and id, for example "Apply these to Crystal Clear Window Cleaning (#1234)?"
- Right before the first write, call `list_catalog_services` again and check that `company.id` still matches the brief. Check again before the next write whenever the connection was renewed or switched, or a call failed for sign-in or permission. If it differs, stop with no further writes and tell the coach.
- Keep a change log as you go: for each saved change, what changed, the old value and the new value. Show it to the coach at the end, or when setup stops early, so a wrong change can be put back by hand. It is for the coach, not the owner's homework message.

1. Turn on the brief's sub-services: `set_service_settings` with `sub_service_id` and `enabled: true`, one sub-service per call. Then read each service's pricing with `get_service_pricing`. A sub-service that is on can be quoted at once, before its prices and minimum are set. Keep track of which are still unpriced; if setup stops before steps 2–5 finish for one, tell the coach and put "set prices and minimum for <sub-service>: it's on and can be quoted now" on homework.
2. House sizes (pricing-setup).
3. Packages (pricing-setup): count, which are on, hourly rate.
4. Prices (pricing-setup), after packages.
5. Minimums and trip charge on or off: `set_service_settings` per sub-service. Show a per-package table. Ask if the trip charge is unclear.
6. Service areas: `add_service_areas` with the confirmed cities. After the apply, report the `created`, `already_present`, `failed` and `not_confirmed` cities. Check any `not_confirmed` city with `list_service_areas` before trying it again. Failures go to homework. Never call `remove_service_area` unless the coach asks.
7. Bundle auto-add (pricing-setup).
8. Follow-ups, only if the coach asked (follow-up-rewrite).
9. Test quote: call `compute_pricing` with an inline property (city and ZIP inside a confirmed service area, a house size from the brief, and the number of stories) and the top service's enabled sub-service. Ask the coach for the city or stories if the brief doesn't give them. This is a price check only.

## Finish with homework

The final homework list and the draft message must always include the four things the tools cannot do:
- Copy a service from the master template
- Trip charge or minimum per area
- Logo and email images
- Send a test email

Plus the brief's open items, anything skipped or failed, any sub-service left on without prices or a minimum, and "review follow-up wording" if not changed.

The homework message goes to the company owner (the coach sends it). Address it to the brief's Contact by first name when there is one. When the owner is running the skill themself, address them directly and give them the list instead.

The skill never sends the message, never creates a bid, never starts a follow-up, never creates a contact.
