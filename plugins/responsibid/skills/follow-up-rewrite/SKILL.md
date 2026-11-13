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

Ask how the user wants to approve: one step at a time (the default), or all the steps together after seeing every one. Use one at a time unless they choose all together.

If `update_follow_up_step` takes `apply` and `preview_token`, it previews first, and the approval rules are in the pricing-setup skill:

1. Call it without `apply` for one step, with only the fields that change. Show its before and after, and its warnings. A reply with `preview: true` saved nothing.
2. One at a time: wait for the user's approval of that step, then call it again with `apply: true` and that step's own `previewToken` as `preview_token`, before previewing the next step. All together: preview every step first, show them all, and after one approval apply each step with its own `previewToken`.
3. On `PREVIEW_EXPIRED` or `STORED_VALUE_CHANGED`, preview that step again and get a fresh approval. A preview lasts about 10 minutes, so for many steps all together, apply soon after the approval.
4. On this path, report a step as saved only when its reply says `applied: true`.

If the tool has no `apply` input, every call saves at once and there is no preview. Show the old and new text side by side for the steps being approved, and wait for the user's approval before making any call. Then call it once per approved step with only the fields that change. A successful reply means that step is saved; report it as saved.

If a call fails partway through, tell the user which steps were already saved.
