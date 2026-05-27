---
name: sync-dev-skills
description: Copy the skills collection from /Users/shrivatsa/Documents/dev-setup/skills into the current repository, another repository, or an explicit skills directory. Use when the user asks to copy, sync, install, update, or bring over their dev-setup skills.
---

# Sync Dev Setup Skills

Use this skill when the user wants the skills from the `dev-setup` repository copied into another workspace.

## Source

Default source:

```text
/Users/shrivatsa/Documents/dev-setup/skills
```

Override with `DEV_SETUP_SKILLS_SOURCE` or `--source` when needed.

## Workflow

1. Decide the destination.
   - Current repository: use `--repo .`, which writes to `./skills`.
   - Another repository: use `--repo /path/to/repo`, which writes to `/path/to/repo/skills`.
   - Explicit skills directory: use `--target /path/to/skills`.
   - Codex home skills: use `--target ~/.codex/skills`.
2. Preview first unless the user explicitly asked to copy immediately:

```bash
plugins/dev-skills/scripts/sync-dev-skills.sh --repo . --dry-run
```

3. Run the copy:

```bash
plugins/dev-skills/scripts/sync-dev-skills.sh --repo .
```

4. Verify:

```bash
find skills -mindepth 2 -maxdepth 2 -name SKILL.md | sort
```

## Notes

- The script copies complete skill directories, including linked files, scripts, assets, references, and `SOURCES.md`.
- Existing destination files with the same path are overwritten.
- Use `--delete` only when the user explicitly wants destination files removed if they are absent from the source.
- The script excludes `.git/` and `__pycache__/` by default.
- Use `--exclude SOURCES.md` if the destination should receive only skill directories.
- The script refuses to run if the source directory does not exist.
