---
name: domain-driven-design
description: DDD planning and review workflow for greenfield systems and brownfield codebases. Use when shaping bounded contexts, ubiquitous language, aggregates, invariants, integration boundaries, or reviewing an existing model for DDD fit.
---

# DDD Grill

Use this when the user wants to design a domain model from scratch or review an existing codebase through a DDD lens.

## First Move

- Pick the mode (below) before anything else.
- If the project is greenfield, load [references/greenfield.md](references/greenfield.md).
- If the project is brownfield, load [references/brownfield.md](references/brownfield.md).
- If the repo already has docs, check `CONTEXT.md`, `CONTEXT-MAP.md`, and `docs/adr/` before asking broad questions.
- If the code answers the question, inspect the code first.

## Pick The Mode

- **Grill mode** — the user is present and shaping decisions interactively. Ask one question at a time, walk one branch at a time.
- **Report mode** — a one-shot or autonomous review where nobody can answer mid-task. Do not ask questions. Convert every would-be question into either a stated assumption (named as such) or an explicit open question in the output.
- Default to report mode when the request is "analyse / review / audit X"; default to grill mode when the request is "help me design / decide".

## Working Style

- Prefer concrete scenarios over abstract prompts.
- Call out term drift immediately when language is fuzzy or overloaded.
- Keep the output sharp: short findings, clear decisions, no filler.
- If a term is ambiguous, stop and resolve it before moving on.
- If the code contradicts the stated model, surface it immediately.
- Every finding cites evidence (`file:line`). Verify each red flag in the source before reporting it — exploration summaries lie. Negative findings (missing invariant, missing atomicity, missing validation) especially must be re-checked against the actual code.
- Grill mode only: ask one question at a time, give a recommended answer when asking, keep circling the same branch until the decision is clear.

## Core Lens

- Identify the real domain concepts, not just technical modules.
- Separate language, boundaries, and invariants from implementation detail.
- Distinguish ownership, integration, and transaction scope.
- Treat hard-to-reverse boundary or integration choices as ADR-worthy.
- Use the glossary as the source of truth for terminology. If no glossary exists, emitting a starter glossary is itself a deliverable.
- Keep the model honest by checking examples and edge cases.

## Outputs To Maintain

Formats and skeletons for all of these live in [references/templates.md](references/templates.md).

- A tight glossary of domain terms.
- A context map when there is more than one bounded context.
- ADRs for meaningful architectural trade-offs.
- Brownfield review notes that name drift, leaks, and refactor targets — triaged by severity (see brownfield reference).
- Update context docs as terms are resolved.

## When To Open The References

- Open [references/greenfield.md](references/greenfield.md) for planning prompts and decision order.
- Open [references/brownfield.md](references/brownfield.md) for review heuristics, red flags, cross-repo contract checks, and the severity triage.
- Open [references/templates.md](references/templates.md) when producing a glossary, context map, or review notes.
