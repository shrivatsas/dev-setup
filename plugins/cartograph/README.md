# Cartograph

Evaluate a large project the way you would explore a map under fog of war: area by area, layer by layer, clearing fog only where the path needs it, and judging every decision against a shortlisted set of software design principles.

## The model in one paragraph

The project is a grid. **Areas** (capabilities or bounded contexts, discovered as you go) run down the side; **layers** run across: intent → domain → structure → data → runtime → delivery. Each cell ("this area, through this layer") has a fog state: `fog → sighted → scouted → charted → verified`, plus `contested` when a revisit trigger fires and fog returns. A **survey** builds the map wide and shallow. Each **expedition** takes one cell from the frontier, scouts it, decides, proves the one-way doors, and updates the map. Decisions are settled with a conflict ladder whose first rung is "one-way or two-way door?" and whose tie-breaker is ETC (Easier To Change).

## Skills

| Skill | Invoked by | Job |
|---|---|---|
| `cartograph-survey` | you | Create the map, run the wide-shallow pass, select and weight principles |
| `cartograph-expedition` | you | Take the next frontier cell through scout → decide → prove → update → hand off |
| `cartograph-principles` | model | The library: principles catalog, practices, conflict ladder, layer exit criteria |
| `cartograph-decide` | model | Evaluate one decision: door type, ladder, principles scorecard, record |
| `cartograph-map` | model | Keep `map.yaml` honest: state transitions, zoom (split/merge), validate, render, frontier, build readiness, status report |
| `cartograph-review` | model | The third review axis: does this diff/plan honour the principles and accepted decisions? |
| `cartograph-inspect` | model | Existing systems: walk the architect through what is built, record it, give an advisory verdict per area |

User-invoked skills orchestrate; model-invoked skills hold the reusable discipline. A user-invoked skill may call model-invoked ones, never another user-invoked one.

## Typical flow

```
/cartograph-survey              # once per project (re-run when scope changes a lot)
/cartograph-expedition          # repeatedly; one cell per session
/cartograph-expedition ready payments   # when you want to build an area
→ hand off to your spec / plan / tickets skills
```

## New builds and existing systems

The survey asks whether you're building something new, evaluating an existing system, or both. Each area is marked `origin: new` or `origin: existing`.

```
/cartograph-survey
  └─ existing code here?
       no  ─▶ grill → areas → sight intent → principles            (greenfield)
       yes ─▶ grill → areas → walk as built → principles → advisory  (brownfield)
```

For existing areas, `cartograph-inspect` walks the architect through the system bottom-up (delivery → runtime → data → structure → domain → intent). At each stop it shows what the repo reveals, asks one question, and records the answer. Commitments the system already made (a schema other teams read, a public API) become **inherited** decision records: found, not chosen, and confirmed instead of approved. After the principles are approved it writes `advisory.md` with one verdict per area (**leave alone, wrap, strangle, replace**), each with evidence, confidence and what would change it. The advisory is advice. The architect adopts verdicts as decisions in later expeditions.

Existing areas have no layer gate: you can chart data before anyone remembers the intent.

## What it produces in your repo

```
project-map/
  map.yaml          # source of truth: areas × layers, states, danger, dependencies
  MAP.md            # rendered view + frontier (generated; don't edit)
  PRINCIPLES.md     # shortlist, weights, per-area overrides, tension stances
  GLOSSARY.md
  assumptions.yaml  # every fog patch walked through, with its revisit trigger
  advisory.md       # existing systems only: verdict per area, with evidence and confidence
  areas/<area>/AREA.md
  areas/<area>/decisions/D-<area>-NNN.md   # one-way-door decisions
  expeditions/YYYY-MM-DD-<area>-<layer>.md
  reports/YYYY-MM-DD.md              # stakeholder status report
  reports/snapshot-YYYY-MM-DD.json   # lets the next report say what changed
```

## Outputs, by reader

- **Whoever is doing the work:** MAP.md (grid, frontier, open assumptions), AREA.md pages, expedition logs.
- **Whoever approves decisions:** decision records with door analysis, principles scorecard, trade-offs accepted and revisit triggers.
- **Architect of an existing system:** `advisory.md` (verdict per area, with evidence and confidence), the as-built section of each AREA.md, and inherited records to confirm.
- **Leads, sponsors, reviewers:** `reports/YYYY-MM-DD.md` — headline, changes since last report, coverage, risk, principles in practice, build readiness, integrity checks.
- **Whoever is about to build:** `ready <area>` go/no-go with blockers.
- **Code reviewers:** principles review findings (Blocking / Should fix / Note) and implied map updates.

## Companion skills (optional)

Cartograph delegates when these are installed and falls back to inline behaviour when they aren't:

- Matt Pocock's skills: `grilling` / `grill-me`, `domain-modeling`, `research`, `prototype`, `tdd`, `codebase-design`, `to-spec`, `to-tickets`, `code-review`, `handoff`
- obra/superpowers: `brainstorming`, `writing-plans`, `verification-before-completion`

## Install

Claude Code: copy `skills/*` into `.claude/skills/` (project) or `~/.claude/skills/` (user), or install this folder as a plugin. The map script needs Python 3 and PyYAML.
