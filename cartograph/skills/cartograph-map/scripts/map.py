#!/usr/bin/env python3
"""Cartograph map tool.

Usage:
  map.py validate <map-dir>
  map.py render   <map-dir>            # writes <map-dir>/MAP.md
  map.py frontier <map-dir> [--top N]  # ranked next cells
  map.py ready    <map-dir> <area>     # is this area clear enough to build?
  map.py report   <map-dir>            # stakeholder status report -> reports/YYYY-MM-DD.md

<map-dir> holds map.yaml and (optionally) assumptions.yaml.
Exit code 1 on validation errors or when `ready` says no.
"""
import json
import re
import sys
from collections import Counter
from datetime import date
from pathlib import Path

try:
    import yaml
except ImportError:  # pragma: no cover
    sys.exit("PyYAML is required: pip install pyyaml")

LAYERS = ["intent", "domain", "structure", "data", "runtime", "delivery"]
STATES = ["fog", "sighted", "scouted", "charted", "verified", "contested"]
DONE = {"charted", "verified"}
LEVEL = {"low": 1, "medium": 2, "high": 3}
SYMBOL = {"fog": "·", "sighted": "○", "scouted": "◐", "charted": "●",
          "verified": "✔", "contested": "!"}
# Layers an area must have charted before it is buildable. Runtime and
# delivery are required too, but may be covered by open assumptions.
BUILD_HARD = ["intent", "domain", "structure", "data"]
BUILD_SOFT = ["runtime", "delivery"]
# origin: new = being designed; existing = already built (brownfield). Existing
# areas are mapped bottom-up from what can be observed, so the layer gate is off.
ORIGINS = ["new", "existing"]
EXISTING_MARK = "⌂"


def load(map_dir):
    d = Path(map_dir)
    if not (d / "map.yaml").exists():
        sys.exit(f"No map.yaml in {d}. Run /cartograph-survey first.")
    try:
        m = yaml.safe_load((d / "map.yaml").read_text()) or {}
        a_path = d / "assumptions.yaml"
        assumptions = (yaml.safe_load(a_path.read_text()) or {}) if a_path.exists() else {}
    except yaml.YAMLError as e:
        sys.exit(f"YAML syntax error — fix this before anything else:\n{e}")
    m.setdefault("areas", {})
    for area in m["areas"].values():
        area.setdefault("cells", {})
        area.setdefault("depends_on", [])
        for layer in LAYERS:
            cell = area["cells"].get(layer) or {}
            cell.setdefault("state", "fog")
            area["cells"][layer] = cell
    # A sub-area without its own origin takes its parent's; top level defaults to new.
    def origin_of(name, seen=()):
        area = m["areas"].get(name) or {}
        if area.get("origin"):
            return area["origin"]
        parent = area.get("parent")
        if parent and parent in m["areas"] and parent not in seen:
            return origin_of(parent, seen + (name,))
        return "new"
    for name, area in m["areas"].items():
        area["_origin"] = origin_of(name)
    return m, assumptions


def live_assumptions(cell, assumptions):
    return [a for a in cell.get("assumptions", [])
            if (assumptions.get(a) or {}).get("status", "open") in ("open", "confirmed")]


def dependents(m):
    count = {k: 0 for k in m["areas"]}
    for name, area in m["areas"].items():
        for dep in area["depends_on"]:
            if dep in count:
                count[dep] += 1
    return count


def gate_ok(area, i, assumptions):
    """A layer is workable if the previous layer is done or assumed through.

    Existing areas have no gate: their lower layers can be observed before
    anyone can say what the intent was.
    """
    if i == 0 or area.get("_origin") == "existing":
        return True, None
    prev = area["cells"][LAYERS[i - 1]]
    if prev["state"] in DONE:
        return True, None
    if live_assumptions(prev, assumptions):
        return True, "via assumption"
    return False, None


def validate(m, assumptions):
    errors, warnings = [], []
    areas = m["areas"]
    for name, area in areas.items():
        for dep in area["depends_on"]:
            if dep not in areas:
                errors.append(f"{name}: depends_on unknown area '{dep}'")
        parent = area.get("parent")
        if parent and parent not in areas:
            errors.append(f"{name}: parent '{parent}' does not exist")
        if area.get("origin") is not None and area["origin"] not in ORIGINS:
            errors.append(f"{name}: origin must be new|existing")
        for i, layer in enumerate(LAYERS):
            cell = area["cells"][layer]
            ref = f"{name}.{layer}"
            st = cell["state"]
            if st not in STATES:
                errors.append(f"{ref}: unknown state '{st}'")
                continue
            for key in ("irreversibility", "uncertainty"):
                if key in cell and cell[key] not in LEVEL:
                    errors.append(f"{ref}: {key} must be low|medium|high")
            for a in cell.get("assumptions", []):
                if a not in assumptions:
                    errors.append(f"{ref}: assumption {a} not in assumptions.yaml")
            if st in DONE:
                ok, _ = gate_ok(area, i, assumptions)
                if not ok:
                    errors.append(f"{ref}: is {st} but {name}.{LAYERS[i-1]} is neither "
                                  f"charted nor covered by a live assumption")
                if not cell.get("decisions") and not cell.get("no_decisions_needed"):
                    warnings.append(f"{ref}: {st} with no decisions recorded "
                                    f"(set no_decisions_needed: true if intended)")
            if st == "verified" and not cell.get("evidence"):
                warnings.append(f"{ref}: verified but no evidence listed")
            if st == "contested" and not cell.get("contested_by"):
                warnings.append(f"{ref}: contested but contested_by is empty")
    rank = {"fog": 0, "sighted": 1, "scouted": 2, "contested": 2, "charted": 3, "verified": 4}
    for name, area in areas.items():
        kids = [k for k, a in areas.items() if a.get("parent") == name]
        for layer in LAYERS:
            for k in kids:
                if rank.get(area["cells"][layer]["state"], 0) > rank.get(areas[k]["cells"][layer]["state"], 0):
                    warnings.append(f"{name}.{layer}: parent is ahead of sub-area {k}.{layer}; "
                                    f"a parent cell summarises its children")
    for aid, a in assumptions.items():
        if not (a or {}).get("revisit_when"):
            warnings.append(f"assumption {aid}: no revisit_when trigger")
    return errors, warnings


def frontier(m, assumptions):
    deps = dependents(m)
    rows = []
    for name, area in m["areas"].items():
        for i, layer in enumerate(LAYERS):
            cell = area["cells"][layer]
            if cell["state"] in DONE:
                continue
            ok, how = gate_ok(area, i, assumptions)
            if not ok:
                continue
            irr = LEVEL.get(cell.get("irreversibility", "medium"), 2)
            default_unc = "high" if cell["state"] == "fog" else "medium"
            unc = LEVEL.get(cell.get("uncertainty", default_unc), 2)
            score = irr * unc * (1 + deps[name])
            reasons = [f"irr={irr}", f"unc={unc}", f"dependents={deps[name]}"]
            if area.get("on_path"):
                score *= 2
                reasons.append("on path")
            if cell["state"] == "contested":
                score *= 1.5
                reasons.append("contested")
            if how:
                reasons.append(how)
            rows.append((score, i, f"{name}.{layer}", cell["state"], ", ".join(reasons)))
    rows.sort(key=lambda r: (-r[0], r[1], r[2]))
    return rows


def ready(m, assumptions, name):
    area = m["areas"].get(name)
    if area is None:
        return False, [f"unknown area '{name}'"]
    problems = []
    for layer in BUILD_HARD:
        st = area["cells"][layer]["state"]
        if st not in DONE:
            problems.append(f"{name}.{layer} is {st}; must be charted")
    for layer in BUILD_SOFT:
        cell = area["cells"][layer]
        if cell["state"] not in DONE and not live_assumptions(cell, assumptions):
            problems.append(f"{name}.{layer} is {cell['state']}; chart it or record an assumption")
    for layer in LAYERS:
        cell = area["cells"][layer]
        if cell.get("one_way_pending"):
            problems.append(f"{name}.{layer} has unverified one-way doors: {cell['one_way_pending']}")
        for a in cell.get("assumptions", []):
            if (assumptions.get(a) or {}).get("blocking"):
                problems.append(f"{name}.{layer} relies on blocking assumption {a}")
    for dep in area["depends_on"]:
        dep_area = m["areas"].get(dep, {"cells": {}})
        for layer in ("intent", "domain"):
            st = dep_area["cells"].get(layer, {}).get("state", "fog")
            if st not in DONE:
                problems.append(f"dependency {dep}.{layer} is {st}; must be charted")
    return not problems, problems


def ordered_areas(m):
    areas = m["areas"]
    out = []

    def walk(name, depth):
        out.append((name, depth))
        for child, a in areas.items():
            if a.get("parent") == name:
                walk(child, depth + 1)

    for name, a in areas.items():
        if not a.get("parent"):
            walk(name, 0)
    return out


def render(m, assumptions, map_dir):
    lines = [f"# Map — {m.get('project', 'project')}", "",
             f"_Generated {date.today().isoformat()} from map.yaml. Do not edit by hand._", "",
             "Legend: · fog  ○ sighted  ◐ scouted  ● charted  ✔ verified  ! contested", "",
             "| Area | " + " | ".join(l.capitalize() for l in LAYERS) + " |",
             "|---|" + "---|" * len(LAYERS)]
    for name, depth in ordered_areas(m):
        area = m["areas"][name]
        label = ("↳ " * depth) + area.get("title", name)
        if area.get("on_path"):
            label += " ★"
        if area["_origin"] == "existing":
            label += " " + EXISTING_MARK
        cells = []
        for layer in LAYERS:
            c = area["cells"][layer]
            mark = SYMBOL[c["state"]]
            if c.get("assumptions"):
                mark += "ᵃ"
            cells.append(f"{mark} {c['state']}")
        lines.append(f"| {label} | " + " | ".join(cells) + " |")
    for u in m.get("undiscovered", []) or []:
        lines.append(f"| ? {u} | " + " | ".join(["·"] * len(LAYERS)) + " |")
    has_existing = any(a["_origin"] == "existing" for a in m["areas"].values())
    lines += ["", "★ on the current build path · " +
              (f"{EXISTING_MARK} existing system (mapped as built) · " if has_existing else "") +
              "ᵃ relies on an assumption", "",
              "## Frontier (top 5)", ""]
    for score, _, ref, st, why in frontier(m, assumptions)[:5]:
        lines.append(f"- **{ref}** ({st}) — score {score:g} — {why}")
    open_a = [(k, v) for k, v in assumptions.items() if (v or {}).get("status", "open") == "open"]
    if open_a:
        lines += ["", "## Open assumptions", ""]
        for k, v in open_a:
            lines.append(f"- **{k}** ({v.get('cell', '?')}): {v.get('statement', '')} "
                         f"— revisit when: {v.get('revisit_when', 'NOT SET')}")
    out = Path(map_dir) / "MAP.md"
    out.write_text("\n".join(lines) + "\n")
    return out


# ---------------------------------------------------------------- report --

def read_frontmatter(path):
    text = path.read_text()
    if not text.startswith("---"):
        return None
    parts = text.split("---", 2)
    if len(parts) < 3:
        return None
    try:
        return yaml.safe_load(parts[1]) or {}
    except yaml.YAMLError:
        return None


def load_decisions(map_dir):
    out, broken = {}, []
    for f in sorted(Path(map_dir).glob("areas/*/decisions/*.md")):
        fm = read_frontmatter(f)
        if not fm or "id" not in fm:
            broken.append(str(f.relative_to(map_dir)))
            continue
        fm["_file"] = str(f.relative_to(map_dir))
        out[fm["id"]] = fm
    return out, broken


def load_light_records(map_dir):
    ids = {}
    for f in Path(map_dir).glob("areas/*/AREA.md"):
        for line in f.read_text().splitlines():
            mt = re.match(r"^\|\s*(L-[\w-]+)\s*\|\s*(\w+)\s*\|\s*(\w+)\s*\|", line)
            if mt:
                ids[mt.group(1)] = {"area": f.parent.name, "layer": mt.group(2), "door": mt.group(3)}
    return ids


def load_weights(map_dir):
    """Return (contextual weights, per-area overrides, invariant names), keys lower-cased."""
    p = Path(map_dir) / "PRINCIPLES.md"
    weights, overrides, invariant = {}, {}, set()
    if not p.exists():
        return weights, overrides, invariant
    section = None
    for line in p.read_text().splitlines():
        if line.startswith("## "):
            section = line[3:].strip().lower()
            continue
        if section is None:
            continue
        if section.startswith("invariant") and " · " in line:
            invariant |= {x.strip().lower() for x in line.split(" · ") if x.strip()}
            continue
        cols = [c.strip() for c in line.strip().strip("|").split("|")]
        if section.startswith("contextual") and len(cols) >= 2 and cols[1].isdigit():
            weights[cols[0].lower()] = int(cols[1])
        if section.startswith("per-area") and len(cols) >= 3 and cols[2].isdigit():
            overrides[(cols[0], cols[1].lower())] = int(cols[2])
    return weights, overrides, invariant


def snapshot_of(m, assumptions, decisions):
    return {
        "cells": {f"{n}.{l}": a["cells"][l]["state"] for n, a in m["areas"].items() for l in LAYERS},
        "decisions": sorted(decisions),
        "assumptions": {k: (v or {}).get("status", "open") for k, v in assumptions.items()},
        "one_way_pending": sorted(f"{n}.{l}:{d}" for n, a in m["areas"].items() for l in LAYERS
                                  for d in a["cells"][l].get("one_way_pending", [])),
    }


def previous_snapshot(reports_dir, today):
    snaps = sorted(p for p in reports_dir.glob("snapshot-*.json") if p.stem[9:] < today)
    if not snaps:
        return None, None
    return snaps[-1].stem[9:], json.loads(snaps[-1].read_text())


def build_report(m, assumptions, map_dir, warnings):
    today = date.today().isoformat()
    areas = m["areas"]
    decisions, broken_files = load_decisions(map_dir)
    # Inherited records describe commitments found in an existing system. Nobody
    # chose them here, so they don't count towards principles or ceremony stats.
    inherited = {i: d for i, d in decisions.items() if d.get("status") == "inherited"}
    chosen = {i: d for i, d in decisions.items() if i not in inherited}
    light = load_light_records(map_dir)
    weights, overrides, invariant = load_weights(map_dir)
    cells = [(n, l, areas[n]["cells"][l]) for n in areas for l in LAYERS]
    total = len(cells)
    states = Counter(c["state"] for _, _, c in cells)
    done = states["charted"] + states["verified"]
    pending = [(f"{n}.{l}", d) for n, l, c in cells for d in c.get("one_way_pending", [])]
    open_a = {k: v or {} for k, v in assumptions.items() if (v or {}).get("status", "open") == "open"}
    blocking = [k for k, v in open_a.items() if v.get("blocking")]
    broken_a = [k for k, v in assumptions.items() if (v or {}).get("status") == "broken"]
    contested = [(f"{n}.{l}", c.get("contested_by", "reason not recorded")) for n, l, c in cells
                 if c["state"] == "contested"]
    ready_list, not_ready = [], []
    for n, _depth in ordered_areas(m):
        ok, problems = ready(m, assumptions, n)
        (ready_list if ok else not_ready).append((n, problems))

    L = [f"# Status report — {m.get('project', 'project')} — {today}", ""]

    # Headline
    pct = round(100 * done / total) if total else 0
    head = (f"{done} of {total} cells are charted or verified ({pct}%), across {len(areas)} areas. "
            f"{len(pending)} one-way decision(s) are accepted but unproven; "
            f"{len(open_a)} assumption(s) are open, {len(blocking)} of them blocking; "
            f"{len(contested)} cell(s) are contested. ")
    head += ("Ready to build: " + ", ".join(areas[n].get("title", n) for n, _ in ready_list) + "."
             if ready_list else "No area is ready to build yet.")
    L += ["## Headline", "", head, ""]

    # Since last report
    reports_dir = Path(map_dir) / "reports"
    prev_date, prev = previous_snapshot(reports_dir, today) if reports_dir.exists() else (None, None)
    snap = snapshot_of(m, assumptions, decisions)
    L += ["## Since last report", ""]
    if not prev:
        L += ["First report — no earlier snapshot to compare against.", ""]
    else:
        moved = [(r, prev["cells"].get(r, "fog"), s_) for r, s_ in snap["cells"].items()
                 if prev["cells"].get(r, "fog") != s_]
        new_d = [d for d in snap["decisions"] if d not in prev["decisions"] and d not in inherited]
        new_inh = [d for d in snap["decisions"] if d not in prev["decisions"] and d in inherited]
        new_a = [a for a in snap["assumptions"] if a not in prev["assumptions"]]
        changed_a = [(a, prev["assumptions"][a], st) for a, st in snap["assumptions"].items()
                     if a in prev["assumptions"] and prev["assumptions"][a] != st]
        proven = [x for x in prev["one_way_pending"] if x not in snap["one_way_pending"]]
        L.append(f"Compared with {prev_date}:")
        L.append("")
        L.append(f"- Cells moved: {len(moved)}" + ("" if not moved else " — " +
                 "; ".join(f"{r} {a}→{b}" for r, a, b in moved[:12]) + (" …" if len(moved) > 12 else "")))
        L.append(f"- New one-way decisions: {', '.join(new_d) or 'none'}")
        if new_inh:
            L.append(f"- Inherited commitments found: {', '.join(new_inh)}")
        L.append(f"- One-way doors proven: {len(proven)}")
        L.append(f"- New assumptions: {', '.join(new_a) or 'none'}; status changes: " +
                 (", ".join(f"{a} {x}→{y}" for a, x, y in changed_a) or "none"))
        backward = [r for r, a, b in moved if b == "contested" or
                    STATES.index(b) < STATES.index(a) and b != "contested"]
        if backward:
            L.append(f"- Fog returned on: {', '.join(backward)}")
        L.append("")

    # Coverage
    L += ["## Coverage", "",
          "Legend: · fog  ○ sighted  ◐ scouted  ● charted  ✔ verified  ! contested", "",
          "| Area | " + " | ".join(l.capitalize() for l in LAYERS) + " | Done |",
          "|---|" + "---|" * (len(LAYERS) + 1)]
    for n, depth in ordered_areas(m):
        a = areas[n]
        row = [SYMBOL[a["cells"][l]["state"]] for l in LAYERS]
        d = sum(a["cells"][l]["state"] in DONE for l in LAYERS)
        label = (("↳ " * depth) + a.get("title", n) + (" ★" if a.get("on_path") else "")
                 + (" " + EXISTING_MARK if a["_origin"] == "existing" else ""))
        L.append(f"| {label} | " + " | ".join(row) + f" | {d}/6 |")
    per_layer = [sum(areas[n]["cells"][l]["state"] in DONE for n in areas) for l in LAYERS]
    L.append("| **Charted or verified** | " + " | ".join(f"{x}/{len(areas)}" for x in per_layer) + f" | {done}/{total} |")
    if any(a["_origin"] == "existing" for a in areas.values()):
        L += ["", f"{EXISTING_MARK} existing system, mapped as built. "
              f"Inherited commitments recorded: {len(inherited)}."]
    if m.get("undiscovered"):
        L += ["", f"Suspected but not yet mapped: {', '.join(m['undiscovered'])}."]
    L.append("")

    # Risk
    L += ["## Risk", "", "### Unproven one-way doors", ""]
    if pending:
        for ref, d in pending:
            title = decisions.get(d, {}).get("title", "")
            L.append(f"- **{d}** ({ref}){' — ' + title if title else ''}")
    else:
        L.append("None.")
    L += ["", "### Assumptions", ""]
    if open_a or broken_a:
        for k in sorted(open_a, key=lambda k: not open_a[k].get("blocking")):
            v = open_a[k]
            tag = "BLOCKING · " if v.get("blocking") else ""
            L.append(f"- {tag}**{k}** ({v.get('cell', '?')}): {v.get('statement', '')} "
                     f"— revisit when: {v.get('revisit_when') or '**no trigger set**'}")
        for k in broken_a:
            L.append(f"- BROKEN · **{k}** ({(assumptions[k] or {}).get('cell', '?')}): "
                     f"cells relying on it should be contested")
    else:
        L.append("None open.")
    L += ["", "### Contested cells", ""]
    L += [f"- **{r}** — {why}" for r, why in contested] or ["None."]
    watch = [(i, d.get("revisit_when")) for i, d in decisions.items()
             if d.get("status") in ("accepted", "inherited") and d.get("revisit_when")]
    L += ["", "### Watchlist — triggers that would reopen accepted " +
          ("or inherited " if inherited else "") + "decisions", ""]
    L += [f"- **{i}**: {w}" for i, w in watch] or ["None recorded."]
    L.append("")

    # Principles in practice
    favoured, traded, traded_high, display = Counter(), Counter(), Counter(), {}
    for d in chosen.values():
        if d.get("status") == "superseded":
            continue
        area = str(d.get("cell", ".")).split(".")[0]
        for p_ in d.get("favoured") or []:
            display.setdefault(str(p_).lower(), str(p_))
            favoured[str(p_).lower()] += 1
        for p_ in d.get("traded_away") or []:
            k = str(p_).lower()
            display.setdefault(k, str(p_))
            traded[k] += 1
            if overrides.get((area, k), weights.get(k, 0)) >= 4:
                traded_high[k] += 1
    names = sorted(set(weights) | set(favoured) | set(traded),
                   key=lambda k: (-weights.get(k, 0), k))
    L += ["## Principles in practice", ""]
    if not chosen:
        L += ["No one-way decision records yet." +
              (f" ({len(inherited)} inherited record(s) are not counted: nobody chose them.)"
               if inherited else ""), ""]
    else:
        L += ["Counts come from one-way decision records (superseded and inherited ones excluded). "
              "Per-area override weights are applied when judging trade-offs.", "",
              "| Principle | Weight | Favoured | Traded away | Flag |", "|---|---|---|---|---|"]
        for k in names:
            w = weights.get(k)
            inv = k in invariant
            flag = ""
            if inv and traded[k]:
                flag = "invariant traded away — the record must say why"
            elif traded_high[k] >= 2 and traded_high[k] > favoured[k]:
                flag = "losing often where it weighs ≥4 — re-weight or enforce"
            elif w is None and not inv and (favoured[k] or traded[k]):
                flag = "not on shortlist — add it or stop citing it"
            elif w is not None and w >= 4 and not (favoured[k] or traded[k]):
                flag = "high weight, never cited"
            wtxt = "inv." if inv else (str(w) if w is not None else "—")
            L.append(f"| {display.get(k, k)} | {wtxt} | {favoured[k]} | {traded[k]} | {flag} |")
        rungs = Counter(str(d.get("rung", "?")) for d in chosen.values())
        doors = Counter(str(d.get("door", "?")) for d in chosen.values())
        L += ["", "Settled at rung: " + ", ".join(f"{r}: {c}" for r, c in sorted(rungs.items())) +
              ". Doors: " + ", ".join(f"{k}: {v}" for k, v in sorted(doors.items())) +
              f". Two-way light records: {len(light)}." +
              (f" Inherited (found, not chosen): {len(inherited)}." if inherited else "")]
        ratio = len(chosen) / max(1, len(chosen) + len(light))
        if len(chosen) + len(light) >= 8 and ratio > 0.5:
            L.append("Over half of all decisions were treated as one-way — check for inflated ceremony.")
        if len(light) >= 8 and not chosen:
            L.append("Many decisions and none treated as one-way — check door classification.")
        L.append("")

    # Readiness
    L += ["## Build readiness", ""]
    L.append("**Ready:** " + (", ".join(areas[n].get("title", n) for n, _ in ready_list) or "none") + ".")
    L.append("")
    for n, problems in sorted(not_ready, key=lambda x: len(x[1])):
        star = " ★" if areas[n].get("on_path") else ""
        L.append(f"- **{areas[n].get('title', n)}{star}** — {len(problems)} blocker(s): " +
                 "; ".join(problems[:3]) + (" …" if len(problems) > 3 else ""))
    L.append("")

    # Integrity
    issues = list(warnings)
    for n, l, c in cells:
        for d in c.get("decisions", []) or []:
            if str(d).startswith("D-") and d not in decisions:
                issues.append(f"{n}.{l} cites {d} but no decision file has that id")
            if str(d).startswith("L-") and d not in light:
                issues.append(f"{n}.{l} cites {d} but no AREA.md light record has that id")
        for d in c.get("one_way_pending", []) or []:
            if d not in decisions:
                issues.append(f"{n}.{l} lists pending {d} but no decision file has that id")
    for i, d in decisions.items():
        if d.get("status") == "accepted" and not d.get("approved_by"):
            issues.append(f"{i} is accepted with no approved_by")
        d_area = str(d.get("cell") or "").split(".")[0]
        if d.get("cell") and d_area not in areas:
            issues.append(f"{i} belongs to unknown area '{d_area}'")
        if i in inherited:
            if not d.get("confirmed_by"):
                issues.append(f"{i} is inherited but unconfirmed — read from code only; "
                              f"ask someone who knows the system")
            if d_area in areas and areas[d_area]["_origin"] != "existing":
                issues.append(f"{i} is inherited but area '{d_area}' is not origin: existing")
    issues += [f"{f}: missing or unreadable front matter" for f in broken_files]
    L += ["## Integrity checks", ""]
    L += [f"- {x}" for x in issues] or ["No problems found."]
    L.append("")

    # Next
    L += ["## Suggested next expeditions", ""]
    for score, _, ref, st, why in frontier(m, assumptions)[:3]:
        L.append(f"- **{ref}** ({st}) — {why}")
    L.append("")

    reports_dir.mkdir(exist_ok=True)
    out = reports_dir / f"{today}.md"
    out.write_text("\n".join(L) + "\n")
    (reports_dir / f"snapshot-{today}.json").write_text(json.dumps(snap, indent=1))
    return out


def main(argv):
    if len(argv) < 3 or argv[1] not in ("validate", "render", "frontier", "ready", "report"):
        print(__doc__)
        return 2
    cmd, map_dir = argv[1], argv[2]
    m, assumptions = load(map_dir)
    errors, warnings = validate(m, assumptions)
    if cmd == "validate":
        for e in errors:
            print("ERROR  ", e)
        for w in warnings:
            print("WARN   ", w)
        print(f"{len(errors)} error(s), {len(warnings)} warning(s)")
        return 1 if errors else 0
    if errors:
        print("Map has validation errors; run `validate` first.")
        for e in errors:
            print("ERROR  ", e)
        return 1
    if cmd == "render":
        print(f"wrote {render(m, assumptions, map_dir)}")
        return 0
    if cmd == "frontier":
        top = 5
        if "--top" in argv:
            top = int(argv[argv.index("--top") + 1])
        for score, _, ref, st, why in frontier(m, assumptions)[:top]:
            print(f"{score:>6g}  {ref:<32} {st:<10} {why}")
        return 0
    if cmd == "report":
        print(f"wrote {build_report(m, assumptions, map_dir, warnings)}")
        return 0
    if cmd == "ready":
        if len(argv) < 4:
            print("usage: map.py ready <map-dir> <area>")
            return 2
        ok, problems = ready(m, assumptions, argv[3])
        print("READY" if ok else "NOT READY")
        for p in problems:
            print("  -", p)
        return 0 if ok else 1
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
