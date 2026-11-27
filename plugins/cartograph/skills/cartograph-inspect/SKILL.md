---
name: cartograph-inspect
description: Walk an architect through an existing system (brownfield) area by area and layer by layer — show what the code, schemas and config reveal, confirm it with the architect one question at a time, record it on the Cartograph map as built, then give an advisory verdict per area (leave alone, wrap, strangle, replace) with evidence and confidence. Use when a Cartograph survey or expedition reaches an area with origin existing, when someone asks "what do we have here" or "should we rewrite this" about a mapped system, or when an inherited commitment needs confirming.
---

# Inspect an existing system

An existing system has already made most of its decisions. Inspecting does not re-decide them. It finds them, confirms them with someone who knows the system, records them as built, and then gives advice about each area. The architect makes the decisions.

Two jobs: **walk** (build the as-built picture with the architect) and **advise** (a verdict per area). The survey runs the walk before choosing principles and runs advise after the principles are approved, because the verdict is judged against them. An expedition can walk a single cell.

Use `cartograph-map` for every map change, the `cartograph-decide` section on inherited decisions for every inherited record, and `cartograph-principles` for the layer prompts.

## Walk

### Order: bottom-up

Go through each `origin: existing` area in the order evidence becomes available, not the order it was designed in:

```
delivery → runtime → data → structure → domain → intent
(what you can see in the repo)        (what only people remember)
```

The map has no layer gate for existing areas, so this order is allowed. Do the areas on the build path (`on_path`) first. Skip a layer for an area when nothing in the repo bears on it, and leave that cell `fog`.

### Where to look, per layer

- **Delivery:** CI config, deploy scripts, infrastructure code, release tags, feature flags, migration tooling.
- **Runtime:** service and worker entry points, auth middleware and permission checks, timeouts and retries, logging and metrics, health checks, SLO or alert config.
- **Data:** schemas and migrations, ORM models, who writes each table and who only reads it, other systems or teams reading the same store, retention jobs, audit tables.
- **Structure:** top-level modules and packages, import direction, public interfaces, where tests live, `git log` churn for the last 12 months (`git log --since=12.months --name-only --format=`).
- **Domain:** names of entities and their status fields or enums, state transitions in code, validation rules that read like invariants, comments explaining business rules.
- **Intent:** READMEs, ADRs, tickets, commit messages that say why. Expect gaps here: this layer usually depends on the architect.

### Each stop: show, ask, record

1. **Show.** Say what you found in three to six lines, with file paths, table names or config keys. Separate what you saw from what you are inferring.
   > Data: `orders` has 14 related tables (`db/schema.rb`). `billing-service` and `reporting` also read it directly (`config/database.yml` in each repo). There's no migration tooling beyond Rails migrations.
2. **Ask.** One question, the one whose answer would most change the picture. Offer what you think the answer is so the architect can confirm it quickly.
   > Is anyone outside these three teams reading `orders`? I think no, but I can only see these repos.
   The architect can confirm it, correct it, or say nobody knows. "Nobody knows" is a useful answer: record it as an assumption with a revisit trigger, not as a fact.
3. **Record.**
   - Confirmed observations go into the area's `## As built` section of AREA.md, each with its evidence and who confirmed it.
   - An observation that is a **one-way commitment** gets an inherited decision record (status `inherited`) through `cartograph-decide`. Use the one-way signals in the conflict ladder: a persisted format others consume, a public or cross-team contract, a vendor, a permission model, money movement, a team boundary. Put it in the cell's `decisions`, not in `one_way_pending`. It is already in production.
   - Unknowns become assumptions in `assumptions.yaml`. Mark one `blocking` if a change would be unsafe while it stays open.
   - Glossary terms the code uses go into GLOSSARY.md. Where the code's name and the business's name differ, record both and note which one to use.
   - Set the cell's state, danger estimates and `last_visited`. A walked cell is usually `sighted`, or `scouted` once its risks are named and the changes ahead are classified by door. The walk doesn't chart cells; expeditions do.

Code and business areas often disagree: one business area spread over three modules, or one module serving four areas. Point this out when you see it. It's a finding, and it often explains why the system is hard to change. Propose a split or a merge through `cartograph-map` if it changes which areas exist.

### Keep the walk proportionate

Stay wide and shallow, as the survey does. If one area would take more than a session to walk, walk its `on_path` cells and the data layer, and leave the rest `fog` with a note. The architect's attention is the scarce resource. Don't ask about anything the code already answers clearly, and stop asking about a layer when more answers wouldn't change the verdict.

## Advise

Once PRINCIPLES.md is approved, write `advisory.md` in the map directory from `templates/advisory.md` and add a one-line summary to each existing area's AREA.md. Call it what it is: advice. It is not a decision and it doesn't need approval to be written. Adopting a verdict is a decision, and it goes through `cartograph-decide`.

### The verdicts

From least to most irreversible:

| Verdict | Means | Typical signals |
|---|---|---|
| **Leave alone** | Don't change it now, and route new work around it. | Low change pressure, not on the build path. Even a badly designed area is cheap to keep if nobody needs to change it. |
| **Wrap** | Add a seam at its boundary (an interface, characterization tests) and keep the internals. | Many consumers or inherited one-way doors, change needed, internals untested or poorly understood. |
| **Strangle** | Replace it piece by piece behind a seam, moving one capability at a time. | High change pressure, fails high-weight principles, and a seam can be placed. |
| **Replace** | Build it new and cut over. | Small blast radius, little behaviour worth keeping, fails decisive principles, or forced (end of life, vendor exit). Needs strong evidence. |

### How to reach a verdict

For each existing area, fill the signals:

- **Blast radius:** dependents on the map, plus external consumers found in the walk. Inherited one-way doors raise it.
- **Change pressure:** churn in the last 12 months, plus whether the area is `on_path` for the change that prompted this work.
- **Test seams:** whether tests exist that exercise it through an interface, and whether there is a boundary where one could go.
- **Principles fit:** ask each shortlisted principle's question of the as-built area, highest weight first, using the area's overrides. Report only the clear passes and failures, with evidence.
- **Unknowns:** open assumptions on the area, especially blocking ones.

Then choose. When two verdicts are close, pick the more reversible one (the earlier row in the table). That's the conflict ladder's asymmetry check: you can go from wrap to strangle later, but not back from a half-finished replace. Recommend **Replace** only when the evidence for it is explicit. "The code is ugly" is not evidence. "Nothing depends on it, it has no tests worth keeping and it fails the weight-5 principle in every module" is.

### Confidence

- **High:** every signal is backed by evidence the architect confirmed.
- **Medium:** one signal is missing or unconfirmed.
- **Low:** the verdict rests mainly on reading code, with key facts unknown.

For medium and low confidence, name the check that would raise it ("ask the billing team whether they write to `orders`"). Never present a low-confidence verdict without that line.

### Present it

Lead with the summary table: area, verdict, confidence, one-line reason. Then point the architect to the first decision each verdict implies (for Wrap: where the seam goes and what contract it has). Offer to start the most urgent one as an expedition. Don't write that decision record yourself unless the architect asks.

## Hand-back

The survey or expedition that called this skill closes the session. Make sure the map validates, the assumptions you added have triggers, and every inherited record either has `confirmed_by` or is listed under "unconfirmed" in the advisory.
