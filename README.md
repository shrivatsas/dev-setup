# DevSetup

Personal development environment setup scripts for macOS (Apple Silicon) and Ubuntu.

## Overview

This repository contains automated setup scripts and configuration files to quickly bootstrap a development environment with common tools, languages, and applications.

## Files

| File | Description |
|------|-------------|
| `mac.m1.sh` | Setup script for macOS on Apple Silicon (M1/M2/M3) |
| `ubuntu.sh` | Setup script for Ubuntu/Linux |
| `setup-mcps.sh` | Bootstrap script that renders `mcp/registry.yaml` into Codex config |
| `vscode-extensions.txt` | VS Code extensions to install |
| `conda-packages.txt` | Python packages for data science workflows |
| `mcp/registry.yaml` | Canonical MCP server list rendered into Codex config |
| `fishshell` | Fish shell installation notes |

## What Gets Installed

### Terminal & Shell
- iTerm2, tmux, Alfred
- Zsh with Oh My Zsh (agnoster theme)
- zsh-autosuggestions, zoxide, fzf

### Development Tools
- Git with common aliases
- VS Code with extensions
- DBeaver (database client)
- Docker CLI and Docker Compose plugin, powered by Colima (no Docker Desktop)

### Languages & Runtimes
- mise (runtime version manager)
- Go, Python, uv
- Node.js (via nvm on Ubuntu)

### Kubernetes & Cloud
- kubectl, kubectx, helm, OpenLens
- AWS CLI, Azure CLI, Terraform (commented out)

### Applications
- Browsers: Firefox Developer Edition
- Communication: Slack, Discord, Zoom
- Productivity: Logseq, Dropbox, Spotify
- AI Tools: Claude, ChatGPT, Claude Code, Codex, Gemini CLI

## Usage

### macOS (Apple Silicon)

```bash
# Review the script first, then run:
chmod +x mac.m1.sh
./mac.m1.sh
```

### Ubuntu

```bash
chmod +x ubuntu.sh
./ubuntu.sh
```

### Containers

Both setup scripts install Docker CLI, Docker Compose, and Colima instead of
Docker Desktop. On macOS, Colima is configured with a VZ VM, virtiofs mounts,
2 CPUs, and 4 GiB memory. On Linux, Colima uses its QEMU-based defaults with
2 CPUs and 4 GiB memory. The scripts also configure Docker to discover the
Homebrew-installed Compose plugin.

After setup, verify the runtime with:

```bash
colima status
docker compose version
docker run --rm hello-world
```

### VS Code Extensions

Install extensions separately:
```bash
xargs -n 1 code --install-extension < vscode-extensions.txt
```

### Dev Setup Skills Plugin

Register the local plugin that lets Codex copy this repo's `skills/` collection into another repository or skills directory:

```bash
./setup-skills-plugin.sh
```

Preview or run a copy into the current repository:

```bash
plugins/dev-skills/scripts/sync-dev-skills.sh --repo . --dry-run
plugins/dev-skills/scripts/sync-dev-skills.sh --repo .
```

### MCP Setup

MCP stands for Model Context Protocol. It is a standard way for an assistant to connect to external tools and data sources through a structured server interface.

Render the enabled MCP list from this repo into Codex's local config:

```bash
./setup-mcps.sh --dry-run
./setup-mcps.sh
```

## Skills, prompts, and review dispatch

`skills/` and `prompts/` are the only copies. `./link.sh` symlinks them into every agent that
needs them, so an edit here is live everywhere and nothing can drift:

| Linked into | What |
| --- | --- |
| `~/.agents/skills`, `~/.claude/skills`, `~/.codex/skills` | one link per skill |
| `~/.claude-accounts/*/skills` | claude's skill root lives inside its config dir |
| `~/.pi/agent/prompts`, `~/.claude/commands` | one link per prompt, as a slash command |

`./link.sh --check` reports anything unwired, copied, or pointing elsewhere.

`plugins/dev-skills/scripts/sync-dev-skills.sh` links only — a copy is what drifts. The
`SOURCES.yaml` manifest records a monotonic version and checksum per skill and is regenerated
on every run. It refuses to replace a real directory: move that content into `skills/` instead
of maintaining a second copy.

Prompts are slash commands in pi and claude. Codex has no prompt directory, so send the
prompt text to a codex pane instead: `herdr agent prompt <pane> "$(cat prompts/review.md)"`.

Which model to use, and the commands to launch it, are in [models.md](models.md).

## A new machine

```bash
git clone git@github.com:shrivatsas/dev-setup.git && cd dev-setup
./install.sh              # check tools, wire this checkout, list what a human must do
./install.sh --install    # additionally install codex and the herdr plugin
```

`install.sh` links and adopts; it never invents an install command or a login. Credentials are
not in this repository: claude and codex accounts, `gh auth login`, and the AWS profiles are
per machine and per account.

Agent configuration is adopted the same way as skills, so one file serves every machine:

| source | linked to |
| --- | --- |
| `agents/claude/settings.json`, `agents/claude/hooks/*` | `~/.claude/` and every `~/.claude-accounts/*/` |
| `agents/pi/AGENTS.md`, `agents/pi/extensions/*`, `agents/pi/bin/*` | `~/.pi/agent/` |
| `agents/herdr/config.toml` | `~/.config/herdr/config.toml` (then `herdr server reload-config`) |
| `agents/codex/rules/services.rules` | `~/.codex/rules/services.rules` and every `~/.codex-accounts/*/rules/services.rules` |

Two files are **seeded, never linked**: `agents/codex/config.toml` and `agents/pi/settings.json`.
Pi and Codex rewrite those themselves — device ids, changelog markers, plugin and marketplace
state — so a link would push the agent's own state into this repository. `install.sh` copies
them only when the destination is missing. For Codex, `link.sh` then refreshes only the
portable settings from `agents/codex/config.toml` in the base and every existing account.

The shared defaults include `approval_policy = "on-request"` and
`approvals_reviewer = "auto_review"`. Start plain `codex`; no profile flag is required.
The shared model default is GPT-6 Astra at medium effort; explicit CLI model options
take precedence. Project trust, hook trust, credentials,
local MCP endpoints, and Desktop runtime/plugin registrations remain in each local config.
Do not copy those values into the shared defaults. Updating existing preferences saves a
local `.bak-` copy first. The sync verifies that every other parsed setting is preserved.
Rerun `link.sh` after editing the shared defaults. Python 3.11 or newer is required.
The former `shared.config.toml` links into this repository are removed during migration;
remove `--profile shared` from any launcher where you previously added it.

To wire only Codex without changing the other agents:

```bash
./link.sh --codex-only
./link.sh --codex-only --check
```

The shared command rules allow routine `gh pr`, `gh issue`, `gh run`, and `linear issue`
read commands outside the sandbox without prompting. Writes and arbitrary API/GraphQL calls
retain normal approval handling. Rules load at startup even without selecting the profile.
A managed session policy that rejects sandbox escalation must be changed at its source;
the shared defaults cannot override enforced policy. Restart Codex after wiring.

When a real file is in the way and differs, `link.sh` saves a `.bak-` copy before linking, so
the first run on an existing machine is reversible.

## Customization

The scripts contain many commented-out sections for optional tools. Uncomment what you need:
- Cloud CLIs (AWS, Azure, Terraform)
- Formal methods tools (TLA+, Alloy)
- Additional languages (Elixir, Haskell, Rust, Scala)
- VirtualBox/Vagrant for VMs

## License

MIT License - See [LICENSE](LICENSE) for details.
