# Brownfield

Use this when reviewing or improving an existing system.

## Order

1. Read the code and docs before trusting the stated model.
2. Map the language used in code, docs, APIs, and database names.
3. Identify bounded contexts that already exist, even if they are accidental.
4. Find where invariants are enforced and where they leak.
5. Check whether repositories, services, and modules preserve boundaries.
6. Spot cross-context coupling, shared tables, and shared models.
7. Decide the smallest useful refactor that improves the model.
8. Keep the review focused on one boundary or term at a time.

## Red Flags

- One service owns too many rules.
- Domain logic lives mostly in controllers, handlers, or scripts.
- Repositories expose ORM details or query shaping everywhere.
- The same concept has different names in different layers.
- One change forces edits across unrelated parts of the system.
- A context depends on another context's internals instead of a contract.

## Review Questions

- Where is the invariant actually enforced?
- Who owns this data?
- What is the contract between contexts?
- What breaks if this module is split?
- What is already clean enough to keep?
- Which term in the code is doing too much work?
- What is the concrete failure if this boundary stays fuzzy?

## Typical Improvements

- Rename terms to match the business language.
- Pull invariants into a smaller aggregate.
- Add an anti-corruption layer around a messy dependency.
- Introduce domain events where direct coupling is too tight.
- Split a context only when the boundary is clear enough to own.
