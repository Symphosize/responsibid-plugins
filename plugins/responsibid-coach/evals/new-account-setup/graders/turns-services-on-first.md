---
type: llm
---

PASS if the plan the skill shows (before any write) lists turning services on first, then house sizes, packages, prices, minimums + trip charge on/off later. The single-turn case shows the plan but applies no writes.

FAIL if the plan shows prices or minimums before enabling the service, or if any applied write (set_service_settings with apply:true) happens before plan approval.