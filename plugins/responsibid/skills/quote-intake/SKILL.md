---
name: quote-intake
description: Take a customer's request for a home-service quote (bid) through ResponsiBid, from finding the service to a priced proposal and a booked appointment. Also answers questions about quotes already made. Use when the user wants to create, price, look up, or book a quote or bid.
---

# Quote intake

"Quote" and "bid" mean the same thing. Each tool's description covers its inputs. This skill sets the order and the rules that span tools. Never invent an ID, an answer, or a price.

## 1. Find the service and the customer

1. Call `list_catalog_services`, `list_service_areas`, `list_lead_sources` and `list_house_sizes`. If what the customer asked for doesn't clearly match one service by name, ask which listed service they meant. The other listed services are add-ons you can offer.
2. Call `find_contact_by_phone`. Call `create_contact` only if nothing matches.

## 2. Ask the service's questions

Ask in plain language, one or two at a time. If the customer doesn't know an answer, say so and ask what they can tell you. For a home, offer only residential house sizes.

## 3. Price it

- **Price check only** ("how much would it be?"): call `compute_pricing`. Don't create a bid.
- **A real quote:** call `create_bid` with one `idempotency_key`. Reuse the same key on any retry. Then call `get_proposal`.

Read prices back exactly as `get_proposal` gives them. Never quote prices from `list_bids` or `get_bid`, because they are rounded.

## 4. Record the customer's choice

- **Package:** use `select_proposal_package`.
- **Bundle:** use `select_proposal_bundle`, only when `get_proposal` lists bundles.
- **Vague answers:** if the customer says "the middle one" or "the cheaper one", state the exact package name and price you think they mean. Call the tool only after they confirm.

## 5. Book it

1. **Sign:** call `confirm_signature` with `agreed: true`. When scheduling is on, its reply already lists the open times. Don't call `request_scheduling_slots` for those.
2. **Earlier signature:** call `request_scheduling_slots` only for a bid that was signed before this conversation.
3. **Book:** call `confirm_appointment` with the slot the customer picked and one `idempotency_key`.

This only books a first appointment. To move or cancel one, tell the customer to contact the company.

## Existing quotes

Find a customer's quotes with `list_bids` and read one with `get_bid`. If a write fails, call `get_bid` or `get_proposal` before retrying. The change may already be saved.
