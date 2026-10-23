---
name: customer-quote-page
description: Build a one-file web page for a saved ResponsiBid quote (bid). It shows what the photos showed, each service's packages as tappable cards with a running total, upsells, links into ResponsiBid and to the customer's proposal, and a company-only "How this quote was built" section. Use after photo-quote or quote-intake, or when the user names a quote and wants a page to show the customer.
---

# Customer quote page

Build one self-contained HTML page for a quote that already exists. Never invent a price, a count, an answer or a URL. Each tool's description covers its inputs. This skill sets what goes on the page and where each fact comes from.

## 1. Get the quote

1. Take the bid id from this conversation (`photo-quote` or `quote-intake` just made it) or from the user, then call `get_proposal`. Everything the page says about packages and prices comes from it: package names, prices, which package is `[selected]`, bundles, the contact's name, the property's street and ZIP, and `proposalLink`.
2. Show prices exactly as `get_proposal` prints them. Never take a price from `list_bids`, `get_bid` or a price check; the first two round to whole dollars. In the raw response at the bottom of `get_proposal`, package prices are in cents and `closingPrice` is in whole dollars, so use the formatted lines above it.
3. For a quote from an earlier conversation, call `get_bid` too. Its `notes` hold the photo counts and answers that `photo-quote` saved. Use them for "What we saw in your photos" and "How this quote was built", and say they come from the quote notes. If there are none, leave those parts out.

## 2. Links

| Link | Address | Needs |
|---|---|---|
| Customer's proposal | `proposalLink` as returned | `get_proposal` or `create_bid` |
| Customer profile | `https://app.bids.responsibid.com/CustomerProfile/{contactGroupId}` | `contactGroupId` |
| This quote | `https://app.bids.responsibid.com/CustomerProfile/{contactGroupId}/{bidId}` | `contactGroupId` and the bid id |

- `create_bid` and `create_contact` return `contactGroupId`. `get_proposal`, `get_bid`, `list_bids` and `find_contact_by_phone` don't. Use the one from this conversation. It is not the `contactId`.
- If you have no `contactGroupId`, or `create_bid` returned it empty, leave the profile and quote links out and tell the user which ones and why. Don't guess, don't use `contactId`, and don't call `create_contact` to look it up: it creates a contact when nothing matches. The user can instead paste the customer's profile link from the ResponsiBid app. Accept only a link on `app.bids.responsibid.com`, take the first id after `/CustomerProfile/`, and rebuild the links from the table.
- The profile and quote links open inside the company's ResponsiBid app, so only signed-in staff can use them. The proposal link is the customer's. Label them that way.
- `app.responsibid.com` does not resolve. Use no other host and invent no other address. If `proposalLink` is empty, leave the proposal button out and say so.

## 3. The page

Write one HTML file with its CSS and JavaScript inline and no outside requests: no web fonts, libraries, images or trackers. It reads well on a phone with a 16px side margin, in light and dark modes, with no horizontal scroll. Use real radio inputs with visible focus. HTML-escape every customer and quote value you put in the page. No company branding unless the user names the company, and then only as plain text. No stock photos.

Sections, in order:

1. **Test banner.** Only when the user said this is a test or a dry run. Otherwise leave it out, and don't judge from the data whether a customer looks like a test.
2. **Header.** Customer name, the street and ZIP from `get_proposal` (add the city only if the user gave it), the quote number, and the quote date from `createdAt` when `get_proposal` has one.
3. **"Open in ResponsiBid".** Label it "For staff, needs a ResponsiBid sign-in". The links from step 2 that you can build, each with a one-line note on what it opens.
4. **"What we saw in your photos".** A card per side with the count and a short note, then the facts: pane types, grids, stories, anything else counted. Only counts from the photos and answers the user gave. Leave the section out if there were no photos.
5. **"Pick your options".** One block per service, with its packages as radio cards: name, price, and what's included, taken from the package lines in the raw response; never invent inclusions. Preselect the package marked `[selected]`, and preselect none if none is marked. A running total adds up the selected cards in whole cents, so it adds exactly, and says "Pick a package" until one is chosen. Show a price that isn't a dollar amount, such as "Bid in person", as that text and leave it out of the total. Don't call a `[recommended]` package "most popular" or the company's advice; it is a bundle default.
   - Services the user added as upsells go in a block called "Also spotted in your photos", each with a "Not this time" card preselected at $0. If you can't tell which services were upsells, treat them all as options.
   - Leave off any service the user didn't choose, and list it in the company section. Show bundles as `get_proposal` lists them (name, price, savings) in their own block, outside the total.
6. **Accept.** A "Review and accept your proposal" button linking to `proposalLink`, a "Copy link" button, and the link as text. The copy button uses the clipboard and falls back to selecting the text when the clipboard is blocked. Add: "Choices on this page are a preview. The customer picks and signs on the proposal."
7. **"How this quote was built".** A collapsed `<details>` headed "For the company, not for the customer". Put in it only what this conversation or the quote notes can support:
   - **The process:** the steps that happened, in order (photos sent, counts read, answers given, quote saved and read back, sent to the customer).
   - **Answers saved:** each answer with its source: photos, user, or account.
   - **Confirm on site:** what the user flagged or the photos couldn't settle.
   - **Price check against the saved quote:** a table, only if this conversation made a price check. Mark each row that differs.
   - **Sends the user approved before saving:** the email, text and webhook steps they approved. No tool shows whether a step ran, so don't say it did.
   - **Left off the page:** services or bundles the user didn't choose.

## 4. Deliver it

Show the page as an artifact or canvas where the client supports one. Otherwise save it as `quote-{bidId}.html` and give the full path. If the client can do neither, print the whole file in one code block.

Then tell the user three things: the ResponsiBid links and "How this quote was built" are for the company, the page holds the customer's name and address, and choosing on the page records nothing in ResponsiBid. To record a choice, use `quote-intake`. Name any link you left out and why.
