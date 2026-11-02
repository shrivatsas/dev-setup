# Agent output discipline (all projects)

Tool output is re-billed in every later turn, and each extra tool call re-bills the whole
conversation. Keep both the bytes and the turn count down.

- Inspect files with the native, parameter-bounded tools (`read` with `offset`/`limit`,
  `grep`/`rg --max-count`, `find`, `ls`) rather than shell paging (`sed -n`, `awk`, `cat`) or
  `tail -f`. One bounded read beats four shell pages.
- Batch independent reads, searches, and commands into a single turn.
- When a command is denied as too large, use the bounded alternative the deny names; do not
  route around it or reconstruct the dump in pieces.
- Long jobs: redirect to a log file under `.tmp/logs/`, run once, and read only its final lines.
  Never poll a running process.

# GitHub attribution subtext (all projects)

Any text you add to GitHub on my behalf — PR description, PR or issue comment, review comment
or reply, PR review body — ends with one attribution line, wrapped in `<sub>` so it renders as
minor subtext. Write it only on text you add; never edit another author's existing GitHub text
to append it.

Format (single final line):

<sub>harness: codex · model: &lt;model&gt; (&lt;effort&gt;) · session: &lt;id&gt; · tokens: &lt;in&gt;/&lt;out&gt;</sub>

- harness: `codex`.
- model + effort: the model and reasoning effort used for this session.
- session id: this session's identifier.
- token splits: session input/output token totals from the session log/usage. If they are not
  available, write `tokens: unknown`; never guess or fabricate counts. Keep it to one line: no
  per-call breakdown unless asked.

Before each GitHub write, invoke the helper and append its output verbatim:

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/bin/agent-attribution"
```

It reads `CODEX_THREAD_ID` (or `--session <id>`) and the session log. It reports the latest
recorded model and reasoning effort, and cumulative session input/output totals as of invocation.
Never substitute configured defaults or manually type the metadata. If it cannot find model or
effort metadata, fix the lookup before posting; do not publish `model: unknown`. Missing usage
alone is rendered as `tokens: unknown`. It only prints attribution; it never posts to GitHub.
