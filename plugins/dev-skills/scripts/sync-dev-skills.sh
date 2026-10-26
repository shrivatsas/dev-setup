#!/usr/bin/env bash
# Distribute skills from dev-setup into a repository or an agent skills directory.
#
# Default mode is link: each skill becomes a symlink into this checkout, so an edit is
# visible to every agent immediately and copies cannot drift. Use --copy only when a
# destination must be self-contained (vendoring into a repo someone else checks out).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERATE_MANIFEST="$SCRIPT_DIR/generate-sources-manifest.py"
SOURCE="${DEV_SETUP_SKILLS_SOURCE:-$(cd "$SCRIPT_DIR/../../.." && pwd)/skills}"
TARGET=""
DRY_RUN=0
PRUNE=0
COPY=0
FORCE=0

usage() {
  cat <<'USAGE'
Usage:
  sync-dev-skills.sh (--repo PATH | --target PATH) [options]

Options:
  --repo PATH        Link into PATH/skills.
  --target PATH      Link directly into PATH.
  --source PATH      Override source skills directory.
  --copy             Copy instead of linking. For self-contained destinations only.
  --prune            Remove links whose source skill no longer exists.
  --force            Replace a symlink that points somewhere else.
  --dry-run          Show what would change.
  -h, --help         Show this help.

Never overwrites a real directory: move its content into the source first.

The SOURCES.yaml manifest is regenerated after every run: at the target in copy mode,
where a vendored copy must describe itself, and at the source in link mode, where the
links make per-target copies meaningless and provenance belongs to the one source.

Examples:
  sync-dev-skills.sh --repo .                 # wire a repository to dev-setup
  sync-dev-skills.sh --target ~/.claude/skills
  sync-dev-skills.sh --repo . --prune --dry-run
  sync-dev-skills.sh --target /srv/vendor --copy
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)     [[ $# -ge 2 ]] || { echo "Missing value for --repo" >&2; exit 2; }
                TARGET="$2/skills"; shift 2 ;;
    --target)   [[ $# -ge 2 ]] || { echo "Missing value for --target" >&2; exit 2; }
                TARGET="$2"; shift 2 ;;
    --source)   [[ $# -ge 2 ]] || { echo "Missing value for --source" >&2; exit 2; }
                SOURCE="$2"; shift 2 ;;
    --copy)     COPY=1; shift ;;
    --prune)    PRUNE=1; shift ;;
    --force)    FORCE=1; shift ;;
    --dry-run)  DRY_RUN=1; shift ;;
    -h|--help)  usage; exit 0 ;;
    *)          echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "Choose a destination with --repo PATH or --target PATH." >&2
  usage >&2
  exit 2
fi

[[ -d "$SOURCE" ]] || { echo "Source skills directory does not exist: $SOURCE" >&2; exit 1; }
SOURCE="$(cd "$SOURCE" && pwd)"
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

if [[ "$SOURCE" == "$TARGET" ]]; then
  exit 0
fi

changes=0
conflicts=0

if [[ "$COPY" -eq 1 ]]; then
  for src in "$SOURCE"/*/; do
    name="$(basename "$src")"
    [[ -f "$src/SKILL.md" ]] || continue
    if [[ -L "$TARGET/$name" ]]; then
      echo "conflict $name (symlink in copy mode; remove it first)" >&2
      conflicts=$((conflicts + 1))
      continue
    fi
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "copy     $name"
    else
      rsync -a --delete "$src" "$TARGET/$name"
      echo "copy     $name"
    fi
    changes=$((changes + 1))
  done
else
  for src in "$SOURCE"/*/; do
    name="$(basename "$src")"
    [[ -f "$src/SKILL.md" ]] || continue
    dst="$TARGET/$name"
    want="${src%/}"

    if [[ -L "$dst" ]]; then
      cur="$(readlink "$dst")"
      if [[ "$cur" == "$want" ]]; then
        continue
      fi
      if [[ "$FORCE" -eq 0 ]]; then
        echo "conflict $name (link -> $cur; --force to replace)" >&2
        conflicts=$((conflicts + 1))
        continue
      fi
      [[ "$DRY_RUN" -eq 1 ]] || ln -sfn "$want" "$dst"
      echo "relink   $name"
      changes=$((changes + 1))
      continue
    fi

    if [[ -e "$dst" ]]; then
      echo "conflict $name (real path at $dst; move it into $SOURCE first)" >&2
      conflicts=$((conflicts + 1))
      continue
    fi

    [[ "$DRY_RUN" -eq 1 ]] || ln -s "$want" "$dst"
    echo "link     $name"
    changes=$((changes + 1))
  done

  if [[ "$PRUNE" -eq 1 ]]; then
    shopt -s nullglob
    for dst in "$TARGET"/*; do
      [[ -L "$dst" ]] || continue
      target="$(readlink "$dst")"
      case "$target" in
        "$SOURCE"/*) ;;
        *) continue ;;
      esac
      [[ -e "$target" ]] && continue
      [[ "$DRY_RUN" -eq 1 ]] || rm -f "$dst"
      echo "prune    $(basename "$dst")"
      changes=$((changes + 1))
    done
  fi
fi

manifest_root="$SOURCE"
[[ "$COPY" -eq 1 ]] && manifest_root="$TARGET"

if [[ "$DRY_RUN" -eq 0 ]] && [[ -f "$GENERATE_MANIFEST" ]]; then
  python3 "$GENERATE_MANIFEST" --root "$manifest_root" --write
fi

echo
echo "source: $SOURCE"
echo "target: $TARGET"
echo "changes: $changes  conflicts: $conflicts"
[[ "$conflicts" -eq 0 ]] || exit 1
