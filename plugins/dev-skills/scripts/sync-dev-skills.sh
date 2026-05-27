#!/usr/bin/env bash
set -euo pipefail

SOURCE="${DEV_SETUP_SKILLS_SOURCE:-/Users/shrivatsa/Documents/dev-setup/skills}"
TARGET=""
DRY_RUN=0
DELETE=0
EXCLUDES=(".git/" "__pycache__/")

usage() {
  cat <<'USAGE'
Usage:
  sync-dev-skills.sh (--repo PATH | --target PATH) [options]

Options:
  --repo PATH        Copy into PATH/skills.
  --target PATH      Copy directly into PATH.
  --source PATH      Override source skills directory.
  --exclude PATTERN  Exclude a path pattern. Can be repeated.
                    Defaults already exclude .git/ and __pycache__/.
  --delete           Delete destination files that are absent from the source.
  --dry-run          Show what would be copied.
  -h, --help         Show this help.

Examples:
  sync-dev-skills.sh --repo .
  sync-dev-skills.sh --repo /path/to/project --dry-run
  sync-dev-skills.sh --target ~/.codex/skills
  DEV_SETUP_SKILLS_SOURCE=/tmp/skills sync-dev-skills.sh --repo .
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      [[ $# -ge 2 ]] || { echo "Missing value for --repo" >&2; exit 2; }
      TARGET="$2/skills"
      shift 2
      ;;
    --target)
      [[ $# -ge 2 ]] || { echo "Missing value for --target" >&2; exit 2; }
      TARGET="$2"
      shift 2
      ;;
    --source)
      [[ $# -ge 2 ]] || { echo "Missing value for --source" >&2; exit 2; }
      SOURCE="$2"
      shift 2
      ;;
    --exclude)
      [[ $# -ge 2 ]] || { echo "Missing value for --exclude" >&2; exit 2; }
      EXCLUDES+=("$2")
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --delete)
      DELETE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "Choose a destination with --repo PATH or --target PATH." >&2
  usage >&2
  exit 2
fi

if [[ ! -d "$SOURCE" ]]; then
  echo "Source skills directory does not exist: $SOURCE" >&2
  exit 1
fi

mkdir -p "$TARGET"

if command -v rsync >/dev/null 2>&1; then
  args=(-a)
  [[ "$DELETE" -eq 1 ]] && args+=(--delete)
  [[ "$DRY_RUN" -eq 1 ]] && args+=(--dry-run --itemize-changes)
  for pattern in "${EXCLUDES[@]}"; do
    args+=(--exclude "$pattern")
  done
  rsync "${args[@]}" "$SOURCE"/ "$TARGET"/
else
  if [[ "$DRY_RUN" -eq 1 ]]; then
    find "$SOURCE" -mindepth 1 -maxdepth 1 -print | sort
    exit 0
  fi
  for path in "$SOURCE"/* "$SOURCE"/.[!.]* "$SOURCE"/..?*; do
    [[ -e "$path" ]] || continue
    base="$(basename "$path")"
    skip=0
    for pattern in "${EXCLUDES[@]}"; do
      clean_pattern="${pattern%/}"
      [[ "$base" == $clean_pattern || "$base" == $pattern ]] && skip=1
    done
    [[ "$skip" -eq 1 ]] && continue
    if [[ "$DELETE" -eq 1 ]]; then
      rm -rf "$TARGET/$base"
    fi
    cp -a "$path" "$TARGET/"
  done
fi

echo "Synced dev-setup skills"
echo "  source: $SOURCE"
echo "  target: $TARGET"
