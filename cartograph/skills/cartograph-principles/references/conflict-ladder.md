# Conflict ladder

Use when two principles pull in different directions, or when choosing between options. Walk the rungs in order and **stop at the first rung that settles it.** Record which rung settled it.

## Rung 1 — Classify the door

Ask: *if we're wrong, what does undoing this cost?*

One-way signals (any one is enough to treat it as one-way until shown otherwise):
- Persisted data formats, or data that other systems consume
- Public or cross-team API contracts; event schemas
- External integrations and vendor commitments; anything contractual
- Security and permission models
- Money movement, legal or regulatory exposure
- Boundaries between teams or bounded contexts
- Anything with many dependents on the map (check `depends_on`)

Two-way signals: internal to one module, behind a stable interface, no persisted state, no external consumers, revertible by a single change.

- **Two-way →** decide quickly, prefer the simplest option (YAGNI), and write a one-line light record in AREA.md. Done.
- **One-way →** continue down the ladder. A one-way decision needs explicit human approval.

The common failure in large projects is treating two-way doors as one-way, which makes everything slow. Don't inflate ceremony.

## Rung 2 — Convert the one-way door into a two-way door

Often the best available move. Techniques:
- Put an interface at the seam (ports and adapters) so the choice behind it can be swapped
- Start behind a feature flag, or for one tenant
- Expand-then-contract migrations instead of in-place schema changes
- Strangler pattern: wrap the old thing and replace it piece by piece
- Version the contract from day one
- Keep raw inputs (append-only) so derived models can be rebuilt

If conversion works, the decision is now two-way: go back to rung 1. Record the conversion itself as a small decision.

## Rung 3 — Buy information instead of arguing

If the conflict is really uncertainty ("will this scale?", "will users need X?"), timebox a prototype or tracer bullet so evidence replaces opinion. Leave the cell `scouted` with the experiment recorded as the blocker.

## Rung 4 — Apply ETC

Which option keeps the system easier to change? If you can't tell, choose the option that is easier to replace later.

## Rung 5 — Last responsible moment

If the cost of waiting is lower than the cost of being wrong, defer. Record the deferral with a revisit trigger (a date, an event, or a metric threshold). Deferring is a decision, not an absence of one.

## Rung 6 — Project weights

The higher-weighted principle in PRINCIPLES.md wins (use the area's override if there is one). The record names the trade-off accepted.

## Rung 7 — Decide and commit

Once recorded, the decision is not reopened without new evidence. The evidence that would reopen it is written down as the revisit trigger.

## Side heuristics

- **Duplication is cheaper than the wrong abstraction** (Metz) — settles most DRY conflicts.
- **Chesterton's fence** — understand why something exists before removing it.
- **Pre-mortem** — for anything still one-way after rung 2: "a year from now this failed; why?" Add the answers as risks or revisit triggers.
- **Blast radius** — how much breaks if we're wrong; measures *how* one-way a door is.
- **Asymmetry check** — compare the cost of moving from A to B later with the cost of moving from B to A. Pick the side that is cheaper to leave.

## Worked example — DRY vs bounded contexts

Should one shared `Order` model serve every area?
- Rung 1: once many modules depend on a shared model, splitting it is expensive → one-way.
- Rung 2: start with separate models per context and a translation layer at each seam. Merging later is cheap; splitting later is not. The asymmetry decides it.
- Rung 4 agrees: a change in one context can't break the others.
- Outcome: separate models; DRY consciously traded for decoupling. Revisit trigger: the translation layers end up mirroring each other almost exactly.
