# Agent output discipline (all projects)

Tool output is re-billed in every later turn, and each extra tool call re-bills the whole
conversation. Keep both the bytes and the turn count down.

- Inspect files with the harness's native, parameter-bounded tools (`read` with `offset`/`limit`,
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

<sub>harness: pi · model: &lt;model&gt; (&lt;effort&gt;) · session: &lt;id&gt; · tokens: &lt;in&gt;/&lt;out&gt;</sub>

- harness: `pi`.
- model + effort: the model and reasoning effort used for this session. Read `PI_MODEL` and
  `PI_REASONING_LEVEL`.
- session id: read `PI_SESSION_ID` (session file: `PI_SESSION_FILE`).
- token splits: run `pi-attribution` (on PATH at `~/.pi/agent/bin/`) immediately before
  posting and paste its output verbatim. It reads `PI_MODEL`, `PI_REASONING_LEVEL`,
  `PI_SESSION_ID` and sums the per-message `usage` blocks in `PI_SESSION_FILE`.
  Each tool call adds usage, so expect the posted totals to lag the true final
  counts slightly. Use `tokens: unknown` only if the script itself errors; never
  guess or fabricate counts. Keep it to one line:
  no per-call breakdown unless asked.
