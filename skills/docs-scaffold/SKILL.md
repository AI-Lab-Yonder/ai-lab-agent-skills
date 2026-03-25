---
name: docs-scaffold
description: |
  Scaffold a structured docs/ folder from initial markdown files (architecture, stories, API specs).
  Splits monolithic docs into focused, cross-linked files with an INDEX.md entry point and AGENTS.md
  at project root. Use when starting a project with raw documentation, onboarding a codebase to
  AI-assisted development, or restructuring scattered docs for AI-DLC workflows.
level: advanced
category: documentation
version: 1.0.0
---

# Docs Scaffold

Take raw project documentation and produce a structured `docs/` folder that AI agents can navigate efficiently. Splits monolithic files into focused, cross-linked documents organized by topic, with an INDEX.md as the entry point and AGENTS.md at the project root for tool-universal agent instructions.

Companion skill to `/resolve-docs` — this skill creates the structure, `/resolve-docs` fills the gaps.

## Constraints

- Never invent content — only derive from source material. Unknowns become entries in `decisions/open-questions.md`, not guesses.
- Never auto-load large reference files (OpenAPI specs, database schemas). Ask the user before reading anything over ~500KB.
- Always confirm understanding and planned structure with the user before creating any files.
- One story/feature per file — never combine multiple stories even if they are short.
- Use AGENTS.md (not CLAUDE.md) at the project root for tool-universality across Claude Code, Codex, and other agents.
- Do not duplicate content across files — put information in one canonical location and link to it from others.
- Read `gotchas.md` before starting — it contains real failure points from production use.

## Phase 0 — Read Source Material

Read every input file the user provides. Build a mental model of the project:

- What is this project? Purpose, domain, landscape position.
- What are the components/layers? Major architectural pieces and responsibilities.
- What user stories or tasks exist? Work items, grouped by feature or layer.
- What external systems are involved? APIs, databases, third-party services.
- What cross-cutting concerns exist? Patterns appearing in multiple stories — logging, error handling, auth, status tracking, retry logic. These are easy to miss but critical to extract.
- What domain terminology is used? Especially mixed-language codebases (e.g., Dutch DB terms + English code).

Present a structured summary and wait for confirmation:

```
Here is my understanding of the project:
- [Project summary]
- [Components/layers]
- [Stories identified]
- [External systems]
- [Cross-cutting concerns]
- [Domain terms needing glossary]

Is this correct? Should I proceed with scaffolding?
```

If the user corrects something, incorporate the feedback into your model.

## Phase 1 — Plan Folder Structure

Design the `docs/` structure based on what the source material contains. Use this as the default template — include a section only if there is content for it:

```
docs/
├── INDEX.md                        # Entry point with navigation instructions
├── architecture/                   # System design and technical patterns
│   ├── overview.md                 # System context, diagrams, layers, constraints
│   ├── data-model.md              # Entities, relationships, status lifecycle
│   └── integration-patterns.md    # Cross-cutting technical patterns
├── domain/                         # Business terminology
│   ├── glossary.md                # Term definitions and language mappings
│   └── [topic].md                 # Domain concept files as needed
├── stories/                        # One file per story/feature
│   ├── [story-name].md
│   └── ...
├── api/                            # External API integration
│   ├── [api-name].md              # Distilled human-readable reference
│   └── specs/                     # Raw spec files (never auto-loaded)
├── conventions/                    # Cross-cutting patterns all layers share
│   └── [convention-name].md
└── decisions/
    └── open-questions.md          # Discovered gaps and unknowns
```

Not every project needs every folder. A project with no external APIs skips `api/`. A monolingual codebase skips `domain/glossary.md`. Always include `decisions/open-questions.md`.

Present the planned structure to the user and get confirmation before creating files.

## Phase 2 — Split and Create Files

For each source document, extract content into the appropriate target files:

**Architecture content** — system diagrams, component descriptions, constraints, deployment notes go into `architecture/`. If the source has a mermaid diagram, preserve it verbatim.

**Data model content** — entities, schemas, field definitions, status enums, relationships go into `architecture/data-model.md`.

**Integration patterns** — polling, retry, idempotency, backpressure, threading, configuration patterns go into `architecture/integration-patterns.md`. These are the cross-cutting technical concerns that every layer must follow.

**Domain terminology** — glossary terms, concept definitions, language mappings. Critical when the codebase mixes languages or has domain-specific jargon.

**Stories** — split into one file per story in `stories/`. Each story file should have:
- Summary (the user story statement)
- Context (links to relevant architecture, convention, and API docs)
- Acceptance Criteria (preserved from source)
- Testing notes (if present in source)

**API references** — for external APIs, create a distilled markdown doc with only the endpoints relevant to the current stories. If there is a large spec file (OpenAPI/Swagger), ask the user before reading it. Distill relevant parts and store the full file in `api/specs/` with clear "do not auto-load" instructions.

**Cross-cutting conventions** — patterns that appear in multiple stories (logging, status tracking, error handling). Extract these into `conventions/` so each story can link to them instead of duplicating the description.

After creating each file, add relative links (`[glossary](../domain/glossary.md)`) to connect related documents.

## Phase 3 — Create INDEX.md

INDEX.md is the master entry point. It must contain navigation instructions for AI agents, not just a file list.

Structure:

```markdown
# [Project Name] — Documentation Index

This is the entry point for all project documentation.

## How to Use This Index

- **Starting a story?** Read the relevant story doc + the architecture and conventions it links to.
- **Need domain context?** Check `domain/` for term definitions.
- **Unsure about something?** Check `decisions/open-questions.md` — or run `/resolve-docs`.
- **Need API details?** Read the distilled API doc first. Only load full specs if needed (ask the user first).

---

## [Section]
[description]
- [file link] — [one-line description]

## [Section]
...
```

If there are large reference files that should not be auto-loaded, call this out explicitly with a warning.

## Phase 4 — Create AGENTS.md

Create `AGENTS.md` at the **project root** (not inside `docs/`). This is the entry point for any AI agent working on the project.

Contents:

1. **Documentation section** — pointer to `docs/INDEX.md` as the entry point
2. **Project context** — one paragraph summary derived from the docs (not invented)
3. **Key rules** for agents:
   - Read the relevant story doc and linked docs before implementing anything
   - Cross-cutting conventions in `docs/conventions/` apply to all layers
   - Check `docs/decisions/open-questions.md` for unresolved items
   - Special handling for large reference files (if any): never auto-load, ask user first, distill into the API doc
   - Domain language conventions (if applicable): link to glossary
   - Pointer to `/resolve-docs` for working through open questions

If an `AGENTS.md` (or `CLAUDE.md`) already exists, present the proposed additions and ask the user whether to merge, replace, or keep separate.

## Phase 5 — Populate Open Questions

Create `decisions/open-questions.md` with gaps discovered during scaffolding. These are things the source material did not fully specify:

- Vague or undefined terms
- Missing acceptance criteria details
- Unspecified technical decisions (database, auth mechanism, deployment target, build tool, etc.)
- Contradictions between documents
- Sections marked "TBD" or similar
- Missing API details that stories reference
- Undefined enum values, schema fields, config structures

Format with unique IDs and categories:

```markdown
# Open Questions

Questions that need human decisions. Use `/resolve-docs` to work through these interactively.

## [Category]

- **OQ-1: [Short title]** — [What is unknown and why it matters]
- **OQ-2: [Short title]** — [Description]
```

## Phase 6 — Handle Large Reference Files

If the user provides large reference files (OpenAPI specs, database schemas, WSDL files):

1. **Never auto-load.** Ask the user: "I see [file name] (~[size]). Should I load it to distill the relevant parts?"
2. If approved, search for specific paths/schemas — do not read the entire file
3. Distill only endpoints/schemas relevant to the current stories into a readable markdown file
4. Add a **mapping table** showing which endpoints map to which stories — this bridges `api/` and `stories/`
5. Store the original file in `api/specs/` with a warning at the top of the distilled doc:
   ```
   > The full spec is at `specs/[filename]` (~[size]).
   > **Do not auto-load.** Ask the user before reading.
   > If this doc doesn't answer your question, ask whether to distill more.
   ```

## Phase 7 — Summary and Next Steps

After all files are created, present:

```
Docs scaffold complete.

Created:
- docs/INDEX.md
- docs/architecture/overview.md
- [... all files ...]
- docs/decisions/open-questions.md (X open questions)
- AGENTS.md (project root)

Open questions found: X
  - [top 3-5 most critical]

Recommended next step: Run /resolve-docs to work through the open questions interactively.
```
