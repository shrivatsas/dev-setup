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
- Podman Desktop

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

## Customization

The scripts contain many commented-out sections for optional tools. Uncomment what you need:
- Cloud CLIs (AWS, Azure, Terraform)
- Formal methods tools (TLA+, Alloy)
- Additional languages (Elixir, Haskell, Rust, Scala)
- VirtualBox/Vagrant for VMs

## License

MIT License - See [LICENSE](LICENSE) for details.
