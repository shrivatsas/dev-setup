---
name: cartograph-map
description: Keep a Cartograph project map honest — move cells between fog/sighted/scouted/charted/verified/contested, add or split areas (zoom), record dependencies and assumptions, and run the map script to validate, render MAP.md, rank the frontier and check build readiness. Use whenever map.yaml or assumptions.yaml is read or changed, whenever an expedition or survey finishes, when new territory (an area, sub-area or dependency) is discovered, when a revisit trigger fires, or when someone asks "what should we look at next" or "are we ready to build X".
---

# Map keeping

The map is the shared memory of a project that is too big for any one session. Its value depends entirely on it being true. Never mark progress the evidence doesn't support, and never leave a discovery off the map because it's inconvenient.

Schema details: `references/map-schema.md`. Exit criteria per layer: the `cartograph-principles` skill, `references/layer-exit-criteria.md`.

## Finding the map

Look for the pointer line `Project map: <path>` in AGENTS.md or CLAUDE.md. Default location is `project-map/`. If there is no map, stop and suggest `/cartograph-survey`.

## The script

Run from anywhere; pass the map directory.

```bash
python <this-skill-dir>/scripts/map.py validate project-map
python <this-skill-dir>/scripts/map.py render   project-map   # writes MAP.md
python <this-skill-dir>/scripts/map.py frontier project-map --top 5
python <this-skill-dir>/scripts/map.py ready    project-map <area-id>
python <this-skill-dir>/scripts/map.py report   project-map   # writes reports/YYYY-MM-DD.md
```

Always run `validate` after editing map.yaml, then `render`. MAP.md is generated; never edit it by hand.

## The status report

`report` writes a one-page status report for people who aren't doing the expeditions: headline, what changed since the previous report, coverage grid, risk (unproven one-way doors, assumptions with blocking ones first, contested cells, the watchlist of revisit triggers), principles in practice (which principles decisions favoured or traded away, with flags for ones that keep losing or are never cited), build readiness per area, integrity checks, and suggested next expeditions. It also saves a snapshot so the next report can say what changed.

Run it when the user asks for status, before a milestone or review, and after every few expeditions. When you present it, lead with the headline and the flags; don't paraphrase the whole file. Treat its integrity checks as work: a decision cited on the map with no record, or an accepted decision with no approver, should be fixed before anyone relies on the report.

## State transitions

Allowed moves: `fog → sighted → scouted → charted → verified`, any state `→ contested`, and `contested → scouted`. Moving more than one step in one expedition is fine if the evidence for each step exists.

- Don't move a cell to `charted` unless the layer's exit criteria are met. If a layer genuinely has nothing to decide, set `no_decisions_needed: true` and say why in AREA.md.
- A cell can't be `charted` until the same area's previous layer is charted or covered by a live assumption. The script enforces this. **Exception:** areas with `origin: existing` have no layer gate. They are mapped bottom-up from what can be observed (see `cartograph-inspect`), so data can be charted before anyone can say what the intent was. The exit criteria for each layer still apply.
- When a one-way decision is accepted but not yet proven, list it under `one_way_pending`. Remove it when evidence is added.
- `verified` needs entries in `evidence`.
- To mark `contested`, set `contested_by` (the trigger that fired or the conflicting finding). Don't fix the contested cell in passing; it goes back on the frontier.

## Zoom: splitting and merging areas

Split an area into sub-areas (each with `parent: <area-id>`) when any of these hold:
- one layer has more than about eight open questions;
- it contains two lifecycles that change for different reasons;
- different stakeholders own different parts of it;
- one expedition can't chart a single cell of it.

After a split, the parent's cells summarise the children: a parent cell is never more advanced than its least advanced child in that layer. Merge sub-areas back when they turn out to share a lifecycle and owner. Splits and merges go in the expedition log.

## Existing systems

Each area has `origin: new` (default) or `origin: existing`. A sub-area without its own origin takes its parent's. Existing areas show ⌂ in MAP.md and the report. Commitments found in them are recorded as inherited decisions (`status: inherited`, see `cartograph-decide`). They sit in the cell's `decisions`, never in `one_way_pending`. Set `origin` when the area is created; changing it later means the area's history should be re-read.

## Danger estimates

`irreversibility` and `uncertainty` drive the frontier ranking along with the number of dependents and `on_path`. Update them every time a cell is visited. Unknown irreversibility defaults to medium; uncertainty defaults to high for fog cells.

## Undiscovered territory

Put suspected-but-unnamed areas under `undiscovered` instead of forgetting them. Promote them to real areas once they have a name and a charter.
