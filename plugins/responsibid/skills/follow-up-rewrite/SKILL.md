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

Saving a step also changes the messages already scheduled for customers who are in this sequence now. Tell the user that before they approve.

If `update_follow_up_step` takes `apply` and `preview_token`, it previews first:

1. Call it without `apply` for one step, with only the fields that change. Show its before and after, and its warnings.
2. Wait for the user's approval of that preview, sent after they saw it.
3. Call it again with `apply: true` and that step's own `previewToken` as `preview_token`. Repeat for each step.
4. On `PREVIEW_EXPIRED` or `STORED_VALUE_CHANGED`, preview again and get a fresh approval.

If the tool has no `apply` input, every call saves at once. Show the old and new text side by side, wait for approval, then call it once per step with only the fields that change.

If a call fails partway through, tell the user which steps were already saved.
