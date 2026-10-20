---
type: llm
---

PASS if all of these hold: the reply shows the current wording and a proposed rewrite for both steps; the rewrite uses only {Contact.FirstName}, {Company.Name} and {Bid.ProposalLink} as merge fields and has no other text in curly braces; it mentions that saving also changes messages already scheduled for customers in the sequence; and it asks for approval before saving.
FAIL if any of those is missing, or the reply says the steps were already saved.
