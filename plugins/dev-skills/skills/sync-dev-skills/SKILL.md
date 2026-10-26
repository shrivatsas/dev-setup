---
name: sync-dev-skills
description: Link the skills collection from a dev-setup checkout into the current repository, another repository, or an agent skills directory. Use when the user asks to install, wire, sync, or bring over their dev-setup skills.
---

# Link Dev Setup Skills

Use this skill when the user wants the skills from their `dev-setup` checkout available in
another workspace. The script links; it never copies, because a copy is what drifts.

## Source

The source defaults to `skills/` in the repository that contains the script, so no absolute
path is needed. Override with `DEV_SETUP_SKILLS_SOURCE` or `--source`.

## Workflow

1. Decide the destination.
   - Current repository: `--repo .` links into `./skills`.
   - Another repository: `--repo /path/to/repo` links into `/path/to/repo/skills`.
   - Explicit directory: `--target /path/to/skills`.
2. Preview first unless the user asked to wire it immediately:

```bash
plugins/dev-skills/scripts/sync-dev-skills.sh --repo . --dry-run
```

3. Link:

```bash
plugins/dev-skills/scripts/sync-dev-skills.sh --repo .
```

4. Verify every skill resolves:

```bash
find skills -mindepth 2 -maxdepth 2 -name SKILL.md | sort
```

5. `SOURCES.yaml` is regenerated at the source after each run, recording a version and
   checksum per skill.

## Notes

- Each skill becomes a symlink to the source directory; an edit in the source is live in every
  destination immediately.
- A real directory in the way is reported as a conflict and left untouched. Move its content
  into the source instead of maintaining a second copy.
- `--prune` removes links whose source skill no longer exists. `--force` replaces a link that
  points somewhere else.
- Codex, Claude and Pi all read more than one skills location; `link.sh` in the same repository
  is the command that wires a whole machine.
