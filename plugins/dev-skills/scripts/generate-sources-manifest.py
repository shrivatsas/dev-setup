#!/usr/bin/env python3
"""Generate a versioned YAML manifest for a skills directory.

The manifest records, for each top-level skill folder, a monotonic version
number, a SHA-256 checksum over all tracked files, and a file count.

By default the script writes to <root>/SOURCES.yaml, but it can also print the
manifest to stdout or validate the on-disk manifest with --check.
"""

from __future__ import annotations

import argparse
import hashlib
import sys
from pathlib import Path
from typing import Dict, Iterable, List, Tuple


DEFAULT_ROOT = Path("/Users/shrivatsa/Documents/dev-setup/skills")
MANIFEST_NAME = "SOURCES.yaml"
TRACKED_EXCLUSIONS = {MANIFEST_NAME, "SOURCES.md"}


def load_previous_manifest(manifest_path: Path) -> Dict[str, Dict[str, object]]:
    """Parse the small YAML subset we emit and recover prior versions."""

    if not manifest_path.exists():
        return {}

    previous: Dict[str, Dict[str, object]] = {}
    current: Dict[str, object] | None = None

    for raw_line in manifest_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.rstrip()
        stripped = line.strip()

        if stripped.startswith("- name: "):
            if current and "name" in current:
                previous[str(current["name"])] = current
            current = {"name": stripped[len("- name: ") :].strip().strip('"')}
            continue

        if current is None:
            continue

        if stripped.startswith("path: "):
            current["path"] = stripped[len("path: ") :].strip().strip('"')
        elif stripped.startswith("version: "):
            current["version"] = int(stripped[len("version: ") :].strip())
        elif stripped.startswith("sha256: "):
            current["sha256"] = stripped[len("sha256: ") :].strip().strip('"')
        elif stripped.startswith("file_count: "):
            current["file_count"] = int(stripped[len("file_count: ") :].strip())

    if current and "name" in current:
        previous[str(current["name"])] = current

    return previous


def iter_skill_dirs(root: Path) -> Iterable[Path]:
    for child in sorted(root.iterdir(), key=lambda path: path.name):
        if not child.is_dir():
            continue
        if child.name.startswith("."):
            continue
        if (child / "SKILL.md").is_file():
            yield child


def iter_tracked_files(skill_dir: Path) -> List[Path]:
    tracked: List[Path] = []
    for path in skill_dir.rglob("*"):
        if not path.is_file():
            continue
        rel = path.relative_to(skill_dir)
        if any(part == ".git" for part in rel.parts):
            continue
        if any(part == "__pycache__" for part in rel.parts):
            continue
        if path.name in TRACKED_EXCLUSIONS:
            continue
        if path.name.endswith(".pyc"):
            continue
        tracked.append(path)
    return sorted(tracked, key=lambda path: str(path.relative_to(skill_dir)).replace("\\", "/"))


def hash_skill(skill_dir: Path) -> Tuple[str, int]:
    hasher = hashlib.sha256()
    tracked = iter_tracked_files(skill_dir)

    for path in tracked:
        rel = str(path.relative_to(skill_dir)).replace("\\", "/")
        hasher.update(rel.encode("utf-8"))
        hasher.update(b"\0")
        hasher.update(path.read_bytes())
        hasher.update(b"\0")

    return hasher.hexdigest(), len(tracked)


def build_records(root: Path) -> List[Dict[str, object]]:
    previous = load_previous_manifest(root / MANIFEST_NAME)
    records: List[Dict[str, object]] = []

    for skill_dir in iter_skill_dirs(root):
        sha256, file_count = hash_skill(skill_dir)
        prior = previous.get(skill_dir.name, {})
        version = int(prior.get("version", 0))
        if prior.get("sha256") != sha256:
            version += 1
        if version <= 0:
            version = 1

        records.append(
            {
                "name": skill_dir.name,
                "path": skill_dir.name,
                "version": version,
                "sha256": sha256,
                "file_count": file_count,
            }
        )

    return records


def records_by_name(records: List[Dict[str, object]]) -> Dict[str, Dict[str, object]]:
    return {str(record["name"]): record for record in records}


def render_manifest(root: Path, records: List[Dict[str, object]]) -> str:
    lines: List[str] = [
        "schema_version: 1",
        f'source_root: "{root}"',
        f'generator: "generate-sources-manifest.py"',
        "skills:",
    ]

    for record in records:
        lines.extend(
            [
                f"  - name: {record['name']}",
                f'    path: "{record["path"]}"',
                f"    version: {record['version']}",
                f'    sha256: "{record["sha256"]}"',
                f"    file_count: {record['file_count']}",
            ]
        )

    lines.append("")
    return "\n".join(lines)


def write_manifest(root: Path, content: str) -> Path:
    manifest_path = root / MANIFEST_NAME
    manifest_path.write_text(content, encoding="utf-8")
    return manifest_path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT, help="Skills root to scan.")
    parser.add_argument(
        "--write",
        action="store_true",
        help=f"Write the manifest to <root>/{MANIFEST_NAME} instead of printing it.",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Exit non-zero if the on-disk manifest differs from the generated manifest.",
    )
    parser.add_argument(
        "--compare",
        type=Path,
        help="Compare this root against another skills root and report drift.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = args.root.expanduser().resolve()
    if not root.is_dir():
        print(f"Skills root does not exist: {root}", file=sys.stderr)
        return 1

    records = build_records(root)
    manifest = render_manifest(root, records)

    if args.compare is not None:
        other_root = args.compare.expanduser().resolve()
        if not other_root.is_dir():
            print(f"Skills root does not exist: {other_root}", file=sys.stderr)
            return 1

        other_records = build_records(other_root)
        left = records_by_name(records)
        right = records_by_name(other_records)
        left_names = set(left)
        right_names = set(right)
        shared = sorted(left_names & right_names)
        only_left = sorted(left_names - right_names)
        only_right = sorted(right_names - left_names)
        checksum_mismatches: List[str] = []
        version_mismatches: List[str] = []

        for name in shared:
            if left[name]["sha256"] != right[name]["sha256"]:
                checksum_mismatches.append(name)
            if left[name]["version"] != right[name]["version"]:
                version_mismatches.append(name)

        if not only_left and not only_right and not checksum_mismatches and not version_mismatches:
            print(f"Skills match: {root} <-> {other_root}")
            return 0

        print(f"Drift detected: {root} <-> {other_root}", file=sys.stderr)
        if only_left:
            print(f"  only in {root}:", file=sys.stderr)
            for name in only_left:
                print(f"    - {name}", file=sys.stderr)
        if only_right:
            print(f"  only in {other_root}:", file=sys.stderr)
            for name in only_right:
                print(f"    - {name}", file=sys.stderr)
        if checksum_mismatches:
            print("  checksum mismatches:", file=sys.stderr)
            for name in checksum_mismatches:
                print(
                    f"    - {name}: {left[name]['sha256']} != {right[name]['sha256']}",
                    file=sys.stderr,
                )
        if version_mismatches:
            print("  version mismatches:", file=sys.stderr)
            for name in version_mismatches:
                print(
                    f"    - {name}: {left[name]['version']} != {right[name]['version']}",
                    file=sys.stderr,
                )
        return 1

    if args.check:
        existing = (root / MANIFEST_NAME).read_text(encoding="utf-8") if (root / MANIFEST_NAME).exists() else ""
        if existing != manifest:
            print(f"{MANIFEST_NAME} is out of date for {root}", file=sys.stderr)
            return 1
        print(f"{MANIFEST_NAME} is current for {root}")
        return 0

    if args.write:
        path = write_manifest(root, manifest)
        print(path)
        return 0

    sys.stdout.write(manifest)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
