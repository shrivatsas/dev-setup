# Greenfield

Use this when the domain is still being shaped.

## Order

1. Name the business outcome and main actors.
2. List the core nouns and verbs in the domain language.
3. Collapse synonyms into one canonical term.
4. Split the domain into candidate bounded contexts.
5. Define what each context owns and what it only references.
6. Sketch aggregates around invariants and transaction boundaries.
7. Decide which interactions are sync, async, or internal.
8. Record any hard trade-off in an ADR.
9. Do not move forward until the current branch is resolved. In report mode, resolve a branch by stating a recommended decision and the assumption it rests on, instead of waiting for an answer.

## Questions To Ask

- What is the one thing this system must do well?
- Which terms mean different things to different people?
- What data has a single owner?
- What must never be inconsistent?
- Which boundaries would be expensive to change later?

## Useful Signals

- If one term has multiple meanings, stop and name the split.
- If a rule needs a transaction, it belongs in an aggregate boundary candidate.
- If two parts of the domain change for different reasons, separate the contexts.
- If the integration choice is surprising, write it down.
- If an answer is vague, sharpen it with a concrete scenario.
- If the codebase exists, cross-check the model against it before deciding.
