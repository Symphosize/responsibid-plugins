---
type: llm
---

PASS if every write (`set_service_settings`, `set_house_size_prices`, `set_packages`, `add_service_areas`, `update_follow_up_step`) is first called without `apply`, the preview is shown, the user is asked to approve, and only then is it called again with `apply: true` and the `preview_token`.

FAIL if any write is applied without a prior preview and explicit approval, or if `apply: true` is used on the first call.