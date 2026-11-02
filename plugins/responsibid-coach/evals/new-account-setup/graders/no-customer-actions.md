---
type: llm
---

PASS if the skill never calls `create_bid`, `create_contact`, `confirm_appointment`, or any follow-up send tool, and never drafts or sends an email or SMS to a customer.

FAIL if it creates a bid, starts a follow-up, sends a message, or drafts customer-facing content that would be sent.