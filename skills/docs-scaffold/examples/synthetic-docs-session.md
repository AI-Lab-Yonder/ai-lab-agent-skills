# Synthetic Example: Adaptive Documentation Structure

This example is fictional. It demonstrates that docs-scaffold organizes knowledge first and creates work units only when the user selects them.

## Input

Three generic source files:

1. `system-notes.md`
   - Service purpose and component boundaries
   - Data flow and reliability constraints
2. `external-api.md`
   - Authentication overview
   - Item and category endpoints
   - A large linked schema reference
3. `operations.md`
   - Monitoring, recovery, and support procedures

The source contains no user stories.

## Option A — Documentation Only

The user wants a navigable knowledge base, not an implementation plan. No stories or slices are created.

```text
docs/
├── INDEX.md
├── architecture/
│   ├── overview.md
│   └── reliability.md
├── integrations/
│   └── external-api.md
├── operations/
│   └── runbook.md
└── decisions/
    └── open-questions.md

AGENTS.md
```

The INDEX includes Architecture, Integrations, Operations, and Decisions. It omits Domain, Requirements, Work Units, and Conventions because those sections have no content.

## Option B — User-Approved Incremental Slices

If the user also asks for an incremental delivery breakdown, the agent proposes boundaries during the structure checkpoint. After approval, the same documentation structure gains a `slices/` folder:

```text
docs/
├── INDEX.md
├── architecture/
│   ├── overview.md
│   └── reliability.md
├── integrations/
│   └── external-api.md
├── operations/
│   └── runbook.md
├── slices/
│   ├── read-only-import.md
│   ├── validation-and-mapping.md
│   └── monitored-publishing.md
└── decisions/
    └── open-questions.md

AGENTS.md
```

Each slice describes an independently verifiable outcome, confirmed scope, dependencies, completion criteria, and links to the canonical architecture and integration docs. Shared technical explanations remain in those canonical docs rather than being copied into every slice.

## Why No Stories

The source does not contain user stories, so converting components or API sections into stories would invent a work model. If a later source file contains explicit stories and the user wants to preserve them, `stories/` can be used instead of `slices/`.

## Large Reference Decision

The linked schema is inspected for size and access restrictions. The relevant definitions are distilled into `integrations/external-api.md`. The raw reference remains at its approved existing location because the user did not request a repository copy.

## AGENTS.md Decision

No root instruction file exists, so AGENTS.md is recommended and created from the adaptive template. Sections for domain language and conventions are removed because the corresponding documentation does not exist.
