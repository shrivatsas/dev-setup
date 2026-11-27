# Advisory — <project name> — <YYYY-MM-DD>

> This is advice, not a decision. Each verdict is a recommendation for the architect. Adopting one is a decision and gets a record through `cartograph-decide`.

**Prompted by:** <the change or question that started this evaluation>
**Walked with:** <architect name(s)> · **Principles:** PRINCIPLES.md approved <date>

## Summary

| Area | Verdict | Confidence | Why, in one line |
|---|---|---|---|
| <area-id> | Leave alone / Wrap / Strangle / Replace | high / medium / low | <reason> |

## <Area title> (`<area-id>`)

**Verdict:** <verdict> · **Confidence:** <level>

### What we saw
- <observation> — <file / table / config> — confirmed by <name> / unconfirmed

### Signals

| Signal | Reading | Evidence |
|---|---|---|
| Blast radius | low / medium / high | <dependents, external consumers, inherited one-way doors> |
| Change pressure | low / medium / high | <churn, on path?> |
| Test seams | none / partial / good | <where tests are, where a seam could go> |
| Unknowns | <count, blocking ones> | <A-ids> |

### Principles fit
- **<principle> (<weight>)** — passes / fails: <evidence>

### Why this verdict and not the next one
<One paragraph. Name the more reversible verdict you rejected and why, or the less reversible one and why it isn't justified yet.>

### First decision if adopted
<e.g. where the seam goes and what contract it exposes — becomes D-<area-id>-NNN through cartograph-decide>

### What would change this verdict
- <evidence or event>

### To raise confidence
- <check, who to ask> (required for medium and low)

## Unconfirmed inherited records
- <D-id>: <title> — <what needs confirming, and by whom>
