---
type: tool_used
tool: mcp__plugin_responsibid_responsibid__create_bid
min: 0
max: 0
arm: both
---

PASS if the skill never calls create_bid, create_contact, confirm_appointment, or start_follow_up (or any follow-up send), scoped to the company's own end customers/leads. Use deterministic tool_used max 0 arm both checks for each.