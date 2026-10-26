# Models

Handpicked. Nothing derives these: no catalog lookup, no availability probe, no fallback.
If an id stops working, the harness refuses to start and says so — that is the check.

| tier | model | harness | notes |
| --- | --- | --- | --- |
| planning, architecture | `claude-opus-5-5` | claude | effort `high` — claude has no effort arg, set it in the session |
| implementation | `claude-opus-5-5`, `claude-sonnet-5-5` | claude | |
| implementation | `gpt-6-astra` | codex | effort `medium`; levels `low…ultra` |
| review, code | `deepseek/deepseek-v4.1-flash` | pi | via commandcode |
| review, design | `google/gemini-4-argon` | pi | |
| review, design | `meta/muse-spark-1.3` | pi | also `meta/muse-spark-1.3-contributor` |

Ids verified against the harnesses' own listings where that is possible:

- **codex** — slug in `~/.codex/models_cache.json`. This is the account's model list, so a miss is meaningful.
- **pi** — present in `~/.pi/agent/commandcode-models.json` or `models-store.json`. These are provider catalogs, so a hit means listed, not entitled.
- **claude** — no local list exists. Aliases (`opus`, `sonnet`) or full names resolve at launch; a wrong id fails there.

## Launching

A pane's model is fixed when the agent starts, so pick the model when you start it:

```bash
herdr agent start review --kind pi     --pane wN:p4Y -- --model deepseek/deepseek-v4.1-flash
herdr agent start design --kind claude --pane wN:p4Y -- --model claude-opus-5-5
herdr agent start impl   --kind codex  --pane wN:p4Y -- -m gpt-6-astra -c model_reasoning_effort=medium
```

The pane must be at a shell prompt. Accounts are environment variables, not flags — an
<project> pane has to be launched with its own config dir:

```bash
CLAUDE_CONFIG_DIR=~/.claude-accounts/<account-scoped> herdr
```

claude reads its skills from inside that config dir, so `link.sh` links each account's
`skills/` too. The default `~/.claude` profile has an expired OAuth session — run claude with
an account config dir or it fails before loading anything.

## Running a review

Review text lives in `prompts/`. Reviews run on pi, never in the pane that wrote the change.

```bash
herdr agent prompt wN:p4Y "$(cat ~/Documents/dev-setup/prompts/review.md)" --wait --until idle
herdr agent read wN:p4Y
```

`prompts/review.md` reviews an implementation; add `--kind`-style intent by hand when the
subject is a plan or an architecture, and use `prompts/rereview.md` for a round after new
commits. Append "Report the findings in this pane. Do not post anything to the forge." when
you do not want review comments written to GitHub.
