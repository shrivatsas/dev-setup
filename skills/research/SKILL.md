---
name: research
description: Conduct preliminary research, generate a research outline, and produce concise, evidence-first results for comparisons, benchmarks, technology selection, and topic scans.
---

# Research

Use this skill when the user wants structured research, an outline, or a research report.

## Response Style

- Lead with the conclusion or most useful finding.
- Keep prose short and direct.
- Prefer concrete evidence, dates, names, and sources over abstract commentary.
- Separate facts, inferences, and assumptions.
- Avoid hedging unless uncertainty is real and important.

## Trigger

`/research <topic>`

## Workflow

### Step 1: Build an initial framework

Use model knowledge to draft:
- Main research objects or items in the domain
- A proposed field framework

Then ask the user to confirm:
- items to add or remove
- whether the field framework is sufficient

### Step 2: Supplement with web research

Ask the user for a time range, for example:
- last 6 months
- since 2024
- unlimited

Use this template exactly, replacing only the variables:

```python
prompt = f"""## Task
Research topic: {topic}
Current date: {YYYY-MM-DD}

Based on the following initial framework, supplement latest items and recommended research fields.

## Existing Framework
{step1_output}

## Goals
1. Verify if existing items are missing important objects
2. Supplement items based on missing objects
3. Continue searching for {topic} related items within {time_range} and supplement
4. Supplement new fields

## Output Requirements
Return structured results directly (do not write files):

### Supplementary Items
- item_name: Brief explanation (why it should be added)
...

### Recommended Supplementary Fields
- field_name: Field description (why this dimension is needed)
...

### Sources
- [Source1](url1)
- [Source2](url2)
"""
```

### Step 3: Check for existing field definitions

Ask whether the user already has a field definition file.

If yes, read it and merge it with the research outputs.

### Step 4: Generate outline files

Combine:
- the initial framework
- the web research supplement
- any existing field definitions

Create these files:

- `outline.yaml`
- `fields.yaml`

`outline.yaml` should include:
- `topic`
- `items`
- `execution.batch_size`
- `execution.items_per_agent`
- `execution.output_dir`

`fields.yaml` should include:
- field categories and definitions
- each field's name, description, and `detail_level`
- `detail_level` hierarchy: `brief` -> `moderate` -> `detailed`
- `uncertain` fields reserved for the deep phase

### Step 5: Show results

Create `./{topic_slug}/` and save:
- `outline.yaml`
- `fields.yaml`

Show the generated files to the user for confirmation.

## Follow-up Commands

- `/research-add-items` - supplement items
- `/research-add-fields` - supplement fields
- `/research-deep` - start deep research
