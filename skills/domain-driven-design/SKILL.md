---
name: domain-driven-design
description: DDD planning and review workflow for greenfield systems and brownfield codebases. Use when shaping bounded contexts, ubiquitous language, aggregates, invariants, integration boundaries, or reviewing an existing model for DDD fit.
---

# DDD Grill

Use this when the user wants to design a domain model from scratch or review an existing codebase through a DDD lens.

## First Move

- If the project is greenfield, load [references/greenfield.md](references/greenfield.md).
- If the project is brownfield, load [references/brownfield.md](references/brownfield.md).
- If the repo already has docs, check `CONTEXT.md`, `CONTEXT-MAP.md`, and `docs/adr/` before asking broad questions.
- If the code answers the question, inspect the code first.

## Working Style

- Ask one question at a time.
- Give a recommended answer when asking.
- Prefer concrete scenarios over abstract prompts.
- Call out term drift immediately when language is fuzzy or overloaded.
- Keep the output sharp: short findings, clear decisions, no filler.
- Walk the design tree one branch at a time.
- Keep circling the same branch until the decision is clear.
- If a term is ambiguous, stop and resolve it before moving on.
- If the code contradicts the stated model, surface it immediately.

## Core Lens

- Identify the real domain concepts, not just technical modules.
- Separate language, boundaries, and invariants from implementation detail.
- Distinguish ownership, integration, and transaction scope.
- Treat hard-to-reverse boundary or integration choices as ADR-worthy.
- Use the glossary as the source of truth for terminology.
- Keep the model honest by checking examples and edge cases.

## Outputs To Maintain

- A tight glossary of domain terms.
- A context map when there is more than one bounded context.
- ADRs for meaningful architectural trade-offs.
- Brownfield review notes that name drift, leaks, and refactor targets.
- Update context docs as terms are resolved.

## When To Open The References

- Open [references/greenfield.md](references/greenfield.md) for planning prompts and decision order.
- Open [references/brownfield.md](references/brownfield.md) for review heuristics and red flags.
