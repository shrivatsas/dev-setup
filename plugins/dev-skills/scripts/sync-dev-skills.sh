#!/usr/bin/env bash
# Link skills from dev-setup into a repository or an agent skills directory.
#
# Links only, by design: a copy is what drifts. Each skill becomes a symlink into this
# checkout, so an edit here is live everywhere and there is nothing to re-sync.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERATE_MANIFEST="$SCRIPT_DIR/generate-sources-manifest.py"
SOURCE="${DEV_SETUP_SKILLS_SOURCE:-$(cd "$SCRIPT_DIR/../../.." && pwd)/skills}"
TARGET=""
DRY_RUN=0
PRUNE=0
FORCE=0

usage() {
  cat <<'USAGE'
Usage:
  sync-dev-skills.sh (--repo PATH | --target PATH) [options]

Options:
  --repo PATH        Link into PATH/skills.
  --target PATH      Link directly into PATH.
  --source PATH      Override the source skills directory.
  --prune            Remove links whose source skill no longer exists.
  --force            Replace a symlink that points somewhere else.
  --dry-run          Show what would change.
  -h, --help         Show this help.

Never overwrites a real directory: move its content into the source first, or you will
end up maintaining a copy.

Examples:
  sync-dev-skills.sh --repo .                 # wire a repository to dev-setup
  sync-dev-skills.sh --target ~/.claude/skills
  sync-dev-skills.sh --repo . --prune --dry-run
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)    [[ $# -ge 2 ]] || { echo "Missing value for --repo" >&2; exit 2; }
               TARGET="$2/skills"; shift 2 ;;
    --target)  [[ $# -ge 2 ]] || { echo "Missing value for --target" >&2; exit 2; }
               TARGET="$2"; shift 2 ;;
    --source)  [[ $# -ge 2 ]] || { echo "Missing value for --source" >&2; exit 2; }
               SOURCE="$2"; shift 2 ;;
    --prune)   PRUNE=1; shift ;;
    --force)   FORCE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)         echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
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
[[ "$SOURCE" == "$TARGET" ]] && exit 0

changes=0
conflicts=0

for src in "$SOURCE"/*/; do
  name="$(basename "$src")"
  [[ -f "$src/SKILL.md" ]] || continue
  dst="$TARGET/$name"
  want="${src%/}"

  if [[ -L "$dst" ]]; then
    [[ "$(readlink "$dst")" == "$want" ]] && continue
    if [[ "$FORCE" -eq 0 ]]; then
      echo "conflict $name (link -> $(readlink "$dst"); --force to replace)" >&2
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
    case "$target" in "$SOURCE"/*) ;; *) continue ;; esac
    [[ -e "$target" ]] && continue
    [[ "$DRY_RUN" -eq 1 ]] || rm -f "$dst"
    echo "prune    $(basename "$dst")"
    changes=$((changes + 1))
  done
fi

# macOS without Command Line Tools has no python3; the links above still stand without a
# manifest, so this is a note rather than a failure.
if [[ "$DRY_RUN" -eq 0 ]] && [[ -f "$GENERATE_MANIFEST" ]]; then
  if command -v python3 >/dev/null 2>&1; then
    python3 "$GENERATE_MANIFEST" --root "$SOURCE" --write
  else
    echo "note: python3 not found; SOURCES.yaml not regenerated" >&2
  fi
fi

echo
echo "source: $SOURCE"
echo "target: $TARGET"
echo "changes: $changes  conflicts: $conflicts"
[[ "$conflicts" -eq 0 ]] || exit 1
