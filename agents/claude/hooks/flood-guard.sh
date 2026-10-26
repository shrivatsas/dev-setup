#!/usr/bin/env bash
# Claude Code PreToolUse hook (matcher: Bash). Global output-flood guardrail.
# Blocks known context-flooding command shapes with a capped alternative;
# blocking denies only this call (exit 2) — the agent retries capped, so the
# turn/token budget stays advisory. Any script error defaults to ALLOW.
#
# Installed in ~/.claude/settings.json:
#   "hooks": { "PreToolUse": [ { "matcher": "Bash",
#     "hooks": [ { "type": "command",
#       "command": "/home/user/.claude/hooks/flood-guard.sh" } ] } ] }
# Also symlinked into the Codex account (~/.codex-accounts/*/hooks/).

allow() { exit 0; }
deny() { printf '%s\n' "$1" >&2; exit 2; }

# Line-range dumps at or below this width are allowed; wider ranges are denied
# with the measured width. 60 lines is the working-agreement inspection bound.
#   60 lines is the working-agreement inspection bound. Keep this script's
#   rules and messages aligned with tools/agent_shell_policy.js in guideline
#   repos (this global copy cannot import the repo module).
MAX_RANGE_LINES=60
BOUND_ALT="Bound it: the native read tool with offset/limit, head -n 60 FILE, sed -n '1,60p' FILE, or (guideline repos) tools/page_evidence.sh — and batch independent inspections into one turn."

COMMAND="$(jq -r '.tool_input.command // empty' 2>/dev/null)" || allow
[ -z "$COMMAND" ] && allow

# 1. Unbounded ripgrep: no --max-count / -m flag.
if printf '%s' "$COMMAND" | grep -Eq '(^|[;&|(`" ]+)rg[[:space:]]'; then
  if ! printf '%s' "$COMMAND" | grep -Eq -- '--max-count|-m[0-9 ]'; then
    deny "Unbounded rg floods context. Re-run capped: rg --max-count 25 --max-columns 200 <args>"
  fi
fi

# 2. sed -n 'A,Bp' paging: allow <=60 lines, deny wider (and unbounded '$').
while IFS= read -r span; do
  a="${span%%,*}"; b="${span#*,}"; b="${b%p}"
  if [ "$b" = '$' ]; then
    deny "sed -n range ${a}-\$ is unbounded. ${BOUND_ALT}"
  fi
  width=$(( 10#$b - 10#$a + 1 ))
  [ "$width" -le "$MAX_RANGE_LINES" ] \
    || deny "sed -n range ${a}-${b} is ${width} lines. ${BOUND_ALT}"
done < <(printf '%s' "$COMMAND" \
  | grep -oE "sed[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*-n[[:space:]]*['\"]?[0-9$]+,[0-9$]+p" \
  | grep -oE '[0-9$]+,[0-9$]+p')

# 3. awk 'NR >= A && NR <= B' ranges: allow <=60 lines, deny wider. The old
#    guard never covered awk, so agents routed wide dumps around the sed rule.
while IFS= read -r range; do
  nums="$(printf '%s' "$range" | grep -oE '[0-9]+')"
  a="$(printf '%s' "$nums" | sed -n 1p)"
  b="$(printf '%s' "$nums" | sed -n 2p)"
  width=$(( 10#$b - 10#$a + 1 ))
  [ "$width" -le "$MAX_RANGE_LINES" ] \
    || deny "awk NR range ${a}-${b} is ${width} lines. ${BOUND_ALT}"
done < <(printf '%s' "$COMMAND" \
  | grep -oE 'NR[[:space:]]*>=[[:space:]]*[0-9]+[[:space:]]*&&[[:space:]]*NR[[:space:]]*<=[[:space:]]*[0-9]+')

# 4. cat of a large file (>50KB): inspect with bounds instead.
while IFS= read -r path; do
  case "$path" in -*) continue ;; esac
  if [ -f "$path" ]; then
    size="$(stat -c%s "$path" 2>/dev/null || echo 0)"
    if [ "$size" -gt 49152 ]; then
      deny "cat of large file ($path, ${size} bytes) floods context. ${BOUND_ALT}"
    fi
  fi
done < <(printf '%s' "$COMMAND" \
  | grep -oE '(^|[;&|(`" ]+)cat[[:space:]]+[^;&|`]+' \
  | sed 's/^.*cat[[:space:]]*//' | awk '{print $1}')

# 5. Follow-mode tail: never poll; run once in background and read the log.
#    (No tools/run_scoped_job.sh exists in these repos; name the real recipe.)
if printf '%s' "$COMMAND" | grep -Eq 'tail[[:space:]]+(-[a-zA-Z]*[fF]|--follow)'; then
  deny "tail -f polling loops burn a full context read per turn. Redirect the job to .tmp/logs/<job>-pr<PR>-<TIMESTAMP>.log, run it once, and read only its final lines."
fi

allow