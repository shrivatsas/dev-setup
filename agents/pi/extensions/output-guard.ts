import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

// Global output guardrails (all projects). Repo-local policy stays in each
// repo (tools/agent_env.sh); this file is only the enforcement mechanism.

// Must match tools/agent_output_policy.js in repos that define it.
const MAX_CHARS = 3000;
const HEAD_CHARS = 1800;
const TAIL_CHARS = 900;

let outputCounter = 0;
let breakerNotified = false;

function textOf(content: unknown): string | null {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return null;
  const parts: string[] = [];
  for (const part of content) {
    if (
      part !== null &&
      typeof part === "object" &&
      (part as { type?: unknown }).type === "text" &&
      typeof (part as { text?: unknown }).text === "string"
    ) {
      parts.push((part as { text: string }).text);
    } else {
      return null; // non-text payload (images, etc.): leave untouched
    }
  }
  return parts.join("\n");
}

export default function (pi: ExtensionAPI) {
  // Repo-local env guardrails: source the project's tools/agent_env.sh for
  // rg/git-heavy commands when the project provides it. Skipped otherwise.
  pi.on("tool_call", async (event, ctx) => {
    try {
      if (event.toolName !== "bash") return;
      const input = event.input as { command?: unknown };
      if (typeof input.command !== "string") return;
      const cmd = input.command;
      if (cmd.indexOf("rg ") === -1 && cmd.indexOf("git diff") === -1) return;
      if (cmd.indexOf("agent_env.sh") !== -1) return; // already sourced
      const envFile = join(ctx.cwd, "tools", "agent_env.sh");
      if (!existsSync(envFile)) return;
      input.command = 'source "' + envFile + '" >/dev/null 2>&1; ' + cmd;
    } catch {
      // default: leave the command unchanged
    }
  });

  // Global output truncation: middle-truncate oversized tool results, save
  // the full output to a namespaced log, return head/tail with a pointer.
  pi.on("tool_result", async (event, ctx) => {
    try {
      // The read tool self-bounds (2000 lines / 50 KB) and is the intended way
      // to inspect a file; never post-truncate it.
      if (event.toolName === "read") return;
      const full = textOf((event as { content?: unknown }).content);
      if (full === null || full.length <= MAX_CHARS) return;
      const logDir = join(ctx.cwd, ".tmp", "logs");
      mkdirSync(logDir, { recursive: true });
      outputCounter += 1;
      let session = "nosession";
      try {
        const mgr = ctx.sessionManager as unknown as { getSessionId?: () => string };
        const id = typeof mgr.getSessionId === "function" ? mgr.getSessionId() : "nosession";
        session = (id || "nosession").slice(0, 8);
      } catch {
        // keep default
      }
      const name = "output-" + session + "-" + outputCounter + ".log";
      writeFileSync(join(logDir, name), full, "utf-8");
      const notice =
        "[output truncated: " + full.length + " chars; full output: .tmp/logs/" + name + "]\n";
      const available = Math.max(0, MAX_CHARS - notice.length);
      const head = full.slice(0, Math.min(HEAD_CHARS, available));
      const tail = full.slice(-Math.min(TAIL_CHARS, Math.max(0, available - head.length)));
      const marker = tail
        ? "\n... [" + (full.length - head.length - tail.length) + " chars omitted] ...\n"
        : "";
      return { content: [{ type: "text", text: (notice + head + marker + tail).slice(0, MAX_CHARS) }] };
    } catch {
      // default: leave the result unchanged
    }
  });

  // Advisory session circuit breaker: notify once, never block or kill.
  pi.on("turn_end", async (event, ctx) => {
    try {
      if (breakerNotified) return;
      const turnIndex = (event as { turnIndex?: unknown }).turnIndex;
      let over = typeof turnIndex === "number" && turnIndex + 1 >= 25;
      if (!over) {
        try {
          const usage = ctx.getContextUsage();
          over = !!usage && usage.tokens >= 60000;
        } catch {
          // ignore; turn count alone still applies
        }
      }
      if (over) {
        breakerNotified = true;
        ctx.ui.notify(
          "Advisory: past ~25 turns / ~60k tokens — consider writing a handoff and resetting the thread (see AGENTS.md).",
          "info",
        );
      }
    } catch {
      // never break the turn
    }
  });
}
