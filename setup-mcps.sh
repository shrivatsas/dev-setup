#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY="${ROOT}/mcp/registry.yaml"
CONFIG="${DEV_SETUP_CODEX_CONFIG:-$HOME/.codex/config.toml}"
MODE="apply"

usage() {
  cat <<'EOF'
Usage: ./setup-mcps.sh [--dry-run] [--config PATH]

Render enabled MCP servers from mcp/registry.yaml into Codex config.toml.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      MODE="dry-run"
      shift
      ;;
    --config)
      CONFIG="${2:?missing config path}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ ! -f "$REGISTRY" ]]; then
  echo "Missing registry: $REGISTRY" >&2
  exit 1
fi

python3 - "$REGISTRY" "$CONFIG" "$MODE" <<'PY'
from __future__ import annotations

import os
import re
import sys
from pathlib import Path


def load_registry(path: Path) -> list[dict]:
    lines = path.read_text().splitlines()
    servers: list[dict] = []
    i = 0

    def skip_noise(idx: int) -> int:
        while idx < len(lines):
            stripped = lines[idx].strip()
            if stripped and not stripped.startswith("#"):
                return idx
            idx += 1
        return idx

    i = skip_noise(i)
    if i >= len(lines) or lines[i].strip() != "mcp_servers:":
        raise SystemExit("registry must start with mcp_servers:")
    i += 1

    while True:
        i = skip_noise(i)
        if i >= len(lines):
            break

        line = lines[i]
        if not line.startswith("  - "):
            raise SystemExit(f"unexpected line in registry: {line}")

        server: dict = {}
        item = line[4:].strip()
        if item:
            key, value = item.split(":", 1)
            server[key.strip()] = parse_scalar(value.strip())
        i += 1

        while i < len(lines):
            raw = lines[i]
            stripped = raw.strip()
            if not stripped or stripped.startswith("#"):
                i += 1
                continue
            if raw.startswith("  - "):
                break
            if not raw.startswith("    "):
                raise SystemExit(f"unexpected indentation in registry: {raw}")

            key, sep, value = stripped.partition(":")
            if sep != ":":
                raise SystemExit(f"expected key/value pair in registry: {raw}")

            if value.strip():
                server[key] = parse_scalar(value.strip())
                i += 1
                continue

            i += 1
            if key == "args":
                values = []
                while i < len(lines):
                    inner = lines[i]
                    inner_stripped = inner.strip()
                    if not inner_stripped or inner_stripped.startswith("#"):
                        i += 1
                        continue
                    if inner.startswith("      - "):
                        values.append(parse_scalar(inner[8:].strip()))
                        i += 1
                        continue
                    break
                server[key] = values
                continue

            nested = {}
            while i < len(lines):
                inner = lines[i]
                inner_stripped = inner.strip()
                if not inner_stripped or inner_stripped.startswith("#"):
                    i += 1
                    continue
                if inner.startswith("      "):
                    nested_key, nested_sep, nested_value = inner_stripped.partition(":")
                    if nested_sep != ":":
                        raise SystemExit(f"expected nested key/value pair in registry: {inner}")
                    nested[nested_key] = parse_scalar(nested_value.strip())
                    i += 1
                    continue
                break
            server[key] = nested

        servers.append(server)

    return servers


def parse_scalar(value: str):
    if value.startswith('"') and value.endswith('"'):
        return value[1:-1].replace('\\"', '"').replace("\\\\", "\\")
    if value.startswith("'") and value.endswith("'"):
        return value[1:-1]
    if value == "true":
        return True
    if value == "false":
        return False
    if re.fullmatch(r"-?\d+", value):
        return int(value)
    if re.fullmatch(r"-?\d+\.\d+", value):
        return float(value)
    return value


def interpolate(value: str) -> str:
    def replace(match: re.Match[str]) -> str:
        return os.environ[match.group(1)]

    return re.sub(r"\$\{([A-Z0-9_]+)\}", replace, value)


def toml_string(value) -> str:
    return '"' + str(value).replace("\\", "\\\\").replace('"', '\\"') + '"'


def render_scalar(value) -> str:
    if isinstance(value, str):
        return toml_string(interpolate(value))
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int) or isinstance(value, float):
        return str(value)
    return toml_string(interpolate(str(value)))


def render_array(values) -> str:
    return "[" + ", ".join(render_scalar(value) for value in values) + "]"


def render_blocks(servers: list[dict]) -> str:
    lines: list[str] = []
    for server in servers:
        if not server.get("enabled", True):
            continue

        name = server["name"]
        lines.append(f"[mcp_servers.{name}]")
        if server.get("command"):
            lines.append(f"command = {toml_string(server['command'])}")
        if server.get("url"):
            lines.append(f"url = {toml_string(server['url'])}")
        if "args" in server:
            lines.append(f"args = {render_array(server.get('args', []))}")
        if server.get("startup_timeout_sec") is not None:
            lines.append(f"startup_timeout_sec = {server['startup_timeout_sec']}")

        if server.get("env"):
            lines.append("")
            lines.append(f"[mcp_servers.{name}.env]")
            for key, value in server["env"].items():
                lines.append(f"{key} = {render_scalar(value)}")

        if server.get("http_headers"):
            lines.append("")
            lines.append(f"[mcp_servers.{name}.http_headers]")
            for key, value in server["http_headers"].items():
                lines.append(f"{key} = {render_scalar(value)}")

        lines.append("")

    return "\n".join(lines).rstrip()


registry_path = Path(sys.argv[1])
config_path = Path(sys.argv[2]).expanduser()
mode = sys.argv[3]

servers = load_registry(registry_path)
managed_text = "# BEGIN dev-setup MCPs\n" + render_blocks(servers) + "\n# END dev-setup MCPs"

if mode == "dry-run":
    print(managed_text)
    raise SystemExit(0)

existing = config_path.read_text() if config_path.exists() else ""
pattern = re.compile(r"# BEGIN dev-setup MCPs.*?# END dev-setup MCPs\n?", re.S)
if pattern.search(existing):
    updated = pattern.sub(managed_text + "\n", existing)
else:
    cleaned = existing.rstrip()
    if cleaned:
        cleaned += "\n\n"
    updated = cleaned + managed_text + "\n"

config_path.parent.mkdir(parents=True, exist_ok=True)
config_path.write_text(updated)
print(f"Updated {config_path} with {sum(1 for server in servers if server.get('enabled', True))} MCP server(s).")
PY
