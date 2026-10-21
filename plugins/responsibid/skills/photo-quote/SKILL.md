---
name: photo-quote
description: Build a ResponsiBid quote (bid) from photos of a property. Count what the photos show, ask the rest as quick choices, offer upsells the photos support, price-check, show what saving will send, save, and read the quote back. Use when someone shares photos of a home or building and asks for a quote, an estimate, or to "price this house" for exterior services such as house washing, windows, roof, gutters, or flatwork.
---

# Photo quote

The photos give counts. The user gives every other fact. Speed is the point, so ask each question as a quick choice, never as a paragraph.

The `quote-intake` skill holds the rules for every quote: finding the service and the contact, one `idempotency_key` per `create_bid`, reading prices only from `get_proposal`, and confirming a vague package choice. Follow it and don't contradict it. This skill adds the photo steps and the checks before saving. If `quote-intake` isn't installed, follow the same rules from the tool descriptions.

## Ground rules

- **Count, don't guess.** Use photos only for counts: panes or windows per side, doors with glass, stories, visible surfaces, rough measurements. Show the counts as a short table per side. Say what a photo can't show, such as screens at dusk or gutters hidden by trees.
- **Ask what a tech knows at a glance.** Grid type, screens, hard water, wall material, gutter guards, roof moss and pitch, and any measurement to confirm. Don't reason these out from pixels unless the user asks you to figure one out from the photo.
- **Ask as quick choices.** Use a multiple-choice menu where the client offers one. Otherwise use a short numbered list the user can answer with one number or letter per question. `quote-intake` asks one or two questions at a time because it talks to a customer; here the user is a tech answering with a tap, so group up to four questions per round, with two to four options each. Use a numbered list for anything longer, such as house sizes. Put your photo-based estimate first, and mark it recommended only when the photo supports it. Each option's description names its price effect from the catalog ("adds 10%", "bid in person"). Use free text only for names, phone, email, street address and ZIP.
- **Use the account's own words.** Question text, option names and their definitions come from the catalog (the account's own pane types, for example), not from industry terms.
- **Never invent customer details.** Ask for real ones. If the user says this is a test, use the values they give you.
- **Continue the job in progress.** If a quote or customer already exists in this conversation, or the user names a quote, reuse its `contact_id` and `property_id` (`get_bid` returns both) and don't ask for contact details again.

## Steps

### 1. Load the catalog

Call `get_catalog` with `services` set to the services the user asked for. `meta.availableServices` lists every quotable service; the ones the user didn't ask for are your upsell candidates. Read each question, each option, what the option means and its price effect. For a home, use only residential house sizes.

### 2. Read the photos

Make one table per side: windows and panes by the account's pane types, doors with glass, stories, wall surfaces, roof type, flatwork. Note anything the photos can't show.

### 3. Ask the photo questions

Cover every catalog question for the requested services that the photos didn't settle, in one or two rounds:

1. Grids, screens, hard water, wall material, house size, and an **Add-ons** multi-select. List every other quotable service the photos support (roof cleaning, gutter cleaning, flatwork or walkway, deck, and so on). The user may pick several or none. In a numbered list, ask for every number that applies.
2. For each add-on picked, call `get_catalog` with `services` set to the add-ons, then ask their own questions: gutter length, downspouts and guards; roof moss and pitch; walkway size.

### 4. Customer (skip when continuing a job)

Ask in one short list: first and last name, mobile phone, email (optional), street address and ZIP. Ask the service area as a choice from the catalog. Call `find_contact_by_phone` with the mobile number first. If it matches, show the match and ask whether it is the same customer; if so, reuse that `contact_id`. If nothing matches, ask the lead source as a choice from the catalog. Don't create the contact yet: pass it inline to `create_bid` in step 6, which attaches an existing contact with the same email or phone instead of duplicating it.

### 5. Price check

Call `compute_pricing` with the exact selections and an inline property (house size, stories, service area). Show one table: service, package, price. A price that comes back as `bid-in-person` shows as "Bid in person"; never put a number on it, and put the details you collected for that service in the notes. Keep this table for step 7.

### 6. Show what saving will send, then save

A new quote joins the company's `open` follow-up sequence, and its steps can email, text or call a webhook, some right away and some later. Before you save:

1. Call `list_follow_up_sequences` and pick the sequence whose default marker is `open`, then call `get_follow_up_sequence` for its steps. If no sequence is marked `open`, say so: the quote then joins no follow-up.
2. List every enabled EMAIL, SMS and WEBHOOK step. Skip disabled ones. For each, give the recipient, the content and the timing:
   - Recipient: an email goes to the customer's email, a text to their mobile. A webhook posts the quote and the customer's contact and property details to its target address; give the address if the step shows one, otherwise say it isn't shown. If you collected no email, say the email steps have no address to go to.
   - Content: the subject and body as stored. Merge fields in braces fill in from this customer.
   - Timing: the delay after the quote or the previous step, and the time of day.
   - Name any other enabled step, such as a status change, in one line.
3. Ask approval as a menu or numbered list. The Save option states exactly what will send and to whom. A real phone number or email means real messages. Don't call `create_bid` until the user says yes, and treat the yes as covering only the list you showed.
4. If the follow-up tools aren't available to this login, say so: you can't show what the quote will send. Ask whether to save anyway.
5. Call `create_bid`, as `quote-intake` says, with the requested service and every add-on picked in `selections`, and with `notes`: the photo counts per side, every answer and whether it came from the photos or the user, and what to confirm on site.

If `create_bid` fails with "This submission has been blocked by the company", nothing was created. The company's block list matched one of the contact or property details, and the error doesn't say which. Don't retry to find out. Offer different details, or the blocked list in ResponsiBid.

### 7. Read back

Call `get_proposal`. Compare every package price to the price check and report the differences in one table. Report any service on the quote that the user didn't choose, and don't present it as their choice; a company's bundle auto-add can attach services to a new quote. `pricingStatus: "queued"` in the `create_bid` reply is a fixed word, not a live status.

### 8. Offer the customer page

Offer to build it with the `customer-quote-page` skill. Hand it the bid id, `contactGroupId` and `proposalLink` from `create_bid`, the photo counts, the answers with their sources, the price check, and the sends the user approved.

## What the connector can't do

- **Edit or delete a saved quote.** No tool changes a saved quote's services or answers, or deletes it. To add work, create another quote with the same `contact_id` and `property_id`. To change or remove a quote, use the ResponsiBid app. Say so before the user assumes otherwise.
- **Attach photos.** No tool accepts photos, so the counts and findings go in the notes.
- **Set up bundles.** Bundles are set up in the ResponsiBid app, not through the connector. Use `select_proposal_bundle` only on a quote whose `get_proposal` already lists bundles; on any other quote it fails with `BUNDLES_DISABLED`.
