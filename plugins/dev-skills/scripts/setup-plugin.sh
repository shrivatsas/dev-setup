#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MARKETPLACE="${DEV_SETUP_MARKETPLACE_PATH:-$HOME/.agents/plugins/marketplace.json}"

mkdir -p "$(dirname "$MARKETPLACE")"

python3 - "$MARKETPLACE" "$PLUGIN_DIR" <<'PY'
import json
import sys
from pathlib import Path

marketplace = Path(sys.argv[1]).expanduser()
plugin_dir = Path(sys.argv[2]).resolve()

if marketplace.exists():
    payload = json.loads(marketplace.read_text())
else:
    payload = {
        "name": "local",
        "interface": {"displayName": "Local Plugins"},
        "plugins": [],
    }

payload.setdefault("name", "local")
payload.setdefault("interface", {}).setdefault("displayName", "Local Plugins")
plugins = payload.setdefault("plugins", [])

entry = {
    "name": "dev-skills",
    "source": {
        "source": "local",
        "path": str(plugin_dir),
    },
    "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL",
    },
    "category": "Productivity",
}

for i, existing in enumerate(plugins):
    if existing.get("name") == entry["name"]:
        plugins[i] = entry
        break
else:
    plugins.append(entry)

marketplace.write_text(json.dumps(payload, indent=2) + "\n")
print(f"Registered dev-skills in {marketplace}")
print(f"Plugin path: {plugin_dir}")
PY
