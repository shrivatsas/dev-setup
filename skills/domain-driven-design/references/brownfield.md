# Brownfield

Use this when reviewing or improving an existing system.

## Order

1. Read the code and docs before trusting the stated model.
2. Map the language used in code, docs, APIs, and database names.
3. Identify bounded contexts that already exist, even if they are accidental.
4. Find where invariants are enforced and where they leak.
5. Check whether repositories, services, and modules preserve boundaries.
6. Spot cross-context coupling, shared tables, and shared models.
7. If the system spans repos, review each integration contract from both sides (see below).
8. Triage findings by severity before reporting (see below).
9. Decide the smallest useful refactor that improves the model.
10. Keep the review focused on one boundary or term at a time.

## Red Flags

- One service owns too many rules.
- Domain logic lives mostly in controllers, handlers, or scripts.
- Repositories expose ORM details or query shaping everywhere.
- The same concept has different names in different layers.
- One change forces edits across unrelated parts of the system.
- A context depends on another context's internals instead of a contract.
- An invariant is enforced only in the API/validation layer — background jobs, admin tools, and migrations bypass it.
- State encoded implicitly (e.g. "absence of a row means active") with nothing but convention guarding it.
- Nullable foreign keys that make aggregate ownership ambiguous (a child pointing at two parents with no consistency rule between them).
- The same enum respelled or recased across layers, with ad-hoc mapping at each boundary.
- A constant (role name, claim name, enum value) hardcoded as a string in more than one repo.
- Code that consumes a contract field nothing produces — it looks live but is dead, and usually hides a silent fallback.

## Cross-Repo Contract Review

When the system spans repos (API, frontend, identity, workers), the highest-value drift usually lives *between* them, not inside any one. For each integration contract, read both sides:

- **Token/claim contracts:** what claims does the issuer actually emit vs what do consumers parse? Diff the mapper config against every consumer's extraction code.
- **API type contracts:** do client types mirror server shapes, or silently reshape them? Where are the mappers, and are they localized?
- **Duplicated names:** grep each repo for the other repos' role names, group names, claim names, enum values. Every shared string is an unversioned contract — note who owns it and what breaks on rename.
- **Ownership:** for each contract, name the owning context. A field nobody owns will drift.

## Evidence Discipline

- Every finding cites `file:line`.
- Verify each red flag in the source before reporting it. If exploration was delegated, re-check the load-bearing claims yourself — especially negative findings ("X is missing", "Y is not atomic"), which are the easiest to get wrong.
- If the code contradicts a finding, drop or correct the finding; never report unverified.

## Severity Triage

Report findings in this order:

1. **Wrong now** — data can already go bad or access can already leak with the current code (e.g. a missing cross-FK invariant, a bypassed state machine).
2. **Breaks on change** — correct today, but an unguarded rename/edit in one place silently breaks another (e.g. string-duplicated contracts, convention-only rules).
3. **Language hygiene** — naming drift, glossary gaps, term overload. Real, but fix opportunistically.

## Review Questions

- Where is the invariant actually enforced — and which write paths never pass through that point?
- Who owns this data?
- What is the contract between contexts, and is it written down anywhere?
- What breaks if this module is split?
- What is already clean enough to keep? Say so explicitly — it stops good patterns being refactored away.
- Which term in the code is doing too much work?
- What is the concrete failure if this boundary stays fuzzy?

## Typical Improvements

- Rename terms to match the business language.
- Pull invariants into a smaller aggregate — one mutation method on the model that validates and saves, called from every write path.
- Add an anti-corruption layer around a messy dependency.
- Introduce domain events where direct coupling is too tight.
- Turn an implicit cross-repo contract into a published one: a one-page claims/contract doc, or a CI check that diffs the shared names.
- Split a context only when the boundary is clear enough to own.
