---
# Machine-readable fields: the status report reads these. Keep them in sync with the body.
id: D-<area-id>-<NNN>
title: <short title in glossary terms>
cell: <area-id>.<layer>
status: proposed              # proposed | accepted | superseded (inherited records use templates/inherited.md)
superseded_by: null
door: one-way                 # one-way | converted
rung: <1-7>                   # ladder rung that settled it
date: <YYYY-MM-DD>
approved_by: <name>           # required once accepted
favoured:                     # principle names exactly as in the catalog / PRINCIPLES.md
  - "<principle>"
traded_away:
  - "<principle>"
revisit_when: <trigger>
---

# D-<area-id>-<NNN>: <short title in glossary terms>

| Cell | Status | Door | Settled at rung | Date | Approved by |
|---|---|---|---|---|---|
| <area-id>.<layer> | proposed / accepted / superseded by D-… | one-way / converted | <1–7> | <date> | <name> |

## Context
<The forces at play, in two to five sentences. Link the open question this answers.>

## Options considered
1. **<Option A>** — <one line>
2. **<Option B>** — <one line>
3. (Do nothing / defer) — <one line>

## Door analysis
- One-way signals present: <persisted data, public contract, money, …>
- Conversion attempted (rung 2): <technique, and whether it worked>
- Blast radius if wrong: <what breaks>
- Asymmetry: <cost A→B later vs B→A later>

## Principles scorecard
Score each option −2 (works against) … +2 (strongly serves). Use the area's override weights where they exist. The total informs the decision; it does not make it.

| Principle (weight) | A | B | Note |
|---|---|---|---|
| <principle> (<w>) | <−2…+2> | <−2…+2> | <why> |
| **Weighted total** | <n> | <n> | |

## Decision
<What we will do, in one paragraph.>

## Trade-offs accepted
- We give up <principle/quality> in favour of <principle/quality> because <reason>.

## Evidence
- Needed to verify: <tracer bullet / prototype / test / review>
- Collected: <links, results> (moves the cell toward verified)

## Revisit when
- <date, event or metric threshold that reopens this>

## Consequences
- <What becomes easier, what becomes harder, what other cells this touches>
