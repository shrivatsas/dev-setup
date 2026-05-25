---
name: pkm-curation
description: Curate links, reading lists, TODO notes, topic maps, media links, and resource queues in a personal knowledge base, especially Logseq-style Markdown pages. Use when the user asks to add links, title/describe raw URLs, dereference shortlinks, remove noisy generated titles, dedupe entries, place links semantically near related notes, normalize YouTube/X/social links, organize a topic hierarchy, normalize tags across related pages, or maintain pages such as TODO.md in a PKM.
---

# PKM Curation

## Expectations

Treat the PKM as a living map, not a dumping ground. Preserve useful user context, reduce future lookup friction, and make links discoverable by topic, creator, and intent.

Prefer small, reviewable edits when the user asks for staged work. For bulk curation, keep changes mechanical and validate with searches before finishing.

## Workflow

1. Locate the target note.
   - Default to `pages/TODO.md` only when the user refers to TODO or link backlog work.
   - For topic selection, entropy questions, or previously curated clusters, check `pages/PKM Metadata.md` first when it exists.
   - Use `rg --files` and `rg` before broad directory listing.

2. Understand local conventions.
   - Inspect nearby lines before editing.
   - Preserve indentation, Logseq bullets, `collapsed:: true`, `id::`, and existing tags.
   - Prefer Markdown links: `[Readable Title](https://example.com)`.
   - Prefer Logseq tags already used in the repository: `#[[Multi Word Topic]]` or `#SingleWord`.
   - In Logseq PKMs, prefer a flat `pages/` note space. Treat nested folders under `pages/` as imports or cleanup candidates, not the desired long-term structure.
   - Keep `pages/` Markdown-only when possible. Move PDFs, decks, app configs, and other non-note files to `assets/` or another archive/import area, then link to them from notes.

3. Normalize link titles.
   - Replace raw URLs and URL-as-title labels with readable titles.
   - Replace Logseq media/embed macros with Markdown links. Use `[X post by handle](https://x.com/handle/status/...)` for `{{twitter ...}}`. For `{{video ...}}`, `{{youtube ...}}`, raw YouTube URLs, and generic labels like `YouTube video`, use the resolved video/playlist title when possible, e.g. `[Readable Talk Title](https://youtube...)`.
   - Remove tracking hash suffixes and generated IDs from titles, while preserving the original URL.
   - Keep acronym casing correct: AI, LLM, RAG, MCP, SQL, dbt, API, APIs, HTTP, JSON, XML, SSO, CSS, AWS, DynamoDB, GitHub, OpenAI, DuckDB, PySpark, YAML, DSL.
   - Dereference shortlinks such as `t.co` when possible. If blocked, say so and use a temporary source label.
   - For YouTube, prefer oEmbed or page metadata to recover the real title. If title lookup is blocked, use nearby context or the page title as a conservative label; for channel URLs, use `Creator YouTube channel` rather than pretending it is a video.

4. Place links semantically.
   - Add new links near an existing cluster when one is obvious: e.g. LLM evals under eval material, data lineage under data governance/quality, agent posts under LLM engineering/agent sections.
   - If no cluster exists, create a concise heading or place in the closest topical area rather than appending blindly.
   - Dedupe exact repeated URLs unless the user explicitly wants duplicates.
   - The source channel, media type, or inbox type is not the destination. Avoid keeping generic pages or buckets such as `Videos / presentations`, `Social Media Posts`, `Twitter`, `LinkedIn`, or similar format buckets as long-term homes when a semantic topic page is available.
   - Resolve social and video links into the most relevant topic page whenever the meaning is clear; use creator/source/media grouping only as a temporary holding area for links whose topic cannot yet be inferred.

5. Tag links.
   - Add topic tags when the title, surrounding heading, or resolved target gives enough evidence.
   - For opaque X/Twitter/social posts, tag by creator handle when the content cannot be inferred.
   - Do not add generic media tags such as `#Video` merely because a link points to YouTube or another video host. Prefer semantic page placement and topic tags such as `#[[RAG]]`, `#[[SQLMesh]]`, or `#[[Compliance]]`.
   - For unresolved or opaque links, use the best source-style label and avoid overclaiming.

6. Move backlog items into topic pages when asked.
   - Treat `TODO.md` as an inbox, not the final home for well-classified links.
   - Build an inventory of tagged link entries, ignoring pseudo-tags inside URL fragments.
   - Map entries to existing `pages/*.md` files by strong semantic tags, not creator-only tags or media format. Prefer exact or near-exact topic pages such as `AI Agent.md`, `Agentic Search.md`, `Data Lineage.md`, `Data Governance.md`, `Deep Learning.md`, `Python.md`, `Leadership.md`, `Database design.md`, `Distributed Systems.md`, `Machine Learning.md`, `Observability.md`, `SQLMesh.md`, `RAG.md`, `LLMOps.md`, and `AI Evals for Engineers & PMs.md`.
   - Do not create new topic pages unless the user asks or the task explicitly requires semantic placement and the target topic is already referenced as a wiki link/backlog group. Leave entries in `TODO.md` when no clear destination exists.
   - Append moved items under a `- TODO links` bullet in the destination page. Preserve the original link and useful semantic tags; drop purely generic media tags.
   - Remove moved entries from `TODO.md` only after confirming the destination page exists and does not already contain the URL.
   - Group remaining tagged TODO entries under `- Tagged backlog` with `collapsed:: true`, using the strongest semantic tag as the group. Put opaque creator-only social posts under a temporary creator/social group rather than scattering them into weak topic pages.
   - For old numbered or format buckets, dedupe URLs already present in topic pages. Move unique leftovers into `TODO.md` under tagged backlog groups before deleting the bucket. For video/presentation buckets, move clearly topical videos to topic pages first; keep only ambiguous event/recording/presentation links in a temporary media bucket.
   - When cleaning old social/channel buckets, move semantically clear links into topic pages and delete the generic bucket instead of renaming it into another long-term format page.
   - Treat `CatchAll*.md`, inbox dumps, and other generic catchall files as import buckets. Move or merge their contents into semantic pages, delete exact duplicates, and avoid leaving a catchall page in active `pages/`.
   - Do not delete pages that contain substantial non-link personal notes. Rename them to a clean semantic name and preserve the notes.
   - For personal-note cleanup, keep reflections, private planning, and personal document links in the personal page. Move only obvious reusable resource links to existing topic pages, and remove duplicates only after confirming the URL already exists elsewhere.

7. Audit `assets/` when asked.
   - Treat `assets/` as the home for non-Markdown support files such as PDFs, images, decks, imports, and app-specific files.
   - When asked to audit assets, compare files under `assets/` against references from Markdown files under `pages/`.
   - Maintain a review note such as `pages/Unlinked Assets.md` for files in `assets/` that are not referenced from any page.
   - Prefer recording unlinked assets as a backlog for later triage rather than deleting them immediately.
   - For each unlinked asset, the later action should usually be one of: link from an existing topic page, move to a deeper archive/import area, or delete.

8. Analyze and organize a topic cluster when asked.
   - Start read-only unless the user has already approved action.
   - If `pages/PKM Metadata.md` exists, read the relevant cluster entries first to avoid rescanning the whole PKM.
   - Search by filename and body text. Use broad synonyms and related terms, then prune false positives.
   - Inspect each candidate page's title, `Tags::` line, backlinks, outgoing wiki links, and first meaningful bullets.
   - Classify pages into a small hierarchy: hub/root page, core concept pages, method pages, domain/context pages, adjacent/bridge pages, and false positives.
   - Prefer improving an existing topic page as the hub over creating a new page.
   - Present the proposed hierarchy and tag changes before editing when the user asks for approval first.
   - When approved, update the hub with navigational sections that link to child pages, preserve existing resources, and move loose links only when the destination is clearly better.
   - For dense hub pages, first convert the hub into a short map with only residual cross-cutting notes. Move coherent resource blocks into existing child pages or narrowly named child pages when the hub explicitly lists that child and no page exists yet.
   - Normalize equivalent tags across the cluster, but preserve useful secondary tags such as `#Article`, `#Course`, `#Project`, creator tags, and domain tags.
   - Keep adjacent branches linked but distinct when they have a different center of gravity, such as LLM evals adjacent to software testing or observability adjacent to production testing.
   - Update `pages/PKM Metadata.md` after major topic work with the hub, children, adjacent pages, entropy level, signals, and next action.

## Link Intake Heuristics

Use these defaults unless local context suggests better tags:

- AI agents: `#[[AI Agent]]`, `#[[Agentic Workflow]]`, `#[[LLM Engineering]]`
- Agentic search: `#[[Agentic Search]]`, `#[[AI Agent]]`
- LLM evals: `#[[LLM Evals]]`, `#[[Evaluation]]`
- Context engineering: `#[[Context Engineering]]`, `#[[LLM Engineering]]`
- AI coding: `#[[AI Coding]]`, `#[[Software Engineering]]`
- Data lineage / quality: `#[[Data Lineage]]`, `#[[Data Quality]]`, `#[[Data Governance]]`
- Query engines: `#[[Query Engine]]`, plus specific technology tags like `#[[DataFusion]]`, `#[[DuckDB]]`, or `#[[SQLMesh]]`
- Leadership/executive material: `#[[Leadership]]`, `#[[Executive]]`, `#[[Engineering Management]]`

## Topic Cluster Heuristics

Use these defaults unless local context suggests better grouping:

- Hub pages should be short navigational maps with stable sections and links to child notes.
- Concept pages hold definitions, distinctions, and evergreen references.
- Article/course/video pages keep source metadata and summaries, then link back to the relevant concept page through tags or wiki links.
- Duplicate-looking pages should usually be linked or staged for merge, not deleted, unless the user explicitly approves deletion.
- Numbered category pages such as `02_Data_Engineering_Analytics.md` should be renamed to clean semantic names when there is no collision, then old wiki links should be rewritten.
- Generic catchall pages should not be treated as durable categories. Split them by strongest topic signal; if a block is broad personal reflection rather than reusable reference material, preserve it in a clearly named personal-learning or personal-notes page instead of forcing weak topical placement.
- When singular/plural or alias-like pages coexist, pick the page with the clearest hub semantics as canonical and convert the weaker page into a lightweight pointer unless a real content split is needed.
- When a curated hub links to a missing child page and existing resources already use that topic as a tag, create a lightweight semantic child page and move the relevant resources there instead of leaving dangling hub links.
- Flatten copied-in note folders under `pages/` into canonical top-level page names unless the user explicitly wants a different structure.
- If nested directories remain only because they contain non-Markdown files, move those files to `assets/` or another non-note area so `pages/` stays flat and note-oriented.
- Filename matches are only candidates. Exclude pages where the matched word belongs to another domain, such as `Property graph` when organizing testing.
- Normalize `#Topic` and `#[[Topic]]` toward the local convention already dominant for that topic; for multi-word topics prefer `#[[Multi Word Topic]]`.
- For cross-cutting topics, use two-tier grouping: the main topic tag plus a domain tag, e.g. `#[[Testing]] #[[Distributed Systems]]`, `#[[Testing]] #[[Performance Testing]]`, or `#[[Evals]] #[[LLM Evals]]`.

## Metadata Heuristics

Maintain `pages/PKM Metadata.md` as a compact index for future low-token decisions:

- One top-level bullet per curated hub or high-entropy cluster.
- Use Logseq properties: `pkm_type::`, `pkm_status::`, `pkm_last_curated::`, `pkm_children::`, `pkm_adjacent::`, `pkm_entropy::`, `pkm_signals::`, and `pkm_next_action::`.
- Keep entries short and operational. The metadata should answer "what is this cluster, how messy is it, and what should happen next?"
- Record old names after renames in `pkm_signals::` so future backlink cleanup can explain why names changed.
- Prefer updating metadata over embedding long analysis summaries in chat.

## Validation

Before finishing, run targeted checks relevant to the edit:

```bash
rg -n 'https?://' pages/TODO.md
rg -n '\[https?://' pages/TODO.md
rg -n 't\.co|Unclassified|P [0-9]+|C [0-9]+|Activity [0-9]+|[0-9a-f]{8,}' pages/TODO.md
```

For move operations, verify each moved URL is present in its destination page and absent from `TODO.md`. Also check that tagged link entries outside `Tagged backlog` are intentional:

```bash
python3 - <<'PY'
from pathlib import Path
import re
text = Path('pages/TODO.md').read_text()
in_section = False
outside = []
for n, line in enumerate(text.splitlines(), 1):
    if line.strip() == '- Tagged backlog':
        in_section = True
    elif in_section and line.startswith('- ') and line.strip() != '-':
        in_section = False
    clean = re.sub(r'\([^)]*\)', '', line)
    if not in_section and 'http' in line and re.search(r'#[A-Za-z]|#\[\[', clean):
        outside.append((n, line))
print(f'tagged_link_lines_outside_group={len(outside)}')
for n, line in outside:
    print(f'{n}: {line}')
PY
```

For social tagging, verify relevant opaque social lines still have a useful semantic or creator tag:

```bash
python3 - <<'PY'
from pathlib import Path
from urllib.parse import urlparse
import re
hosts = {'x.com','twitter.com','mobile.twitter.com','t.co'}
missing = []
for n, line in enumerate(Path('pages/TODO.md').read_text().splitlines(), 1):
    urls = re.findall(r'\((https?://[^)]+)\)', line)
    if any(urlparse(u).netloc.lower() in hosts for u in urls):
        clean = re.sub(r'\([^)]*\)', '', line)
        if not re.search(r'#[A-Za-z]|#\[\[', clean):
            missing.append((n, line))
print(f'missing_social_tags={len(missing)}')
for n, line in missing:
    print(f'{n}: {line}')
PY
```

For YouTube/media cleanup, verify titles and placement instead of adding generic media tags:

```bash
python3 - <<'PY'
from pathlib import Path
import re
generic = []
raw = []
generic_tags = []
todo_youtube = []
for p in Path('pages').glob('*.md'):
    for n, line in enumerate(p.read_text(errors='ignore').splitlines(), 1):
        if re.search(r'(?<!s)#Video\b', line):
            generic_tags.append((p, n, line))
        if re.search(r'\[(YouTube video|YouTube playlist|YouTube short)\]', line):
            generic.append((p, n, line))
        if re.match(r'\s*-?\s*https?://(?:www\.)?(?:youtube\.com|youtu\.be)', line.strip()):
            if line.strip().rstrip('/') not in {'https://youtube.com','https://www.youtube.com'}:
                raw.append((p, n, line))
        if p.name == 'TODO.md' and ('youtube.com' in line or 'youtu.be' in line):
            todo_youtube.append((p, n, line))
print(f'generic_video_tags={len(generic_tags)}')
print(f'generic_youtube_titles={len(generic)}')
print(f'raw_youtube_lines={len(raw)}')
print(f'todo_youtube_lines={len(todo_youtube)}')
for group in (generic_tags, generic, raw, todo_youtube):
    for p, n, line in group[:20]:
        print(f'{p}:{n}: {line}')
PY
```

For asset audits, verify the count of unlinked files and keep the tracker note current:

```bash
python3 - <<'PY'
from pathlib import Path
import re
pkm = Path('.')
assets = pkm / 'assets'
pages = pkm / 'pages'
refs = set()
names = set()
patterns = [
    re.compile(r'\.\./assets/([^\)\]\s]+)'),
    re.compile(r'\(\.{0,2}/?assets/([^\)]+)\)'),
    re.compile(r'file-path::\s+\.\./assets/(\S+)'),
]
for md in pages.rglob('*.md'):
    text = md.read_text(errors='ignore')
    for pat in patterns:
        for m in pat.findall(text):
            refs.add(m.strip())
            names.add(Path(m.strip()).name)
unused = []
for f in assets.rglob('*'):
    if f.is_file() and str(f.relative_to(assets)) not in refs and f.name not in names:
        unused.append(str(f.relative_to(assets)))
print(f'unlinked_assets={len(unused)}')
for item in unused:
    print(item)
PY
```

## Reporting

Summarize the actual edits, not the entire note. Include counts or validation output when useful. Mention any intentionally unresolved links and why.
