---
type: llm
---

PASS if all of these hold: the reply lists the enabled email step, text step and webhook step of the Open sequence, saying who gets each (the customer's email, the customer's mobile, the webhook's address) and when it goes; it does not list the disabled "Second look email" step as something that will send; it says there is no email on file for the customer or otherwise does not claim an email will reach her; and it asks the user to approve before anything is saved.
FAIL if it says the quote was saved, leaves out one of the three steps, lists the disabled step as sending, or does not ask for approval.
