---
name: test-signal-vs-waste
description: Use when judging test value — auditing an existing test suite for waste, deciding whether a new or AI-generated test is worth keeping, arguing against a suite that only measures coverage, or choosing which tests to keep when deleting or pruning
when_to_use: when reviewing tests, evaluating AI-generated tests, pruning or auditing a suite, or deciding whether a failing test justifies a fix
version: 1.1.0
---

# Test Signal vs. Waste

## Overview

Every test either produces **signal** — information that changes what someone does next — or **waste** — effort that does not. Most suites are a mix, and no number of green checkmarks tells you which kind you have.

**Core principle:** A test's value is what you learn when it fails, not what you feel when it passes.

A test produces signal if, when it fails, a person does something different: fixes a real regression, revises a wrong expectation, or stops trusting a broken assumption. A test is waste if a red result teaches nothing new, or if it goes green even when behavior is broken.

## When to Use

Use this skill in two situations:

- **Auditing an existing suite** — you suspect the suite is heavy and thin: slow, flaky, high coverage, low detection power.
- **Gatekeeping new tests** — including LLM-generated tests, which fail differently: they look plausible, cover lines, and often cannot fail on the bug they claim to guard against.

When NOT to use:
- You are choosing test cases for a *specification* (use `pict-test-designer` for combinatorial coverage).
- You are mid red-green-refactor on a known behavior (use `test-driven-development`; the rubric here explains why the red step matters, not the loop itself).
- The question is "should this test exist" versus "is this mock legitimate" — the latter is `testing-anti-patterns`, a single waste filter, not the full taxonomy.

## The Rubric

Before classifying anything, ask three questions about one test:

```
1. Can it ever fail on a real behavior regression?
   → name the exact production edit that should turn it red (return wrong value, drop a
     guard, reverse a condition). If you cannot name one, it guards nothing.
   → if the test asserts on a constant, list, or fixture, first trace where that value
     comes from: a production artifact (schema JSON, contract, committed seed) means the
     test guards that artifact; hand-written test data on both sides means it guards only
     the test. A wrong mental mutation is worse than none — it produces confident deletion.

2. Does it fail on implementation-only refactors?
   → rename an identifier, reorder internals, swap an internal data structure.
     If the test breaks, it is coupled to the implementation.

3. If it went red right now, would anyone act?
   → flaky, unreadable, or unowned failures train people to ignore red.
     A failure nobody acts on is indistinguishable from noise.
```

- Q1 is the minimum bar. No → waste, stop.
- Q1 yes, Q2 no → signal, but brittle signal.
- Q1 yes, Q2 yes, Q3 no → real signal rendered unusable.

## Signal Categories

| Category | What it tells you | Example |
|---|---|---|
| Regression-catch | A bug that shipped would have been caught here | Asserting `refund > 0` when a clipped-minus bug exists |
| Specification | Documents intended behavior in executable form | "expired sessions redirect to login with a flash" |
| Refactor-enabler | Lets you restructure internals without fear | Pure-function tests over the domain core |
| Stop-trusting | Tells you an assumption or integration broke | Contract test against a real wire format |
| Removal guard | Asserts a retired API, write path, or fallback is gone and stays gone; the mutation is re-adding it | `assert(M.cloneVersionForDraft === undefined)` — draft creation must keep going through governed source intake |

## Waste Categories

| Category | Detection heuristic |
|---|---|
| Tautological | Mentally delete the production logic the test names; the test still passes |
| Mock-mirroring | Asserts on a mock's call, return, or state instead of the unit's output; changing behavior changes nothing, changing mocks fails it |
| Redundant | Kills the same mutant as a neighbor test; keep the clearest one, delete the rest |
| Coverage-padding | Adds lines executed, no branch or behavior distinguished; a test that only runs code, never evaluates it |
| Flaky | Nondeterministic input, timing, or ordering; red sometimes, so red stops meaning anything |
| Zombie | Slow enough that people skip or background it; its failures arrive after the decision |
| Never-failing | Snapshot or echo test whose diff is waved through; nothing would ever make you act on its red |
| Sunk-cost | Exists because writing it took effort, not because it has ever told anyone anything |

### Classification traps

Three shapes look like waste and are not. Each trap below is a real deletion that a
mutation run later proved was signal (see `TESTING.md` in this directory for the mutations
and the verbatim rationalizations that produced them).

- **Absence is not automatically waste.** A test asserting that something is *gone* has
  one obvious mutation: put it back. Ask what wrong thing happens then. If re-adding the
  export, storage key, or fallback would take a wrong route, it is a removal guard — keep
  it. Only if re-adding changes nothing is it waste.
- **Two lists compared are not automatically tautology.** Trace the constant to its
  origin before calling it a data echo. A fixture derived from a production artifact is a
  regression test on that artifact; the mutation lives in the artifact, not the fixture.
- **"Implied by an existing test" is not a finding.** If you claim redundancy, name the
  test function and the mutant it already kills. Without a named line you have not
  checked; you have pattern-matched.

## Measurement: what to actually track

Ranked by information per unit of effort, cheapest first:

1. **Red-green correspondence** — deliberately break one behavior (swap a comparison, remove a guard) and see which tests go red. This is a manual spot-check mutation test. Tests that stay green have zero detection power regardless of coverage.
2. **Mutation score, not coverage** — coverage says the code ran under test; mutation score says the test suite can tell correct behavior from broken. If mutation testing is cheap to run locally on a module, prefer it; a module at 90% coverage with a 15% mutation score is a waste report, not a test suite.
3. **Real-failure history** — grep CI history: how many red runs did each test cause, and how many led to a fix? A test with years of uptime and zero catches is either a redundant guard (cheap, keep) or a tautology (delete after the rubric check).
4. **Flake rate** — retries per green run. Anything retried regularly is waste until proven otherwise.
5. **Time-to-diagnose** — when it fails, how long until someone knows what broke and why? Signal a human cannot read is signal lost.
6. **Maintenance cost** — how often does this test change with zero behavior change? High cost plus Q2 failure means coupled waste.

Never report coverage alone as evidence of suite health. Coverage is a floor for waste detection, not a measure of signal.

## Workflow A: Auditing an Existing Suite

1. **Sample, do not read everything.** Pick 10-15 tests across the suite, weighted toward the oldest, the newest, and the flakiest.
2. **Run the rubric on each sample.** Table of test → Q1/Q2/Q3 → category.
3. **One spot mutation per module.** For each important module, make one deliberate behavior-breaking edit, run the module's tests, note which fail, revert. This calibrates the whole suite cheaply.
4. **Pull the history.** Flake rates and real-failure counts from CI, not from memory.
5. **Cut in confidence order.** Delete the unambiguous categories first: tautological, never-failing, sunk-cost. Batch the debatable ones for a human decision. Redundant and zombie tests need judgment about how much defense-in-depth is wanted. Removal guards and data-constant tests do not go in the delete batch until you have traced their origin and named their mutant.
6. **Recheck.** After deletions, re-run one spot mutation. Detection power should hold; if it drops, you deleted signal and mislabeled waste.

Report results as counts per category and one mutation-check summary. Do not report "deleted N tests" without the mutation comparison.

## Workflow B: Gatekeeping New and LLM-Generated Tests

LLM-generated tests fail in characteristic ways: they mirror the implementation they were written alongside, assert on the happy path a summary describes, and pass for reasons disconnected from the behavior they name. Treat every generated test as waste until proven to have signal.

The gate, per test:

```
1. What behavior does this test claim to guard? (If the answer is a function name
   instead of a behavior, suspect tautology.)

2. Run the can-fail check: temporarily break the behavior it claims to guard
   (delete the fix, reverse the condition, return the wrong value).
   The test MUST go red. Revert.

3. Run the refactor check: make a trivial internal-only change.
   The test must stay green.

4. Read the failure mode: when it fails, does the message name the behavior
   or an internal call? Assert on the mock → waste (see testing-anti-patterns).

5. Redundancy: does an existing test already kill the same mutants?
   Generated tests often duplicate; keep one.
```

For a batch of generated tests, do steps 2-3 on a sample plus any test guarding critical behavior. Never accept "tests pass, all green" as evidence — green is the waste hypothesis's starting state, not its refutation.

When a generated test has good signal but terrible form (unreadable names, magic values, wrong home in the tree), fix the form and keep the signal. Signal is the expensive part to generate.

## When You Cannot Run the Check

Reading a test is not running the can-fail check. If you have no execution access — no
repo, no runner, no time — then:

- say which edits you would make and which test you would run, as an open question;
- mark the classification **unverified** and cap your confidence at "needs the check";
- never upgrade "I could not run it" to a confident delete, and never state an unverified
  claim about the code as fact ("break the vocabulary and it stays green") — that sentence
  is how a confident deletion gets made on a wrong mental mutation.

The rubric is a claim about a mutant. A mutant you did not run is a hypothesis, not a
result.

## Rationalizations and Their Counters

| Rationalization | Counter |
|---|---|
| "Its only red is that someone re-added a name." | Re-adding it is the mutation. Ask what the re-added path does wrong; if it bypasses a governed route, that red is the guard working. |
| "Both sides are test data." | Trace the constant. If the fixture is generated from a production artifact, the mutation is in that artifact. |
| "Implied by every other test in the file." | Name the test and the mutant. Otherwise you asserted a feeling. |
| "The module already proves the API is gone." | It proves it today. The test is what keeps it gone across future edits. |
| "Coverage is high and it all passes." | Green is the waste hypothesis's starting state, not its refutation. |
| "I could not run the suite, so detection power is inferred" — stated with high confidence anyway. | Then the classification is unverified. Confidence follows the evidence you have, not the argument you built. |

## Judgment Calls

- **Brittle-but-signal** (Q1 yes, Q2 no): do not delete; tighten by shifting assertions from internals to observable output. If unavoidable coupling is inherent (testing a serialization format byte-for-byte), that is signal — the brittleness is the test.
- **Redundant defense-in-depth**: two tests killing the same mutants at different layers (unit and end-to-end) are not redundant. Redundancy is same-fault, same-layer.
- **Slow but unique**: one expensive test that is the only thing catching an integration class of bug beats ten fast tautologies. Cost matters only in comparison, never alone.
- **Someone must own the delete.** Deleting tests feels like losing work. The rubric is the defense: if the can-fail check keeps the suite's behavior broken without any test noticing, the deleted tests were never holding anything.

## Related Skills

- `test-driven-development` — the red-green loop that makes step 1 of the rubric unpassable by construction
- `testing-anti-patterns` — the mock-behavior waste filter in depth
- `condition-based-waiting` — removes the flaky category's largest source
- `verification-before-completion` — runs before claiming a suite is healthy
