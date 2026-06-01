# Mermaid for Excalidraw

Use Mermaid `flowchart` diagrams that import cleanly into Excalidraw.

## Conventions

- Prefer `flowchart LR` for context and workflow diagrams.
- Prefer `flowchart TB` for container, component, and deployment diagrams.
- Use quoted node labels:
  - `api["API\nDjango REST"]`
- Use short IDs without punctuation:
  - Good: `providerApp`, `objectStore`, `apiLayer`
  - Avoid: `provider-app`, `object.store`
- Use `\n` line breaks inside labels instead of very long single-line labels.
- Keep edge labels short:
  - `web -->|"REST / JSON"| api`
- Use `subgraph` for boundaries:
  - users, client layer, application layer, data layer, external services, observability, AWS/VPC/private subnet.

## Syntax Hazards

- Avoid Markdown links inside Mermaid labels.
- Avoid unescaped quotes inside labels.
- Avoid overly complex arrows and Mermaid features that Excalidraw may not support.
- Avoid huge diagrams. Split by C4 level or runtime flow.

## Visual Quality

- Put humans/users on the left or top.
- Put the system/application in the center.
- Put external systems on the right.
- Put data stores below the application layer.
- Put observability and identity in separate clusters when they are important.
