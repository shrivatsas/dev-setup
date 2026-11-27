---
name: cartograph-survey
description: Start a Cartograph evaluation of a new or existing project — build the fog-of-war map of areas × layers, run a wide-and-shallow first pass, and select and weight the principles that will judge every decision. For an existing system (brownfield), it walks the architect through what is already built and ends with an advisory verdict per area. Run once per project, and again when scope changes a lot.
disable-model-invocation: true
---

# Survey

The survey answers three questions before any deep work: *what territory is there*, *what matters here*, and *where is it most dangerous to be wrong*. It is deliberately shallow. Resist the pull to solve any one area; that is what expeditions are for.

Load the `cartograph-principles` skill and use `cartograph-map` for every map change.

## 0. Set up

1. Ask where the map should live (default `project-map/`). Copy this skill's `templates/` there: `map.yaml`, `assumptions.yaml`, `PRINCIPLES.md`, `GLOSSARY.md`, and `AREA.md` (one copy per area later, under `areas/<area-id>/`).
2. Add one line to AGENTS.md or CLAUDE.md: `Project map: <path>` so later sessions can find it.
3. Gather the source material: requirement docs, briefs, existing code, the conversation so far. Read before asking.
4. **Choose the branch.** Look at the repo first. If there is code, schemas or deploy config for the system being evaluated, say what you found and ask whether this is a **new build**, an **existing system**, or **both** (and which parts already exist). Record the answer: it sets each area's `origin` in step 2.
   - **New build:** follow the steps as written.
   - **Existing system (brownfield):** follow the steps, plus the marked **Brownfield** notes. Existing areas are mapped as built through `cartograph-inspect`, and the survey ends with an advisory.
   - **Both:** each area takes the branch matching its origin.

## 1. Grill for intent (whole project)

Interview the user one question at a time until these are clear: the outcomes the project exists to produce, who it serves, hard constraints (deadlines, budget, regulation, contracts, existing systems), explicit non-goals, the quality bar, and who can make decisions. Prefer the `grilling` / `grill-me` skill if installed. Record new terms in GLOSSARY.md as they appear.

**Brownfield:** also establish why the system is being looked at now (the change, pain or deadline that prompted it), who still knows its history, and what must not break. That change is what makes an area `on_path`.

Stop grilling when further answers wouldn't change which areas exist or which principles matter. Detailed questions belong to expeditions.

## 2. Discover areas

Propose candidate areas from the material. Good sources: capabilities the business names; nouns that have lifecycles; external parties and integrations; regulatory zones; anything with a distinct owner. Aim for roughly 4–12 top-level areas; larger projects zoom later, they don't start with 40 rows.

For each area: an id, a title, a two-sentence charter, `depends_on`, `origin` (`new` or `existing`), and whether it is `on_path` for the first thing the user wants built. Put suspected-but-unclear areas under `undiscovered`. Confirm the list with the user before continuing.

**Brownfield:** read the code as a source too: top-level modules and packages, database schemas, deploy units, external integrations (client libraries, config), and queue or cron consumers. Name areas by what the business calls them, not by module names. Where code boundaries and business areas disagree, say so; that mismatch is an early finding.

## 3. Wide-and-shallow pass

For **new** areas: move every area's **intent** cell to `sighted` (or further if the material already settles it), with its obvious open questions and first estimates of `irreversibility` and `uncertainty`. Where the material clearly reveals domain questions, sight the domain cell too.

For **existing** areas: run the walk in `cartograph-inspect` instead. It goes bottom-up (delivery → intent), shows the architect what the repo reveals, confirms it one question at a time, and records it as built: observations in AREA.md, inherited decision records for one-way commitments, assumptions for the unknowns.

Create `areas/<area-id>/AREA.md` for each area.

Don't make decisions here beyond what the user has already firmly decided. If they have, record them properly through `cartograph-decide`. Finding what an existing system already committed to is recording, not deciding.

## 4. Select principles

1. Copy the invariant tier into PRINCIPLES.md as is.
2. For each contextual principle in the catalog, check its **signals** against the requirements. Propose a shortlist, each with a weight (1–5) and a trace to the requirement or person that justifies it. A principle with no trace doesn't make the list.
3. Propose per-area overrides where an area's criticality differs (for example, auditability 5 in payments, 1 in notifications).
4. Write a stance for each live tension from the catalog.
5. List principles considered and not selected, with the reason.
6. Set the innovation token budget.

**Brownfield:** the walk is a source of signals too. Pain the architect described (for example "every pricing change breaks reporting") traces to a principle as well as a requirement does. Don't lower a weight because the existing system fails it; the advisory needs to show that gap.

PRINCIPLES.md governs every later decision, so **get explicit approval** from the user before saving it as approved. Present the shortlist compactly and invite them to change weights.

## 4b. Advise (brownfield only)

Once PRINCIPLES.md is approved, run the advise step in `cartograph-inspect`. It writes `advisory.md` with one verdict per existing area (leave alone, wrap, strangle, replace), with evidence and confidence. Present the summary table. The architect adopts verdicts as decisions in later expeditions; the survey doesn't record them.

## 5. Close the survey

1. Run `validate` and `render` (via `cartograph-map`).
2. Run `frontier --top 5` and show the top three candidates, with the reason each ranks high.
3. Run `report` to create the baseline status report and snapshot.
4. Write `expeditions/<date>-survey.md` from the expedition-log template (in the `cartograph-expedition` skill), listing areas found, principles selected, assumptions made and open threads. For brownfield, also list the inherited records and the advisory verdicts.
5. Stop. Tell the user the next step is `/cartograph-expedition`. Don't start one in the same session unless they ask; a fresh session starts with a cleaner context.
