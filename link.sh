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

# Agent skill directories. Codex keeps .system/ alongside user skills, so links are
# created per skill rather than replacing the directory.
SKILL_TARGETS=(
  "$HOME/.agents/skills"
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
)

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
        for shadow in "$dir"/*/; do
          name="$(basename "$shadow")"
          [[ "$name" == ".system" ]] && continue
          [[ -e "$SKILLS/$name" ]] && continue
          echo "orphan   ${dir/#$HOME/\~}/$name (no source skill)"
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

link_bin() {
  local dir="$HOME/.local/bin"
  if [[ "$CHECK" -eq 1 ]]; then
    for src in "$ROOT"/bin/*; do
      [[ -e "$src" ]] || continue
      name="$(basename "$src")"
      dst="$dir/$name"
      if [[ ! -e "$dst" ]]; then
        echo "missing  ${dst/#$HOME/\~}"
        fail=1
      elif [[ ! -L "$dst" ]] || [[ "$(readlink "$dst")" != "$src" ]]; then
        echo "drift    ${dst/#$HOME/\~} (not a link to dev-setup)"
        fail=1
      fi
    done
  else
    mkdir -p "$dir"
    echo "== ${dir/#$HOME/\~}"
    for src in "$ROOT"/bin/*; do
      [[ -e "$src" ]] || continue
      ln -sfn "$src" "$dir/$(basename "$src")"
    done
  fi
}

markdown_commands_note() {  cat <<'NOTE'

Prompt templates are argument-free by design: pi substitutes $1/$@ and claude uses
$ARGUMENTS, so a shared file cannot rely on either. Each command names its target and
the skill it follows; the PR number comes from the invocation line.
NOTE
}

link_skills
link_prompts
link_bin

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
