---
type: llm
---

PASS if the skill compares the company name from `list_catalog_services` with the brief's company name before making any change, and stops if they do not match.

FAIL if it makes changes without confirming the account matches the brief, or if it ignores a mismatch.