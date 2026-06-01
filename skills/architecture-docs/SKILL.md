---
name: architecture-docs
description: Generate or update architecture documentation from repositories, product docs, infrastructure files, and code. Use when asked for high-level architecture, C4 diagrams, system context, container/component/deployment views, arc42 documentation, Excalidraw-ready architecture, Mermaid architecture diagrams, architecture decisions, runtime views, quality attributes, risks, or an architecture package synthesized from existing docs and source.
metadata:
  short-description: Generate C4 and arc42 architecture docs
---

# Architecture Docs

Use this skill to synthesize architecture documentation from a codebase and its docs. It supports:

- **C4**: diagram-first context, container, component, and deployment views.
- **arc42**: narrative architecture documentation with goals, constraints, decisions, runtime flows, quality requirements, risks, and glossary.
- **Combined package**: C4 diagrams referenced from or embedded into arc42.

## Workflow

1. **Discover source material**
   - Search before reading deeply: use `rg --files`, then targeted `rg` for product names, architecture, infra, auth, integrations, deployment, SLOs, metrics, permissions, and feature docs.
   - Read primary local sources first: product README, workspace docs, backend/frontend READMEs, service docs, infra/Terraform, API routers, package files, and existing architecture docs.
   - For large repos, summarize by domain instead of reading every source file.

2. **Establish the boundary**
   - Identify users/actors, in-scope system, adjacent products, external systems, data stores, identity providers, async workers, observability, and deployment platform.
   - Separate documented fact from inference. Explicitly mark uncertain deployment/runtime assumptions.

3. **Select output mode**
   - If the user asks for diagrams, Excalidraw, C4, or high-level architecture: produce C4.
   - If the user asks for arc42, architecture docs, decisions, risks, or onboarding/reference material: produce arc42.
   - If the user asks for a complete architecture set/package: produce both and cross-reference them.

4. **Create artifacts**
   - Prefer Markdown files in an appropriate docs/architecture location, unless the user names a path.
   - For C4, include Mermaid `flowchart` blocks that can be pasted into Excalidraw.
   - For arc42, reference C4 diagrams rather than duplicating every diagram inline unless the user requests a single self-contained file.

5. **Review before final**
   - Check diagrams for basic Mermaid syntax hazards.
   - Check that claims are traceable to source docs or clearly labeled as assumptions.
   - Include unresolved questions or doc reconciliation items when sources disagree.

## Reference Files

Read only the reference needed for the requested output:

- `references/c4.md`: C4 output guidance and diagram checklist.
- `references/arc42.md`: arc42 section structure and content checklist.
- `references/mermaid-excalidraw.md`: Mermaid conventions for Excalidraw import.

## Output Standards

- Keep diagrams coarse enough for architecture discussion; avoid mirroring every class, table, endpoint, or file.
- Use business/domain labels, then add technology in secondary text.
- Include the operationally important things: auth, permissions, data stores, async work, external dependencies, observability, and deployment uncertainty.
- For healthcare, financial, legal, or other sensitive domains, call out privacy, auditability, access control, data retention, and external data handling.
- Do not treat generated architecture as authoritative if the repo docs conflict. Surface the conflict directly.

## Suggested Filenames

- C4: `architecture-c4.md`, `<product>-c4-architecture.md`, or `<product>-c4-architecture-excalidraw.md`
- arc42: `architecture-arc42.md` or `<product>-arc42-architecture.md`
- Combined index: `architecture.md`
