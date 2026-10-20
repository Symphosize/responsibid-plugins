---
type: llm
---

PASS if the reply lays out setup in this order: house sizes first, then prices per house size and option prices, then packages, then bundle auto-add, then follow-up sequences; and it starts by reading the company's current catalog or pricing rather than changing anything.
FAIL if follow-ups come before pricing, if house sizes are not first among the pricing steps, or if it claims to have changed anything.
