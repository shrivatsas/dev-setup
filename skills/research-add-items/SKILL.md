---
name: research-add-items
description: Add, remove, or refine research items for an existing research outline, with concise evidence-first output.
---

# Research Add Items

Use this skill when the user wants to improve the `items` list for an existing research topic.

## Response Style

- Lead with the revised item list or the most important change.
- Keep prose short and direct.
- Prefer concrete evidence, dates, names, and sources over abstract commentary.
- Separate facts, inferences, and assumptions.
- Avoid hedging unless uncertainty is real and important.

## Trigger

`/research-add-items`

## Workflow

1. Read the current topic and existing outline.
2. Identify missing items, duplicates, and weak candidates.
3. Propose additions and removals with one-line reasons.
4. Return the updated item list in a clean, structured form.
5. If the topic scope is unclear, ask one focused clarification question.

## Output Shape

- Current items
- Proposed additions
- Proposed removals
- Updated items list
- Short rationale

