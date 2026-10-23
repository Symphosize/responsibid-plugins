---
name: photo-quote
description: Build a ResponsiBid quote (bid) from photos of a property in two replies from the user - photos plus the customer, then one round of quick choices - price it with a price check that saves nothing, show the prices, and save it and send it to the customer on one more tap. Count what the photos show, offer only the services the photos show a need for, and ask only what changes the price. Also quotes a returning customer found by phone, name, email, address or quote number. Use when someone shares photos of a home or building and asks for a quote, an estimate, or to "price this house" for exterior services such as house washing, windows, roof, gutters, flatwork, or deck.
---

# Photo quote

Target: **two replies from the user, then one tap to save and send.**

1. Their first message: photos, plus the customer. A new customer is name, mobile, email, street address and ZIP. A returning customer is a phone number, name, email, address or quote number.
2. One round of quick choices from you. Then you price the quote with `compute_pricing`, which saves nothing, and show the prices.
3. One tap: "Send to <name>" saves the quote and starts the follow-up in one `create_bid` call. That is the moment the customer's messages are scheduled.

Everything else happens without the user: looking up the customer, reading the catalog, counting, pricing, saving, reading back.

The `quote-intake` skill holds the rules for every quote: one `idempotency_key` per `create_bid`, reading a saved quote's prices only from `get_proposal`, and confirming a vague package choice. Follow it. The prices shown before the Send tap come from `compute_pricing`, its price check. Where it asks one or two questions at a time, this skill groups up to four, because the user is a tech answering with taps, not a customer. If `quote-intake` isn't installed, follow the same rules from the tool descriptions.

## Straight line to the quote

The user is waiting. Between their first message and the price table, make only these calls: one customer lookup, `get_catalog` and the follow-up read (the first time in a conversation only), the round of quick choices, and one `compute_pricing` call. Reuse the catalog and the follow-up for every later quote in the conversation.

## Ground rules

- **Count from the photos.** Panes per side in the account's pane types, screens on windows that open, doors with glass, stories, rough measurements.
- **Offer only what the photos show.** Offer a service only when its trigger in the table below is visible or described. Otherwise don't offer it and don't estimate it; the user can still name it. Never assume gutters because of trees, or a deck because of a back yard.
- **Ask only what changes the price.** Check each catalog question's price effect for this quote. A question with no price effect goes in the notes, not the round.
- **Ask what a tech knows at a glance.** Grid type, screens, hard water and gutter guards can't be read reliably from photos. Ask them as one "check all that apply" question. Don't reason them out unless the user asks you to.
- **Show what you filled in.** Before the round, list in one line the measurements you took from the photos, such as gutter run, downspouts, driveway size and wall material. Say the user can change any of them.
- **Nothing reaches the customer until the user taps Send.** Before the tap, use only `compute_pricing`; it saves nothing and sends nothing. On the tap, call `create_bid` with the follow-up started.
- **Never save quietly.** Don't call `create_bid` with `start_follow_up: false`, and don't call `start_follow_up`. On the current server a quote saved without a status gets no prices, and `start_follow_up` doesn't add them, so the customer would get a proposal showing $0.00.
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

- **Returning customer:** find them with `find_contact_by_phone` for a phone number, `find_contact` for a name, email or address, or `get_bid` for a quote number. Then call `list_bids` with that `contact_id`, and `get_proposal` on recent bids to read their addresses and `property_id`.
  - One address: reuse it.
  - Several addresses or several matching contacts: ask which one in the round.
- **New customer:** call `find_contact_by_phone` with the mobile. If it matches, `create_bid` would attach the quote to that contact, so ask "This number belongs to <name>. Use that record?" in the round.
- **Customer missing from the first message:** ask for it in the same reply as the round, and don't save until it arrives.
- **Service area:** leave `service_area_id` out and pass the property's `city` and `zip`; the server picks the matching service area. If it refuses and names candidates, ask which one.
- **Lead source:** set it only if the user mentioned one.

### 2. Load the catalog (first quote of the conversation only)

Call `get_catalog` with `services` set to the requested service plus every exterior service a photo could trigger, so a later quote in the same conversation doesn't wait on another read. For a home, use only residential house sizes.

### 3. Read the follow-up (first quote of the conversation only)

Call `list_follow_up_sequences`, then `get_follow_up_sequence` for the sequence whose default marker is `open`. Count its enabled EMAIL, SMS and WEBHOOK steps and note when the first email and first text go out. Skip disabled steps. An email step with no email on file reaches no one; say so. It becomes the wording of the Send choice in step 6. If the follow-up tools aren't available to this login, say you can't show what sending will do.

### 4. Show the counts, then the one round

First, a short text block:
- One line of counts: windows, panes by type, screens, stories.
- One line on what you filled in from the photos.
- For a returning customer, one line naming who and where.

Then one round of at most four questions, two to four options each. Use a multiple-choice menu where the client offers one; otherwise a short numbered list answered with one number or letter per question.

1. **Services** (pick several): the services the photos triggered, each option naming what you counted. Put any service the user asked for first.
2. **Which of these are true?** (pick several, none is fine): the yes/no facts that change price for the offered services, such as screens on most windows, hard water, raised grids on the outside, or gutter guards. Each option names its price effect.
3. **Stories and house size** (pick one): combined options with your estimate first, labeled as your estimate. Name the price effect where it differs, such as a story charge or bid in person.
4. **A customer question, only if step 1 needs one.**

Skip any question the user already answered. There's no save question; the answers go straight to the price check.

### 5. Price it (saves nothing)

Call `compute_pricing` with every picked service in `selections`, and the `property_id` or an inline property with `city`, `zip`, house size and stories. Keep the selections, contact, property and notes ready for the save in step 7.

### 6. Show the quote, then one tap to save and send

Reply with:
- **Quote for <name>. Nothing is saved or sent yet.**
- One table: service by package by price. Show a bid-in-person price as "Bid in person", never as $0.

Then one round with two questions, as a menu or a numbered list:

1. **"Send the quote to <name>?"** It has two options:
   - "Send to <name>": its description says it saves the quote and starts the follow-up, and states what goes out, to whom and when, from step 3.
   - "Not yet": nothing is saved and nothing is sent. The user can ask to send it later, and you save it then with these answers.
2. **"Build the customer quote page?"** The options are "Build the page" and "Not now". On "Build the page", build it with the `customer-quote-page` skill once the quote is saved. If the user chose "Not yet", say the page comes once the quote is sent, and offer it again after the send (step 7).

### 7. Save and send (only on "Send to <name>")

Call `create_bid` with `start_follow_up: true`, one `idempotency_key`, the selections you priced, and `contact_id`/`property_id` or the inline contact and property. Write `notes` with:
- the photo counts per side
- what was filled in from the photos
- every answer
- what to confirm on site

Then call `get_proposal` for the saved prices, and confirm:
- **Sent: quote #id for <name> is in Open**, with when the first email and text go out, and the customer's `proposalLink`.
- Any saved price that differs from the price check: name the service and both prices.
- Any service the account attached on its own. A company's auto-added services can join a new quote; don't present them as the user's choice.

If the user answered "Not now" to the page in step 6, end with one more question: **"Build the customer quote page for <name>?"** with "Build the page" and "Done". The quote is saved now, so the page can link to it. On "Build the page", build it with the `customer-quote-page` skill; on "Done", stop.

If `create_bid` fails with an unexpected error, retry once with the same `idempotency_key` and the same body; the same key can't create a second quote. If the retry fails too, say so and stop.

If it fails with "This submission has been blocked by the company", nothing was created. The company's block list matched one of the contact or property details, and the error doesn't say which. Don't retry to find out. Offer different details, or the blocked list in ResponsiBid.

Never call `create_bid` without the user's choice, and never with a new key for a quote you already sent.

`pricingStatus: "queued"` in the `create_bid` reply is a fixed word, not a live status.

## Older connector

On a connector without the `start_follow_up` option, `create_bid` starts the follow-up anyway, so the same flow works: price with `compute_pricing`, then call `create_bid` on the Send tap.

## What the connector can't do

- **Edit or delete a saved quote.** To add work, create another quote with the same `contact_id` and `property_id`. To change or remove a quote, use the ResponsiBid app. Say so before the user assumes otherwise.
- **Attach photos.** Counts and findings go in the notes.
- **Set up bundles.** Use `select_proposal_bundle` only on a quote whose `get_proposal` already lists bundles; on any other quote it fails with `BUNDLES_DISABLED`.
