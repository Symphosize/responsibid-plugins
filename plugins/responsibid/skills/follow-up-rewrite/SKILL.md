---
name: follow-up-rewrite
description: Review and rewrite a company's ResponsiBid follow-up sequences (the automated emails and texts sent after a quote or job). Use when the user wants to read, improve, or edit follow-up messages.
---

# Follow-up rewrite

If the follow-up tools aren't available, this login has no access to follow-ups. Say so and stop.

Sequences are company-wide templates, not tied to one customer.

## 1. Read the sequence

1. Call `list_follow_up_sequences` and pick the sequence the user named.
2. Call `get_follow_up_sequence` for its steps and the merge fields it can use.
3. Show the current wording.

## 2. Draft the rewrite

Use only the merge fields that sequence lists, copied exactly. Never put curly braces in ordinary text, because the merge engine blanks anything it can't resolve. Rewrite the sequence the user named, never a copy of it.

## 3. Approve and save

Preview EACH changed step separately: call `update_follow_up_step` without `apply` for one step, show its preview (old vs new), get approval, then apply with THAT step's own `preview_token`. Repeat for every step. Do not show a combined side-by-side on top of the per-step previews.

On PREVIEW_EXPIRED, preview again and get fresh approval before applying.

If a call fails partway through, tell the user which steps were already saved.
