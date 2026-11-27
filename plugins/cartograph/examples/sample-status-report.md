<!-- Example output of `map.py report` on a small invented map, included to show the format. -->

# Status report — Test marketplace — 2026-11-21

## Headline

6 of 24 cells are charted or verified (25%), across 4 areas. 1 one-way decision(s) are accepted but unproven; 3 assumption(s) are open, 1 of them blocking; 1 cell(s) are contested. No area is ready to build yet.

## Since last report

Compared with 2026-11-14:

- Cells moved: 2 — core.data scouted→charted; payments.domain scouted→contested
- New one-way decisions: D-core-003
- One-way doors proven: 1
- New assumptions: A-004; status changes: none
- Fog returned on: payments.domain

## Coverage

Legend: · fog  ○ sighted  ◐ scouted  ● charted  ✔ verified  ! contested

| Area | Intent | Domain | Structure | Data | Runtime | Delivery | Done |
|---|---|---|---|---|---|---|---|
| Core workflow ★ | ✔ | ● | ● | ● | ◐ | ○ | 4/6 |
| Payments | ● | ! | · | · | · | · | 1/6 |
| ↳ Refunds | ○ | · | · | · | · | · | 0/6 |
| Reporting | ● | · | · | · | · | · | 1/6 |
| **Charted or verified** | 3/4 | 1/4 | 1/4 | 1/4 | 0/4 | 0/4 | 6/24 |

Suspected but not yet mapped: partner portal.

## Risk

### Unproven one-way doors

- **D-core-001** (core.domain) — Separate Order models per context

### Assumptions

- BLOCKING · **A-003** (core.delivery): single region launch — revisit when: EU customer signs
- **A-001** (refunds.intent): refunds only within 30 days — revisit when: legal review
- **A-002** (core.runtime): 99.5% availability is enough — revisit when: first enterprise contract
- BROKEN · **A-004** (payments.domain): cells relying on it should be contested

### Contested cells

- **payments.domain** — A-004 broken: partial captures are needed

### Watchlist — triggers that would reopen accepted decisions

- **D-core-001**: translation layers mirror each other
- **D-core-002**: team grows past 3 squads
- **D-core-003**: regulator asks for full history

## Principles in practice

Counts come from one-way decision records (superseded ones excluded). Per-area override weights are applied when judging trade-offs.

| Principle | Weight | Favoured | Traded away | Flag |
|---|---|---|---|---|
| Bounded contexts | 5 | 1 | 0 |  |
| Auditability and append-only history | 4 | 0 | 2 | losing often where it weighs ≥4 — re-weight or enforce |
| Explicit consistency model | 4 | 1 | 0 |  |
| YAGNI | 3 | 1 | 0 |  |
| DRY applies to knowledge, not text | inv. | 0 | 1 | invariant traded away — the record must say why |
| ETC | inv. | 1 | 0 |  |

Settled at rung: 2: 1, 4: 1, 5: 1, 6: 1. Doors: converted: 1, one-way: 3. Two-way light records: 2.

## Build readiness

**Ready:** none.

- **Core workflow ★** — 2 blocker(s): core.domain has unverified one-way doors: ['D-core-001']; core.delivery relies on blocking assumption A-003
- **Payments** — 5 blocker(s): payments.domain is contested; must be charted; payments.structure is fog; must be charted; payments.data is fog; must be charted …
- **Reporting** — 6 blocker(s): reporting.domain is fog; must be charted; reporting.structure is fog; must be charted; reporting.data is fog; must be charted …
- **Refunds** — 7 blocker(s): refunds.intent is sighted; must be charted; refunds.domain is fog; must be charted; refunds.structure is fog; must be charted …

## Integrity checks

- payments.intent: parent is ahead of sub-area refunds.intent; a parent cell summarises its children
- payments.domain: parent is ahead of sub-area refunds.domain; a parent cell summarises its children
- payments.intent cites L-003 but no AREA.md light record has that id
- D-core-003 is accepted with no approved_by

## Suggested next expeditions

- **core.runtime** (scouted) — irr=2, unc=2, dependents=2, on path
- **core.delivery** (sighted) — irr=2, unc=2, dependents=2, on path, via assumption
- **payments.domain** (contested) — irr=2, unc=2, dependents=2, contested

