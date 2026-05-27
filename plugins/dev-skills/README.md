# Dev Setup Skills Plugin

This plugin exposes a `sync-dev-skills` skill and script for copying the skills collection from this repository into another repository or skills directory.

## Quick Setup

From the `dev-setup` repository:

```bash
plugins/dev-skills/scripts/setup-plugin.sh
```

This registers the plugin in `~/.agents/plugins/marketplace.json` with a local source path pointing back to this checkout.

## Usage

Preview copying skills into the current repository:

```bash
plugins/dev-skills/scripts/sync-dev-skills.sh --repo . --dry-run
```

Copy skills into the current repository:

```bash
plugins/dev-skills/scripts/sync-dev-skills.sh --repo .
```

Copy skills into Codex home skills:

```bash
plugins/dev-skills/scripts/sync-dev-skills.sh --target ~/.codex/skills
```
