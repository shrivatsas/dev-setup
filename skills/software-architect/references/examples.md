# Example Patterns

Use these as output shape examples.

## Product

User: "We need to improve onboarding."

Good follow-up:
- What onboarding metric is broken: activation, time-to-value, or retention?
- What is the current funnel from signup to first success?
- How many users are affected per week?
- What target and by when?

Do not:
- accept "make it simpler" without a measurable definition
- recommend a redesign before the funnel and target are clear

## Platform

User: "We should build a shared event platform."

Good follow-up:
- How many producers and consumers will use it?
- What latency and delivery guarantees are required?
- Who owns on-call and incident response?
- What breaks if delivery is delayed or duplicated?

Do not:
- recommend an event bus or vendor before SLOs and blast radius are explicit

## Migration

User: "We need to move from monolith to services."

Good follow-up:
- What is the source system and target boundary?
- What is the cutover strategy and rollback time?
- What data must move, and what is the validation plan?
- What is the business cost of partial failure?

Do not:
- treat "strangler fig" as an answer without scope and transition risk

## Analysis style

- state assumptions explicitly
- quantify impact when possible
- compare options only after gates are satisfied
- identify the single biggest unknown
- ask the next question that reduces decision risk the most

## Weak answer follow-up patterns

User: "We want it faster."

Follow-up:
- Faster relative to what baseline?
- What number matters: page load, job completion, or response time?
- What target do you need?

User: "The blast radius is small."

Follow-up:
- Small means what: 5 users, 2 teams, or 1 service?
- Which systems, data, and operations are actually affected?

User: "We just need a scalable solution."

Follow-up:
- Scalable to what load, by when?
- Which dimension matters: throughput, tenants, data volume, or team growth?

User: "Let's use microservices."

Follow-up:
- Why is that the right answer for this requirement?
- What are the source/target boundaries, and what migration risk exists?

## Sample completed intake

### Product

```md
## Business outcome
- increase trial-to-paid conversion by 8% in 2 quarters

## Current state
- onboarding drop-off at account setup step

## Constraints
- timeline: 6 weeks
- scale: 30k weekly signups
- compliance: none

## E2E requirement
- signup -> verification -> workspace creation -> first successful action

## Blast radius
- users: free trial users
- teams: growth, support
- systems: auth, billing, analytics
- data: signup events

## Recommendation gate
- e2e_requirement_clear: yes
- blast_radius_clear: yes
- decision_criteria_clear: yes
- constraints_clear: yes
- options_comparable: yes
- tradeoffs_ranked: yes
```

### Platform

```md
## Business outcome
- provide shared event delivery for 4 product teams

## Current state
- 3 teams use custom queues

## Constraints
- latency: p95 under 2s
- reliability: 99.9%
- ops: one team on-call

## E2E requirement
- produce event -> validate -> deliver -> retry -> audit

## Blast radius
- users: internal services
- teams: 4 product teams, infra
- systems: producer APIs, storage, consumers
- data: event payloads and audit logs

## Recommendation gate
- e2e_requirement_clear: yes
- blast_radius_clear: yes
- decision_criteria_clear: yes
- constraints_clear: yes
- options_comparable: yes
- tradeoffs_ranked: yes
```

### Migration

```md
## Business outcome
- move checkout from monolith to service with no revenue loss

## Current state
- checkout logic in monolith, 12k orders/day

## Constraints
- cutover: 1 weekend
- rollback: under 30 minutes
- no payment data loss

## E2E requirement
- cart -> pricing -> payment auth -> order creation -> receipt

## Blast radius
- users: all buyers
- teams: commerce, support, finance
- systems: cart, payment, order DB, CRM
- data: orders, transactions

## Recommendation gate
- e2e_requirement_clear: yes
- blast_radius_clear: yes
- decision_criteria_clear: yes
- constraints_clear: yes
- options_comparable: yes
- tradeoffs_ranked: yes
```
