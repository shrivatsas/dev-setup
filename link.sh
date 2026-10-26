#!/usr/bin/env bash
# Wire this machine to dev-setup as the single source.
#
# Symlinks only. Skills and review prompts are edited in this checkout and are visible to
# every agent immediately; nothing is copied, so nothing can drift.
#
#   ./link.sh            link skills and prompts into every agent directory
#   ./link.sh --check    report drift only; exit 1 if anything is unwired
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS="$ROOT/skills"
PROMPTS="$ROOT/prompts"
SYNC="$ROOT/plugins/dev-skills/scripts/sync-dev-skills.sh"

CHECK=0
[[ "${1:-}" == "--check" ]] && CHECK=1

# Skill directories per agent:
#   ~/.agents/skills, ~/.claude/skills, ~/.codex/skills — pi, claude and codex all read more
#     than one of these, so keeping all three populated means no agent goes without skills
#   ~/.claude-accounts/*/skills — claude's skill root lives inside its config dir, so each
#     account needs its own links
SKILL_TARGETS=(
  "$HOME/.agents/skills"
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
)
for acct in "$HOME"/.claude-accounts/*/; do
  [[ -d "$acct" ]] && SKILL_TARGETS+=("${acct}skills")
done

# Agent prompt/command directories: agent|dir. Codex is unlisted until its custom prompt
# format is verified on this machine.
PROMPT_TARGETS=(
  "pi|$HOME/.pi/agent/prompts"
  "claude|$HOME/.claude/commands"
)

fail=0

link_skills() {
  for dir in "${SKILL_TARGETS[@]}"; do
    if [[ "$CHECK" -eq 1 ]]; then
      for src in "$SKILLS"/*/; do
        name="$(basename "$src")"
        [[ -f "$src/SKILL.md" ]] || continue
        dst="$dir/$name"
        if [[ -L "$dst" ]]; then
          [[ "$(readlink "$dst")" == "${src%/}" ]] && continue
          echo "drift    ${dir/#$HOME/\~}/$name -> $(readlink "$dst")"
          fail=1
        elif [[ -e "$dst" ]]; then
          echo "copy     ${dir/#$HOME/\~}/$name (real path, not a link)"
          fail=1
        else
          echo "missing  ${dir/#$HOME/\~}/$name"
          fail=1
        fi
      done
      if [[ -d "$dir" ]]; then
        # Only a link into dev-setup whose source vanished is an orphan; the agent's own
        # entries in its skills directory are not ours to judge.
        for entry in "$dir"/*; do
          [[ -L "$entry" ]] || continue
          target="$(readlink "$entry")"
          case "$target" in "$SKILLS"/*) ;; *) continue ;; esac
          [[ -e "$target" ]] && continue
          echo "orphan   ${entry/#$HOME/\~} (link to a removed skill)"
          fail=1
        done
      fi
    else
      echo "== ${dir/#$HOME/\~}"
      "$SYNC" --target "$dir" --prune --force >/dev/null
    fi
  done
}

link_prompts() {
  for entry in "${PROMPT_TARGETS[@]}"; do
    agent="${entry%%|*}"
    dir="${entry#*|}"
    if [[ "$CHECK" -eq 1 ]]; then
      if [[ ! -d "$dir" ]]; then
        echo "missing  ${dir/#$HOME/\~} (no prompt dir for $agent)"
        fail=1
        continue
      fi
      for src in "$PROMPTS"/*.md; do
        [[ -e "$src" ]] || continue
        name="$(basename "$src")"
        dst="$dir/$name"
        if [[ ! -e "$dst" ]]; then
          echo "missing  ${dir/#$HOME/\~}/$name"
          fail=1
        elif [[ ! -L "$dst" ]] || [[ "$(readlink "$dst")" != "$src" ]]; then
          echo "drift    ${dir/#$HOME/\~}/$name (not a link to dev-setup)"
          fail=1
        fi
      done
      for dst in "$dir"/*.md; do
        [[ -e "$dst" ]] || continue
        [[ -L "$dst" ]] && continue
        echo "copy     ${dir/#$HOME/\~}/$(basename "$dst") (real file, not a link)"
        fail=1
      done
    else
      mkdir -p "$dir"
      echo "== ${dir/#$HOME/\~} ($agent)"
      for src in "$PROMPTS"/*.md; do
        [[ -e "$src" ]] || continue
        ln -sfn "$src" "$dir/$(basename "$src")"
      done
    fi
  done
}

# Agent configuration adopted from this checkout: one source, same as skills and prompts.
agent_pairs() {
  printf '%s\t%s\n' \
    "agents/codex/config.toml"  "$HOME/.codex/config.toml" \
    "agents/pi/settings.json"   "$HOME/.pi/agent/settings.json" \
    "agents/pi/AGENTS.md"       "$HOME/.pi/agent/AGENTS.md" \
    "agents/herdr/config.toml"  "$HOME/.config/herdr/config.toml" \
    "agents/claude/settings.json" "$HOME/.claude/settings.json"
  local f acct
  for f in "$ROOT"/agents/pi/extensions/*; do
    [[ -e "$f" ]] || continue
    printf '%s\t%s\n' "agents/pi/extensions/$(basename "$f")" "$HOME/.pi/agent/extensions/$(basename "$f")"
  done
  for f in "$ROOT"/agents/claude/hooks/*; do
    [[ -e "$f" ]] || continue
    printf '%s\t%s\n' "agents/claude/hooks/$(basename "$f")" "$HOME/.claude/hooks/$(basename "$f")"
  done
  # claude reads its configuration from the active config dir, so each account needs the
  # same settings and hooks as ~/.claude.
  for acct in "$HOME"/.claude-accounts/*/; do
    [[ -d "$acct" ]] || continue
    printf '%s\t%s\n' "agents/claude/settings.json" "${acct}settings.json"
    for f in "$ROOT"/agents/claude/hooks/*; do
      [[ -e "$f" ]] || continue
      printf '%s\t%s\n' "agents/claude/hooks/$(basename "$f")" "${acct}hooks/$(basename "$f")"
    done
  done
}

link_agents() {
  local rel dst src
  while IFS=$'\t' read -r rel dst; do
    src="$ROOT/$rel"
    [[ -f "$src" ]] || continue

    if [[ "$CHECK" -eq 1 ]]; then
      if [[ ! -e "$dst" ]]; then
        echo "missing  ${dst/#$HOME/\~} (from $rel)"
        fail=1
      elif [[ ! -L "$dst" ]] || [[ "$(readlink "$dst")" != "$src" ]]; then
        echo "drift    ${dst/#$HOME/\~} (not a link to $rel)"
        fail=1
      fi
      continue
    fi

    mkdir -p "$(dirname "$dst")"
    if [[ -L "$dst" ]]; then
      [[ "$(readlink "$dst")" == "$src" ]] || { ln -sfn "$src" "$dst"; echo "relink   ${dst/#$HOME/\~}"; }
    elif [[ -e "$dst" ]]; then
      if cmp -s "$dst" "$src"; then
        rm -f "$dst"; ln -s "$src" "$dst"
        echo "link     ${dst/#$HOME/\~}"
      else
        cp -p "$dst" "$dst.bak-$(date +%Y%m%d-%H%M%S)"
        ln -sfn "$src" "$dst"
        echo "adopt    ${dst/#$HOME/\~} (kept a .bak copy)"
      fi
    else
      ln -s "$src" "$dst"
      echo "link     ${dst/#$HOME/\~}"
    fi
  done < <(agent_pairs)
}

markdown_commands_note() {  cat <<'NOTE'

Prompt templates are argument-free by design: pi substitutes $1/$@ and claude uses
$ARGUMENTS, so a shared file cannot rely on either. Each command names its target and
the skill it follows; the PR number comes from the invocation line.
NOTE
}

link_skills
link_prompts
link_agents

if [[ "$CHECK" -eq 1 ]]; then
  if [[ "$fail" -eq 0 ]]; then
    echo "ok: skills and prompts are linked to $ROOT"
  else
    echo "unwired: run ./link.sh" >&2
    exit 1
  fi
else
  markdown_commands_note
fi
