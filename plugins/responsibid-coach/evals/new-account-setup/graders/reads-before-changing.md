---
type: llm
---

PASS if the skill first calls `list_catalog_services` (with `include_disabled: true`), `list_house_sizes`, and `list_service_areas` before suggesting or making any change.

FAIL if it proposes a change before reading the current catalog, house sizes, or service areas.