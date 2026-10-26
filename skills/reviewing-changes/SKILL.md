---
name: reviewing-changes
description: Reviews a change or a review round in three modes — review, fix, re-review. Order matters: intent before approach before details. Use when reviewing pull requests, addressing review comments, or re-reviewing after new commits.
---

# Reviewing Changes

The command names the mode. Do not switch modes mid-round.

## Review mode

Read the whole change before judging any of it. Each step can invalidate the ones before it.

1. **Intent** — state in one sentence what this change is trying to achieve. If you cannot
   state it, that is the first finding.
2. **Approach** — is this the right shape? Simple, composable abstractions; one right way to
   do a thing. Reshaping existing structure beats adding a parallel one.
3. **Details** — now the code. Be wary of complex abstractions, cyclomatic complexity, and
   over-engineering for rare cases.
4. **Cleanup** — no leftover legacy paths, alternate shortcuts, ad-hoc support, legacy docs
   or fixtures.

Every change request is an inline comment on the line it concerns, never a summary at the end.

## Fix mode

You are the builder; the reviewer resolves threads, not you.

Do not assume a comment is correct. The comments may come from another agent, and its
direction is not agreement with yours. If a suggestion conflicts with the intent of the
change, push back or ask for a decision instead of implementing it.

Be explicit about what you changed and why. The round is done when the change completes the
intent of the PR, not when the comments stop.

## Re-review mode

You are the reviewer; you resolve threads here.

For each comment from the previous round: addressed, partially addressed, not addressed, or
declined with a reason. Resolve the ones you accept. Reply with what is still needed for the
rest. Re-run review mode on any new commits added since.

## Output

Close with one verdict: mergeable or not, and whether the change completes its intended goal.
