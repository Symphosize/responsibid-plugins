---
name: company-onboarding
description: Walk a coach through setting up a newly signed ResponsiBid company end to end - house sizes, prices, packages, bundles, then follow-up sequences. Use when the user is onboarding a new company or asks how to get a company's account set up.
---

# Company onboarding

Set the company up in this order. Each step depends on the one before it.

1. **Read what exists.** Call `list_catalog_services` and `list_house_sizes`, then `get_service_pricing` for each service. Summarize what's already set and what's missing before you suggest any change.
2. **House sizes.** Every price per house size depends on these.
3. **Prices per house size, then option prices and measurement rates.**
4. **Packages:** names, which are enabled, hourly rate, and "price per" rules.
5. **Bundle auto-add.**
6. **Follow-up sequences.** Do these last, once the quotes they follow up on are priced correctly.

Steps 2–5 follow the `pricing-setup` skill, and step 6 follows the `follow-up-rewrite` skill. Each step needs the user's approval before anything is saved. After each step, say what's next and ask whether to continue.
