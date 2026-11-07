# How this skill was tested

Campaign run 2026-01 on the `guideline-studio` suite (133 test files, JavaScript/PostgreSQL
clinical guideline review app) with 8 live model calls, model `deepseek/deepseek-v4.1-flash`,
no tools on the tested agents (`pi --print --no-tools`, isolated cwd, skill passed only via
appended system prompt). Method: `testing-skills-with-subagents` (RED / ground truth / GREEN /
REFACTOR).

## Ground truth first (the scoring key)

One behavior mutation per module, owning test run, then reverted:

| Mutation | Owning test | Result |
|---|---|---|
| Renamed a field in `schema/patient-fields.json` | `testPreoperativeFieldsAreInTheVocabulary` | **red** — real signal; the fixture derives from the production vocabulary |
| Re-exported the retired `cloneVersionForDraft` | `testCloneFromCommittedVersion` | **red** — real signal; re-adding bypasses governed source intake |
| Made the top bar always render Reset layout, asserted literal left byte-identical | `test_ui_shell.js` | **green** — false green for the behavior it names |
| `setGraphView('focused')` → `'focus'` (implementation-only rename) | `test_ui_shell.js` | **red** — brittle coupling, Q2 failure |

Without this table the baseline transcripts are unscoreable: two of the three deletions both
conditions recommended were signal.

## What leaked, and what closed it

| Leak (verbatim from a run) | Closed by |
|---|---|
| "Its only red is 'someone re-added a name' … Tombstone, not guard." — deleted a test the mutation run proves catches a governed-path bypass | Signal category **Removal guard**; absence trap in *Classification traps* |
| "Both sides are test data … Break the production vocabulary and it stays green." — a confident factual claim about a fixture it never traced, and wrong | Q1 now requires tracing a constant to its origin before classifying; data-echo trap; "unverified claim stated as fact" row in the counter table |
| "Implied by every other test in the file." | Redundancy now needs the test function name and the mutant it kills |
| "The module already proves the API is gone." | Counter row: it proves it today; the test keeps it gone |
| Deletions proposed with no mutation run, presented as findings | *When You Cannot Run the Check*: name the edits, mark unverified, cap confidence, never upgrade that to a confident delete |

## Delta per scenario

- **Keep-or-delete a source-string suite** (`test_ui_shell.js`, ~55 greps): baseline already
  reached the right boundary; the skill's contribution is rigor, not the boundary — separating
  Q1-no from Q2-no, keeping the absence guards with a named mutant each, and marking unrun
  deletions unverified.
- **Gate an AI-generated batch** (7 fabricated tests for `reviewer-model.js`): **no delta.**
  Both conditions deleted the same 6 and kept the same 1, and both cited the right reasons. A
  strong model does not need this skill for obvious tautologies; do not claim it does.
- **Delete to trim maintenance** (`test_reviewer_utils.js`, 9 tests): baseline deleted 2 real
  guards; the 1.0.0 skill did the same with better vocabulary and one false fact. After the
  1.1.0 patch the same prompt kept `testCloneFromCommittedVersion` as a removal guard, asked
  the tracing question instead of asserting, and found a genuine tautology in
  `testReusableModuleTaxonomy` (`every(phase === 'Treatment')` after filtering on that phase).

## Reproduce

The scenario prompts and subagent logs are campaign artifacts, not shipped fixtures: they
live in `.tmp/` during a run. Re-running means rebuilding the three prompts (keep-or-delete,
generated-batch gate, trim probe) and redoing the mutation table first.
