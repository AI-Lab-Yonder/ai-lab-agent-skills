# Splitting Rules

Route source material according to what it is, not according to a fixed folder tree. Omit every target folder that has no content.

## Content Routing

| Source content | Suggested target | Notes |
|---|---|---|
| System diagrams, component descriptions, constraints, deployment rationale | `architecture/overview.md` or a focused architecture file | Preserve meaningful diagrams and split only when navigation improves |
| Entities, schemas, status lifecycles, relationships | `architecture/data-model.md` | Create only when the source contains a data model |
| System-wide reliability, concurrency, or integration rationale | `architecture/cross-cutting-concerns.md` | Explain why the system behaves this way |
| Glossary terms, concept definitions, language mappings | `domain/glossary.md` | Create early when terminology needs a canonical definition |
| Domain concepts needing focused explanation | `domain/[topic].md` | Use descriptive topic names |
| Product or system requirements | `requirements/[topic].md` | Preserve requirement intent; do not convert automatically into stories |
| Procedures and developer or user guidance | `guides/[topic].md` | Keep task-oriented guidance separate from architecture rationale |
| Deployment, support, monitoring, and recovery material | `operations/[topic].md` | Include only operational content present in the source |
| Explicit source user stories | `stories/[story-name].md` | Use only when the user chooses to preserve stories |
| User-approved incremental delivery units | `slices/[slice-name].md` | Use only after slice boundaries are proposed and confirmed |
| External API endpoints, auth flows, schemas | `api/[api-name].md` or `integrations/[system-name].md` | Distill only relevant material |
| Large raw reference files | Existing approved location or `api/specs/[filename]` | Do not copy without approval and policy checks |
| Actionable patterns reused across multiple documents or work units | `conventions/[pattern-name].md` | State the rule and where it applies |
| Undefined terms, missing decisions, contradictions | `decisions/open-questions.md` | Unknowns go here rather than becoming assumptions |

These paths are defaults, not a closed taxonomy. If the source has another coherent content type, propose a descriptive folder rather than forcing it into the nearest listed category.

## Choosing Work Units

Work-unit folders are optional.

### Use `stories/` when

- The source explicitly contains user stories or equivalent named items
- Preserving story identity matters to the user
- The planned tree is confirmed

Do not reinterpret architecture sections, requirements, or components as stories.

### Use `slices/` when

- The user asks for an incremental implementation or delivery breakdown
- Each proposed slice produces a meaningful, independently verifiable outcome
- Dependencies and boundaries can be stated from the source or user confirmation
- The user confirms the proposed slices before files are created

Do not create slices merely because a document has several headings.

### Use neither when

The goal is to organize a knowledge base, reference set, architecture package, operating guide, or other explanatory documentation without defining work assignments.

## Optional Work-Unit Structures

Use only the structure for the selected mode. Omit sections unsupported by the source instead of filling them with guesses.

### Explicit story

```markdown
# Story: [Name]

## Summary
[Story statement preserved from the source]

## Context
- [Links to relevant docs]

## Acceptance Criteria
[Criteria preserved from the source]

## Testing Notes
[Only when present]
```

### Incremental slice

```markdown
# Slice: [Outcome]

## Outcome
[Independently useful result]

## Included
[Confirmed scope]

## Excluded
[Confirmed boundary, when useful]

## Dependencies
[Only known dependencies]

## Completion Criteria
[How the slice can be verified]

## Related Documentation
- [Links to relevant docs]
```

## Architecture and Conventions

Avoid duplicating cross-cutting material:

- **Architecture** records system-wide properties, constraints, and rationale.
- **Conventions** record actionable rules contributors should follow repeatedly.
- When both are needed, keep the explanation in architecture, the concise rule in conventions, and link them.

## Cross-Reference Rules

- Link work units, when present, to the architecture, domain, API, conventions, and guides they need
- Link architecture and integration docs to related requirements or work units only when that relationship exists
- State where each convention applies
- Link domain-specific terms to the glossary when clarification is useful
- Use relative links and verify them after generation
- Do not create links to optional files or folders that were omitted
