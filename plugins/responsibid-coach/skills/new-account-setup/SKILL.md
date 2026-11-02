---
name: new-account-setup
description: Set up a newly signed ResponsiBid company from its setup brief — turn on the right services, set prices, minimums, trip charge, service areas, then follow-ups — for a coach on a setup call now, and for the company owner later. Trigger on "set up this account", "new account setup", or a pasted brief starting "Use the new-account-setup skill".
---

# New account setup

Set up a newly signed company from its setup brief. The brief comes from the Biz App and lists the company, ResponsiBid company id, coach, form status, services with pricing method/minimum/drivers/add-ons/prices, top services, package count, house sizes, ZIP + radius, trip charge, hourly rate, website, lead sources, asset links, and "Open items".

## Input

If the user pastes a brief or says "set up this account" or "new account setup", use it. If no brief is given, ask for the few facts needed (which services, prices) as short multiple-choice questions.

## Confirm the account

Before any change, call `list_catalog_services`. Its reply names the connected company (`company.id` and `company.name`). Compare the id with the brief's ResponsiBid company id; when the brief has no id, compare the name. If they don't match, stop and say so: the coach may be connected to the wrong account.

## Order

1. **Read first.** Call `list_catalog_services` with `include_disabled: true` (switched-off services are the ones to turn on), `list_house_sizes`, and `list_service_areas`. Summarise what is on/off and what the brief asks for.

2. **Draft the whole plan.** Prepare the complete draft build at once and show it as one plan the user can approve or edit:
   - Services to turn on
   - Prices per service
   - Minimums
   - Trip charge
   - Service areas
   - What stays for homework

   This is the "draft before the call" so the call is for confirming, not collecting.

3. **Apply in order.** Every write previews, shows before/after in dollars and package names, waits for approval, then applies with the preview token. Group approvals per service so the user approves one service's changes at a time.

   - Turn services on with `set_service_settings` (use `enabled: true`)
   - House sizes with `manage_house_sizes` and `set_house_size_prices` (follow `pricing-setup`)
   - Prices (follow `pricing-setup`)
   - Minimums and trip charge with `set_service_settings` (use `minimums`, `trip_charge_enabled`, `minimum_enabled`)
   - Service areas with `add_service_areas`, using the brief's ZIP/radius to propose nearby cities and asking the user to confirm the list
   - Packages with `set_packages`
   - Bundle auto-add with `set_bundle_auto_add`
   - Follow-ups last (follow `follow-up-rewrite`)

4. **Test a quote.** Call `compute_pricing` for the top service and show the price.

5. **Finish with homework.** List the open items from the brief plus anything skipped. Draft a short homework message the coach can send — the skill never sends it, never creates a bid, and never starts a follow-up.

## What the tools cannot do yet

Say plainly what the tools cannot do yet, so the coach does it in the app:
- Copy a service from the master template
- Trip charge or minimum per area
- Logo and email images
- Test email
