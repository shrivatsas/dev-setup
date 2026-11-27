---
name: cartograph-review
description: Review a diff, pull request, spec or plan on the Principles axis — does it honour the project's PRINCIPLES.md and the accepted decisions of the map areas it touches, and does it sneak in undocumented one-way doors? Use whenever reviewing changes or plans in a project that has a Cartograph map, alongside any standards or spec review, and before merging work that touches persisted data, public contracts, permissions or external integrations.
---

# Principles review

This is the third review axis. Standards review asks "is it well written?", spec review asks "does it do what was asked?"; this asks "does it fit the design we agreed, and does it create new commitments nobody approved?" Run it independently of the other two so the findings don't blur.

## 1. Locate the context

Find the map (pointer in AGENTS.md / CLAUDE.md). Work out which areas the change touches. Load PRINCIPLES.md (with those areas' overrides), GLOSSARY.md, and the accepted decisions in those areas.

## 2. Check, in priority order

1. **Undocumented one-way doors.** New or changed persisted schemas, public or cross-team contracts, event formats, permission rules, external dependencies or vendors, money movement. Each needs a decision record. Missing record → blocking finding.
   In an existing system, if the change touches a commitment that was already there, the missing record is an inherited one: a **Should fix** to record it, not Blocking. A change that *alters* an inherited commitment without a superseding decision is Blocking.
2. **Contradicted decisions.** The change goes against an accepted decision. Either the change is wrong or the decision is stale: say which seems more likely and, if stale, recommend marking the cell `contested`.
3. **Weighted principles.** Ask each shortlisted principle's question of the change, highest weight first. Report only where the answer is concerning.
4. **Language.** Names that don't match the glossary, or new domain terms that should be added.
5. **Assumptions.** The change relies on an open assumption, or would break one.

## 3. Report

Group findings as **Blocking**, **Should fix** and **Note**. For each: the file or section, the principle or decision involved, what's wrong, and the smallest fix. Then list map updates the change implies (cells to contest, decisions to record, glossary terms to add) so they can be applied through `cartograph-map`. Keep it short; an empty section is fine.
