# arc42 Guidance

Use arc42 when the user needs a durable architecture reference rather than only diagrams.

## Recommended Sections

1. **Introduction and Goals**
   - Business goals, architecture goals, stakeholders.

2. **Architecture Constraints**
   - Technical stack, platform constraints, compliance, domain constraints, organizational coupling.

3. **System Scope and Context**
   - System boundary, external users/systems, important dependencies.
   - Reference C4 System Context if available.

4. **Solution Strategy**
   - Core architectural approach and major design principles.

5. **Building Block View**
   - Top-level containers and key internal components.
   - Reference C4 Container/Component diagrams when available.

6. **Runtime View**
   - Important user journeys and operational flows.
   - Include auth/session, core domain flow, document/file flow, async flow, integration flow, and any high-risk workflow.

7. **Deployment View**
   - Hosted topology and local development topology.
   - Highlight known gaps or conflicting source docs.

8. **Cross-Cutting Concepts**
   - Authn/authz, permissions, privacy, auditability, observability, error handling, external integration pattern, frontend/backend conventions, async work.

9. **Architecture Decisions**
   - Use a concise table: decision, rationale, consequence.

10. **Quality Requirements**
   - Performance, availability, security/privacy, maintainability, operability.
   - Include SLOs/SLIs if documented.

11. **Risks and Technical Debt**
   - Risk, impact, mitigation.

12. **Glossary**
   - Domain and technology terms needed for onboarding.

## Writing Style

- Be concise and specific.
- Prefer source-backed claims.
- Mark inference clearly.
- Do not paste large source excerpts.
- Capture "why" and "what can go wrong", not just "what exists".
