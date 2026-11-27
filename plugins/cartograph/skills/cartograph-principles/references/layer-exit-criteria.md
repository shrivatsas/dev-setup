# Layer exit criteria and scouting prompts

A cell's state means the same thing in every layer; what differs is the evidence. Use these to decide state transitions and to generate scouting questions.

## What each state means

- **fog** — not looked at.
- **sighted** — we know the cell exists and have listed at least the obvious open questions.
- **scouted** — questions are listed and prioritised, risks named, and every pending decision classified as one-way or two-way.
- **charted** — the layer's exit criteria below are met; every one-way decision has a record and human approval; two-way decisions have light records; remaining unknowns are written as assumptions with triggers.
- **verified** — the one-way decisions are backed by evidence that actually tests them (tracer bullet, prototype result, load test, review by the owning team, production data).
- **contested** — a revisit trigger fired, or new evidence contradicts a decision. Scheduled like `scouted`, with a priority boost.

**Existing systems (`origin: existing`).** The criteria below are the same, but the evidence can be as built. A confirmed observation in AREA.md's `## As built` section counts toward "decided". An inherited decision record stands in for a one-way decision record and needs confirmation rather than approval. An existing area's cell can be charted without changing anything, once what is there is understood well enough to meet the criteria. "Verified by" evidence can come from production: running code, real data, an incident history.

---

## Intent
**Charted when:** outcomes, users, constraints, non-goals and the quality bar for this area are agreed, and each is traced to a requirement or a named stakeholder.
**Scouting prompts:** Who uses this and what are they trying to get done? What happens if this area doesn't exist? What is explicitly out of scope? What would "good enough" look like? What deadlines, regulations or contracts bind it? Who can say yes?
**Verified by:** stakeholder sign-off, a walkthrough of key scenarios, or user research.

## Domain
**Charted when:** core terms are in GLOSSARY.md; invariants ("must never", "only if") are listed; entity lifecycles have named states and transitions; boundaries with neighbouring areas say where terms change meaning.
**Scouting prompts:** What are the nouns with lifecycles? What states can each be in, and who moves it between them? Which rules can never be broken? Where does the same word mean something different next door? What edge cases would a domain expert raise first?
**Verified by:** a domain expert walking through edge-case scenarios against the model; a prototype state machine.

## Structure
**Charted when:** module boundaries, their interfaces and dependency direction are decided; each interface is deep (small surface, a lot hidden); seams for likely change are identified.
**Scouting prompts:** What changes together? What must be swappable? What is the smallest interface that serves the callers? Which way do dependencies point? Where are the test seams?
**Verified by:** a tracer bullet crossing the main boundaries; tests written through the interfaces.

## Data
**Charted when:** every important fact has an owner; consistency needs per read path are stated; history/audit, retention and migration approach are decided.
**Scouting prompts:** Who owns each fact and who only reads it? Which reads must be exact? What must be reconstructable later? How long do we keep it? How will this schema change in a year? What happens if a write runs twice?
**Verified by:** a migration rehearsal; an idempotency test; an audit-reconstruction test.

## Runtime
**Charted when:** the security model (who can do what), failure modes of each dependency, isolation strategy, observability needs and service-level targets are decided.
**Scouting prompts:** What is the default permission? What happens when each dependency is down or slow? What must we be able to see in production? What load, latency and availability are actually required, and what evidence supports those numbers?
**Verified by:** a threat-model review; failure injection; a load test against stated targets.

## Delivery
**Charted when:** the build is cut into ordered vertical slices; the test strategy is chosen; rollout, migration and rollback paths are decided.
**Scouting prompts:** What is the first slice that proves the path end to end? How do we release without a big bang? How do we roll back? What fitness functions guard the key principles?
**Verified by:** the first slice shipped behind a flag; a rollback rehearsed.
