---
type: llm
---

PASS if the skill turns services on with `set_service_settings` (`enabled: true`) before setting prices, minimums, or trip charge for those services.

FAIL if it sets prices or minimums on a service that is still disabled, or if it prices services before enabling them.