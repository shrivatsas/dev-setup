---
name: ship-it
description: Implement the next repo phase, verify it, then update plan.md and ship the commit after confirmation.
---

# Ship It

## Overview

Use this skill when the user wants the next repository phase implemented end-to-end in the current checkout, then reviewed, then committed and pushed on `main`.

## Workflow

1. Inspect current state.
   - Check `git status`, `plan.md`, and the relevant source/tests.
   - Identify the next phase from `plan.md` and stay within that phase unless the user changes scope.
2. Implement the phase.
   - Make the smallest set of code changes that satisfies the phase goal.
   - Add or update tests alongside the code.
3. Validate and report.
   - Run the most relevant lint/test commands.
   - Give the user exact commands to reproduce the validation locally.
   - If validation fails because of environment or dependency issues, state the blocker clearly.
4. Wait for confirmation.
   - Do not update `plan.md`, commit, or push until the user confirms the implementation and test plan are acceptable.
5. Finalize after confirmation.
   - Update `plan.md` with the new current state and completed phase.
   - Stage only the intended files.
   - Commit on `main` with a terse present-tense message.
   - Push to `origin/main`.
6. Report the ship result.
   - Include the commit hash, pushed branch, validation performed, and any residual risks.

## Guardrails

- Keep the phase scope tight unless the user explicitly expands it.
- Prefer concrete test commands over vague advice.
- Do not silently update `plan.md` before the user has had a chance to review the implementation.
- Commit only the intended files for the phase and keep the commit message terse.
