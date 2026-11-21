---
name: cartograph-principles
description: The reference library behind Cartograph — a catalog of software design principles (each phrased as the question it forces and what it trades against), the working practices from The Pragmatic Programmer, the conflict-resolution ladder (one-way/two-way doors, ETC tie-breaker) and per-layer exit criteria. Use whenever you need to select principles for a project, judge a design decision, resolve a conflict between two principles, decide whether a map cell is sighted/scouted/charted/verified, or explain why a design choice is good or bad. Also use when the user asks "which principle applies here", "is this a one-way door", or "how do we settle this trade-off".
---

# Cartograph principles library

This skill holds knowledge, not a workflow. The other Cartograph skills load the parts they need. Read only the reference file that answers the question in front of you.

| You need to… | Read |
|---|---|
| Pick or weight principles for a project, or check what a principle asks | `references/catalog.md` |
| Choose how to work (tracer bullet vs prototype, how far ahead to plan) | `references/practices.md` |
| Settle a conflict or classify a decision's door type | `references/conflict-ladder.md` |
| Decide whether a cell has reached sighted / scouted / charted / verified, or find scouting questions for a layer | `references/layer-exit-criteria.md` |

## The ideas everything else rests on

**ETC — Easier To Change — is the meta-value.** Nearly every other principle is a special case of keeping the system easy to change. When nothing more specific settles a question, ask which option leaves the system easier to change; if you can't tell, choose the option that is easier to replace.

**A principle is only usable if it is a question.** Every catalog entry is phrased as the question it forces you to ask of a decision. If you can't ask it of a concrete choice, it isn't helping.

**Principles conflict; the conflicts are the decisions.** Every entry names what it trades against. A decision record must say which side of each live tension it took.

**Principles come in three tiers.**
- *Invariant* — always on, never re-selected per project.
- *Contextual* — selected and weighted per project (and per area) from the requirements. This is the only tier the survey selects from.
- *Tactical* — code-level; belongs in linters and standards review, not architecture discussions.

Tier assignments in the catalog are defaults. A project's `PRINCIPLES.md` may promote or demote a principle, with a reason.

**Principles describe the system; practices describe how we work.** Keep them separate. Practices are in `references/practices.md`.
