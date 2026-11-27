---
name: cartograph-expedition
description: Run one Cartograph expedition — take the next cell from the project map's frontier (or one the user names), scout it, decide, prove one-way doors, update the map and hand off. Also answers "are we ready to build <area>?". Use after /cartograph-survey has created the map.
disable-model-invocation: true
---

# Expedition

One expedition = one cell (or a small cluster), taken as far as the evidence allows in one session. The discipline is staying in your cell: when you find something about another cell, write it down and put it on the map, don't go and solve it.

Load `cartograph-principles`; use `cartograph-map` for every map change and `cartograph-decide` for every decision. Arguments: none (take the frontier), a cell ref like `payments.domain`, or `ready <area-id>`.

## `ready <area-id>`

Run the map script's `ready` check and report it. If ready, hand off to the user's planning skills (`to-spec` and `to-tickets`, or `writing-plans`) with links to the area's AREA.md, its decisions and PRINCIPLES.md. If not ready, list the blockers and offer the top blocker as the next expedition. Then stop.

## 1. Choose the target

1. Run `validate`. Fix errors before anything else.
2. Check `assumptions.yaml` and recent changes for fired revisit triggers; mark affected cells `contested`.
3. Run `frontier --top 5`. Take the top candidate unless the user named one. A cluster is allowed only if it is small: adjacent layers of one area, or one layer across two tightly coupled areas.
4. Tell the user the target and why it ranks high, in two lines, and proceed unless they redirect.

## 2. Orient

Read, in this order: PRINCIPLES.md (and this area's overrides), GLOSSARY.md, the area's AREA.md, decisions in the same area's earlier layers, and decisions in the same layer of areas this one depends on. Note any assumption the target relies on.

**Existing areas** (`origin: existing`): also read the area's `## As built` section, its inherited records and its line in `advisory.md`. If the target cell was never walked, walk that one cell first with `cartograph-inspect`. Don't design changes to something you haven't seen as built.

## 3. Scout

Use the layer's scouting prompts from `layer-exit-criteria.md`. Interview the user one question at a time (prefer `grilling`, or `domain-modeling` for the domain layer); use `research` for external facts. Produce:
- the open questions, prioritised;
- risks;
- every pending decision, classified one-way or two-way (rung 1 of the ladder).

Move the cell to `scouted`. If the cell turns out too big to chart in one go, stop and split the area (zoom) through `cartograph-map` instead of pressing on.

## 4. Decide

Take decisions in dependency order. For each, use `cartograph-decide`. Two-way doors are quick; one-way doors need explicit user approval. In an existing area, adopting the advisory verdict is usually the first one-way decision. Changing an inherited commitment means a new decision that supersedes the inherited record. When something can't be decided now, either record an assumption with a revisit trigger or leave it open with what it is blocked by. Never leave an unknown implicit.

When the exit criteria are met, move the cell to `charted`.

## 5. Prove

For each accepted one-way decision, say what evidence would verify it (see the layer's "Verified by"). Offer a tracer bullet or a prototype, labelled as which one it is (`prototype`, `tdd` and `to-tickets` skills if installed). If proving can't happen this session, leave it in `one_way_pending` and note the planned proof in the log.

## 6. Update the map

Through `cartograph-map`: the cell's state and danger estimates; new areas, sub-areas and dependencies found; glossary terms; assumptions; any other cell that the findings contradict (mark it `contested`, don't fix it). Then `validate` and `render`.

## 7. Log and hand off

Write `expeditions/<YYYY-MM-DD>-<area>-<layer>.md` from `templates/expedition-log.md`, including the new frontier top three. Prefer the `handoff` skill if installed. End by telling the user the state change, the decisions waiting on them (if any) and the next suggested target.

## Status reports

If the user asks where the project stands, or this is the third expedition since the last file in `reports/`, run `report` through `cartograph-map` after updating the map, and lead your closing summary with its headline and flags.

## When to stop early

Stop and hand off when the context is getting heavy, when the user needs to consult someone (offer a questionnaire, e.g. `to-questionnaire`), or when a discovery changes the map enough that the frontier should be recomputed.
