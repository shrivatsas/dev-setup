---
name: test-signal-vs-waste
description: Use when judging test value — auditing an existing test suite for waste, deciding whether a new or AI-generated test is worth keeping, arguing against a suite that only measures coverage, or choosing which tests to keep when deleting or pruning
when_to_use: when reviewing tests, evaluating AI-generated tests, pruning or auditing a suite, or deciding whether a failing test justifies a fix
version: 1.0.0
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
   → mentally mutate the behavior (return wrong value, drop a check, reverse a condition).
     If the test still passes, it guards nothing.

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
5. **Cut in confidence order.** Delete the unambiguous categories first: tautological, never-failing, sunk-cost. Batch the debatable ones for a human decision. Redundant and zombie tests need judgment about how much defense-in-depth is wanted.
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
