# Splitting Rules

How to distribute source material into the `docs/` folder structure. Read this during Phase 2 when splitting monolithic docs into focused files.

## Content Routing

| Source content | Target location | Notes |
|---------------|----------------|-------|
| System diagrams, component descriptions, constraints, deployment | `architecture/overview.md` | Preserve mermaid diagrams verbatim |
| Entities, schemas, field definitions, status enums, relationships | `architecture/data-model.md` | Include status lifecycle if present |
| Polling, retry, idempotency, backpressure, threading, config patterns | `architecture/cross-cutting-concerns.md` | Cross-cutting technical concerns |
| Glossary terms, concept definitions, language mappings | `domain/glossary.md` | Create BEFORE other files if multilingual |
| Domain concepts that need their own page | `domain/[topic].md` | E.g., message types, entity categories |
| User stories, feature descriptions | `stories/[story-name].md` | One file per story, always |
| External API endpoints, auth flows, schemas | `api/[api-name].md` | Distilled only — full spec in `api/specs/` |
| Large reference files (OpenAPI, DB schema) | `api/specs/[filename]` | Check size first; large files not auto-loaded |
| Patterns appearing in 2+ stories | `conventions/[pattern-name].md` | Extract before writing story files |
| Undefined terms, missing decisions, vague sections | `decisions/open-questions.md` | Everything unknown goes here |

## Story File Structure

Each story file in `stories/` should follow this structure:

```markdown
# Story: [Name]

## Summary
[User story statement from source material]

## Context
- [Link to relevant architecture doc]
- [Link to relevant convention]
- [Link to API reference if applicable]
- [Link to glossary if domain terms are used]

## Acceptance Criteria
[Preserved from source — numbered list]

## Testing Notes
[If present in source material]
```

## Cross-Reference Rules

After creating all files, add relative links between related documents:

- Stories link to architecture docs, conventions, domain terms, and API references they depend on
- Architecture docs link to the stories that implement them
- Conventions note which stories/layers they apply to
- The glossary is referenced from any file that uses domain-specific terms
- Use relative paths: `[glossary](../domain/glossary.md)`

## Identifying Cross-Cutting Concerns

Before writing story files, scan all stories for patterns that appear in 2+ stories. Common cross-cutting concerns:

- Logging / audit trail patterns
- Status tracking / state machine
- Error handling / retry logic
- Authentication / authorization
- Idempotency mechanisms
- Configuration loading

Extract these into `conventions/` FIRST, then link from each story. This prevents duplication and ensures consistency.
