#!/usr/bin/env python3
"""Refresh portable Codex defaults without serializing private local state."""

import argparse
import copy
import datetime
import json
from pathlib import Path
import re
import shutil
import tomllib


def set_scalars(block, values):
    for key, value in values.items():
        line = f"{key} = {json.dumps(value, ensure_ascii=False)}\n"
        pattern = rf"(?m)^[ \t]*{re.escape(key)}[ \t]*=.*(?:\n|$)"
        if re.search(pattern, block):
            block = re.sub(pattern, lambda match: line, block, count=1)
        else:
            block = block.rstrip() + "\n" + line
    return block


def merge(text, defaults):
    before = tomllib.loads(text)
    expected = copy.deepcopy(before)
    scalars = {key: value for key, value in defaults.items() if key != "features"}
    expected.update(scalars)
    expected.setdefault("features", {}).update(defaults["features"])

    first_table = re.search(r"(?m)^[ \t]*\[", text)
    end = first_table.start() if first_table else len(text)
    updated = set_scalars(text[:end], scalars) + text[end:]
    header = re.search(r"(?m)^[ \t]*\[features\][ \t]*(?:#.*)?$", updated)
    if header:
        start = header.end()
        next_table = re.search(r"(?m)^[ \t]*\[", updated[start:])
        end = start + next_table.start() if next_table else len(updated)
        updated = updated[:start] + set_scalars(updated[start:end], defaults["features"]) + updated[end:]
    else:
        updated = updated.rstrip() + "\n\n[features]\n" + set_scalars("", defaults["features"]).lstrip()

    # Stop before writing if an unfamiliar TOML representation changes other settings.
    if tomllib.loads(updated) != expected:
        raise ValueError("Cannot preserve local settings; config was not written")
    return before, expected, updated


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("source", type=Path)
    parser.add_argument("directories", nargs="+", type=Path)
    args = parser.parse_args()
    defaults = tomllib.loads(args.source.read_text())
    if set(defaults) != {"model", "model_reasoning_effort", "approval_policy", "approvals_reviewer", "features"} or defaults["features"] != {"hooks": True}:
        parser.error("Shared defaults must contain only the approved portable settings")

    failed = False
    for directory in args.directories:
        if not directory.is_dir() and directory != args.directories[0]:
            continue  # No account directories matched the shell glob.
        config = directory / "config.toml"
        if config.is_symlink():
            raise ValueError(f"Expected a writable local file, not a symlink: {config}")
        text = config.read_text() if config.exists() else ""
        before, expected, updated = merge(text, defaults)
        old_profile = directory / "shared.config.toml"
        stale_profile = old_profile.is_symlink() and old_profile.resolve() == args.source.parent / "shared.config.toml"
        if args.check:
            if before != expected or stale_profile:
                print(f"drift    {config} (run ./link.sh --codex-only)")
                failed = True
            continue
        if before != expected:
            directory.mkdir(parents=True, exist_ok=True)
            if config.exists():
                stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
                shutil.copy2(config, config.with_name(f"config.toml.bak-{stamp}"))
            else:
                config.touch(mode=0o600)
            config.write_text(updated)
            print(f"sync     {config}")
        if stale_profile:
            old_profile.unlink()
            print(f"remove   {old_profile} (profile selection no longer needed)")
    return int(failed)


if __name__ == "__main__":
    raise SystemExit(main())
