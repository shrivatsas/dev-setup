# map.yaml and assumptions.yaml schema

## map.yaml

```yaml
version: 1
project: <string>
areas:
  <area-id>:                    # kebab-case, stable
    title: <string>
    parent: <area-id> | null    # sub-area of
    origin: new | existing      # default new; sub-areas inherit the parent's. existing = no layer gate
    depends_on: [<area-id>, …]  # this area relies on those
    on_path: <bool>             # needed for the next build slice (doubles frontier score)
    cells:
      <layer>:                  # intent | domain | structure | data | runtime | delivery
        state: fog | sighted | scouted | charted | verified | contested
        irreversibility: low | medium | high
        uncertainty: low | medium | high
        open_questions: [<string>]
        decisions: [<id>]       # D-<area>-NNN files or L-NNN light records
        assumptions: [<A-id>]
        one_way_pending: [<id>] # accepted one-way decisions not yet verified
        evidence: [<string>]    # required for verified
        contested_by: <string>  # required for contested
        no_decisions_needed: <bool>
        last_visited: <YYYY-MM-DD>
undiscovered: [<string>]
```

Missing layers default to `state: fog`.

## assumptions.yaml

```yaml
A-001:
  cell: <area-id>.<layer>
  statement: <string>
  made_in: <expedition log path>
  revisit_when: <string>        # required (warning if missing)
  status: open | confirmed | broken
  blocking: <bool>              # blocks build readiness until confirmed
```

An assumption with status `open` or `confirmed` is *live*: it satisfies the layer gate for the next layer. A `broken` assumption satisfies nothing, and every cell that relied on it should be marked `contested`.

## Decision record front matter

The report reads YAML front matter from `areas/<area>/decisions/*.md`: `id`, `title`, `cell`, `status` (proposed | accepted | superseded | inherited), `superseded_by`, `door` (one-way | converted), `rung`, `date`, `approved_by`, `favoured` and `traded_away` (lists of principle names exactly as in PRINCIPLES.md), `revisit_when`. Two-way light records are rows in AREA.md's decision log starting `| L-NNN | <layer> | two |`.

Inherited records (`status: inherited`) describe commitments found in an existing system. They need `confirmed_by` instead of `approved_by`, have no `rung`, `favoured` or `traded_away`, and are left out of the principles and ceremony statistics. The report flags an inherited record with no `confirmed_by`, or one in an area that isn't `origin: existing`.

The report reads weights from PRINCIPLES.md: the invariant list (names separated by ` · `), the contextual shortlist table (name, weight) and the per-area overrides table (area, name, weight). Keep those headings and column orders.

## Reports and snapshots

`report` writes `reports/YYYY-MM-DD.md` and `reports/snapshot-YYYY-MM-DD.json`. "Since last report" compares with the newest snapshot dated before today. Commit both.

## Frontier score

`irreversibility × uncertainty × (1 + dependents)`, ×2 if the area is `on_path`, ×1.5 if the cell is `contested`. Only cells that are not charted/verified and whose layer gate is open are candidates (always open in `origin: existing` areas). Ties go to the earlier layer. The score orders the candidates; the human can always override it.

## Build readiness (`ready`)

An area is ready to build when intent, domain, structure and data are charted; runtime and delivery are charted or covered by live assumptions; no `one_way_pending` remain; no blocking assumptions are relied on; and every area it depends on has intent and domain charted.
