# Principles catalog

Each entry: the question it forces, what it trades against, its default tier, and — for contextual principles — the **signals** in requirements that suggest it matters. The survey matches signals against requirements to propose a shortlist.

Layers: A Intent · B Domain · C Structure · D Data & correctness · E Runtime · F Change & delivery.

## Contents
- Meta: ETC
- A. Intent (5)
- B. Domain (4)
- C. Structure (7)
- D. Data & correctness (7)
- E. Runtime (4)
- F. Change & delivery (5)
- Known tensions

---

## Meta

### ETC — Easier To Change · invariant
- **Question:** Which option leaves the system easier to change?
- **Trades against:** nothing directly; it is the tie-breaker.

---

## A. Intent

### YAGNI — build for today's stated need · contextual
- **Question:** Does a current requirement actually need this?
- **Trades against:** extensibility.
- **Signals:** early-stage product, unclear market fit, tight deadline. Weight down when requirements are contractual and stable.

### Shared language (ubiquitous language) · invariant
- **Question:** Does the code use the same word the business uses for this?
- **Trades against:** upfront modelling time.

### Reversibility awareness (one-way vs two-way doors) · invariant
- **Question:** If we're wrong, what does undoing this cost?
- **Trades against:** speed.

### Decisions are recorded · invariant
- **Question:** Will someone in six months know *why*?
- **Trades against:** velocity.

### Good-enough software · contextual
- **Question:** Who decided how good this needs to be, and was it the people paying for it?
- **Trades against:** perfectionism, or gold-plating.
- **Signals:** mixed-criticality areas (a regulated core beside internal tools), explicit SLAs, prototypes vs products.

---

## B. Domain

### Bounded contexts · contextual
- **Question:** Where does this term change meaning?
- **Trades against:** DRY (models get duplicated across contexts).
- **Signals:** the same noun used by different departments; multiple teams; external parties with their own vocabulary.

### Make illegal states unrepresentable · contextual
- **Question:** Can our types or schema express a state the business forbids?
- **Trades against:** flexibility for ad-hoc cases.
- **Signals:** money, compliance, safety, rules phrased as "must never" or "only if".

### Explicit lifecycle (state machines) · contextual
- **Question:** Is every state and transition named and guarded?
- **Trades against:** speed of quick one-off changes.
- **Signals:** entities with statuses (draft/approved/closed), approvals, workflows, SLAs on transitions.

### Single source of truth · contextual
- **Question:** Who owns this fact, and who only reads it?
- **Trades against:** read performance (caches, replicas).
- **Signals:** data synced between systems, reports that must reconcile, master data.

---

## C. Structure

### Deep modules (Ousterhout) · invariant
- **Question:** Is the interface much smaller than what it hides?
- **Trades against:** fine-grained reuse.

### Orthogonality — high cohesion, low coupling · invariant
- **Question:** Can I change this without side effects elsewhere?
- **Trades against:** convenience shortcuts.

### Dependencies point inward (ports and adapters) · contextual
- **Question:** Does the domain depend on infrastructure, or the other way round?
- **Trades against:** extra layers of indirection.
- **Signals:** likely vendor swaps, many integrations, long expected lifespan, heavy domain logic.

### DRY applies to knowledge, not text · invariant
- **Question:** Is this the same *knowledge*, or just code that looks similar?
- **Trades against:** decoupling.
- **Note:** duplication is cheaper than the wrong abstraction (Metz); wait for the third occurrence.

### Tell, don't ask (Law of Demeter) · tactical
- **Question:** Am I reaching through objects to make decisions that belong to them?
- **Trades against:** quick data access.

### Design by contract · contextual
- **Question:** What does this promise, and what does it require from callers?
- **Trades against:** upfront specification effort.
- **Signals:** shared libraries, public APIs, many consumers, cross-team interfaces.

### Least surprise · invariant
- **Question:** Would a new teammate predict how this behaves?
- **Trades against:** clever solutions.

---

## D. Data & correctness

### Parse, don't validate · invariant
- **Question:** Once data is inside, can we trust its shape?
- **Trades against:** lenient inputs.

### Crash early / assertive programming · contextual
- **Question:** If an "impossible" state happens, do we fail loudly or silently corrupt data?
- **Trades against:** apparent uptime.
- **Signals:** financial or regulated data, irreversible side effects, data that feeds other systems.

### Idempotency · contextual
- **Question:** What happens if this runs twice?
- **Trades against:** implementation complexity.
- **Signals:** retries, queues, webhooks, payments, at-least-once delivery, user double-clicks on consequential actions.

### Auditability and append-only history · contextual
- **Question:** Can we reconstruct who changed what, and when?
- **Trades against:** storage and complexity.
- **Signals:** regulation, disputes, approvals, money, "who approved this?" questions, legal hold.

### Explicit consistency model · contextual
- **Question:** Which reads must be exact, and which can lag?
- **Trades against:** availability and latency.
- **Signals:** distributed data, high read volume, multi-region, balances or inventory.

### Schema evolution · contextual
- **Question:** Can we change this without a big-bang migration?
- **Trades against:** short-term simplicity.
- **Signals:** long-lived data, many consumers of a schema, mobile clients you can't force-upgrade, event streams.

### Data minimisation and retention · contextual
- **Question:** Do we need to keep this, and for how long?
- **Trades against:** future analytics options.
- **Signals:** personal data, privacy regulation (GDPR, DPDP and similar), health or financial data.

---

## E. Runtime

### Secure by default, least privilege · invariant
- **Question:** Who can do this, and what is the default?
- **Trades against:** convenience.

### Observability · contextual
- **Question:** Could we debug this in production from telemetry alone?
- **Trades against:** cost and noise.
- **Signals:** distributed components, async flows, external SLAs, on-call expectations.

### Failure isolation · contextual
- **Question:** When this dependency fails, what else fails with it?
- **Trades against:** simplicity.
- **Signals:** third-party APIs, mixed-criticality features, batch jobs beside interactive paths.

### Measure before optimising · invariant
- **Question:** Is there evidence this is actually a bottleneck?
- **Trades against:** building for scale upfront.

---

## F. Change & delivery

### Small steps, fast feedback · invariant
- **Question:** What is the smallest slice that proves this works end to end?
- **Trades against:** completeness of the big design.

### Testable through the interface · invariant
- **Question:** Can we test the behaviour without touching internals?
- **Trades against:** some internal optimisations.

### Boring technology (innovation tokens) · contextual
- **Question:** Does the novel option buy something the boring one can't?
- **Trades against:** capability.
- **Signals:** small team, long maintenance horizon, hiring constraints. Record the token budget in PRINCIPLES.md.

### Guardrails are automated (fitness functions) · invariant
- **Question:** Is this principle enforced by a check, or only by goodwill?
- **Trades against:** setup cost.

### No broken windows · invariant
- **Question:** Are we leaving decay that tells everyone it's fine to add more?
- **Trades against:** short-term velocity.

---

## Known tensions

Name a stance in PRINCIPLES.md on each tension that is live in the project.

- DRY ↔ bounded contexts
- YAGNI ↔ reversibility (skip it, unless adding it later is a one-way door)
- Single source of truth ↔ read performance
- Auditability ↔ simplicity
- Consistency ↔ availability/latency
- Crash early ↔ apparent uptime
- Boring technology ↔ capability
