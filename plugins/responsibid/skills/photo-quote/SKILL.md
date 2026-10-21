---
name: photo-quote
description: Build a ResponsiBid quote (bid) from photos of a property in two replies from the user - photos plus the customer, then one round of quick choices - and save it. Count what the photos show, offer only the services the photos show a need for, ask only what changes the price, save, and hand back the prices and links. Also quotes a returning customer found by phone or quote number. Use when someone shares photos of a home or building and asks for a quote, an estimate, or to "price this house" for exterior services such as house washing, windows, roof, gutters, flatwork, or deck.
---

# Photo quote

Target: **two replies from the user.**

1. Their first message: photos, plus the customer. A new customer is name, mobile, email, street address and ZIP. A returning customer is a phone number or a quote number.
2. One round of quick choices from you. Then the quote is saved and you show the prices and links.

Everything else happens without the user: looking up the customer, reading the catalog, counting, saving, reading back.

The `quote-intake` skill holds the rules for every quote: one `idempotency_key` per `create_bid`, reading prices only from `get_proposal`, and confirming a vague package choice. Follow it. Where it asks one or two questions at a time, this skill groups up to four, because the user is a tech answering with taps, not a customer. If `quote-intake` isn't installed, follow the same rules from the tool descriptions.

## Ground rules

- **Count from the photos.** Panes per side in the account's pane types, screens on windows that open, doors with glass, stories, rough measurements.
- **Offer only what the photos show.** Offer a service only when its trigger in the table below is visible or described. Otherwise don't offer it and don't estimate it; the user can still name it. Never assume gutters because of trees, or a deck because of a back yard.
- **Ask only what changes the price.** Check each catalog question's price effect for this quote. A question with no price effect goes in the notes, not the round.
- **Ask what a tech knows at a glance.** Grid type, screens, hard water and gutter guards can't be read reliably from photos. Ask them as one "check all that apply" question. Don't reason them out unless the user asks you to.
- **Show what you filled in.** Before the round, list in one line the measurements you took from the photos, such as gutter run, downspouts, driveway size, wall material and service area. Say the user can change any of them.
- **Use the account's own words.** Pane types, option names and package names come from the catalog.
- **Never invent customer details.** If the user says it's a test, use what they give you.

## What each service needs to see

| Service | Offer it only when the photos show | Count or estimate from the photos |
|---|---|---|
| Window cleaning | Windows or glass doors | Panes per side by pane type; screens on windows that open |
| House washing | Siding or another wall surface | Wall material (ask only if it could change the price); note algae or dirt |
| Roof cleaning | Moss, algae streaks or debris on the roof | Roof type; moss coverage (notes unless it changes the price) |
| Gutter cleaning | Gutter troughs on the eaves, or downspouts | Linear feet of guttered eaves; downspouts counted |
| Flatwork | Driveway, walkway or patio surface | The size option that matches |
| Deck cleaning | Deck boards or railings | Rough area; railing feet; stair steps |

Match each row to the account's own service names in the catalog. Interior services such as blinds are never offered from exterior photos.

## Steps

### 1. Find or check the customer (no questions)

- **Returning customer** (phone or quote number given): find them with `find_contact_by_phone`, or `get_bid` for a quote number. Then call `list_bids` with that `contact_id`, and `get_proposal` on recent bids to read their addresses and `property_id`. One address: reuse it. Several: ask "Which address?" in the round.
- **New customer:** call `find_contact_by_phone` with the mobile. If it matches, `create_bid` would attach the quote to that contact, so ask "This number belongs to <name>. Use that record?" in the round.
- **Customer missing from the first message:** ask for it in the same reply as the round, and leave the save choice out until it arrives.
- **Service area:** match the customer's city or ZIP to the catalog's service areas. Ask only if nothing matches.
- **Lead source:** set it only if the user mentioned one.

### 2. Load the catalog

Call `get_catalog` with `services` set to the requested service plus every service whose trigger is visible. For a home, use only residential house sizes.

### 3. Read the follow-up once

Call `list_follow_up_sequences`, then `get_follow_up_sequence` for the sequence whose default marker is `open`. Count its enabled EMAIL, SMS and WEBHOOK steps and note when the first email and first text go out. Skip disabled steps. An email step with no email on file reaches no one; say so. Do this once per conversation. It becomes one line in the save choice. If the follow-up tools aren't available to this login, say you can't show what the quote will send.

### 4. Show the counts, then the one round

First, a short text block:
- One line of counts: windows, panes by type, screens, stories.
- One line on what you filled in from the photos.
- For a returning customer, one line naming who and where.

Then one round of at most four questions, two to four options each. Use a multiple-choice menu where the client offers one; otherwise a short numbered list answered with one number or letter per question.

1. **Services** (pick several): the services the photos triggered, each option naming what you counted. Put any service the user asked for first.
2. **Which of these are true?** (pick several, none is fine): the yes/no facts that change price for the offered services, such as screens on most windows, hard water, raised grids on the outside, or gutter guards. Each option names its price effect.
3. **Stories and house size** (pick one): combined options with your estimate first, labeled as your estimate. Name the price effect where it differs, such as a story charge or bid in person.
4. **Save** (pick one): the question states who gets what. For example: "Saving sends Jane 1 text (555-010-0100, in about an hour) and posts to 1 webhook; there's no email on file." The options are "Save and send" and "Prices only, don't save". Don't call `create_bid` until the user picks "Save and send". That pick covers only the sends you named.

A customer question (a phone match, or which address) replaces a question that changes nothing for this quote.

"Save and send" is the approval to save, so there's no separate `compute_pricing` check. Run `compute_pricing` only for "Prices only, don't save". Show its table and offer to save.

### 5. Save

Call `create_bid` with every picked service in `selections`. Use `contact_id`/`property_id`, or the inline contact and property. Write `notes` with:
- the photo counts per side
- what was filled in from the photos
- every answer
- what to confirm on site

If it fails with "This submission has been blocked by the company", nothing was created. The company's block list matched one of the contact or property details, and the error doesn't say which. Don't retry to find out. Offer different details, or the blocked list in ResponsiBid.

### 6. Show the result

Call `get_proposal`, then reply with:
- **Saved: quote #id for <name>**, and the customer's `proposalLink`.
- One table: service by package by price. Show a bid-in-person service as "Bid in person", never as $0.
- One line naming any service the account attached on its own. A company's auto-added services can join a new quote; don't present them as the user's choice.
- One line on when the follow-up's first email and text go out.
- One line offering the customer page, built with the `customer-quote-page` skill only if the user asks.

`pricingStatus: "queued"` in the `create_bid` reply is a fixed word, not a live status.

## What the connector can't do

- **Edit or delete a saved quote.** To add work, create another quote with the same `contact_id` and `property_id`. To change or remove a quote, use the ResponsiBid app. Say so before the user assumes otherwise.
- **Attach photos.** Counts and findings go in the notes.
- **Find a customer by name, email or address.** Lookup works by phone number or quote number only.
- **Set up bundles.** Use `select_proposal_bundle` only on a quote whose `get_proposal` already lists bundles; on any other quote it fails with `BUNDLES_DISABLED`.
