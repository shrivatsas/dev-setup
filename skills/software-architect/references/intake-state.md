# Running Intake State

Use this file as the single source of truth for the conversation.

## File path

`./architect-intake.md`

## Update rule

After each user reply, append or revise only the sections that changed. Keep the file compact and current.

## Compact update format

Use short bullet updates only:

```md
- business outcome: ...
- current state: ...
- constraint: ...
- question: ...
- gate e2e_requirement_clear: yes/no
- gate blast_radius_clear: yes/no
- gate decision_criteria_clear: yes/no
- gate constraints_clear: yes/no
- gate options_comparable: yes/no
- gate tradeoffs_ranked: yes/no
- note if the user has stated a preferred solution without the requirement
- note if the request is impossible under current constraints
- missing data priority:
- highest blocker:
```

Do not rewrite sections that did not change.

## Suggested structure

```md
# Architecture Intake

## Goal

## Business outcome

## Users / stakeholders

## Current state

## Constraints
- timeline:
- budget:
- scale:
- reliability:
- security/privacy:
- compliance:
- team/ops:

## E2E requirement

## Blast radius
- users:
- teams:
- systems:
- data:
- integrations:
- operations/on-call:
- downstream dependencies:

## Recommendation gate
- e2e_requirement_clear: no
- blast_radius_clear: no
- decision_criteria_clear: no
- constraints_clear: no
- options_comparable: no
- tradeoffs_ranked: no

## Work type
- product:
- platform:
- migration:

## Work type gate
- customer_problem_clear: no
- user_journey_clear: no
- business_value_clear: no
- internal_consumers_clear: no
- service_boundaries_clear: no
- slo_clear: no
- source_target_clear: no
- cutover_clear: no
- rollback_clear: no
- data_validation_clear: no

## Assumptions

## Open questions

## Options considered

## Recommendation

## Risks / unknowns
```

## Work type classifier

- `product`: customer-facing feature, workflow, or experience
- `platform`: shared internal capability, service, or infrastructure
- `migration`: moving between systems, versions, or architectures

If unclear, choose the dominant decision risk and ask one clarifying question.

## Question order

- `product`: customer problem -> end-to-end user journey -> business value or KPI -> dependencies and blast radius -> main risk if wrong
- `platform`: internal consumers -> service boundaries -> SLOs / reliability expectations -> operational ownership -> dependency chain and blast radius
- `migration`: source and target states -> migration scope -> coexistence or cutover -> rollback path -> data validation -> transition blast radius

## First-turn questions

1. exact outcome
2. affected users and current flow
3. hard constraints with numbers
4. blast radius if wrong
5. work type

## First-turn wording

- "What exact outcome are we optimizing for, and how will we measure it?"
- "Walk me through the current end-to-end flow, from trigger to result."
- "Which hard constraints are fixed, and what are the numbers?"
- "What systems, teams, data, or users break if this is wrong?"
- "Is this a product, platform, or migration problem?"

## Weak answer follow-ups

- "That is too broad. Which outcome matters most?"
- "Give me the current flow, not the desired one."
- "What is the actual number, range, or deadline?"
- "Name the specific systems and teams in the blast radius."
- "Pick one work type; the gate depends on it."

## Missing data priority

1. most blocking fact
2. work type if unclear
3. end-to-end flow or source/target state
4. blast radius
5. quantitative constraint
6. decision criterion

## Rules

- Preserve prior answers unless the user corrects them.
- Mark contradictions clearly instead of overwriting them silently.
- Separate facts, assumptions, and recommendations.
- If a question has already been answered, cite the stored answer and move on.
- Avoid fluffy summaries and agreement-only responses.
- If the request is impossible under the current constraints, mark it explicitly instead of forcing a recommendation.
