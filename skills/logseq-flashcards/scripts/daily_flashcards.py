#!/usr/bin/env python3
"""Generate daily Logseq flashcards from existing PKM content.

Default priority:
1. AI and Agents
2. Leadership and Management
3. Everything else

The script appends new cards to pages/Flashcards Inbox.md so Logseq can pick
them up immediately after re-indexing.
"""

from __future__ import annotations

import argparse
import dataclasses
import datetime as dt
import json
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path
from typing import Iterator


AI_PATTERNS = (
    r"\bai\b",
    r"\bllm\b",
    r"\bagent\b",
    r"\brag\b",
    r"\bmcp\b",
    r"\bprompt\b",
    r"context engineering",
    r"harness engineering",
    r"ai foundations",
    r"ai stack",
    r"ai coding",
    r"ai safety",
    r"ai agent",
    r"agentic",
)

LEADERSHIP_PATTERNS = (
    r"leadership",
    r"management",
    r"\bmanager\b",
    r"mentor",
    r"coaching",
    r"career",
    r"feedback",
    r"hiring",
    r"one-on-one",
    r"planning",
    r"culture",
    r"\bteam\b",
    r"executive",
    r"\borg\b",
)

EXCLUDED_PAGES = {
    "PKM Metadata.md",
    "PKM Cleanup.md",
    "PKM Taxonomy.md",
}

DEFAULT_OUTPUT = Path("pages/Flashcards Inbox.md")
DEFAULT_MODEL = os.environ.get("OPENAI_MODEL", "gpt-5.1")


@dataclasses.dataclass(frozen=True)
class Candidate:
    page_title: str
    page_path: Path
    topic: str
    excerpt: str
    score: int


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--graph", default=".", help="Path to the PKM root.")
    parser.add_argument(
        "--output",
        default=str(DEFAULT_OUTPUT),
        help="Output page path relative to the graph root.",
    )
    parser.add_argument(
        "--count",
        type=int,
        default=10,
        help="Number of cards to generate.",
    )
    parser.add_argument(
        "--model",
        default=DEFAULT_MODEL,
        help="OpenAI model to use when API generation is enabled.",
    )
    parser.add_argument(
        "--provider",
        choices=("openai", "heuristic"),
        default="openai",
        help="Card generation mode.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the generated markdown without writing it.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    graph = Path(args.graph).expanduser().resolve()
    pages_dir = graph / "pages"
    output_path = (graph / args.output).resolve()

    existing_fronts = collect_existing_fronts(pages_dir)
    candidates = collect_candidates(pages_dir, output_path)

    if not candidates:
        print("No candidate source material found.", file=sys.stderr)
        return 1

    desired_topics = topic_plan(args.count)
    selected = pick_candidates(candidates, desired_topics, args.count)
    if not selected:
        print("No candidates available after filtering.", file=sys.stderr)
        return 1

    if args.provider == "openai":
        cards = generate_with_openai(selected, args.model)
    else:
        cards = generate_with_heuristics(selected)

    cards = dedupe_cards(cards, existing_fronts)
    cards = cards[: args.count]

    if not cards:
        print("No new cards were generated.", file=sys.stderr)
        return 1

    markdown = render_output(cards)
    if args.dry_run:
        print(markdown)
        return 0

    write_output(output_path, markdown)
    print(f"Wrote {len(cards)} cards to {output_path}")
    return 0


def topic_plan(count: int) -> list[str]:
    ai = min(6, count)
    leadership = min(3, max(0, count - ai))
    other = max(0, count - ai - leadership)
    plan = ["ai"] * ai + ["leadership"] * leadership + ["other"] * other
    return plan


def collect_existing_fronts(pages_dir: Path) -> set[str]:
    fronts: set[str] = set()
    for path in pages_dir.glob("*.md"):
        text = safe_read(path)
        for match in re.finditer(r"^\s*-\s*(.+?)\s+#card\b", text, flags=re.M):
            fronts.add(normalize_key(match.group(1)))
        for match in re.finditer(r"^\s*-\s*(.+?)\s+\[\[card\]\]", text, flags=re.M):
            fronts.add(normalize_key(match.group(1)))
    return fronts


def collect_candidates(pages_dir: Path, output_path: Path) -> list[Candidate]:
    candidates: list[Candidate] = []
    for path in sorted(pages_dir.glob("*.md")):
        if path.name in EXCLUDED_PAGES or path.resolve() == output_path:
            continue
        text = safe_read(path)
        page_title = page_title_from_text(path, text)
        topic = classify_page(page_title, text)
        for excerpt, score in extract_candidate_lines(text):
            if len(excerpt) < 24:
                continue
            candidates.append(
                Candidate(
                    page_title=page_title,
                    page_path=path,
                    topic=topic,
                    excerpt=excerpt,
                    score=score,
                )
            )
    candidates.sort(key=lambda c: (-priority_rank(c.topic), -c.score, c.page_title, c.excerpt))
    return candidates


def page_title_from_text(path: Path, text: str) -> str:
    match = re.search(r"^title:\s*(.+)$", text, flags=re.M)
    if match:
        return match.group(1).strip()
    return path.stem


def classify_page(title: str, text: str) -> str:
    haystack = f"{title}\n{extract_tag_text(text)}".lower()
    if any(re.search(pattern, haystack) for pattern in AI_PATTERNS):
        return "ai"
    if any(re.search(pattern, haystack) for pattern in LEADERSHIP_PATTERNS):
        return "leadership"
    return "other"


def extract_tag_text(text: str) -> str:
    tags: list[str] = []
    for match in re.finditer(r"^(?:tags::|- tags::)\s*(.+)$", text, flags=re.M | re.I):
        tags.append(match.group(1))
    return " ".join(tags)


def priority_rank(topic: str) -> int:
    return {"ai": 3, "leadership": 2, "other": 1}.get(topic, 0)


def extract_candidate_lines(text: str) -> Iterator[tuple[str, int]]:
    body = strip_frontmatter(text)
    for raw_line in body.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        if is_noise(line):
            continue
        excerpt = collapse_whitespace(strip_bullet(line))
        if is_noise(excerpt):
            continue
        score = score_line(excerpt)
        if score <= 0:
            continue
        yield excerpt, score


def strip_frontmatter(text: str) -> str:
    if not text.startswith("---"):
        return text
    parts = text.split("\n---\n", 1)
    if len(parts) == 2:
        return parts[1]
    return text


def is_noise(line: str) -> bool:
    lowered = line.lower()
    if lowered.startswith("tags::"):
        return True
    if lowered.startswith("- tags::"):
        return True
    if lowered.startswith("title:"):
        return True
    if lowered.startswith("- title:"):
        return True
    if lowered.startswith("card-"):
        return True
    if lowered.startswith("source-page::"):
        return True
    if lowered.startswith("source-excerpt::"):
        return True
    if lowered.startswith("- source-page::"):
        return True
    if lowered.startswith("- source-excerpt::"):
        return True
    if lowered.startswith("http://") or lowered.startswith("https://"):
        return True
    if lowered.startswith("![](") or lowered.startswith("!["):
        return True
    if lowered.startswith("- todo"):
        return True
    if lowered == "-" or lowered == "--":
        return True
    return False


def strip_bullet(line: str) -> str:
    return re.sub(r"^\s*[-*]\s+", "", line).strip()


def score_line(line: str) -> int:
    score = 0
    lowered = line.lower()
    if any(token in lowered for token in (" is ", " are ", " means ", " should ", " can ", " why ", " how ", " because ")):
        score += 3
    if re.search(r"^\*\*[^*]+\*\*", line) or re.search(r"^[A-Z][A-Za-z0-9 /&-]{3,40}[:\-]", line):
        score += 2
    if 30 <= len(line) <= 220:
        score += 2
    if 12 <= len(line) <= 280:
        score += 1
    if "#" in line and "#card" not in lowered:
        score += 1
    if "TODO" in line:
        score -= 4
    if re.search(r"https?://", line):
        score -= 2
    return score


def pick_candidates(candidates: list[Candidate], plan: list[str], count: int) -> list[Candidate]:
    chosen: list[Candidate] = []
    used: set[str] = set()

    buckets = {
        "ai": [c for c in candidates if c.topic == "ai"],
        "leadership": [c for c in candidates if c.topic == "leadership"],
        "other": [c for c in candidates if c.topic == "other"],
    }

    # First satisfy the priority plan.
    for topic in plan:
        cand = next((c for c in buckets[topic] if fingerprint(c) not in used), None)
        if cand is None:
            continue
        chosen.append(cand)
        used.add(fingerprint(cand))

    # Then backfill from the highest-priority remaining buckets.
    if len(chosen) < count:
        for topic in ("ai", "leadership", "other"):
            for cand in buckets[topic]:
                if len(chosen) >= count:
                    break
                fp = fingerprint(cand)
                if fp in used:
                    continue
                chosen.append(cand)
                used.add(fp)

    return chosen[:count]


def fingerprint(candidate: Candidate) -> str:
    return normalize_key(candidate.page_title + "\n" + candidate.excerpt)


def generate_with_openai(selected: list[Candidate], model: str) -> list[dict[str, str]]:
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        return generate_with_heuristics(selected)

    prompt = build_prompt(selected)
    schema = {
        "type": "object",
        "additionalProperties": False,
        "properties": {
            "cards": {
                "type": "array",
                "minItems": 1,
                "maxItems": len(selected),
                "items": {
                    "type": "object",
                    "additionalProperties": False,
                    "properties": {
                        "topic": {
                            "type": "string",
                            "enum": ["AI and Agents", "Leadership and Management", "Other"],
                        },
                        "front": {"type": "string"},
                        "back": {"type": "string"},
                        "source_page": {"type": "string"},
                        "source_excerpt": {"type": "string"},
                    },
                    "required": ["topic", "front", "back", "source_page", "source_excerpt"],
                },
            }
        },
        "required": ["cards"],
    }
    payload = {
        "model": model,
        "input": [
            {
                "role": "system",
                "content": [
                    {
                        "type": "input_text",
                        "text": (
                            "Generate concise Logseq flashcards from the provided source snippets. "
                            "Use the priority order AI and Agents, then Leadership and Management, then Other. "
                            "Return only valid JSON that matches the schema. "
                            "Make each front a good active-recall question and keep each back short and grounded in the snippet. "
                            "Avoid duplicates and avoid copying source text verbatim when a better question/answer pair is possible."
                        ),
                    }
                ],
            },
            {"role": "user", "content": [{"type": "input_text", "text": prompt}]},
        ],
        "text": {
            "format": {
                "type": "json_schema",
                "name": "flashcard_batch",
                "strict": True,
                "schema": schema,
            }
        },
        "max_output_tokens": 3000,
    }
    request = urllib.request.Request(
        "https://api.openai.com/v1/responses",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            body = json.loads(response.read().decode("utf-8"))
    except urllib.error.URLError as exc:
        print(f"OpenAI request failed, falling back to heuristics: {exc}", file=sys.stderr)
        return generate_with_heuristics(selected)

    text = extract_response_text(body)
    if not text:
        print("OpenAI response had no text output, falling back to heuristics.", file=sys.stderr)
        return generate_with_heuristics(selected)

    try:
        parsed = json.loads(text)
    except json.JSONDecodeError as exc:
        print(f"Could not parse OpenAI JSON output, falling back to heuristics: {exc}", file=sys.stderr)
        return generate_with_heuristics(selected)
    cards = parsed.get("cards", [])
    return [normalize_card(card) for card in cards]


def build_prompt(selected: list[Candidate]) -> str:
    lines = [
        "Create one flashcard per source snippet.",
        "Keep questions concrete and answers short.",
        "Use the source page name as provided.",
        "Do not invent facts outside the snippet.",
        "",
        "Source snippets:",
    ]
    for i, cand in enumerate(selected, 1):
        topic_label = {
            "ai": "AI and Agents",
            "leadership": "Leadership and Management",
            "other": "Other",
        }.get(cand.topic, "Other")
        lines.append(f"{i}. [{topic_label}] {cand.page_title}: {cand.excerpt}")
    return "\n".join(lines)


def extract_response_text(body: dict) -> str:
    if isinstance(body, dict) and isinstance(body.get("output_text"), str):
        return body["output_text"].strip()

    output = body.get("output", [])
    chunks: list[str] = []
    for item in output:
        if item.get("type") != "message":
            continue
        for content in item.get("content", []):
            if content.get("type") in {"output_text", "text"} and isinstance(content.get("text"), str):
                chunks.append(content["text"])
    return "".join(chunks).strip()


def generate_with_heuristics(selected: list[Candidate]) -> list[dict[str, str]]:
    cards: list[dict[str, str]] = []
    for cand in selected:
        front, back = make_qa_from_excerpt(cand)
        cards.append(
            {
                "topic": topic_label(cand.topic),
                "front": front,
                "back": back,
                "source_page": cand.page_title,
                "source_excerpt": cand.excerpt,
            }
        )
    return cards


def make_qa_from_excerpt(candidate: Candidate) -> tuple[str, str]:
    text = de_markdown(candidate.excerpt).rstrip(".")
    lowered = text.lower()
    if lowered.startswith("the "):
        subject = text[4:].split(" is ", 1)[0].split(" are ", 1)[0]
        return (f"What is {subject}?", text)
    if " is " in text:
        left, right = text.split(" is ", 1)
        return (f"What is {left.strip()}?", f"{left.strip()} is {right.strip()}.")
    if " are " in text:
        left, right = text.split(" are ", 1)
        return (f"What are {left.strip()}?", f"{left.strip()} are {right.strip()}.")
    if ":" in text:
        left, right = text.split(":", 1)
        return (f"What does {left.strip()} refer to?", right.strip().capitalize() + ".")
    return (f"What does this note say about {candidate.page_title}?", text + ".")


def de_markdown(text: str) -> str:
    text = re.sub(r"\[\[([^\]]+)\]\]", r"\1", text)
    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r"\1", text)
    text = text.replace("**", "")
    text = text.replace("__", "")
    text = re.sub(r"(?<!\w)#([A-Za-z][\w-]+)", r"\1", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def normalize_card(card: dict[str, str]) -> dict[str, str]:
    return {
        "topic": card.get("topic", "Other").strip() or "Other",
        "front": card.get("front", "").strip(),
        "back": card.get("back", "").strip(),
        "source_page": card.get("source_page", "").strip(),
        "source_excerpt": card.get("source_excerpt", "").strip(),
    }


def dedupe_cards(cards: list[dict[str, str]], existing_fronts: set[str]) -> list[dict[str, str]]:
    seen = set(existing_fronts)
    deduped: list[dict[str, str]] = []
    for card in cards:
        front_key = normalize_key(card["front"])
        if not front_key or front_key in seen:
            continue
        seen.add(front_key)
        deduped.append(card)
    return deduped


def render_output(cards: list[dict[str, str]]) -> str:
    today = dt.date.today().isoformat()
    lines = [
        "---",
        "title: Flashcards Inbox",
        "---",
        "",
        "- Tags:: #TODO #[[Logseq]] #[[Flashcards]]",
        f"- Generated:: {today}",
        "  - Daily batch",
    ]
    for card in cards:
        topic = topic_label_slug(card["topic"])
        lines.extend(
            [
                f"    - {card['front']} #card #[[{topic}]]",
                f"      source-page:: [[{card['source_page']}]]" if card["source_page"] else "      source-page::",
                f"      source-excerpt:: {card['source_excerpt']}" if card["source_excerpt"] else "      source-excerpt::",
                f"      - {card['back']}",
            ]
        )
    lines.append("")
    return "\n".join(lines)


def topic_label(topic: str) -> str:
    return {
        "ai": "AI and Agents",
        "leadership": "Leadership and Management",
        "other": "Other",
    }.get(topic, "Other")


def topic_label_slug(topic_label_value: str) -> str:
    return topic_label_value


def write_output(path: Path, markdown: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(markdown, encoding="utf-8")


def safe_read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text(encoding="utf-8", errors="ignore")


def collapse_whitespace(text: str) -> str:
    text = text.strip()
    text = re.sub(r"\s+", " ", text)
    return text


def normalize_key(text: str) -> str:
    return collapse_whitespace(text).lower()


def normalize_text(text: str) -> str:
    return collapse_whitespace(text)


if __name__ == "__main__":
    raise SystemExit(main())
