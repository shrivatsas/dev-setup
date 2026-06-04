---
name: research-add-fields
description: Add, remove, or refine research fields for an existing research outline, with concise evidence-first output.
---

# Research Add Fields

Use this skill when the user wants to improve the `fields` schema for an existing research topic.

## Response Style

- Lead with the revised field framework or the most important change.
- Keep prose short and direct.
- Prefer concrete evidence, dates, names, and sources over abstract commentary.
- Separate facts, inferences, and assumptions.
- Avoid hedging unless uncertainty is real and important.

## Trigger

`/research-add-fields`

## Workflow

1. Read the current topic, item list, and existing field definitions.
2. Identify missing fields, redundant fields, and ambiguous labels.
3. Propose additions and removals with one-line reasons.
4. Return the updated field list in a clean, structured form.
5. If the schema is unclear, ask one focused clarification question.

## Output Shape

- Current fields
- Proposed additions
- Proposed removals
- Updated fields list
- Short rationale

