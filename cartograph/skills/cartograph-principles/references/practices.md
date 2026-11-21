# Practices — how we work (mostly from The Pragmatic Programmer)

Principles describe the system; these describe the work. Each names the companion skill to delegate to when it is installed, and the inline fallback when it isn't.

## Tracer bullet vs prototype — always say which you're building
- **Tracer bullet:** a thin, production-quality path end to end that you keep and grow. Use it to *verify* a charted one-way door in real code. Companions: `to-tickets` (tracer-bullet tickets), `tdd`.
- **Prototype:** throwaway code that answers one question, then gets deleted. Use it to *buy information* when a conflict is really uncertainty. Companion: `prototype`.
- **Fallback:** write the smallest thing that answers the question and label it in the expedition log as TRACER or PROTOTYPE. A prototype that survives into production needs a decision record first.

## Don't outrun your headlights
Plan and decide only as far ahead as your feedback lets you see. In map terms: clear fog along the path, leave the rest. Companions: `tdd`, `writing-plans`.

## Don't program (or decide) by coincidence
If you can't explain why it works, it doesn't count as working. A cell is not *verified* because a demo ran once; it is verified when the evidence actually tests the decision. Companion: `verification-before-completion`.

## Requirements are discovered, not gathered
Nobody knows exactly what they want up front. Grill, one question at a time, until each branch of the design tree is resolved. Put new terms into GLOSSARY.md as they appear. Companions: `grilling`, `grill-me`, `grill-with-docs`, `domain-modeling`, `brainstorming`.

## Estimate, then re-estimate from the code
Estimates are ranges that narrow as cells are charted. Record the range per area in AREA.md and revise it after each expedition.

## Fix broken windows
When an expedition finds decay in a charted cell (a stale decision, a contradicted assumption), mark it `contested` straight away rather than leaving it.

## Rubber duck before you escalate
Explain the problem in writing, step by step, before asking the human. Often the explanation solves it. Companions: `diagnosing-bugs`, `systematic-debugging` for runtime problems.

## Hand off warm
Every session ends with an expedition log good enough for a fresh agent to continue. Companion: `handoff`.
