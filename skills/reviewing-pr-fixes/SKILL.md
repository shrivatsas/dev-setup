---
name: reviewing-pr-fixes
description: Fixes a round of pull-request review findings without re-ingesting the repository or repeatedly running expensive gates. Use when addressing review comments, or when a review round needs one coherent pass instead of a loop.
---

# Reviewing PR Fixes

Repository conventions come first: read the repository's `AGENTS.md` and any implementation
guide it names. This skill is the procedure around them.

## Establish the contract

1. Identify the PR, branch, and baseline commit before touching code. Work in that checkout.
2. Address only the unresolved findings in this round. The reviewer resolves threads; the
   builder leaves them open unless the repository says otherwise.
3. Do not assume a finding is correct. Reviewed comments may come from another agent, and its
   direction is not agreement. If a suggestion conflicts with the intent of the change, push
   back or ask for a decision instead of implementing it.

## Build a bounded finding set

1. Fetch the threads once, filtered to unresolved findings newer than the baseline.
2. Group findings by subsystem and shared root cause. Record each finding's file, cited hunk,
   required behavior, and regression test.
3. Inspect the cited hunks and their ownership path first. Search for exact names before
   behavior-level discovery; do not dump whole large files.
4. If a finding is stale, duplicate, or already fixed, verify that against the current diff and
   prepare a concise reply instead of changing code.

## Implement one coherent round

1. Read each target region immediately before patching it.
2. Fix a shared cause once rather than adding per-finding special cases.
3. Add behavioral regression coverage for observable failures. Source-string assertions fit
   static shell or contract checks only.
4. Batch related patches before running any expensive gate.
5. Preserve unrelated checkout changes and untracked files; keep them out of the diff and out of
   review prompts.

## Verify proportionately

1. Run syntax and directly owned tests while iterating.
2. Run each applicable completion gate once, after the round is coherent.
3. Diagnose a failure before retrying; never rerun an identical failed command without changing
   the condition or understanding a transient cause.
4. Keep a compact check ledger so repeated prompts can cite results without reprinting output,
   and trim long deterministic or CI output before it enters context.

## Gate independent review

Before an independent pass, require no unresolved merge conflicts, a clean `git diff --check`,
passing focused and completion tests, a diff of only intended files, and a self-review against
every acceptance criterion. Use independent review for subtle, cross-module, safety,
concurrency, persistence, or lifecycle risks — not as a loop after every edit. Batch all fixes
before one follow-up.

## Reply efficiently

One reply per finding:

```text
Fixed in <commit or current diff>: <behavioral change>.
Regression coverage: <focused test or case>.
```

Post replies in one batch. Report what changed, what was checked, any unavailable gate, and any
remaining decision that belongs to the reviewer.
