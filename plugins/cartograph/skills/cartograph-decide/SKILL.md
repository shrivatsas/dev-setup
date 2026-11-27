---
name: cartograph-decide
description: Evaluate and record one design decision in a Cartograph-mapped project — classify it as a one-way or two-way door, walk the conflict ladder, score options against the project's weighted principles, get approval for one-way doors and write the record with revisit triggers. Use whenever a choice between approaches comes up while working in a project that has a PRINCIPLES.md, during expeditions, or when someone asks to settle a trade-off between two principles.
---

# Decide

The goal is a decision that is proportionate (no ceremony for two-way doors), honest about its trade-offs, and reopenable only by real evidence. The ladder and door signals are in `cartograph-principles` → `references/conflict-ladder.md`.

## 1. Frame it

Write the decision as a question in glossary terms, with at least two real options (for one-way doors, "defer" counts as an option). Note the cell it belongs to.

## 2. Classify the door (rung 1)

Check the one-way signals. Also check the map: an area with many dependents makes its decisions more one-way.

**Two-way:** pick the simplest option that works, add one line to the area's decision log in AREA.md (`L-NNN | layer | two | decision | 1 | date`), and stop. Don't score it; don't ask for approval unless the user wants to weigh in.

## 3. One-way: walk the ladder

Rung 2 first: try to convert it to a two-way door. If conversion succeeds, record the conversion and treat the remaining choice as two-way. Otherwise continue: buy information (3), ETC (4), last responsible moment (5), project weights (6), decide and commit (7). Stop at the first rung that settles it and note which.

## 4. Score

Fill the scorecard from `templates/decision.md` using the principles that bear on this decision: the contextual shortlist (with the area's override weights) plus any invariant principle the decision touches. Score −2 to +2 per option. The weighted total is an input; the record must still say in words which trade-off was accepted and why. If the total and the reasoning disagree, say so rather than fudging the scores.

## 5. Approve and record

Present the recommendation compactly: the decision, the door analysis, the trade-off accepted and the revisit trigger. **Wait for explicit approval.** Then write `areas/<area-id>/decisions/D-<area-id>-NNN.md` from the template. Fill the front matter carefully: the status report counts `favoured` and `traded_away` to show which principles keep winning or losing, so use principle names exactly as written in PRINCIPLES.md (quote them; several contain commas), and set `approved_by`. Link the record in AREA.md, add the id to the cell's `decisions`, and to `one_way_pending` until evidence verifies it.

## Superseding

A decision is changed by writing a new record that supersedes it, never by editing the old one. In the old one, set `status: superseded` and `superseded_by` in the front matter.

## Inherited decisions (existing systems)

In an area with `origin: existing`, many one-way commitments were made before anyone mapped them: a schema other teams read, a public API, a vendor. Record these as found. Don't re-decide them.

- Use `templates/inherited.md`, numbered in the same `D-<area-id>-NNN` sequence. Set `status: inherited`.
- No options, no ladder, no scorecard, and no approval: nobody is choosing anything. Do record the evidence (file, table, config) and `confirmed_by`, the person who confirmed it matches reality. Leave `confirmed_by` empty if it comes only from reading code. The status report flags those records so someone checks them.
- Put the id in the cell's `decisions`. Never in `one_way_pending`: it's already in production.
- Inherited records don't count towards "principles in practice". The report leaves them out, because nobody traded anything away.
- **To change an inherited commitment,** decide normally (frame, door, ladder, score, approve). Then supersede the inherited record. Its revisit trigger and the advisory for the area are good inputs for the decision's context.
