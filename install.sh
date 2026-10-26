#!/usr/bin/env bash
# Prepare a machine that already has this checkout.
#
#   ./install.sh            report what is present and what a human still has to do
#   ./install.sh --install  also install what can be installed unattended
#
# Everything a human must do is printed, never faked: logins, account creation, the SSH
# machine target, and anything whose install command is not verifiable from this machine.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DO_INSTALL=0
[[ "${1:-}" == "--install" ]] && DO_INSTALL=1

tools=(
  "herdr|the terminal workspace manager everything runs inside"
  "pi|review panes"
  "claude|planning and implementation"
  "codex|implementation"
  "gh|pull requests and review comments"
  "mise|language runtimes, including the node codex installs under"
  "aws|bedrock access for extraction work"
)

echo "== tools"
missing=()
for entry in "${tools[@]}"; do
  name="${entry%%|*}"
  why="${entry#*|}"
  if command -v "$name" >/dev/null 2>&1; then
    printf '  %-8s %-10s %s\n' "$name" "ok" "$($name --version 2>/dev/null | head -1 | cut -c1-40)"
  else
    printf '  %-8s %-10s %s\n' "$name" "MISSING" "$why"
    missing+=("$name")
  fi
done

if [[ "$DO_INSTALL" -eq 1 ]]; then
  echo
  echo "== installing what this script can install unattended"
  if printf '%s\n' "${missing[@]:-}" | grep -qx codex; then
    echo "  npm install -g @openai/codex"
    npm install -g @openai/codex
  fi
  if command -v herdr >/dev/null 2>&1; then
    if herdr plugin list 2>/dev/null | grep -q 'shrivatsa.model-capacity'; then
      echo "  herdr plugin: model-capacity already installed"
    else
      echo "  herdr plugin install shrivatsas/herdr-model-capacity"
      herdr plugin install shrivatsas/herdr-model-capacity -y || echo "  (skipped: failed)"
    fi
  fi
fi

echo
echo "== seeding agent-written config (copied, never linked)"
# pi and codex rewrite these files themselves, so a link would push the agent's own state
# into this repository.
seed() {
  local src="$ROOT/$1" dst="$2"
  [[ -f "$src" ]] || return 0
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" ]]; then
    printf '  %-34s %s\n' "${dst/#$HOME/~}" "exists, left alone"
  else
    cp "$src" "$dst"
    printf '  %-34s %s\n' "${dst/#$HOME/~}" "seeded"
  fi
}
seed agents/codex/config.toml "$HOME/.codex/config.toml"
seed agents/pi/settings.json  "$HOME/.pi/agent/settings.json"

echo
echo "== wiring this checkout into the machine"
"$ROOT/link.sh"

echo
echo "== still yours to do"
cat <<'STEPS'
  Logins, per account. None of this is in the repository, on purpose:
    claude   CLAUDE_CONFIG_DIR=~/.claude-accounts/<account>/ claude 
    codex    codex login                                                # per codex account
    github   gh auth login
    aws      aws login --profile default
             aws sts get-caller-identity --profile bedrock-<profile>

  Machines and plugins for herdr:
    herdr machine add <ssh-target>          # the other box, e.g. macbook
    herdr server reload-config              # after agents/herdr/config.toml changes

  Tools with no unattended install from here:
    herdr    https://herdr.dev — then `herdr update` on later upgrades
    pi       its managed installer; `pi update self` afterwards
    claude   its installer; `claude --version` to confirm

  Restart your agents once wiring is done: skills, prompt templates and settings are read
  at startup, so a running session keeps the old set.
STEPS

echo "== verify"
"$ROOT/link.sh" --check && echo "  wiring ok" || echo "  wiring incomplete (see above)"
