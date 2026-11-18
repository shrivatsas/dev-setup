#!/usr/bin/env python3
"""The session-cost tool reads Codex rollouts and Claude Code transcripts.

Codex: sessions are found in every Codex home, not one hardcoded account. A hardcoded
`~/.codex-accounts/shrivatsa-dev/sessions` reported "no session matching" for a session that
existed under another account (`shrivatsa-swadi`, session 01a18b1e), so a handoff that needs a
cost line recorded "unavailable" instead. This pins the resolution order and the override paths
that make the measurement reproducible.

Claude Code: a model call repeated across lines is counted once, input is the whole prompt
(uncached + cache writes + cache reads), tool results are measured, a compaction is counted, and
only typed prompts count as turns.

    python3 agents/claude/tests/test_agent_session_cost.py
"""
import importlib.machinery
import importlib.util
import json
import os
import pathlib
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
TOOL = ROOT / "bin" / "agent-session-cost"  # no .py suffix, so name the loader explicitly
SPEC = importlib.util.spec_from_file_location(
    "agent_session_cost", TOOL, loader=importlib.machinery.SourceFileLoader("agent_session_cost", str(TOOL)))
cost = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = cost  # dataclasses resolves its module through sys.modules
SPEC.loader.exec_module(cost)

SID = "01a18b1e-a86e-7133-bf0f-17efa245c5ac"


def write_rollout(sessions_root: pathlib.Path) -> pathlib.Path:
    """One rollout with a single billed call, in the shape `load` reads."""
    path = sessions_root / "2026" / "10" / "30" / f"rollout-2026-10-30T05-00-00-{SID}.jsonl"
    path.parent.mkdir(parents=True, exist_ok=True)
    rows = [
        {"timestamp": "2026-10-30T05:00:00.000Z", "ordinal": 1, "type": "event_msg",
         "payload": {"type": "token_count", "model": "fixture-model",
                     "info": {"last_token_usage": {"input_tokens": 1000, "cached_input_tokens": 800,
                                                   "output_tokens": 50, "reasoning_output_tokens": 10}}}},
        {"timestamp": "2026-10-30T05:00:01.000Z", "ordinal": 2, "type": "response_item",
         "payload": {"type": "custom_tool_call_output", "output": "x" * 4000}},
    ]
    path.write_text("\n".join(json.dumps(row) for row in rows) + "\n")
    return path


def run(args, env):
    return subprocess.run([sys.executable, str(ROOT / "bin" / "agent-session-cost"), *args],
                          capture_output=True, text=True, env=env)


with tempfile.TemporaryDirectory() as tmp:
    home = pathlib.Path(tmp) / "home"
    work = home / ".codex-accounts" / "work"
    other = home / ".codex-accounts" / "other"
    write_rollout(work / "sessions")
    write_rollout(other / "sessions")
    env = {key: value for key, value in os.environ.items()
           if key not in ("CODEX_HOME", "CODEX_SESSIONS_ROOT")}
    env["HOME"] = str(home)

    # 1. Resolution order: the active CODEX_HOME first, then every account home.
    #    default_roots reads os.environ, so the fixture home is installed there and
    #    the subprocess environment carries the same values.
    saved = {key: os.environ.get(key) for key in ("HOME", "CODEX_HOME", "CODEX_SESSIONS_ROOT")}
    try:
        os.environ["HOME"] = str(home)
        os.environ.pop("CODEX_HOME", None)
        os.environ.pop("CODEX_SESSIONS_ROOT", None)
        roots = [pathlib.Path(root) for root in cost.default_roots()]
        assert other / "sessions" in roots, f"a sibling account home must be searched, got {roots}"
        assert work / "sessions" in roots, f"every account home must be searched, got {roots}"
        assert home / ".codex" / "sessions" not in roots, "a missing root must not be reported"
        os.environ["CODEX_HOME"] = str(work)
        with_home = [pathlib.Path(r) for r in cost.default_roots()]
        assert with_home[0] == work / "sessions", f"CODEX_HOME must come first, got {with_home}"
        assert with_home.count(work / "sessions") == 1, f"a root must not be searched twice, got {with_home}"
        os.environ.pop("CODEX_HOME")
    finally:
        for key, value in saved.items():
            if value is None:
                os.environ.pop(key, None)
            else:
                os.environ[key] = value

    # 2. The observed failure: a session under another account, with no CODEX_HOME set.
    found = run(["--session", SID], env)
    assert found.returncode == 0, f"sibling-account session must be found, got {found.stderr.strip()}"
    assert f"session {SID}" in found.stdout and "model=fixture-model" in found.stdout, found.stdout
    assert "input=1,000" in found.stdout, f"anatomy must report the fixture's input tokens:\n{found.stdout}"
    assert ">3000 chars=1" in found.stdout, f"a 4,000-char output must be counted:\n{found.stdout}"

    # 3. An unknown id still fails closed and names the roots it searched.
    missing = run(["--session", "ffffffff"], env)
    assert missing.returncode != 0, "an unknown session must not report a cost line"
    assert "other/sessions" in missing.stderr or "work/sessions" in missing.stderr, missing.stderr

    # 4. Overrides: CODEX_SESSIONS_ROOT, then --root, both narrow the search.
    #    Prove each override is honored with a root that holds no session: the run must
    #    fail and its error may name only the root the override pointed at.
    empty_root = home / "sessions-empty"
    empty_root.mkdir()
    narrowed = run(["--session", SID], {**env, "CODEX_SESSIONS_ROOT": str(empty_root)})
    assert narrowed.returncode != 0, "CODEX_SESSIONS_ROOT must narrow the search"
    assert str(empty_root) in narrowed.stderr, narrowed.stderr
    assert str(work) not in narrowed.stderr and str(other) not in narrowed.stderr, narrowed.stderr
    narrowed_root = run(["--session", SID], {**env, "CODEX_SESSIONS_ROOT": str(work / "sessions")})
    assert narrowed_root.returncode == 0, narrowed_root.stderr
    work_only = run(["--session", SID, "--root", str(work / "sessions")], env)
    assert work_only.returncode == 0, work_only.stderr
    empty = run(["--session", SID, "--root", str(home / "nothing")], env)
    assert empty.returncode != 0, "--root must be able to point away from the session"


def call(mid, uncached, written, read, out):
    return {"type": "assistant", "timestamp": "2026-10-30T01:00:00Z", "message": {"id": mid, "model": "claude-fixture",
            "usage": {"input_tokens": uncached, "cache_creation_input_tokens": written, "cache_read_input_tokens": read, "output_tokens": out}}}


RECORDS = [
    {"type": "user", "timestamp": "2026-10-30T00:59:00Z", "message": {"content": "fix mode pr 1"}},
    {"type": "user", "isMeta": True, "message": {"content": "<system reminder>"}},
    call("msg_1", 2, 1000, 0, 40),
    call("msg_1", 2, 1000, 0, 40),  # the same call, written again for its next content block
    {"type": "user", "message": {"content": [{"type": "tool_result", "content": "x" * 5000}]}},
    call("msg_2", 1, 100, 1000, 10),
    {"type": "user", "message": {"content": [{"type": "tool_result", "content": [{"type": "text", "text": "y" * 20}]}]}},
    {"type": "assistant", "message": {"id": "synthetic-1", "model": "<synthetic>", "usage": {"input_tokens": 0, "output_tokens": 0}}},
    {"type": "system", "subtype": "compact_boundary"},
    {"type": "user", "isCompactSummary": True, "message": {"content": "summary"}},
    {"type": "user", "message": {"content": [{"type": "text", "text": "next prompt"}]}},
    call("msg_3", 3, 0, 1100, 5),
]

with tempfile.TemporaryDirectory() as tmp:
    project = pathlib.Path(tmp) / "projects" / "-repo"
    project.mkdir(parents=True)
    path = project / "0f0f0f0f-aaaa-bbbb-cccc-1234567890ab.jsonl"
    path.write_text("".join(json.dumps(record) + "\n" for record in RECORDS) + "not json\n")
    s = cost.load_claude(str(path))
    assert (s.harness, s.sid, s.model, s.dates) == ("claude", path.stem, "claude-fixture", ["2026-10-30"]), s
    assert s.calls == 3, f"a repeated or synthetic call was counted: {s.calls}"
    assert s.in_tokens == (2 + 1000) + (1 + 100 + 1000) + (3 + 1100), s.in_tokens
    assert (s.cached, s.out_tokens, s.first_in) == (2100, 55, 1002), (s.cached, s.out_tokens, s.first_in)
    assert [chars for _, chars in s.out_chars] == [5000, 20], s.out_chars
    assert (s.compactions, s.turns) == (1, 2), (s.compactions, s.turns)
    # The 5000-char result is resident for the second call only: the compaction drops it.
    assert s.amplification() == 5000 // 4 + 0, s.amplification()

    # The command finds a Claude Code session by id, beside the Codex sessions.
    shown = subprocess.run([sys.executable, str(ROOT / "bin" / "agent-session-cost"), "--root", str(pathlib.Path(tmp) / "codex"),
                            "--claude-root", str(project.parent), "--session", "0f0f0f0f"], capture_output=True, text=True, check=True).stdout
    assert "harness=claude" in shown and "calls=3 compactions=1" in shown, shown

print("agent session cost: ok")
