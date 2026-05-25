---
name: logseq-flashcards
description: Work with Logseq flashcards in file-based graphs. Use when the user asks how to create, inspect, normalize, bulk-edit, or validate Logseq flashcards or cloze cards in Markdown or Org files, especially when they want a plain-files workflow, need to understand which parts are stored in note files, or want to script or curate card content outside the Logseq UI.
---

# Logseq Flashcards

## Scope

This skill is for file-based Logseq graphs where cards are stored in Markdown or Org files and Logseq indexes them.

Use it for:
- Explaining Logseq card syntax
- Creating or bulk-editing cards directly in files
- Converting existing notes into cards
- Validating whether a PKM already contains cards
- Explaining what review metadata Logseq writes back into files
- Generating a daily batch of new cards from existing content

Do not assume DB-graph behavior applies to file graphs.

## Core Model

For file graphs, treat a standard flashcard as:

```md
- Question text #card
  - Answer text
```

The block with `#card` or `[[card]]` is the front.
Its child blocks are the back.

Equivalent form:

```md
- Question text [[card]]
  - Answer text
```

Prefer the local convention already present in the graph. If none exists, default to `#card`.

## Cloze Cards

Logseq also supports cloze-style cards in note text:

```md
- The capital of France is {{cloze Paris}}.
```

Practical rules:
- Keep a literal space before `{{cloze ...}}` when embedding it in text.
- Prefer single-line cloze content.
- Do not assume Anki-style numbered clozes such as `{{c1::...}}` work in Logseq.
- If clozes are being generated programmatically, validate in Logseq after writing them.

## File-Only vs UI

Card authoring is file-native. Review is not purely file-native.

You can do these exclusively by editing files:
- Create cards
- Edit prompts and answers
- Tag cards for topic filtering
- Move cards across pages
- Bulk-convert note blocks into cards

Logseq typically handles these via the app UI:
- Reviewing due cards
- Rating recall
- Updating spaced-repetition state

When cards have been reviewed, Logseq may write card properties back into the file, such as:
- `card-last-interval::`
- `card-repeats::`
- `card-ease-factor::`
- `card-next-schedule::`
- `card-last-reviewed::`
- `card-last-score::`

Treat those as app-managed state. Do not fabricate or rewrite them unless the user explicitly wants a migration or repair.

## Filtering And Grouping

Cards can be tagged and reviewed in subsets.

Example:

```md
- Binary search runs in what time? #card #algorithms
  - O(log n)

- {{cards [[algorithms]]}}
```

Use semantic topic tags on the card block itself when the user wants grouped review.

## Editing Rules

When editing existing Logseq files:
- Preserve indentation and bullet structure exactly.
- Preserve `id::`, `collapsed::`, and unrelated properties.
- Do not strip existing review metadata unless the user asks.
- When templated cards were copied from old reviewed cards, remove copied review metadata only if the user wants those copies treated as new cards.

## Conversion Patterns

Convert plain note material into cards only when the prompt/answer boundary is clear.

Good conversion:

```md
- What does CAP stand for? #card
  - Consistency, Availability, Partition tolerance
```

Good conversion from definition note:

```md
- CAP theorem #distributed-systems
  - What are the three tradeoffs in CAP? #card
    - Consistency, Availability, Partition tolerance
```

Avoid making weak cards that only restate headings without a discriminating answer.

## Validation

Use targeted searches before and after edits.

Find likely cards:

```bash
rg -n '#card|\\[\\[card\\]\\]|\\{\\{cloze ' pages journals
```

Find cards with review metadata:

```bash
rg -n 'card-(last-interval|repeats|ease-factor|next-schedule|last-reviewed|last-score)::' pages journals
```

Find possible copied review state after template expansion:

```bash
rg -n 'card-next-schedule::|card-last-reviewed::' pages journals
```

When adding new cards, verify:
- The card marker is on the intended front block
- The answer is nested as child content for standard cards
- Topic tags are on the card block, not only on parent headings, when filtered review is expected
- Cloze syntax is literal and not transformed into another templating format

## Response Pattern

When helping a user:
1. State whether they are asking about file graphs or DB graphs if that matters.
2. Explain the simplest valid card syntax first.
3. Separate authoring syntax from review-state behavior.
4. If they want automation, prefer editing the Markdown files and let Logseq re-index.
5. If they want a migration or cleanup, search the graph and operate mechanically.

## Daily Generation

Use `scripts/daily_flashcards.py` to generate a new batch of cards from the existing graph.

Default behavior:
- Pulls from `pages/` content
- Prioritizes `AI and Agents`, then `Leadership and Management`, then everything else
- Produces 10 additional cards by default
- Appends them to `pages/Flashcards Inbox.md`
- Skips duplicate fronts already present in the graph

Recommended workflow:
1. Run the script once per day.
2. Open `Flashcards Inbox` in Logseq.
3. Review the new cards in the UI.
4. Keep the source notes untouched unless you want to refine the underlying material.

Environment:
- Set `OPENAI_API_KEY` for the normal generator path.
- Override `OPENAI_MODEL` if you want a different model.
- Use `--provider heuristic` when you want a local fallback without an API call.
